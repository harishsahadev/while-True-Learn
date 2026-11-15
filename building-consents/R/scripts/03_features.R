# =============================================================================
# 03_features.R: district-quarters -> the Q1 modelling frame.
# Run from building-consents/:   Rscript R/scripts/03_features.R
# Input:  <derived>/district_quarters.rds   (from 02_clean.R)
# Output: <derived>/q1_frame.rds and .csv, <derived>/price_index.rds
#
# Response: log of REAL $/m² of new houses. Consent values are nominal and GST
# inclusive; 4.7x of nominal growth since 1991 is mostly inflation, so every
# quarter is deflated by the Capital Goods Price Index for residential
# buildings (CEPQ.S61101) into the latest index quarter's dollars.
#
# Inflation is also kept as information:
#   * dollars_per_m2 / log_nom_m2 : nominal response (for the nominal-vs-real check)
#   * log_real_m2_ppi             : response deflated by a second index, the PPI for
#                                   residential building construction outputs
#                                   (PPIQ.SQUEE1120), for a deflator sensitivity check
#   * cgpi_growth_lag1            : construction-cost inflation over the year to the
#                                   PREVIOUS quarter (a feature, known in advance)
#
# Leakage rule: no feature uses the current quarter's dollar values; activity
# features use previous quarters only.
# =============================================================================

source("R/config.R")
suppressPackageStartupMessages(library(tidyverse))

period_year    <- function(p) as.integer(substr(p, 1, 4))
period_quarter <- function(p) (as.integer(substr(p, 6, 7)) - 1L) %/% 3L + 1L
read_infoshare_chr <- function(name) {
  read_csv(data_file(name), col_types = cols(.default = col_character()), progress = FALSE)
}

frame <- readRDS(derived_file("district_quarters.rds"))

# ---- type mix, size, volume, non-residential share ----------------------------
frame <- frame %>%
  mutate(multi_unit_share  = if_else(dwellings_n > 0, 1 - houses_n / dwellings_n, NA_real_),
         m2_per_house      = if_else(houses_n > 0, houses_area / houses_n, NA_real_),
         log_houses        = if_else(houses_n > 0, log(houses_n), NA_real_),
         nonres_area_share = if_else(allbld_area > 0, nonres_area / allbld_area, NA_real_),
         time_trend        = year + (quarter - 1) / 4)

# ---- recent building activity (previous 8 quarters only) ------------------------
frame <- frame %>%
  group_by(area) %>%
  mutate(dw_trail4 = lag(dwellings_n, 1) + lag(dwellings_n, 2) + lag(dwellings_n, 3) + lag(dwellings_n, 4),
         dw_prev4  = lag(dwellings_n, 5) + lag(dwellings_n, 6) + lag(dwellings_n, 7) + lag(dwellings_n, 8),
         dw_growth = log((dw_trail4 + 1) / (dw_prev4 + 1))) %>%
  ungroup() %>%
  mutate(log_dw_trail4 = log1p(dw_trail4))

# ---- new dwellings per 1,000 residents, year to the previous quarter ---------------
per1000_q <- read_infoshare_chr(f_per1000_ta) %>%
  filter(Series_title_1 != "New Zealand",
         substr(Period, 6, 7) %in% c("03", "06", "09", "12")) %>%
  transmute(area = Series_title_1,
            qtr_index = period_year(Period) * 4L + period_quarter(Period) + 1L,  # next quarter
            per1000_lag1 = as.numeric(Data_value))
frame <- frame %>% left_join(per1000_q, by = c("area", "qtr_index"))

# ---- concentration: share of new dwellings in the 3 busiest SA2s --------------------
message("Reading the SA2 file...")
sa2_conc <- read_csv(data_file(f_sa2_2026),
                     col_types = cols(month = col_date(), .default = col_character()),
                     progress = FALSE) %>%
  mutate(total_dwelling_units = as.integer(total_dwelling_units),
         area    = stringi::stri_trans_general(territorial_authority, "Latin-ASCII"),
         year    = as.integer(format(month, "%Y")),
         quarter = (as.integer(format(month, "%m")) - 1L) %/% 3L + 1L) %>%
  group_by(area, year, quarter, SA2_code) %>%
  summarise(d = sum(total_dwelling_units), .groups = "drop_last") %>%
  summarise(sa2_total = sum(d),
            sa2_top3_share = if_else(sa2_total > 0,
                                     sum(sort(d, decreasing = TRUE)[1:3], na.rm = TRUE) / sa2_total,
                                     NA_real_),
            .groups = "drop") %>%
  select(area, year, quarter, sa2_top3_share)
