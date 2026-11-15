# =============================================================================
# 02_clean.R: raw Stats NZ territorial authority file -> one row per district
# and quarter (wide), with counts, values and floor areas of new work.
# Run from building-consents/:   Rscript R/scripts/02_clean.R
# Output: <derived>/district_quarters.rds
#   columns <type>_<n|value|area> for new work (houses, dwellings, apartments,
#   retirement, townhouses, nonres, allbld, res) and alt_res_value (residential
#   alterations, $).
#
# Decisions (from the EDA):
#   * Period is read as text: as a number, 2025.10 (October) becomes 2025.1.
#   * Building types are nested, so each type is used on its own, never summed.
#   * Months are summed to calendar quarters; a quarter needs all 3 months,
#     which drops the partial 2026-Q3.
#   * The area outside any territorial authority is dropped: 67 districts.
# =============================================================================

source("R/config.R")
suppressPackageStartupMessages(library(tidyverse))

# ---- shared readers ------------------------------------------------------------
infoshare_cols <- cols(
  Series_reference = col_character(), Period = col_character(),
  Data_value = col_double(), Suppressed = col_character(), Status = col_character(),
  Units = col_character(), Magnitude = col_integer(), Subject = col_character(),
  Group = col_character(), Series_title_1 = col_character(),
  Series_title_2 = col_character(), Series_title_3 = col_character(),
  Series_title_4 = col_character(), Series_title_5 = col_character()
)
read_infoshare <- function(name) {
  read_csv(data_file(name), col_types = infoshare_cols, na = c("", "NA"), progress = FALSE)
}
period_year    <- function(p) as.integer(substr(p, 1, 4))
period_quarter <- function(p) (as.integer(substr(p, 6, 7)) - 1L) %/% 3L + 1L

# ---- load new work for the seven building types used ----------------------------
type_short <- c("Houses"                                        = "houses",
                "Dwelling units"                                = "dwellings",
                "Apartments"                                    = "apartments",
                "Retirement village units"                      = "retirement",
                "Townhouses, flats, units, and other dwellings" = "townhouses",
                "Non-residential buildings"                     = "nonres",
                "All buildings"                                 = "allbld",
                "Residential buildings"                         = "res")
measure_short <- c("Number" = "n", "Value" = "value", "Floor area" = "area")

message("Reading the territorial authority file (large, ~1 min)...")
# new work for every type above, plus the VALUE of residential alterations
# (renovations/additions, used for the alterations share in Q2)
df_ta <- read_infoshare(f_ta) %>%
  filter(Series_title_1 != "New Zealand",
         Series_title_2 %in% names(type_short),
         Series_title_3 == "New" |
           (Series_title_3 == "Altered" & Series_title_2 == "Residential buildings" &
              Series_title_4 == "Value")) %>%
  transmute(area = Series_title_1, building_type = Series_title_2,
            work = Series_title_3, measure = Series_title_4, Period, Data_value)

# ---- months -> complete quarters, long -> wide -----------------------------------
q_long <- df_ta %>%
  mutate(year    = period_year(Period),
         quarter = period_quarter(Period),
         var     = paste0(if_else(work == "Altered", "alt_", ""),
                          unname(type_short[building_type]), "_",
                          unname(measure_short[measure]))) %>%
  group_by(area, year, quarter, var) %>%
  summarise(total = sum(Data_value), months = n(), .groups = "drop")

dropped <- q_long %>% filter(months < 3) %>% distinct(year, quarter)
message("Incomplete quarters dropped: ",
        paste0(dropped$year, "-Q", dropped$quarter, collapse = ", "))

q_wide <- q_long %>%
  filter(months == 3) %>%
  pivot_wider(id_cols = c(area, year, quarter), names_from = var, values_from = total)
rm(df_ta, q_long); invisible(gc())

# ---- check: districts add up to Stats NZ's own national quarterly figure ---------
region_q_nz <- read_infoshare(f_region_q) %>%
  filter(Series_title_1 == "New Zealand", Series_title_2 == "Houses",
         Series_title_3 == "New", Series_title_4 == "Number",
         Series_title_5 == "Actual") %>%
  transmute(year = period_year(Period), quarter = period_quarter(Period),
            region_file = Data_value)

recon <- q_wide %>%
  group_by(year, quarter) %>%
  summarise(ta_sum = sum(houses_n), .groups = "drop") %>%
  inner_join(region_q_nz, by = c("year", "quarter"))
message("Reconciliation with the regional file: ", nrow(recon), " quarters, max abs difference = ",
        max(abs(recon$region_file - recon$ta_sum)))

# ---- 67 districts, unbroken run of quarters ----------------------------------------
district_quarters <- q_wide %>%
  filter(area != "Area Outside Territorial Authority") %>%
  mutate(qtr_index = year * 4L + quarter) %>%
  arrange(area, qtr_index)

gaps <- district_quarters %>% group_by(area) %>% summarise(ok = all(diff(qtr_index) == 1))
stopifnot("a district has a gap in its quarters" = all(gaps$ok))

saveRDS(district_quarters, derived_file("district_quarters.rds"))
message("Saved ", nrow(district_quarters), " district-quarters (",
        n_distinct(district_quarters$area), " districts) to ",
        derived_file("district_quarters.rds"))
