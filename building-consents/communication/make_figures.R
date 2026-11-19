# =============================================================================
# communication/make_figures.R
# Large, plain-language figures for the poster and the presentation slides.
# They use only the processed data and the results tables written by the notebooks.
# Run from the project folder:  Rscript communication/make_figures.R
# =============================================================================

source("R/utils_data.R")
out_dir <- "outputs/figures/communication"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# palette and font of the group's pitch deck (theme colours of whileTrue_learn_Pitch.pptx)
#   slate = dark text, coral = dark orange (highlight), teal = orange, blue = warm brown, grey = warm light grey
pal <- c(slate = "#2B2B2B", coral = "#C76B0A", teal = "#FBAC4D", blue = "#5C5148", grey = "#D9CCBF")
font_dir <- "communication/assets/fonts"
if (!"Open Sauce One" %in% systemfonts::system_fonts()$family) systemfonts::register_font("Open Sauce One",
  plain = file.path(font_dir, "OpenSauceOne-Regular.ttf"), bold = file.path(font_dir, "OpenSauceOne-Bold.ttf"),
  italic = file.path(font_dir, "OpenSauceOne-Italic.ttf"), bolditalic = file.path(font_dir, "OpenSauceOne-Bold.ttf"))
update_geom_defaults("text", list(family = "Open Sauce One"))
theme_comm <- theme_minimal(base_size = 20, base_family = "Open Sauce One") +
  theme(plot.title.position = "plot", panel.grid.minor = element_blank(),
        panel.grid.major.y = element_line(colour = "#EADFD3"), panel.grid.major.x = element_blank(),
        plot.title = element_text(face = "bold", size = 22, colour = pal["slate"]),
        plot.subtitle = element_text(size = 16, colour = "#5C5148"),
        axis.text = element_text(colour = "#3D3630"), legend.position = "top",
        plot.background = element_rect(fill = "transparent", colour = NA),
        panel.background = element_rect(fill = "transparent", colour = NA),
        legend.background = element_rect(fill = "transparent", colour = NA))
theme_set(theme_comm)
save_comm <- function(p, name, w = 10, h = 6) {
  ggsave(file.path(out_dir, paste0(name, ".png")), p, width = w, height = h, dpi = 220, bg = "transparent",
         device = ragg::agg_png)
}
tab <- function(rq, name) read_csv(file.path("outputs/tables", rq, paste0(name, ".csv")), show_col_types = FALSE)
short <- function(x) str_remove(x, " District| City")

full <- read_csv(file.path(paths$processed, "rq1_district_quarter_full.csv"), show_col_types = FALSE)

# numbers quoted on the poster and slides that are not in an analysis table are written here
num_dir <- "outputs/tables/communication"
dir.create(num_dir, recursive = TRUE, showWarnings = FALSE)
m1 <- readRDS(file.path(paths$processed, "rq1_model_data.rds"))   # RQ1 modelled rows, as in 02_rq1_eda.Rmd

# ---- 1. Which districts are dear or cheap, relative to the rest of NZ (1990–2019) ------
# Same calculation as fig08 in 02_rq1_eda.Rmd: each district's median relative cost over its training quarters.
# Shown as a % (exp of the log difference) next to the district's median real cost per m².
rank1 <- m1 |> filter(split == "train", ta != "Chatham Islands Territory") |>
  group_by(ta) |>
  summarise(rel_pct = 100 * (exp(median(rel_log_cost_m2)) - 1), cost = median(real_cost_m2),
            quarters = n(), .groups = "drop")
# 2025 prices kept in the csv for reference only: they are not shown, because ranking on 1990–2019 and pricing in
# 2025 mixes periods (Opotiki, cheapest over 1990–2019, cost more than Selwyn in 2025)
p25 <- full |> filter(year == 2025) |> group_by(ta) |>
  summarise(houses_2025 = sum(houses_n), cost_2025 = sum(houses_val * real_factor) / sum(houses_m2), .groups = "drop")
