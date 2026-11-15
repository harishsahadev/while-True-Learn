# =============================================================================
# 04_q2_profiles.R: one profile row per district for Q2 (clustering).
# Run from building-consents/:   Rscript R/scripts/04_q2_profiles.R
# Input:  <derived>/district_quarters.rds (02_clean.R), price_index.rds (03_features.R)
# Output: <derived>/q2_profiles.rds and .csv
#
# Window: q2_years in config.R (2015-2025, complete years only). Every feature
# is a ratio or rate, so district size does not drive the clusters.
# Totals are pooled over the window before dividing, which keeps small
# districts' ratios stable.
# =============================================================================

source("R/config.R")
suppressPackageStartupMessages(library(tidyverse))

dq  <- readRDS(derived_file("district_quarters.rds"))
idx <- readRDS(derived_file("price_index.rds"))
cgpi_base <- attr(idx, "base")[["cgpi"]]

w <- dq %>%
  filter(year %in% q2_years) %>%
  left_join(select(idx, year, quarter, cgpi), by = c("year", "quarter")) %>%
  mutate(houses_value_real = houses_value * cgpi_base / cgpi)

stopifnot("every quarter needs a CGPI value" = all(!is.na(w$cgpi)))

# ---- pooled ratios over the window -------------------------------------------------
pooled <- w %>%
  group_by(area) %>%
  summarise(
    dwellings_total   = sum(dwellings_n),
    houses_total      = sum(houses_n),
    share_townhouses  = sum(townhouses_n) / sum(dwellings_n),
    share_apartments  = sum(apartments_n) / sum(dwellings_n),
    share_retirement  = sum(retirement_n) / sum(dwellings_n),
    real_m2           = sum(houses_value_real) / sum(houses_area),   # CGPI-deflated
    m2_per_house      = sum(houses_area) / sum(houses_n),
    alt_share         = sum(alt_res_value) / sum(alt_res_value + res_value),
    nonres_area_share = sum(nonres_area) / sum(allbld_area),
    .groups = "drop")

# ---- growth and volatility from annual dwelling counts -------------------------------
yrs <- range(q2_years)
first5 <- yrs[1] + 0:4
last5  <- yrs[2] - 4:0
annual <- w %>% group_by(area, year) %>% summarise(dw = sum(dwellings_n), .groups = "drop")
dyn <- annual %>%
  group_by(area) %>%
  arrange(year, .by_group = TRUE) %>%
  summarise(
    # log growth, last five years vs first five (+1 guards against zero)
    growth     = log((sum(dw[year %in% last5]) + 1) / (sum(dw[year %in% first5]) + 1)),
    # SD of year-on-year log changes: how bumpy the pipeline is
    volatility = sd(diff(log(dw + 1))),
    .groups = "drop")

# ---- building intensity: new dwellings per 1,000 residents (calendar years) ----------
per1000 <- read_csv(data_file(f_per1000_ta), col_types = cols(.default = col_character()),
                    progress = FALSE) %>%
  filter(Series_title_1 != "New Zealand", substr(Period, 6, 7) == "12",
         as.integer(substr(Period, 1, 4)) %in% q2_years) %>%
  group_by(area = Series_title_1) %>%
  summarise(per1000 = mean(as.numeric(Data_value)), .groups = "drop")

profiles <- pooled %>%
  inner_join(dyn, by = "area") %>%
  left_join(per1000, by = "area") %>%
  filter(area != "Area Outside Territorial Authority")

message("Districts: ", nrow(profiles), "   missing values: ",
        sum(!complete.cases(select(profiles, -area))))
print(profiles %>% arrange(houses_total) %>% head(5) %>% select(area, houses_total, dwellings_total, real_m2))

attr(profiles, "years") <- q2_years
attr(profiles, "base_period") <- attr(idx, "base_period")
saveRDS(profiles, derived_file("q2_profiles.rds"))
write_csv(profiles, derived_file("q2_profiles.csv"))
message("Saved to ", derived_file("q2_profiles.rds"))
