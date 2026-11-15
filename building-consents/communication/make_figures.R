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
systemfonts::register_font("Open Sauce One",
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

# ---- 1. Cost per m² in 2025: dearest and cheapest districts ------------------
d25 <- full |> filter(year == 2025) |>
  group_by(ta) |>
  summarise(houses = sum(houses_n), cost = sum(houses_val * real_factor) / sum(houses_m2), .groups = "drop") |>
  filter(houses >= 50)
nz25 <- full |> filter(year == 2025) |> summarise(cost = sum(houses_val * real_factor) / sum(houses_m2)) |> pull(cost)
ends <- bind_rows(d25 |> slice_max(cost, n = 5) |> mutate(group = "Dearest"),
                  d25 |> slice_min(cost, n = 5) |> mutate(group = "Cheapest")) |>
  mutate(name = fct_reorder(short(ta), cost))
p1 <- ggplot(ends, aes(cost, name, fill = group)) +
  geom_vline(xintercept = nz25, linetype = 2, colour = pal["slate"]) +        # drawn first: bars sit on top
  geom_col(width = 0.7) +
  annotate("text", x = nz25, y = 10.65, label = paste0("NZ average ", fmt_dol(nz25)), size = 5, hjust = -0.05) +
  geom_text(aes(label = fmt_dol(cost), colour = group), hjust = 1.1, size = 5.5, fontface = "bold") +
  scale_colour_manual(values = c(Dearest = "white", Cheapest = unname(pal["slate"])), guide = "none") +
  scale_fill_manual(values = c(Dearest = unname(pal["coral"]), Cheapest = unname(pal["teal"])), guide = "none") +
  scale_x_continuous(labels = scales::dollar, expand = expansion(mult = c(0, 0.05))) +
  coord_cartesian(clip = "off") +
  labs(title = "Building a new house costs very different amounts",
       subtitle = "Real cost per square metre of new houses, 2025 (districts with 50+ new houses)",
       x = NULL, y = NULL)
save_comm(p1, "c01_cost_by_district_2025", w = 10, h = 5.1)

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
       subtitle = "New-house value per square metre, New Zealand", x = NULL, y = NULL, colour = NULL) +
  guides(colour = guide_legend(nrow = 2))
save_comm(p2, "c02_inflation", w = 9, h = 6)

# ---- 3. RQ1: how accurate are the predictions? ---------------------------------
t1 <- tab("rq1", "t09_test_results")
acc1 <- tribble(~label, ~model, ~set,
  "Guess the national average", "Overall mean", "none",
  "Each district's own past average", "District mean", "none",
  "Best model, measured drivers only", "SVM (radial)", "drivers",
  "Best model, drivers + district", "Linear regression", "district") |>
  left_join(t1 |> select(model, set, test_mape), by = c("model", "set")) |>
  mutate(label = fct_inorder(label), best = model == "Linear regression")
p3 <- ggplot(acc1, aes(test_mape, fct_rev(label), fill = best)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = sprintf("%.1f%%", 100 * test_mape)), hjust = -0.15, size = 6.5, fontface = "bold",
            colour = pal["slate"]) +
  scale_fill_manual(values = c(`TRUE` = unname(pal["coral"]), `FALSE` = unname(pal["grey"])), guide = "none") +
  scale_x_continuous(labels = scales::percent, limits = c(0, 0.12), breaks = c(0, 0.05, 0.10)) +
  labs(title = "How far off are the predictions? (2020–2026)",
       subtitle = "Average error in cost per square metre on years the models never saw (lower is better)",
       x = NULL, y = NULL)
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
       subtitle = "Change in cost per square metre, low to high value of each factor (two models)",
       x = NULL, y = NULL,
       caption = "* For the same renovation spending. Within one district, busy years are dearer.")
save_comm(p4, "c04_rq1_drivers", w = 10, h = 5.5)

# ---- 6. RQ2: the three markets on a map of districts --------------------------------
rq2  <- readRDS(file.path(paths$processed, "rq2_district_features.rds"))
fit2 <- readRDS("outputs/models/rq2/rq2_clusters.rds")
X2 <- scale(rq2$transformed[fit2$vars])
pc <- prcomp(X2)
mk_cols <- c("House-building districts" = unname(pal["blue"]), "Slow provincial districts" = unname(pal["coral"]),
             "Urban medium-density" = unname(pal["teal"]))