rank1 <- rank1 |> left_join(p25, by = "ta")
write_csv(rank1 |> arrange(desc(rel_pct)), file.path(num_dir, "c01_district_relative_cost.csv"))
grp1 <- c("Top 5 (dearest)" = unname(pal["coral"]), "Bottom 5 (cheapest)" = unname(pal["teal"]))
ends <- bind_rows(rank1 |> slice_max(rel_pct, n = 5) |> mutate(group = names(grp1)[1]),
                  rank1 |> slice_min(rel_pct, n = 5) |> mutate(group = names(grp1)[2])) |>
  mutate(name = fct_reorder(short(ta), rel_pct), group = factor(group, names(grp1)),
         label = sprintf("%+.0f%%  ·  %s", rel_pct, fmt_dol(cost)))
p1 <- ggplot(ends, aes(rel_pct, name, fill = group)) +
  geom_col(width = 0.7) +
  geom_vline(xintercept = 0, colour = pal["slate"]) +
  geom_text(aes(label = label, hjust = if_else(rel_pct > 0, -0.06, 1.06)), size = 4.6, colour = pal["slate"]) +
  facet_grid(group ~ ., scales = "free_y", space = "free_y") +
  scale_fill_manual(values = grp1) +
  scale_x_continuous(labels = function(x) paste0(ifelse(x > 0, "+", ""), x, "%"), limits = c(-44, 48),
                     breaks = c(-20, 0, 20)) +
  labs(x = "Cost vs rest of NZ in the same quarter (%)", y = "District", fill = NULL) +   # title is in the poster / slide
  theme(strip.text = element_blank(), panel.spacing = unit(0.6, "lines"), legend.text = element_text(size = 16),
        legend.margin = margin(0, 0, 0, 0), plot.margin = margin(4, 6, 4, 4),
        axis.text = element_text(size = 15), axis.title = element_text(size = 16), plot.title = element_text(size = 19),
        plot.subtitle = element_text(size = 14), legend.key.size = unit(0.9, "lines"))
save_comm(p1, "c01_district_relative_cost", w = 7.2, h = 3.4)

# ---- 2. Inflation: nominal vs real --------------------------------------------
nz <- tab("rq1", "t02_nz_annual_cost_m2")
p2 <- nz |> pivot_longer(c(nominal, real), names_to = "basis", values_to = "cost") |>
  mutate(basis = recode(basis, nominal = "In the dollars of each year", real = "After removing building-cost inflation")) |>
  ggplot(aes(year, cost, colour = basis)) +
  geom_line(linewidth = 1.6) +
  scale_colour_manual(values = c("In the dollars of each year" = "#B9AA9A",
                                 "After removing building-cost inflation" = unname(pal["coral"]))) +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Most of the rise in cost is inflation",
       subtitle = "New-house value per square metre, New Zealand", x = "Year", y = "Cost per square metre (NZ$)", colour = NULL) +
  guides(colour = guide_legend(nrow = 2))
save_comm(p2, "c02_inflation", w = 9, h = 6)

# poster version: wider and shorter, lines labelled at their ends instead of a legend
ends2 <- nz |> filter(year %in% range(year))
rise <- c(nominal = ends2$nominal[2] / ends2$nominal[1], real = ends2$real[2] / ends2$real[1])
p2b <- nz |> pivot_longer(c(nominal, real), names_to = "basis", values_to = "cost") |>
  ggplot(aes(year, cost, colour = basis)) +
  geom_line(linewidth = 1.6, show.legend = FALSE) +
  annotate("text", x = 2026, y = max(nz$real) + 180, hjust = 1, vjust = 0, size = 7.5, fontface = "bold", colour = pal["coral"],
           label = paste0("real dollars: up ", round(100 * (rise["real"] - 1)), "%")) +
  annotate("text", x = 2026, y = 480, hjust = 1, size = 7.5, fontface = "bold", colour = "#8C7B6A",
           label = paste0("each year's dollars: ", sprintf("%.1f", rise["nominal"]), " times")) +
  scale_colour_manual(values = c(nominal = "#B9AA9A", real = unname(pal["coral"]))) +
  scale_x_continuous(breaks = seq(1990, 2020, 10), limits = c(1990, 2026)) +
  scale_y_continuous(labels = scales::dollar, limits = c(330, 3800), breaks = c(1000, 2000, 3000)) +
  labs(x = "Year", y = "Cost (NZ$)") +
  theme(axis.text = element_text(size = 26), axis.title = element_text(size = 24, colour = "#5C5148"))
save_comm(p2b, "c02b_inflation_poster", w = 10, h = 3.5)

