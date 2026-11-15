# =============================================================================
# 05_q3_frame.R: one row per district x year for Q3 (classification).
# Run from building-consents/:   Rscript R/scripts/05_q3_frame.R
# Input:  <derived>/district_quarters.rds (02_clean.R), price_index.rds (03_features.R)
# Output: <derived>/q3_frame.rds and .csv
#
# Label: rising = 1 if new dwellings consented in year t+1 > year t, else 0.
# Features describe the district at the END of year t only (no look-ahead).
# Years: complete calendar years only. Feature years start in 1996 (the
# per-1,000 series and 5-year volatility need history) and end in 2024 (the
# label needs 2025). Test = feature years >= q3_test_start (config.R).
# =============================================================================

source("R/config.R")
suppressPackageStartupMessages(library(tidyverse))

# SD of the last 5 values (NA until 5 are available)
zoo_sd5 <- function(x) {
  vapply(seq_along(x), function(i) if (i < 5) NA_real_ else sd(x[(i - 4):i]), numeric(1))
}

dq  <- readRDS(derived_file("district_quarters.rds"))
idx <- readRDS(derived_file("price_index.rds"))
cgpi_base <- attr(idx, "base")[["cgpi"]]

# ---- quarters -> complete calendar years ---------------------------------------------
annual <- dq %>%
  left_join(select(idx, year, quarter, cgpi), by = c("year", "quarter")) %>%
  group_by(area, year) %>%
  filter(n() == 4) %>%
  summarise(dw          = sum(dwellings_n),
            houses      = sum(houses_n),
            dw_h1       = sum(dwellings_n[quarter <= 2]),
            dw_h2       = sum(dwellings_n[quarter >= 3]),
            value_real  = sum(houses_value * cgpi_base / cgpi),   # CGPI-deflated
            houses_area = sum(houses_area),
            .groups = "drop")

# national totals and construction-cost inflation, by year
national <- annual %>% group_by(year) %>% summarise(nat_dw = sum(dw), .groups = "drop") %>%
  arrange(year) %>% mutate(nat_growth = log(nat_dw / lag(nat_dw)))
cgpi_year <- idx %>% filter(quarter == 4) %>% arrange(year) %>%
  transmute(year, cgpi_growth = log(cgpi / lag(cgpi)))   # Dec year on Dec year

# new dwellings per 1,000 residents, year ending December
per1000 <- read_csv(data_file(f_per1000_ta), col_types = cols(.default = col_character()),
                    progress = FALSE) %>%
  filter(Series_title_1 != "New Zealand", substr(Period, 6, 7) == "12") %>%
  transmute(area = Series_title_1, year = as.integer(substr(Period, 1, 4)),
            per1000 = as.numeric(Data_value))

# ---- features at the end of year t, label from year t+1 --------------------------------
l1 <- function(x) log(x + 1)
frame <- annual %>%
  arrange(area, year) %>%
  group_by(area) %>%
  mutate(
    rising       = as.integer(lead(dw) > dw),           # LABEL (uses t+1)
    dw_next      = lead(dw),
    log_dw       = l1(dw),
    growth_1y    = l1(dw) - l1(lag(dw, 1)),
    growth_3y    = l1(dw) - l1(lag(dw, 3)),
    momentum_h2  = l1(dw_h2) - l1(dw_h1),               # 2nd half vs 1st half of year t
    volatility   = zoo_sd5(growth_1y),
    multi_unit_share = if_else(dw > 0, 1 - houses / dw, NA_real_),
    real_m2      = if_else(houses_area > 0, value_real / houses_area, NA_real_),
    rose_last    = as.integer(dw > lag(dw))             # for the persistence baseline
  ) %>%
  # small districts have years with no houses: carry the last known value forward
  fill(multi_unit_share, real_m2, .direction = "down") %>%
  ungroup() %>%
  mutate(log_real_m2 = log(real_m2)) %>%
  left_join(national, by = "year") %>%
  left_join(cgpi_year, by = "year") %>%
  left_join(per1000, by = c("area", "year")) %>%
  filter(area != "Area Outside Territorial Authority")

q3_features <- c("log_dw", "growth_1y", "growth_3y", "momentum_h2", "volatility",
                 "multi_unit_share", "log_real_m2", "per1000",
                 "nat_growth", "cgpi_growth")

q3_frame <- frame %>%
  filter(!is.na(rising), if_all(all_of(q3_features), is.finite)) %>%
  mutate(split = if_else(year >= q3_test_start, "test", "train"),
         rising_f = factor(if_else(rising == 1, "rise", "fall"), levels = c("fall", "rise"))) %>%
  select(area, year, split, rising, rising_f, dw, dw_next, rose_last, real_m2,
         all_of(q3_features))

message("Feature years: ", min(q3_frame$year), "-", max(q3_frame$year),
        "   districts: ", n_distinct(q3_frame$area))
print(q3_frame %>% group_by(split) %>%
        summarise(rows = n(), years = paste(range(year), collapse = "-"),
                  share_rising = round(mean(rising), 3)))

saveRDS(q3_frame, derived_file("q3_frame.rds"))
write_csv(q3_frame, derived_file("q3_frame.csv"))
message("Saved to ", derived_file("q3_frame.rds"))