frame <- frame %>% left_join(sa2_conc, by = c("area", "year", "quarter"))

# ---- price indexes: CGPI (main deflator) and PPI (sensitivity) -----------------------
prices <- read_infoshare_chr(f_prices) %>%
  filter(Series_reference %in% c("CEPQ.S61101", "PPIQ.SQUEE1120")) %>%
  transmute(series = if_else(Series_reference == "CEPQ.S61101", "cgpi", "ppi"),
            Period, year = period_year(Period), quarter = period_quarter(Period),
            index = as.numeric(Data_value))
stopifnot("CGPI series CEPQ.S61101 not found" = any(prices$series == "cgpi"))

base_period <- max(prices$Period[prices$series == "cgpi"])
base <- prices %>% filter(Period == base_period) %>% select(series, base = index) %>% deframe()

idx <- prices %>%
  select(series, year, quarter, index) %>%
  pivot_wider(names_from = series, values_from = index) %>%
  arrange(year, quarter) %>%
  # annual construction-cost inflation to the PREVIOUS quarter (no look-ahead)
  mutate(cgpi_growth      = log(cgpi / lag(cgpi, 4)),
         cgpi_growth_lag1 = lag(cgpi_growth, 1)) %>%
  select(year, quarter, cgpi, ppi, cgpi_growth_lag1)

# saved for Q2/Q3, so every question deflates with the same index and base
attr(idx, "base_period") <- base_period
attr(idx, "base") <- base
saveRDS(idx, derived_file("price_index.rds"))

frame <- frame %>%
  left_join(idx, by = c("year", "quarter")) %>%
  mutate(dollars_per_m2  = if_else(houses_n > 0 & houses_area > 0, houses_value / houses_area, NA_real_),
         log_nom_m2      = log(dollars_per_m2),
         real_m2         = dollars_per_m2 * base[["cgpi"]] / cgpi,
         log_real_m2     = log(real_m2),
         log_real_m2_ppi = log(dollars_per_m2 * base[["ppi"]] / ppi))

# ---- last observed real $/m² in the district (for the persistence baseline) -------
frame <- frame %>%
  group_by(area) %>%
  mutate(obs = if_else(houses_n >= min_houses, log_real_m2, NA_real_),
         last_log_real_m2 = lag(obs)) %>%
  fill(last_log_real_m2, .direction = "down") %>%
  ungroup() %>%
  select(-obs)

# ---- sanity anchor from the EDA: 2025 nominal Queenstown ~4,516, Selwyn ~2,593 ------
anchor <- frame %>%
  filter(year == 2025, area %in% c("Queenstown-Lakes District", "Selwyn District")) %>%
  group_by(area) %>%
  summarise(nominal = round(sum(houses_value) / sum(houses_area)))
message("EDA anchor (expect ~4,516 and ~2,593): ",
        paste(anchor$area, anchor$nominal, collapse = "; "))

# ---- final frame ----------------------------------------------------------------
model_features <- c("multi_unit_share", "m2_per_house", "log_houses", "nonres_area_share",
                    "per1000_lag1", "dw_growth", "log_dw_trail4", "sa2_top3_share",
                    "time_trend", "cgpi_growth_lag1")

q1_frame <- frame %>%
  filter(houses_n >= min_houses,
         if_all(all_of(c("log_real_m2", model_features)), ~ is.finite(.x))) %>%
  mutate(area      = factor(area),
         quarter_f = factor(quarter),
         split     = if_else(year <= train_end_year, "train", "test")) %>%
  select(area, year, quarter, quarter_f, split,
         log_real_m2, real_m2, dollars_per_m2, log_nom_m2, log_real_m2_ppi,
         last_log_real_m2, cgpi, ppi, houses_n,
         all_of(model_features))

attr(q1_frame, "base_period") <- base_period
saveRDS(q1_frame, derived_file("q1_frame.rds"))
write_csv(q1_frame, derived_file("q1_frame.csv"))

message("Saved ", nrow(q1_frame), " rows (train ", sum(q1_frame$split == "train"),
        ", test ", sum(q1_frame$split == "test"), "; real dollars of ", base_period,
        ") to ", derived_file("q1_frame.rds"))