show_names <- c("Auckland", "Wellington", "Christchurch", "Queenstown-Lakes", "Selwyn", "Tasman",
                "Thames-Coromandel", "Wairoa", "Hamilton", "Clutha")
pdf2 <- as_tibble(pc$x[, 1:2]) |>
  mutate(name = short(rq2$transformed$ta), market = factor(fit2$membership$market, levels = names(mk_cols)))
p6 <- ggplot(pdf2, aes(PC1, PC2, colour = market)) +
  stat_ellipse(level = 0.8, linewidth = 0.9, linetype = 2, show.legend = FALSE) +
  geom_point(size = 4, alpha = 0.9) +
  geom_text(data = pdf2 |> filter(name %in% show_names), aes(label = name), size = 4.8, vjust = -0.9,
            show.legend = FALSE, fontface = "bold") +
  scale_colour_manual(values = mk_cols) +
  scale_x_continuous(expand = expansion(mult = c(0.08, 0.18))) +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
  labs(title = "Three kinds of building market",
       subtitle = "Each dot is a district (2016–2026); nearby dots build in similar ways",
       x = "Builds more homes per resident, bigger houses  →", y = "More townhouses, dearer  →",
       colour = NULL) +
  theme(axis.text = element_blank(), panel.grid.major.y = element_blank()) +
  guides(colour = guide_legend(nrow = 1, override.aes = list(size = 5)))
save_comm(p6, "c05_rq2_markets", w = 10.5, h = 5.8)

# ---- 7. RQ2: what each market looks like ----------------------------------------------
# median district of each market, from the district features (natural units)
panel_order <- c("Townhouses &\napartments (%)", "New homes per\n1,000 residents",
                 "Cost vs other\ndistricts (%)", "Commercial share\nof building (%)")
show <- rq2$raw |>
  mutate(market = factor(fit2$membership$market, levels = names(mk_cols))) |>
  group_by(market) |>
  summarise(`Townhouses &\napartments (%)` = 100 * median(town_share + apt_share),
            `New homes per\n1,000 residents` = median(dwell_per_1000),
            `Cost vs other\ndistricts (%)` = 100 * (exp(median(rel_cost)) - 1),
            `Commercial share\nof building (%)` = 100 * median(nonres_share)) |>
  pivot_longer(-market) |>
  mutate(name = factor(name, levels = panel_order))
p7 <- ggplot(show, aes(market, value, fill = market)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 0, colour = "grey40") +
  geom_text(aes(label = round(value, 1), vjust = if_else(value >= 0, -0.3, 1.3)), size = 5.5, fontface = "bold",
            colour = pal["slate"]) +
  facet_wrap(~name, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = mk_cols) +
  scale_y_continuous(expand = expansion(mult = c(0.15, 0.2))) +
  labs(title = "How the three markets differ (median district)", x = NULL, y = NULL, fill = NULL) +
  theme(axis.text.x = element_blank(), strip.text = element_text(size = 15, face = "bold"),
        panel.grid.major.y = element_blank(), axis.text.y = element_blank())
save_comm(p7, "c06_rq2_profiles", w = 12, h = 5.5)

# ---- 8. RQ3: share of districts rising each year ---------------------------------------
rq3 <- readRDS(file.path(paths$processed, "rq3_model_data.rds"))$data
yr <- rq3 |> group_by(year) |> summarise(share = mean(rise), nat = first(nat_rise_next)) |>
  mutate(outcome_year = year + 1, nat = factor(nat, 0:1, c("New Zealand total fell", "New Zealand total rose")))
p8 <- ggplot(yr, aes(outcome_year, share, fill = nat)) +
  geom_col(width = 0.8) +
  geom_hline(yintercept = 0.5, colour = "#3D3630", linetype = 2) +
  scale_fill_manual(values = c("New Zealand total fell" = unname(pal["blue"]), "New Zealand total rose" = unname(pal["coral"]))) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(title = "Districts rise and fall together",
       subtitle = "Share of districts building more homes than the year before",
       x = NULL, y = NULL, fill = NULL)
save_comm(p8, "c07_rq3_together", w = 10, h = 5.5)

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
       x = NULL, y = NULL)
save_comm(p9, "c08_rq3_accuracy", w = 10, h = 5)

list.files(out_dir)
