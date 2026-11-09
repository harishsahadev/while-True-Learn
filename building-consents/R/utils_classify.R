# =============================================================================
# R/utils_classify.R
# Shared helpers for classification (RQ3). Source AFTER utils_data.R and
# utils_models.R (which provides make_time_folds):
#   source(file.path(proj_root, "R", "utils_data.R"))
#   source(file.path(proj_root, "R", "utils_models.R"))
#   source(file.path(proj_root, "R", "utils_classify.R"))
# =============================================================================

paths$fig_rq3    <- "outputs/figures/rq3"
paths$tab_rq3    <- "outputs/tables/rq3"
paths$models_rq3 <- "outputs/models/rq3"

# ---- Area under the ROC curve -------------------------------------------------
# Probability that a randomly chosen positive (y = 1) gets a higher predicted
# probability than a randomly chosen negative (y = 0). 0.5 = no better than
# guessing, 1 = perfect ranking. Computed from ranks (the Mann-Whitney statistic);
# ties count as one half.
auc <- function(y, p) {
  n1 <- sum(y == 1); n0 <- sum(y == 0)
  if (n1 == 0 || n0 == 0) return(NA_real_)
  r <- rank(p)
  (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

# ---- All classification metrics in one row ----------------------------------
#   y : 0/1 outcomes; p : predicted probabilities of y = 1
#   accuracy          share classified correctly at the threshold
#   sensitivity       share of actual rises predicted as rises (true positive rate)
#   specificity       share of actual falls predicted as falls (true negative rate)
#   balanced_accuracy mean of sensitivity and specificity
#   auc               threshold-free ranking quality
#   brier             mean squared error of the probabilities (lower is better)
#   log_loss          mean -log(probability given to what happened) (lower is better)
class_metrics <- function(y, p, threshold = 0.5) {
  p    <- pmin(pmax(p, 1e-6), 1 - 1e-6)          # keep log() finite
  pred <- as.integer(p > threshold)
  sens <- mean(pred[y == 1] == 1)
  spec <- mean(pred[y == 0] == 0)
  tibble(accuracy = mean(pred == y), sensitivity = sens, specificity = spec,
         balanced_accuracy = (sens + spec) / 2, auc = auc(y, p),
         brier = mean((p - y)^2), log_loss = -mean(y * log(p) + (1 - y) * log(1 - p)))
}

# ---- ROC curve points -----------------------------------------------------------
# For every threshold, the true positive rate (sensitivity) and false positive
# rate (1 - specificity).
roc_points <- function(y, p) {
  th <- sort(unique(c(-Inf, p, Inf)), decreasing = TRUE)
  tibble(threshold = th,
         tpr = map_dbl(th, \(t) mean(p[y == 1] >= t)),
         fpr = map_dbl(th, \(t) mean(p[y == 0] >= t)))
}

# ---- Generic tuner for classifiers ---------------------------------------------
# Same idea as cv_tune() in utils_models.R, with classification metrics.
# fit_predict(train_df, new_df, params) returns predicted probabilities of y = 1
# (a vector), or a matrix with one column per value of an "inner" setting.
# Settings are ranked by mean CV AUC (higher is better).
cv_tune_class <- function(fit_predict, grid, data, folds, response, inner = NULL) {
  grid <- as_tibble(grid)
  if (nrow(grid) == 0) grid <- tibble(.dummy = 1)

  per_fold <- map_dfr(seq_len(nrow(grid)), function(g) {
    params <- as.list(grid[g, , drop = FALSE])
    map_dfr(names(folds), function(fn) {
      f    <- folds[[fn]]
      pred <- as.matrix(fit_predict(data[f$train, ], data[f$valid, ], params))
      if (is.null(colnames(pred))) colnames(pred) <- "0"
      obs  <- data[[response]][f$valid]
      map_dfr(colnames(pred), function(cn)
        class_metrics(obs, pred[, cn]) |>
          mutate(config = g, inner_value = as.numeric(cn), fold = fn))
    })
  })

  summary <- per_fold |>
    group_by(config, inner_value) |>
    summarise(cv_auc = mean(auc), cv_auc_sd = sd(auc), cv_accuracy = mean(accuracy),
              cv_balanced_accuracy = mean(balanced_accuracy), cv_brier = mean(brier),
              cv_log_loss = mean(log_loss), .groups = "drop") |>
    left_join(grid |> mutate(config = row_number()), by = "config") |>
    select(-any_of(".dummy")) |>
    arrange(desc(cv_auc))
  if (!is.null(inner)) summary <- rename(summary, !!inner := inner_value)
  else summary <- select(summary, -inner_value)

  list(folds = per_fold, summary = summary, best = summary[1, ])
}

# One row per model: best setting and its CV scores (for the comparison table)
summarise_class_tuning <- function(res, model) {
  b <- res$best
  settings <- b |> select(-any_of(c("config", "cv_auc", "cv_auc_sd", "cv_accuracy", "cv_balanced_accuracy",
                                    "cv_brier", "cv_log_loss")))
  tibble(model = model,
         cv_auc = b$cv_auc, cv_auc_se = b$cv_auc_sd / sqrt(n_distinct(res$folds$fold)),
         cv_accuracy = b$cv_accuracy, cv_balanced_accuracy = b$cv_balanced_accuracy,
         cv_brier = b$cv_brier, cv_log_loss = b$cv_log_loss,
         n_settings_tried = nrow(res$summary),
         best_settings = if (ncol(settings) == 0) "(none)" else
           paste(names(settings), signif(unlist(settings), 3), sep = " = ", collapse = ", "))
}
