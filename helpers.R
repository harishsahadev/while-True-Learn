# Shared helpers for the building-consents project (STAT462 A1, Group 8).
#
# These are the readers and small utilities first written in 01_EDA.Rmd, moved
# here so that every document in 04_Analysis/R/ uses one copy. Source this file
# from the setup chunk after library(tidyverse) and after `data_root` has been set:
#
#   library(tidyverse)
#   data_root <- Sys.getenv("STAT462_DATA", unset = "C:/Users/AndrewBoulton/stat462-data/raw")
#   source("helpers.R")
#
# Nothing here reads a file on its own or writes anything.

# column types for Stats NZ's long "Infoshare" CSV layout (14 columns)
infoshare_cols <- readr::cols(
  Series_reference = readr::col_character(),
  Period           = readr::col_character(),   # must stay text: 2025.10 read as a number is 2025.1
  Data_value       = readr::col_double(),
  Suppressed       = readr::col_character(),
  Status           = readr::col_character(),
  Units            = readr::col_character(),
  Magnitude        = readr::col_integer(),
  Subject          = readr::col_character(),
  Group            = readr::col_character(),
  Series_title_1   = readr::col_character(),
  Series_title_2   = readr::col_character(),
  Series_title_3   = readr::col_character(),
  Series_title_4   = readr::col_character(),
  Series_title_5   = readr::col_character()
)

# read one Infoshare-format CSV from data_root (looked up in the calling environment)
read_infoshare <- function(file) {
  readr::read_csv(file.path(data_root, file),
                  col_types = infoshare_cols,
                  na = c("", "NA"),
                  progress = FALSE)
}

# turn a "YYYY.MM" period into the first day of that month
period_to_date <- function(period) {
  as.Date(paste0(period, ".01"), format = "%Y.%m.%d")
}

# the calendar year and the quarter (1-4) of a "YYYY.MM" period
period_year <- function(period) {
  as.integer(substr(period, 1, 4))
}

period_quarter <- function(period) {
  (as.integer(substr(period, 6, 7)) - 1L) %/% 3L + 1L
}

# the "YYYY.MM" period of the last month of the quarter before (year, quarter)
previous_quarter_end <- function(year, quarter) {
  dplyr::if_else(quarter == 1L,
                 paste0(year - 1L, ".12"),
                 sprintf("%d.%02d", year, (quarter - 1L) * 3L))
}

# standard deviation of the trailing n values of x, NA until n values exist
rolling_sd <- function(x, n) {
  purrr::map_dbl(seq_along(x), function(i) {
    if (i < n) NA_real_ else stats::sd(x[(i - n + 1):i])
  })
}

# compact profile of an Infoshare table, one row per fact
profile_infoshare <- function(df) {
  tibble::tibble(
    rows           = nrow(df),
    series         = dplyr::n_distinct(df$Series_reference),
    first_period   = min(df$Period),
    last_period    = max(df$Period),
    periods        = dplyr::n_distinct(df$Period),
    areas          = dplyr::n_distinct(df$Series_title_1, na.rm = TRUE),
    building_types = dplyr::n_distinct(df$Series_title_2, na.rm = TRUE),
    work_types     = dplyr::n_distinct(df$Series_title_3, na.rm = TRUE),
    measures       = dplyr::n_distinct(df$Series_title_4, na.rm = TRUE),
    adjustments    = dplyr::n_distinct(df$Series_title_5, na.rm = TRUE),
    status         = paste(sort(unique(df$Status)), collapse = ", "),
    suppressed     = paste(sort(unique(df$Suppressed)), collapse = ", "),
    units          = paste(sort(unique(df$Units)), collapse = ", "),
    missing_values = sum(is.na(df$Data_value))
  ) %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) %>%
    tidyr::pivot_longer(dplyr::everything(), names_to = "item", values_to = "value")
}