# ---- 3. RQ1: how accurate are the predictions? ---------------------------------
t1 <- tab("rq1", "t09_test_results")
acc1 <- tribble(~label, ~model, ~set,
  "Guess the national average", "Overall mean", "none",
  "Each district's own past average", "District mean", "none",
  "Chosen model, measured drivers only\n(random forest)", "Random forest", "drivers",
  "Chosen model, drivers + district\n(linear regression)", "Linear regression", "district") |>
  left_join(t1 |> select(model, set, test_mape), by = c("model", "set")) |>
  mutate(label = fct_inorder(label), best = model == "Linear regression" & set == "district")
p3 <- ggplot(acc1, aes(test_mape, fct_rev(label), fill = best)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = sprintf("%.1f%%", 100 * test_mape)), hjust = -0.15, size = 6.5, fontface = "bold",
            colour = pal["slate"]) +
  scale_fill_manual(values = c(`TRUE` = unname(pal["coral"]), `FALSE` = unname(pal["grey"])), guide = "none") +
  scale_x_continuous(labels = scales::percent, limits = c(0, 0.12), breaks = c(0, 0.05, 0.10)) +
  labs(title = "How far off are the predictions? (2020–2026)",
       subtitle = "Average error in cost per square metre on years the models never saw (lower is better)",
       x = "Average test error, MAPE (%)", y = NULL)
save_comm(p3, "c03_rq1_accuracy", w = 10, h = 5)

# ---- 4. RQ1: what drives cost ----------------------------------------------------
e1 <- tab("rq1", "t12_effect_sizes")
drv <- e1 |>
  transmute(feature, effect = (`Random forest, drivers` + `Linear, drivers`) / 2) |>
  mutate(label = recode(feature,
    log_resid_alt_real = "Renovation spending in the district",
    dwell_per_1000     = "New homes per 1,000 residents",
    log_houses_n       = "Number of new houses*",
    rel_house_m2       = "Bigger houses",
    log_nonres_real    = "Commercial building",
    houses_yoy         = "Change from last year")) |>
  filter(feature != "log_nonres_real") |>
  mutate(label = fct_reorder(label, effect), dir = effect > 0)
p4 <- ggplot(drv, aes(effect, label, fill = dir)) +
  geom_col(width = 0.65) +
  geom_vline(xintercept = 0, colour = "grey40") +
  geom_text(aes(label = sprintf("%+.0f%%", effect), hjust = if_else(dir, -0.2, 1.2)), size = 6.5,
            fontface = "bold", colour = pal["slate"]) +
  scale_fill_manual(values = c(`TRUE` = unname(pal["coral"]), `FALSE` = unname(pal["teal"])), guide = "none") +
  scale_x_continuous(labels = function(x) paste0(x, "%"), limits = c(-8, 13)) +
  labs(title = "What makes a district dearer to build in?",
       subtitle = "Each factor moved from a low (10th percentile) to a high (90th percentile) value",
       x = "Change in predicted cost vs rest of NZ (%)", y = "Factor",
       caption = "* For the same renovation spending. Within one district, busy years are dearer.")
save_comm(p4, "c04_rq1_drivers", w = 10, h = 5)

# low and high values behind each bar (10th and 90th percentile of the training rows, 1996–2019), in plain units
tr1 <- m1 |> filter(split == "train", year >= 1996, !ta %in% c("Chatham Islands Territory", "Kawerau District"))   # as in 04_rq1
q10_90 <- function(v) quantile(v, c(0.1, 0.9), names = FALSE, na.rm = TRUE)
write_csv(tribble(~feature, ~unit, ~p10, ~p90,
  "log_resid_alt_real", "renovation spending, $ per quarter (June-2026 dollars)", exp(q10_90(tr1$log_resid_alt_real))[1], exp(q10_90(tr1$log_resid_alt_real))[2],
  "dwell_per_1000", "new dwellings per 1,000 residents (year)", q10_90(tr1$dwell_per_1000)[1], q10_90(tr1$dwell_per_1000)[2],
  "log_houses_n", "new houses in the quarter", exp(q10_90(tr1$log_houses_n))[1], exp(q10_90(tr1$log_houses_n))[2],
  "rel_house_m2", "house size vs rest of NZ (%)", 100 * (exp(q10_90(tr1$rel_house_m2))[1] - 1), 100 * (exp(q10_90(tr1$rel_house_m2))[2] - 1),
  "houses_yoy", "houses vs same quarter last year (%)", 100 * (exp(q10_90(tr1$houses_yoy))[1] - 1), 100 * (exp(q10_90(tr1$houses_yoy))[2] - 1)),
  file.path(num_dir, "c04_driver_low_high_values.csv"))

