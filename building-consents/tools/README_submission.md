# What New Zealand builds, where, and at what cost

**STAT462 Data Mining, Assessment 1 (group project): supplementary materials**
Group 8, *while True: learn()*: Niwesh Baraj, Andrew Boulton, Harish Sahadev M

We analyse 36 years of Stats NZ building-consent data (the *Building consents issued: August 2026* release) to
answer three questions, one for each family of methods in the course: regression, clustering and classification.
The analysis is in R Markdown notebooks, each included with its knitted HTML. The full write-up is in
`report/group_report.pdf`.

**Interactive app:** <https://niwesh.shinyapps.io/nz-building-consents/> (it may take up to 30 seconds to wake up).

---

## Research questions and findings

| | Question | Methods | Finding |
|---|---|---|---|
| **RQ1** | What drives the **real cost per m²** of new houses across districts? | Baselines, linear and polynomial regression, ridge / lasso / elastic net, GAM, regression tree, random forest, XGBoost, SVM | Location matters most. Renovation spending (+8% to +11%) and fast growth raise cost; the measured drivers explain about 15% of the gap between districts. Linear regression with the district predicts 2020–2026 within 7.9% (MAPE). |
| **RQ2** | What kinds of **building markets** does New Zealand have? | k-means and hierarchical clustering (four linkages); five criteria for *k*; bootstrap stability | Three markets: house-building districts (30), slow provincial districts (21) and urban medium-density markets (15). The two methods agree on 60 of 66 districts, but the separation is weak: a summary of a continuum. |
| **RQ3** | Will a district's consents **rise or fall** next year? | Baselines, logistic regression, lasso, LDA, QDA, classification tree, KNN, random forest | Only modestly predictable: logistic regression is right 58% of the time (AUC 0.63), against 53% for the best simple rule. Districts follow the national cycle. |

How results were obtained: chronological train/test splits, forward-chaining cross-validation within the training
years, a single use of each test set, and the one-standard-error rule to pick the simplest adequate model.

---

## Contents

```
Building-Consents-Project/
├── README.md                          this file
├── Building-Consents-Project.Rproj    open in RStudio
│
├── analysis/                          the R Markdown notebooks, each with its knitted .html
│   ├── rq1_cost_per_m2/
│   │   ├── 01_rq1_data_preparation.Rmd   raw Stats NZ tables → district × quarter table, real dollars
│   │   ├── 02_rq1_eda.Rmd                exploratory analysis and modelling decisions
│   │   ├── 03_rq1_models.Rmd             11 models, two feature sets, tuning, test, importance
│   │   └── 04_rq1_interpretation.Rmd     partial dependence, location premium, error analysis
│   ├── rq2_clustering/
│   │   ├── 01_rq2_district_features.Rmd  one profile per district, transforms, VIF, PCA
│   │   └── 02_rq2_clustering.Rmd         k-means vs hierarchical, choosing k, profiles, robustness
│   └── rq3_rise_fall/
│       ├── 01_rq3_district_year.Rmd      district × year table, label, features
│       └── 02_rq3_models.Rmd             classifiers, test, odds ratios, year-by-year errors
│
├── R/                                 shared helper functions (printed in each notebook's appendix)
│   ├── utils_data.R                   reading Stats NZ files, periods, GST, saving figures and tables
│   ├── utils_models.R                 regression metrics, time-ordered CV folds, generic tuner
│   ├── utils_cluster.R                VIF, adjusted Rand index, Calinski–Harabasz, bootstrap stability
│   └── utils_classify.R               AUC, classification metrics, ROC, classifier tuner
│
├── outputs/
│   ├── figures/rq1|rq2|rq3/           all figures made by the notebooks (PNG)
│   └── tables/rq1|rq2|rq3/            all results tables (CSV): model scores, tuning, cluster profiles, odds ratios
│
├── report/group_report.pdf            the group report (numbered figures, appendices)
└── docs/data_dictionary.md            every column of every processed table
```

---

## Data

The data are **not** included, as the assessment brief asks. Both sources are free to download from Stats NZ.

