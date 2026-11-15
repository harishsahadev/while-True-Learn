# Building consents project (Stats NZ, August 2026 release)

Three questions on New Zealand building consents, 1990–2026. See
[Building Consents Project — Understanding the Dataset & Questions.md](Building%20Consents%20Project%20—%20Understanding%20the%20Dataset%20&%20Questions.md).

| Q | Question | File |
|---|---|---|
| 1 | What drives the real cost per m² of new houses? (regression) | `R/analysis/q1_regression.Rmd` |
| 2 | What kinds of building markets does NZ have? (clustering) | `R/analysis/q2_clustering.Rmd` |
| 3 | Will a district's consents rise next year? (classification) | `R/analysis/q3_classification.Rmd` |

Every input file, derived table and column is described in **[DATA_DICTIONARY.md](DATA_DICTIONARY.md)**.

---

## Linking the data (do this once per machine)

The data is **not** in the repo: it is too large, and each of us keeps it somewhere different.
Each person tells the project where their copy is, in a git-ignored `.Renviron` file.
All code then finds the files through `R/config.R`. Nobody edits a path inside an Rmd.

### 1. Download and unzip the data

Put everything in **one folder** (sub-folders are fine, because it is searched recursively), e.g. `.../Group 8 Project/Dataset/`.

| Download | From | Files needed |
|---|---|---|
| Building consents issued: August 2026 (CSV zip) | [Stats NZ release page](https://www.stats.govt.nz/information-releases/building-consents-issued-August-2026/) | `Building consents by territorial authority (Monthly).csv`, `Building consents by region (Quarterly).csv`, `New dwellings consented per 1000 residents by territorial authority (Annual).csv` |
| New dwellings consented by SA2: August 2026 (CSV zip) | same page | `New dwellings consented by 2026 statistical area 2 (Monthly).csv` |
| Business price indexes: June 2026 quarter (CSV) | [Stats NZ release page](https://www.stats.govt.nz/information-releases/business-price-indexes-june-2026-quarter/) | `business-price-indexes-june-2026-csv.csv` (the inflation deflators) |

The building consents zips use **bzip2** compression, which base R's `unzip()` cannot open.
Use 7-Zip (Windows), `unzip` (Linux/macOS), or your OS archive tool.

### 2. Point the project at the folder

```bash
cd building-consents
cp .Renviron.example .Renviron      # Windows: copy .Renviron.example .Renviron
```

Edit `.Renviron` so that it contains one line, with **your** path, using forward slashes and no quotes:

```
STAT462_DATA=/home/you/STAT462/Group 8 Project/Dataset
# Windows: STAT462_DATA=C:/Users/you/STAT462/Group 8 Project/Dataset
```

If `STAT462_DATA` is not set, `config.R` falls back to the group's standard layout: a `Dataset/` folder next to the `Repo/` folder (`Group 8 Project/Dataset`).

### 3. Check it

Open `building-consents.Rproj` in RStudio (this sets the working directory), then:

```r
source("R/scripts/01_check_data.R")
```

You should see `[ok]` next to all five files. If not, the error message says exactly what is missing and where the code looked.

---

## Running the pipeline

All scripts run from the `building-consents/` folder (opening the `.Rproj` does this for you).

| Step | Command | What it does | Output (in `<STAT462_DATA>/derived/`) |
|---|---|---|---|
| 1 | `source("R/scripts/01_check_data.R")` | finds every input file | — |
| 2 | `source("R/scripts/02_clean.R")` | monthly long format → district × quarter wide table; reconciles with Stats NZ national totals | `district_quarters.rds` |
| 3 | `source("R/scripts/03_features.R")` | features, CGPI deflation to real dollars, inflation features | `q1_frame.rds`, `q1_frame.csv`, `price_index.rds` |
| 4 | `source("R/scripts/04_q2_profiles.R")` | one profile row per district, 2015–2025 (type mix, real cost, alterations, growth, intensity) | `q2_profiles.rds`, `q2_profiles.csv` |
| 5 | `source("R/scripts/05_q3_frame.R")` | one row per district × year, label = consents rise next year | `q3_frame.rds`, `q3_frame.csv` |
| (any time after 1) | Knit `R/analysis/eda.Rmd` | exploratory analysis of all 13 tables + the price index (about 1 min) | `eda.html` next to the Rmd |
| 6 | Knit `R/analysis/q1_regression.Rmd` | Q1 analysis (about 7 min the first time; cached afterwards) | `q1_regression.html` next to the Rmd |
| 7 | Knit `R/analysis/q2_clustering.Rmd` | Q2 analysis (about 1 min) | `q2_clustering.html` next to the Rmd |
| 8 | Knit `R/analysis/q3_classification.Rmd` | Q3 analysis (about 1 min) | `q3_classification.html` next to the Rmd |

From a terminal instead: `Rscript R/scripts/02_clean.R` and so on.
To knit outside RStudio you need pandoc. If it is missing, point R at the copy bundled with RStudio, e.g. on Linux:
`export RSTUDIO_PANDOC=/usr/lib/rstudio/resources/app/bin/quarto/bin/tools/x86_64`.

### R packages

```r
install.packages(c("tidyverse", "knitr", "rmarkdown", "glmnet", "rpart", "rpart.plot",
                   "ranger", "gbm", "scales", "stringi", "cluster", "ggrepel"))
```

`config.R` stops with this exact command if anything is missing.

---

## How inflation is handled

Consent values are **nominal** and include GST. New-house $/m² rose about 4.4× from 1996 to 2026, but only about a third of that rise is real.

1. **Deflator.** Every quarter's $/m² is divided by the Capital Goods Price Index for residential buildings (`CEPQ.S61101`), so all dollars are June 2026 quarter dollars. This happens in `03_features.R`.
2. **Feature.** `cgpi_growth_lag1` is construction-cost inflation over the year to the *previous* quarter. It is known in advance, so it causes no leakage.
3. **Q2 profiles.** Each district's real $/m² is pooled from CGPI-deflated quarterly values, so districts that built mostly in the expensive 2022–25 years are not mistaken for high-cost markets.
4. **Q3 features.** Cost enters as CGPI-deflated `log_real_m2`, and construction-cost inflation (`cgpi_growth`) is a predictor.
5. **Sensitivity check.** Q1 is refitted with a second deflator, the residential construction producer price index (`PPIQ.SQUEE1120`), to show that the conclusions do not depend on the deflator.

## Project settings

Shared settings live at the bottom of `R/config.R`: `min_houses` (10), `train_end_year` (2019), `q2_years` (2015–2025), `q3_test_start` (2017) and `seed` (462). Change them there, never inside an Rmd, so that every question uses the same values.

## Layout

```
building-consents/
├── .Renviron.example     # template: copy to .Renviron (git-ignored) and set STAT462_DATA
├── DATA_DICTIONARY.md    # every input file, derived table and column
├── R/
│   ├── config.R          # paths, file names, package check, shared settings
│   ├── scripts/          # 01_check_data → 02_clean → 03_features → 04_q2_profiles → 05_q3_frame
│   └── analysis/         # q1 / q2 / q3 Rmds (+ eda.Rmd)
└── building-consents.Rproj
```