# ---- 5. RQ1: why relative cost (same data as fig13 in 02_rq1_eda.Rmd, in dollars and %) ---------
per_lab <- c(train = "1990–2019 (training years)", test = "2020–2026 (test years)")
sh <- m1 |> transmute(split = factor(per_lab[as.character(split)], per_lab),
                      `Real cost per square metre (June-2026 NZ$)` = real_cost_m2,
                      `Cost vs rest of NZ in the same quarter (%)` = 100 * (exp(rel_log_cost_m2) - 1)) |>
  pivot_longer(-split, names_to = "measure") |>
  mutate(measure = fct_inorder(measure))
sh_med <- sh |> group_by(measure, split) |> summarise(med = median(value), .groups = "drop")
write_csv(sh_med, file.path(num_dir, "c09_train_test_medians.csv"))
sh_lab <- sh_med |> group_by(measure) |>
  summarise(lab = if_else(first(measure) == levels(sh$measure)[1],
                          sprintf("median %s → %s", fmt_dol(med[1]), fmt_dol(med[2])),
                          sprintf("median %+.0f%% → %+.0f%%", med[1], med[2])), .groups = "drop")
p9s <- ggplot(sh, aes(value, fill = split)) +
  geom_density(alpha = 0.6, colour = NA) +
  geom_vline(data = sh_med, aes(xintercept = med, colour = split), linewidth = 1, linetype = 2, show.legend = FALSE) +
  geom_text(data = sh_lab, aes(x = Inf, y = Inf, label = lab), inherit.aes = FALSE, hjust = 1.05, vjust = 1.5,
            size = 5.5, fontface = "bold", colour = pal["slate"]) +
  facet_wrap(~measure, scales = "free", strip.position = "bottom") +
  scale_fill_manual(values = setNames(c("#8C7B6A", unname(pal["coral"])), per_lab)) +
  scale_colour_manual(values = setNames(c("#5C5148", unname(pal["coral"])), per_lab)) +
  scale_x_continuous(labels = function(x) ifelse(abs(x) >= 1000, scales::dollar(x), paste0(x, "%"))) +
  labs(title = "After 2020 costs rose everywhere; relative cost barely moved",
       subtitle = "How district-quarters are spread out before and after 2020 (taller = more common)",
       x = NULL, y = NULL, fill = NULL) +
  theme(strip.placement = "outside", strip.text = element_text(size = 17, colour = "#3D3630"),
        axis.text.y = element_blank(), panel.grid.major.y = element_blank(),
        plot.margin = margin(10, 30, 10, 20))
save_comm(p9s, "c09_rq1_why_relative", w = 12, h = 5.2)

# ---- 6. RQ2: the three markets on a map of districts --------------------------------
rq2  <- readRDS(file.path(paths$processed, "rq2_district_features.rds"))
fit2 <- readRDS("outputs/models/rq2/rq2_clusters.rds")
X2 <- scale(rq2$transformed[fit2$vars])
pc <- prcomp(X2)
mk_cols <- c("House-building districts" = unname(pal["blue"]), "Slow provincial districts" = unname(pal["coral"]),
             "Urban medium-density" = unname(pal["teal"]))
n_mk <- table(factor(fit2$membership$market, levels = names(mk_cols)))
mk_lab <- setNames(sprintf("Cluster %d: %s (%d)", 1:3, c("House-building", "Slow provincial", "Urban medium-density"), n_mk),
                   names(mk_cols))
show_names <- c("Auckland", "Wellington", "Christchurch", "Queenstown-Lakes", "Selwyn", "Tasman",
                "Thames-Coromandel", "Wairoa", "Hamilton", "Clutha")
pdf2 <- as_tibble(pc$x[, 1:2]) |>
  mutate(name = short(rq2$transformed$ta), market = factor(fit2$membership$market, levels = names(mk_cols)))