| Source | Use | Licence |
|---|---|---|
| Stats NZ, [*Building consents issued: August 2026*](https://www.stats.govt.nz/information-releases/building-consents-issued-august-2026) (13 CSV tables, 10.4 million rows) | All three questions | CC BY 4.0 |
| Stats NZ, [*Business price indexes: June 2026 quarter*](https://www.stats.govt.nz/information-releases/business-price-indexes-june-2026-quarter/) (Capital Goods Price Index) | Converting dollars to real June-2026 dollars | CC BY 4.0 |
| District → region lookup (67 districts → 16 regions), compiled by the group | Region and island of each district | available on request |

To reproduce the analysis, create a `data/` folder in the project and place the files like this:

```
data/
├── raw/
│   ├── extracted/      the CSV files from the building consents zip (e.g. "Building consents by
│   │                   territorial authority (Monthly).csv"), unzipped as they are
│   └── external/cgpi/  business-price-indexes-june-2026-csv.csv from the business price indexes release
├── reference/          ta_region_concordance.csv (the district → region lookup)
└── processed/          empty; the notebooks write their tables here
```

All column definitions are in `docs/data_dictionary.md`.

---

## How to reproduce

1. Install R (4.3 or later) and RStudio, then the packages, once:

   ```r
   install.packages(c("tidyverse", "data.table", "knitr", "rmarkdown", "bookdown",
                      "glmnet", "ranger", "rpart.plot", "xgboost", "e1071"))
   # rpart, mgcv, cluster, MASS and class come with R; xgboost must be version 3.x
   ```

2. Open `Building-Consents-Project.Rproj` and knit the notebooks **in this order**. Each writes the files the next
   one reads, and each finds the project folder by itself.

   | Order | Notebook | Run time | Writes |
   |---|---|---|---|
   | 1 | `analysis/rq1_cost_per_m2/01_rq1_data_preparation.Rmd` | ~15 s (needs raw data) | `data/processed/rq1_*` |
   | 2 | `analysis/rq1_cost_per_m2/02_rq1_eda.Rmd` | ~10 s | RQ1 figures 6–14 |
   | 3 | `analysis/rq1_cost_per_m2/03_rq1_models.Rmd` | ~15 min first time, then cached | RQ1 results |
   | 4 | `analysis/rq1_cost_per_m2/04_rq1_interpretation.Rmd` | ~1 min | final RQ1 models |
   | 5 | `analysis/rq2_clustering/01_…`, then `02_…` | < 1 min | RQ2 results |
   | 6 | `analysis/rq3_rise_fall/01_…`, then `02_…` | < 1 min | RQ3 results |

   Slow chunks are cached in `*_cache/` folders; delete a folder to force a full re-run. Saved models are written to
   `outputs/models/` (not included, because they contain processed data rows).

---

## Key decisions

* **RQ1 response:** each district's cost *relative to the rest of NZ in the same quarter*, because raw real cost
  mostly tracks the national price level (time explains 41% of its variation).
* **No leakage:** no feature is built from house value, and every RQ3 feature is known at the end of the year it
  describes.
* **Small counts:** district-quarters with fewer than 5 new houses are not modelled; the Chatham Islands (and, for
  RQ1, Kawerau) are excluded for having too few rows.
* **Validation:** train on the past, test once on the most recent years (RQ1: 2020–2026; RQ3: outcomes 2018–2025);
  tune by forward-chaining cross-validation; choose the simplest model within one standard error of the best.
* **RQ2 features:** size left out (so clusters describe how markets work, not how big they are); skewed features
  transformed; redundant features dropped by variance inflation factor.

Details and the reasoning behind each choice are in the notebooks' text and in the report.

---

## Use of AI

We used Claude (Anthropic) to help write and debug R code, explain methods, structure the documents, and edit
writing. All analysis decisions were made, and all results checked, by the group. This is also acknowledged in the
report, the poster and the slides.

## Licence and citation

Code: for assessment use by the authors. Data: © Stats NZ, licensed under CC BY 4.0. Cite the data as:
Stats NZ. (2026). *Building consents issued: August 2026* [Data set]. https://www.stats.govt.nz/
