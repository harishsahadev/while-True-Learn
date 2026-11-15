# =============================================================================
# 01_check_data.R: confirm every input file is where config.R expects it.
# Run from building-consents/:   Rscript R/scripts/01_check_data.R
#
# Sources (download, unzip anywhere under STAT462_DATA):
#   * Building consents issued: August 2026 (2 zips: main CSVs + SA2 CSVs)
#     https://www.stats.govt.nz/information-releases/building-consents-issued-August-2026/
#   * Business price indexes: June 2026 quarter (CSV, holds the CGPI deflator)
#     https://www.stats.govt.nz/information-releases/business-price-indexes-june-2026-quarter/
# The building consents zips use bzip2 compression: base R's unzip() cannot
# read them. Use 7-Zip, `unzip` (Linux/macOS), or your OS's archive tool.
# =============================================================================

source("R/config.R")

if (check_data()) {
  message("\nAll input files found. Next: Rscript R/scripts/02_clean.R")
} else {
  stop("Some files are missing (see above). Download/unzip them under STAT462_DATA.",
       call. = FALSE)
}