p6 <- ggplot(pdf2, aes(PC1, PC2, colour = market)) +
  stat_ellipse(level = 0.8, linewidth = 0.9, linetype = 2, show.legend = FALSE) +
  geom_point(size = 4, alpha = 0.9) +
  geom_text(data = pdf2 |> filter(name %in% show_names), aes(label = name), size = 4.8, vjust = -0.9,
            show.legend = FALSE, fontface = "bold") +
  scale_colour_manual(values = mk_cols, labels = mk_lab) +
  scale_x_continuous(expand = expansion(mult = c(0.08, 0.18))) +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
  labs(title = "Three clusters of building market (k-means, k = 3)",
       subtitle = "Each dot is a district (2016–2026); nearby dots build in similar ways",
       x = "Builds more homes per resident, bigger houses  →", y = "More townhouses, dearer  →",
       colour = NULL) +
  theme(axis.text = element_blank(), panel.grid.major.y = element_blank()) +
  guides(colour = guide_legend(nrow = 1, override.aes = list(size = 5))) +
  theme(legend.text = element_text(size = 14))
save_comm(p6, "c05_rq2_markets", w = 11.6, h = 5.8)

# ---- 7. RQ2: what each market looks like ----------------------------------------------
# median district of each market, from the district features (natural units)
panel_order <- c("Townhouses & apartments\n(% of new homes)", "New homes per\n1,000 residents a year",
                 "Cost vs rest of NZ\n(%)", "Commercial building\n(% of building value)")
show <- rq2$raw |>
  mutate(market = factor(fit2$membership$market, levels = names(mk_cols))) |>
  group_by(market) |>
  summarise(`Townhouses & apartments\n(% of new homes)` = 100 * median(town_share + apt_share),
            `New homes per\n1,000 residents a year` = median(dwell_per_1000),
            `Cost vs rest of NZ\n(%)` = 100 * (exp(median(rel_cost)) - 1),
            `Commercial building\n(% of building value)` = 100 * median(nonres_share)) |>
  pivot_longer(-market) |>
  mutate(name = factor(name, levels = panel_order))
p7 <- ggplot(show, aes(market, value, fill = market)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 0, colour = "grey40") +
  geom_text(aes(label = round(value, 1), vjust = if_else(value >= 0, -0.3, 1.3)), size = 5.5, fontface = "bold",
            colour = pal["slate"]) +
  facet_wrap(~name, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = mk_cols, labels = mk_lab) +
  scale_y_continuous(expand = expansion(mult = c(0.15, 0.2))) +
  labs(title = "How the three clusters differ (median district in each cluster)",
       x = "Cluster", y = "Median value", fill = NULL) +
  guides(fill = guide_legend(nrow = 1)) +
  theme(legend.text = element_text(size = 15)) +
  theme(axis.text.x = element_blank(), strip.text = element_text(size = 14, face = "bold"),
        panel.grid.major.y = element_blank(), axis.text.y = element_blank())
save_comm(p7, "c06_rq2_profiles", w = 12, h = 5.8)

# districts that best represent each cluster: closest to the cluster centre (scaled features) and largest builders
cl2 <- fit2$membership$cluster
cent2 <- apply(X2, 2, function(v) tapply(v, cl2, mean))
rep2 <- tibble(name = short(rq2$transformed$ta), market = fit2$membership$market,
               dist_to_centre = sqrt(rowSums((X2 - cent2[cl2, ])^2)), dwellings_2016_26 = rq2$raw$dwellings)
write_csv(bind_rows(rep2 |> group_by(market) |> slice_min(dist_to_centre, n = 5) |> mutate(rule = "closest to centre"),
                    rep2 |> group_by(market) |> slice_max(dwellings_2016_26, n = 5) |> mutate(rule = "most new dwellings")) |>
            ungroup(), file.path(num_dir, "rq2_representative_districts.csv"))

# ---- 7b. RQ2: choosing the number of clusters (slides only) ------------------------------
ck <- tab("rq2", "t02_choose_k") |>
  select(k, `Silhouette: how well separated\n(higher is better)` = silhouette,
         `Stability: same groups when resampled\n(higher is better)` = stability) |>
  pivot_longer(-k)
