# RQ1 — course-style replication (Boulton)

STAT462 Group 8, *while True: learn()*. An independent build of research question 1 —
*what drives the real cost per m² of new houses across districts?* — written in the
style of the course lab notebooks, using the course packages, on the group's processed
dataset. It exists so the group has two builds of the same question that can be
checked against each other (section 6.4 of the notebook does that against Niwesh's
`t09_test_results.csv`).

## What is here

| File | What it is |
|---|---|
| `03_RQ1.Rmd` | The notebook. Knit it to reproduce everything. |
| `03_RQ1.html` | The knitted output, so the results can be read without running anything. |
| `data/rq1_model_data.csv` | The modelling table (8,662 district-quarters × 43 columns), copied unchanged from `building-consents/data/processed/` on branch `niwesh`. Built by Niwesh's `01_rq1_data_preparation.Rmd`. |
| `data/rq1_data_dictionary.csv` | Column definitions for the table above (same source). |
| `data/t09_test_results.csv` | Niwesh's test-set results, copied from `building-consents/outputs/tables/rq1/`, used for the comparison in section 6.4. The notebook skips that section if the file is missing. |
| `RQ1_Roadmap.md` | The plan this was built to, with decisions and open questions. |

No raw Stats NZ data is needed: the notebook starts from the processed CSV.

## How to run

1. Install the packages once:

   ```r
   install.packages(c("tidyverse", "GGally", "gridExtra", "leaps",
                      "glmnet", "tree", "randomForest", "gbm"))
   ```

   `MASS` ships with R. Every package except `glmnet` is one the course labs use;
   `glmnet` is the ISLR2 §6.5 ridge/lasso recipe.

2. Open `03_RQ1.Rmd` in RStudio and knit. The notebook reads its data from the `data/`
   folder next to it, so keep the two together. To point it somewhere else, set the
   environment variable `STAT462_RQ1_DATA` to the folder holding the three CSVs (one
   line in `.Renviron`), or edit the `data_root` line in the setup chunk.

3. First knit takes a few minutes: the two tuning chunks (`tune-rf`, `tune-gbm`) fit
   about 50 forests and boosted models on blocked cross-validation folds. They are
   cached, so later knits take about a minute. Delete `03_RQ1_cache/` to force a full
   re-run.

The project seed is `set.seed(462)`, set in the setup chunk and again immediately
before every chunk that draws random numbers, so a full knit reproduces the figures
exactly.

## What the notebook does

Sections follow the course lab template: set up → first impression → one section per
method → evaluate performance.

1. **Set up** — reads the table, builds the modelling frame (two responses, eleven
   count-based drivers, `region`, `ta`), splits by time (train to 2019Q4, test
   2020Q1–2026Q2 using the `split` column).
2. **First impression** — response distributions, district ranking, variance explained
   by district / region / year alone, driver correlations.
3. **Linear regression** — simple regression by hand and by `lm()`, multiple regression
   on the drivers, with district fixed effects, forward selection (`leaps`), two
   transformations.
4. **Ridge and lasso** — `glmnet` with time-block cross-validation folds, coefficient
   paths, which drivers survive, with and without region dummies.
5. **Tree-based models** — regression tree with CV pruning, bagging, random forest,
   boosting; then a small tuning grid for the forest, boosting and the elastic net on
   the same folds.
6. **Evaluate performance** — sensitivity to the early-years drivers, training fit,
   test RMSE for every model, comparison with Niwesh's build, three importance rankings
   side by side, bootstrap standard errors, the real-dollar response, and the answer to
   RQ1.

## Headline result (test years 2020–2026, relative cost response)

Models that carry geography — bagging, random forest, tuned boosting (test RMSE
0.106–0.107), the district-effects regression (0.109) — beat anything with only the
eleven drivers (0.121–0.129); within a band the algorithm barely matters. Of the
measured drivers, residential alteration spending and new dwellings per 1,000
residents are the two that every model ranks first. Full tables in section 6 of the
notebook.

## Known open point

Our drivers-only linear regression tests at 0.1202 RMSE on Niwesh's 1,608 test rows
against his 0.1162 for the same model. The difference is upstream of the model
(columns, transformations or rows fed to `lm()`) and is being resolved with him before
either number is quoted.

## Data source

Stats NZ, *Building consents issued: August 2026* (CC BY 4.0), deflated with the
Capital Goods Price Index, *Business price indexes: June 2026 quarter*. See the data
dictionary and Niwesh's `01_rq1_data_preparation.Rmd` for how the table was built.
