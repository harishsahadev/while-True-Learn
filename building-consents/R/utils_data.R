# =============================================================================
# R/utils_data.R
# Shared helpers for reading and reshaping Stats NZ data.
# Source this from any Rmd after the project root has been set:
#   source(file.path(proj_root, "R", "utils_data.R"))
# =============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(tidyverse)
})

# ---- Paths (all relative to the project root) -------------------------------
paths <- list(
  raw_extracted = "data/raw/extracted",
  raw_cgpi      = "data/raw/external/cgpi",
  reference     = "data/reference",
  processed     = "data/processed",
  fig_rq1       = "outputs/figures/rq1",
  tab_rq1       = "outputs/tables/rq1"
)

# ---- Reading Stats NZ "Infoshare" long-format CSVs --------------------------
# Every Infoshare file has one row per (series x period). We read only the
# columns that carry information and give them short working names.
#
# Notes
# * `Period` MUST be read as text: as a number, "2025.10" becomes 2025.1,
#   which is indistinguishable from January.
# * integer64 is turned off so that large dollar values come back as doubles
#   (integer64 silently overflows on division).
read_infoshare <- function(file,
                           dir = paths$raw_extracted,
                           keep_status = FALSE) {
  cols <- c("Series_reference", "Period", "Data_value",
            "Series_title_1", "Series_title_2",
            "Series_title_3", "Series_title_4", "Series_title_5")
  if (keep_status) cols <- c(cols, "Status")

  dt <- fread(file.path(dir, file),
              select      = cols,
              colClasses  = list(character = "Period"),
              integer64   = "double",
              na.strings  = c("", "NA"),
              showProgress = FALSE)

  as_tibble(dt) |>
    rename(series  = Series_reference,
           period  = Period,
           value   = Data_value,
           area    = Series_title_1,
           btype   = Series_title_2,
           work    = Series_title_3,
           measure = Series_title_4,
           adjust  = Series_title_5)   # Actual / Seasonally adjusted / Trend (regional files only)
}

# ---- Period helpers ----------------------------------------------------------
# "YYYY.MM" -> integer year / month / calendar quarter
period_year    <- function(p) as.integer(substr(p, 1, 4))
period_month   <- function(p) as.integer(substr(p, 6, 7))
month_quarter  <- function(m) (m - 1L) %/% 3L + 1L

# Label like "2019Q3"
yq_label <- function(year, quarter) paste0(year, "Q", quarter)

# Sequential quarter index (1990Q1 = 1) - handy as a numeric time trend
yq_index <- function(year, quarter) (year - 1990L) * 4L + quarter

# ---- GST ---------------------------------------------------------------------
# Consent values are GST-inclusive. GST was 12.5% from 1 Jul 1989 to
# 30 Sep 2010 and 15% from 1 Oct 2010. Every month in our data is >= 1990,
# so only these two rates apply. Quarter boundaries line up with the change
# (2010Q4 starts on 1 Oct 2010), so a quarter-level rule is exact.
gst_rate <- function(year, quarter) {
  if_else(yq_index(year, quarter) >= yq_index(2010L, 4L), 0.15, 0.125)
}

# ---- Small display helpers ---------------------------------------------------
fmt_int <- function(x) format(round(x), big.mark = ",", scientific = FALSE)
fmt_dol <- function(x) paste0("$", fmt_int(x))
fmt_pct <- function(x, d = 1) paste0(format(round(100 * x, d), nsmall = d), "%")

# ---- Figures -----------------------------------------------------------------
theme_set(theme_minimal(base_size = 11) +
            theme(plot.title.position = "plot",
                  panel.grid.minor = element_blank()))

# Save a ggplot as PNG (for the report) and return it (so it also shows in the Rmd)
save_fig <- function(p, name, dir = paths$fig_rq1, width = 7, height = 4.2) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  ggsave(file.path(dir, paste0(name, ".png")), p,
         width = width, height = height, dpi = 200, bg = "white")
  p
}

# Save a table as CSV (for the report) and return it
save_tab <- function(df, name, dir = paths$tab_rq1) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  write_csv(df, file.path(dir, paste0(name, ".csv")))
  df
}
