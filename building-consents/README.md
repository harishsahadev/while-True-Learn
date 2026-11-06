# Building Consents: STAT462 Group Project (Group 8, *while True: learn()*)

Niwesh Baraj, Andrew Boulton, Harish Sahadev M

Machine-learning analysis of Stats NZ *Building consents issued: August 2026*.

| RQ | Question | Methods | Status |
|---|---|---|---|
| 1 | What drives the **real cost per m²** of new houses across districts? | Linear, polynomial, ridge/lasso/elastic net, GAM, tree, random forest, XGBoost, SVM | Done (Steps 1–4) |
| 2 | What kinds of **building markets** does NZ have? | k-means vs hierarchical clustering | Not started |
| 3 | Will a district's consents **rise or fall** next year? | Logistic regression, LDA, classification tree | Not started |

## Project layout

```
Building-Consents-Project/
├── README.md
├── Building-Consents-Project.Rproj      open this in RStudio
├── Building Consents Project — Understanding the Dataset & Questions.md   (in the group repo) guide to the data and the three questions
├── R/
│   ├── utils_data.R                     helpers: reading Stats NZ CSVs, periods, GST, saving figures/tables
│   └── utils_models.R                   helpers: metrics, time-ordered CV folds, generic tuner
├── data/
│   ├── raw/                             not in the repository (1.5 GB); see data/raw/README.md
│   ├── reference/ta_region_concordance.csv   67 districts → region / island
│   └── processed/                       model-ready data written by Step 1
├── analysis/
│   ├── rq1_cost_per_m2/
│   │   ├── 01_rq1_data_preparation.Rmd  Step 1: check, clean, build features, save
│   │   ├── 02_rq1_eda.Rmd               Step 2: exploratory analysis, decisions for modelling
│   │   ├── 03_rq1_models.Rmd            Step 3: tune and compare 11 models, test once, importance
│   │   └── 04_rq1_interpretation.Rmd    Step 4: partial dependence, errors, answer to RQ1
│   ├── rq2_clustering/
│   └── rq3_rise_fall/
├── outputs/
│   ├── figures/rq1/                     PNGs used by the report (fig01–fig28)
│   ├── tables/rq1/                      CSVs used by the report (t01–t14)
│   └── models/rq1/                      Step 3 results and the final fitted models
└── report/
    ├── group_report.Rmd                 knits to group_report.docx
    └── group_report.docx
```

Each notebook's knitted `.html` is kept next to it, so results can be read without running anything.

## How to run

1. Open `Building-Consents-Project.Rproj` in RStudio.
2. Install packages once:

   ```r
   install.packages(c("tidyverse", "data.table", "knitr", "rmarkdown",
                      "glmnet", "ranger", "rpart.plot", "xgboost", "e1071"))
   ```

   (`rpart` and `mgcv` come with R. The code uses the xgboost 3.x interface.)
3. Knit in order:
   1. `01_rq1_data_preparation.Rmd` needs the raw data (see `data/raw/README.md`). Skip it if you only want to
      re-run the models: its outputs are already in `data/processed/`.
   2. `02_rq1_eda.Rmd`
   3. `03_rq1_models.Rmd`: about 15 minutes the first time; slow chunks are then cached
      (`03_rq1_models_cache/`, delete it to force a full re-run).
   4. `04_rq1_interpretation.Rmd`: about 1 minute.
   5. `report/group_report.Rmd` → `report/group_report.docx`.

Notebooks find the project root themselves, so they knit from any working directory.

## Data sources

* Stats NZ, *Building consents issued: August 2026*, CC BY 4.0.
  <https://www.stats.govt.nz/information-releases/building-consents-issued-august-2026>
* Stats NZ, *Business price indexes: June 2026 quarter*, CC BY 4.0. CGPI series `CEPQ.S611011A` (dwelling units),
  `CEPQ.S61101` (residential), `CEPQ.S61102` (non-residential).
  <https://www.stats.govt.nz/information-releases/business-price-indexes-june-2026-quarter/>

## Key decisions (RQ1)

1. Unit: district × quarter, complete quarters 1990Q2–2026Q2 (67 × 145 = 9,715 rows).
2. Response: real $/m² of new houses = value ÷ floor area, GST of the day removed, CGPI-deflated to June-2026 $,
   15% GST re-applied, modelled as a log. Main response from Step 2 on: **relative cost** = log(district real $/m²)
   − log(real $/m² of all other districts in the same quarter).
3. Rows with fewer than 5 new houses are kept in the file but excluded from modelling (8,662 modelled rows).
4. No predictors derived from house value (leakage).
5. Chronological split: train ≤ 2019, test 2020–2026Q2. Models train on 1996–2019 so that every predictor is
   available; Chatham Islands and Kawerau are dropped from modelling (1–2 rows each).
6. Lagged cost excluded from the main (explanatory) models; island and season dropped (no signal).
7. Models are tuned by forward-chaining CV (validation blocks 2012–13, 14–15, 16–17, 18–19) and chosen with the
   one-standard-error rule, on two feature sets (drivers only; drivers + district). The test set is used once.
8. Chosen models: random forest (drivers set) and ridge regression (district set). Both are refitted on all
   1996–2026Q2 rows and saved in `outputs/models/rq1/rq1_final_models.rds`.

## RQ1 result in one paragraph

Location matters most. Of the measured drivers, residential alteration spending (a sign of a wealthy, busy market)
has the largest effect (+8% to +11% from a low to a high value), followed by population growth, especially in the
fastest-growing places. Districts that build many houses are cheaper per m² for the same alteration spending, but
any district is dearer in its own busy quarters. The drivers explain about a fifth of the differences between
districts. With the district included, ridge regression predicts 2020–2026 costs within about 8% (MAPE).
