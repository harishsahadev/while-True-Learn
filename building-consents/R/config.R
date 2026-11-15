# =============================================================================
# config.R: the ONE place that knows where the data lives.
#
# Every script and Rmd starts with
#     source("R/config.R")        # scripts, run from building-consents/
#     source("../config.R")       # Rmds in R/analysis/
# and then uses `data_file(...)`, `derived_dir`, and the f_* file names below.
# Nothing else in the project should contain a path to the data.
#
# Set-up for a new machine: see building-consents/README.md, "Linking the data".
# =============================================================================

# ---- project root: the folder holding building-consents.Rproj -------------
find_project_root <- function(start = getwd()) {
  dir <- normalizePath(start, winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(dir, "building-consents.Rproj"))) return(dir)
    parent <- dirname(dir)
    if (parent == dir) {
      stop("Could not find building-consents.Rproj above ", start,
           ".\nOpen building-consents.Rproj in RStudio, or setwd() into building-consents/.",
           call. = FALSE)
    }
    dir <- parent
  }
}
project_root <- find_project_root()

# ---- read the local .Renviron (git-ignored) --------------------------------
# R reads .Renviron only at start-up and only from the start-up folder, so it is
# read again here. That makes knitting and Rscript behave the same as RStudio.
local_renviron <- file.path(project_root, ".Renviron")
if (file.exists(local_renviron)) readRenviron(local_renviron)

# ---- data folder ------------------------------------------------------------
# 1st choice: STAT462_DATA. Fallback: the group's shared layout, where the
# Dataset folder sits next to the Repo folder (Group 8 Project/Dataset).
fallback_data <- file.path(project_root, "..", "..", "..", "Dataset")
data_root <- Sys.getenv("STAT462_DATA", unset = "")
if (!nzchar(data_root)) data_root <- fallback_data

if (!dir.exists(data_root)) {
  stop("\nData folder not found: ", data_root, "\n\n",
       "Fix: copy building-consents/.Renviron.example to building-consents/.Renviron\n",
       "and set STAT462_DATA to the folder holding the Stats NZ CSVs.\n",
       "See building-consents/README.md, 'Linking the data'.", call. = FALSE)
}
data_root <- normalizePath(data_root, winslash = "/")

# cleaned tables go outside the repo, so no data is ever committed
derived_dir <- Sys.getenv("STAT462_DERIVED", unset = file.path(data_root, "derived"))
dir.create(derived_dir, showWarnings = FALSE, recursive = TRUE)
derived_dir <- normalizePath(derived_dir, winslash = "/")

# ---- the files the project uses -------------------------------------------
f_ta         <- "Building consents by territorial authority (Monthly).csv"
f_region_q   <- "Building consents by region (Quarterly).csv"
f_per1000_ta <- "New dwellings consented per 1000 residents by territorial authority (Annual).csv"
f_sa2_2026   <- "New dwellings consented by 2026 statistical area 2 (Monthly).csv"
f_prices     <- "business-price-indexes-june-2026-csv.csv"   # CGPI / PPI deflators

required_files <- c(f_ta, f_region_q, f_per1000_ta, f_sa2_2026, f_prices)

# search STAT462_DATA recursively once, so any sub-folder layout works
.all_data_files <- list.files(data_root, recursive = TRUE, full.names = TRUE)

# full path of one data file, by its Stats NZ file name
data_file <- function(name) {
  hits <- .all_data_files[basename(.all_data_files) == name]
  if (length(hits) == 0) {
    stop("'", name, "' not found anywhere under ", data_root,
         "\nDownload and unzip it there (see README.md, 'Linking the data').", call. = FALSE)
  }
  hits[1]
}

# derived (cleaned) tables
derived_file <- function(name) file.path(derived_dir, name)

check_data <- function(verbose = TRUE) {
  found <- vapply(required_files,
                  function(f) any(basename(.all_data_files) == f), logical(1))
  if (verbose) {
    message("Data folder:    ", data_root)
    message("Derived folder: ", derived_dir)
    for (f in required_files) message(if (found[[f]]) "  [ok]      " else "  [MISSING] ", f)
  }
  invisible(all(found))
}

# ---- packages ----------------------------------------------------------------
required_packages <- c("tidyverse", "knitr", "rmarkdown", "glmnet", "rpart", "rpart.plot",
                       "ranger", "gbm", "scales", "stringi", "cluster", "ggrepel")
missing_pkgs <- required_packages[!vapply(required_packages, requireNamespace,
                                          logical(1), quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  stop("Missing R packages. Run once:\n  install.packages(c(",
       paste0('"', missing_pkgs, '"', collapse = ", "), "))", call. = FALSE)
}
rm(missing_pkgs)

# ---- project-wide settings -----------------------------------------------------
seed           <- 462
min_houses     <- 10     # min new houses in a district-quarter for its $/m² to count
train_end_year <- 2019   # train <= 2019, test 2020 onwards
q2_years       <- 2015:2025   # Q2: window the district profiles are built from
q3_test_start  <- 2017        # Q3: feature years >= this are test (labels 2018-2025)