p7b <- ggplot(ck, aes(k, value)) +
  geom_line(colour = "#B9AA9A", linewidth = 1.4) +
  geom_point(aes(colour = k == 3), size = 4.5) +
  geom_text(data = ck |> filter(k == 3), aes(label = sprintf("%.2f", value)), vjust = -1.1, size = 6,
            fontface = "bold", colour = pal["coral"]) +
  facet_wrap(~name, scales = "free_y") +
  scale_colour_manual(values = c(`TRUE` = unname(pal["coral"]), `FALSE` = "#8C7B6A"), guide = "none") +
  scale_x_continuous(breaks = 2:8) +
  scale_y_continuous(expand = expansion(mult = c(0.1, 0.25))) +
  labs(title = "Why three clusters?", subtitle = "k-means on the 66 districts, k = 2 to 8",
       x = "Number of clusters (k)", y = "Score") +
  theme(strip.text = element_text(size = 15, face = "bold"))
save_comm(p7b, "c10_rq2_choose_k", w = 10, h = 4.6)

# ---- 8. RQ3: share of districts rising each year ---------------------------------------
rq3 <- readRDS(file.path(paths$processed, "rq3_model_data.rds"))$data
yr <- rq3 |> group_by(year) |> summarise(share = mean(rise), nat = first(nat_rise_next)) |>
  mutate(outcome_year = year + 1, nat = factor(nat, 0:1, c("New Zealand total fell", "New Zealand total rose")))
p8 <- ggplot(yr, aes(outcome_year, share, fill = nat)) +
  geom_col(width = 0.8) +
  geom_hline(yintercept = 0.5, colour = "#3D3630", linetype = 2) +
  scale_fill_manual(values = c("New Zealand total fell" = unname(pal["blue"]), "New Zealand total rose" = unname(pal["coral"]))) +
  geom_text(data = yr |> filter(share %in% range(share)),   # lowest label sits above its neighbours, with a line down
            aes(y = if_else(share < 0.5, 0.69, share + 0.06), label = sprintf("%.0f%% (%d)", 100 * share, outcome_year)),
            size = 5.5, fontface = "bold", colour = pal["slate"], show.legend = FALSE) +
  geom_segment(data = yr |> filter(share == min(share)), aes(xend = outcome_year, y = 0.65, yend = share + 0.01),
               colour = pal["slate"], show.legend = FALSE) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(title = "Districts rise and fall together",
       subtitle = "Share of districts building more homes than the year before",
       x = "Year", y = "Districts building more than\nthe year before (%)", fill = NULL)
save_comm(p8, "c07_rq3_together", w = 10, h = 5)

# ---- 9. RQ3: how well can we predict? ----------------------------------------------------
t3 <- tab("rq3", "t04_test_results")
acc3 <- tribble(~label, ~model,
  "Toss a coin", NA_character_,
  "Always say \"rise\"", "Majority class",
  "Say the opposite of this year", "Opposite of this year",
  "Our model (logistic regression)", "Logistic regression") |>
  left_join(t3 |> select(model, accuracy), by = "model") |>
  mutate(accuracy = replace_na(accuracy, 0.5), label = fct_inorder(label),
         ours = model %in% "Logistic regression")
p9 <- ggplot(acc3, aes(accuracy, fct_rev(label), fill = ours)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = paste0(round(100 * accuracy), "%")), hjust = -0.15, size = 6.5, fontface = "bold",
            colour = pal["slate"]) +
  scale_fill_manual(values = c(`TRUE` = unname(pal["coral"]), `FALSE` = unname(pal["grey"])), guide = "none") +
  scale_x_continuous(labels = scales::percent, limits = c(0, 0.75)) +
  labs(title = "Predicting next year's direction (2018–2025)",
       subtitle = "Share of district-years where the direction was called correctly",
       x = "Test accuracy (% of district-years called correctly)", y = NULL)
save_comm(p9, "c08_rq3_accuracy", w = 10, h = 5)

# precision and recall of "rise" on the test years, from the saved test predictions (threshold 0.5)
pr3 <- readRDS("outputs/models/rq3/rq3_results.rds")$test_predictions |>
  mutate(pred = as.integer(prob >= 0.5)) |>
  group_by(model) |>
  summarise(n = n(), accuracy = mean(pred == rise), precision = sum(pred & rise) / sum(pred),
            recall = sum(pred & rise) / sum(rise), specificity = sum(!pred & !rise) / sum(!rise), .groups = "drop")
chk <- pr3 |> inner_join(t3 |> select(model, acc_saved = accuracy), by = "model")
stopifnot(isTRUE(all.equal(chk$accuracy, chk$acc_saved)))   # same threshold as the notebook
write_csv(pr3, file.path(num_dir, "rq3_test_precision_recall.csv"))

list.files(out_dir)
