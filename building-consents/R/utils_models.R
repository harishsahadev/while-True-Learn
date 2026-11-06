# =============================================================================
# R/utils_models.R
# Shared helpers for fitting, tuning and comparing models (Step 3 onwards).
# Source AFTER utils_data.R:
#   source(file.path(proj_root, "R", "utils_data.R"))
#   source(file.path(proj_root, "R", "utils_models.R"))
#
# The idea: every model is written as ONE function
#     fit_predict(train_df, new_df, params)  ->  predictions for new_df
# and the same tuning / scoring code is used for all of them. That way every
# model is judged on exactly the same folds with exactly the same metrics.
# =============================================================================

paths$models_rq1 <- "outputs/models/rq1"

# ---- Metrics -----------------------------------------------------------------
# obs, pred: numeric vectors on the LOG scale.
#   rmse  root mean squared error   (penalises big misses more)
#   mae   mean absolute error       (typical miss)
#   r2    1 - SSE / SST             (share of variance explained, on these rows)
# On the log scale an error of 0.10 is roughly a 10% miss in $/m².
reg_metrics <- function(obs, pred) {
  e <- pred - obs
  tibble(rmse = sqrt(mean(e^2)),
         mae  = mean(abs(e)),
         r2   = 1 - sum(e^2) / sum((obs - mean(obs))^2))
}

# MAPE on the dollar scale: mean |predicted - actual| / actual
mape <- function(obs_dollars, pred_dollars) mean(abs(pred_dollars - obs_dollars) / obs_dollars)

# ---- Time-ordered cross-validation folds ------------------------------------
# "Forward-chaining" (rolling-origin) CV: each fold trains on all years BEFORE a
# validation block and validates on that block. This mimics the real task
# (learn from the past, predict the future) and never lets a model peek ahead.
#   years        : the year of every training row
#   valid_blocks : list of year vectors, one per fold
# Returns a named list of folds, each with $train and $valid row numbers.
make_time_folds <- function(years,
                            valid_blocks = list(2012:2013, 2014:2015, 2016:2017, 2018:2019)) {
  folds <- lapply(valid_blocks, function(b)
    list(train = which(years < min(b)), valid = which(years %in% b)))
  names(folds) <- vapply(valid_blocks, function(b) paste0("valid ", min(b), "-", max(b)), "")
  folds
}

# ---- Generic tuner -----------------------------------------------------------
# fit_predict(train_df, new_df, params) must return either
#   * a numeric vector (one prediction per row of new_df), or
#   * a matrix with one column per value of an "inner" setting that one fit can
#     produce for free (lambda for glmnet, number of rounds for xgboost). The
#     column names hold that setting's value and `inner` names it.
# grid: data frame, one row per combination of settings to try.
# Returns list(folds = per-fold scores, summary = mean score per setting,
#              best = the setting with the lowest mean RMSE).
cv_tune <- function(fit_predict, grid, data, folds, response, inner = NULL) {
  grid <- as_tibble(grid)
  if (nrow(grid) == 0) grid <- tibble(.dummy = 1)

  per_fold <- map_dfr(seq_len(nrow(grid)), function(g) {
    params <- as.list(grid[g, , drop = FALSE])
    map_dfr(names(folds), function(fn) {
      f    <- folds[[fn]]
      pred <- fit_predict(data[f$train, ], data[f$valid, ], params)
      pred <- as.matrix(pred)
      if (is.null(colnames(pred))) colnames(pred) <- "0"
      obs  <- data[[response]][f$valid]
      map_dfr(colnames(pred), function(cn)
        reg_metrics(obs, pred[, cn]) |>
          mutate(config = g, inner_value = as.numeric(cn), fold = fn, n_valid = length(obs)))
    })
  })

  summary <- per_fold |>
    group_by(config, inner_value) |>
    summarise(cv_rmse = mean(rmse), cv_rmse_sd = sd(rmse),
              cv_mae = mean(mae), cv_r2 = mean(r2), .groups = "drop") |>
    left_join(grid |> mutate(config = row_number()), by = "config") |>
    select(-any_of(".dummy")) |>
    arrange(cv_rmse)
  if (!is.null(inner)) summary <- rename(summary, !!inner := inner_value)
  else summary <- select(summary, -inner_value)

  list(folds = per_fold, summary = summary, best = summary[1, ])
}

# ---- Design matrix with a fixed set of columns ------------------------------
# glmnet, xgboost and svm need a numeric matrix, not a data frame with factors.
# model.matrix() turns each factor into 0/1 "dummy" columns. Because our factors
# carry ALL their levels, train and test matrices always get the same columns.
make_x <- function(df, rhs) {
  model.matrix(as.formula(paste("~", rhs)), data = df)[, -1, drop = FALSE]  # drop intercept
}

# ---- Timing helper -----------------------------------------------------------
# Runs an expression and returns its value with the elapsed seconds attached.
timed <- function(expr) {
  t0  <- Sys.time()
  out <- force(expr)
  attr(out, "seconds") <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  out
}

# ---- Summarising tuning results ---------------------------------------------
# res_by_set: a named list (one element per feature set) of cv_tune() results.
# Returns one row per feature set: the best setting found and its CV scores.
settings_text <- function(best) {
  b <- best |> select(-any_of(c("config", "cv_rmse", "cv_rmse_sd", "cv_mae", "cv_r2")))
  if (ncol(b) == 0) return("(none)")
  paste(names(b), signif(unlist(b), 3), sep = " = ", collapse = ", ")
}

summarise_tuning <- function(res_by_set, model) {
  imap_dfr(res_by_set, function(r, set)
    tibble(model = model, set = set,
           cv_rmse = r$best$cv_rmse, cv_rmse_se = r$best$cv_rmse_sd / sqrt(n_distinct(r$folds$fold)),
           cv_mae = r$best$cv_mae, cv_r2 = r$best$cv_r2,
           n_settings_tried = nrow(r$summary),
           best_settings = settings_text(r$best),
           seconds = round(attr(r, "seconds"), 1)))
}

# ---- Refit the best setting on ALL training rows and predict new rows -------
# factory(vars, y) returns a fit_predict function (see cv_tune). For models with
# an inner setting, the prediction column closest to the chosen value is kept.
refit_predict <- function(factory, res_by_set, sets, y, train_df, new_df, inner = NULL) {
  imap(sets, function(vars, set) {
    best <- res_by_set[[set]]$best
    pred <- as.matrix(factory(vars, y)(train_df, new_df, as.list(best)))
    if (!is.null(inner))
      pred <- pred[, which.min(abs(as.numeric(colnames(pred)) - best[[inner]])), drop = FALSE]
    as.numeric(pred)
  })
}
