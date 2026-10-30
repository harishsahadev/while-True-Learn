# Building Consents Project — Understanding the Dataset & Questions

## 1. What this dataset is

The dataset counts every building consent issued in New Zealand, every month since 1990, broken down by place and building type. A building consent is council permission to build; it is issued before construction starts, so it is a leading indicator of what will be built.

Every council (a "building consent authority") reports each consent it issues that is worth $5,000 or more. Stats NZ adds them up and publishes three measures for every place × building type × month:

- **Number** — how many consents (for dwellings: how many new homes).
- **Value** — the declared $ value of the building work, GST included, excluding land.
- **Floor area** — square metres (m²) of building consented.

**What one row means.** The raw CSVs are in *long* format: one row = one series × one month. A *series* is one combination of place + building type + new/alteration + measure, identified by `Series_reference` (for example `BLDM.SY0701110A1` = Queenstown-Lakes, new houses, Number). So a single month of Queenstown new houses is spread over three rows (Number, Dollars, SQM). Before any modelling you must *pivot* these into wide format: one row per district × period, with columns `n_houses`, `value`, `floor_area`.

**What it is not.** It is not a list of individual consents or buildings. It has no house prices, no land prices, no buyer information. Every number is an aggregate.

**Release used.** *Building consents issued: August 2026*, published 1 October 2026, covering data up to August 2026. The data starts April 1990 (Jan 1990–Aug 2026 would be 440 months; the slide's 437 months = Apr 1990–Aug 2026).

## 2. "What New Zealand builds, where, and at what cost"

The data is big, official and needs real preparation. Every number on it can be re-derived, which is a good first exercise.

| Slide element | What it means | What you should take from it |
| --- | --- | --- |
| **4.35M rows** in the district file; 10.4M across 13 CSVs | The release ZIP holds 13 CSV files. The one we mainly use is *Building consents by territorial authority (Monthly)*, 4,348,384 rows × 14 columns. | Too many rows to eyeball. Read it with `readr`/`data.table`, then filter to the series you need before pivoting. |
| **9,715 district-quarters**: 7,973 train (to 2019), 1,742 test (2020–26) | After pivoting and aggregating months to quarters: 67 districts × 145 quarters = 9,715. Test = 67 × 26 quarters (2020 Q1–2026 Q2) = 1,742. Train = 67 × 119 quarters (1990 Q2–2019 Q4) = 7,973. | This is the modelling table for Question 1. The split is by **time**, not random. 2026 Q3 is dropped because only Jul–Aug exist. |
| **1.05M small-area months**: 2,396 SA2s × 437 months | A second file gives new dwellings by Statistical Area 2 (suburb-sized areas). 2,396 × 437 ≈ 1.05M. | Optional extra detail (maps, finer clustering). Not needed for the three core questions. |
| **Origin** | Stats NZ official statistics, every consent ≥ $5,000, monthly, open licence CC BY 4.0, August 2026 release. | Cite Stats NZ in the report; the licence lets us reuse and publish. |
| **Table preview** (8 of 14 columns) | Columns: `Series_reference`, `Period`, `Data_value`, `Units`, `Series_title_1`–`_4`. `Period` `2026.07` = July 2026. Title 1 = district, 2 = building type, 3 = New/Alteration, 4 = measure. | This is the long format. Each month needs three rows (Number, Dollars, SQM) to compute one $/m². |
| **Reading one month** | Queenstown-Lakes, Aug 2026: $53,693,539 ÷ 13,139 m² = **$4,087 per m²**; 13,139 m² ÷ 65 houses = **202 m² per house**. | These two ratios are *derived features*. $/m² is the target for Question 1. |
| **Key features** | *Where*: 67 districts, region, Auckland local board, SA2. *What*: 26 nested building types × new/alteration. *Measure*: count, $ (GST incl.), m². *Derived*: $/m², m²/house, growth, multi-unit share, CGPI-real $. | "Nested" means types sit inside each other (Houses ⊂ New dwellings ⊂ Residential ⊂ All buildings). Never sum across levels or you double count. |

The slide's main message: the raw data is a tidy official source, but every useful variable (ratios, real dollars, growth) must be built by us.

## 3. "Why this dataset, and what we want to find out"

There is a real pattern worth modelling (cost per m² differs a lot by district) and states the three questions, each tied to a different family of methods from the course.

**The bar chart.** New-house cost per m² in 2025 for the 5 most and 5 least expensive districts, among the 47 districts that consented at least 50 new houses (small districts are excluded because a few houses give a noisy ratio). Queenstown-Lakes is $4,516/m², Selwyn $2,593/m²: 4,516 ÷ 2,593 = 1.74, hence "1.7×". The national figure is $3,226/m². The takeaway: *location matters*, which motivates Question 1.

**Why we chose it.** Every council, monthly since 1990; continuous targets (cost) and natural classes (rise/fall), so regression, classification and clustering all fit; real cleaning work (long → wide, nested types, inflation); and an audience understands housing costs.

**The two headline facts.**

- **×4.7 → +14%**: nominal NZ new-house $/m² rose 4.7-fold from 1991 to 2025, but after removing construction price inflation (CGPI deflation) the real rise is only 14%. Lesson: *most of the raw increase is inflation*, so Question 1 must model **real** dollars, otherwise the model just learns "later years cost more".
- **29% → 55%**: the share of new dwellings that are multi-unit homes (townhouses, flats, apartments, retirement units) went from 29% (1991) to 55% (2025). Lesson: the *type mix* changed a lot, a good feature for both clustering and cost.

**The three research questions** (detailed in section 4):

| # | Question | Task type | Unit (one row) | Models to compare | Size |
| --- | --- | --- | --- | --- | --- |
| 1 | What drives the real cost per m² of new houses across districts? | Regression | district × quarter | Linear, lasso, regression tree, random forest | 7,973 train / 1,742 test |
| 2 | What kinds of building markets does New Zealand have? | Clustering (unsupervised) | district | k-means, hierarchical | 67 districts |
| 3 | Will a district's consents rise or fall next year? | Binary classification | district × year | Logistic regression, LDA, classification tree | 1,742 train / 536 test; 51% "rising" |

Note: 1,742 appears twice by coincidence (67 × 26). In Q1 it is test *quarters*; in Q3 it is train *years* (67 × 26 years), and 536 = 67 × 8 test years.

## 4. The three ML problems, spelled out

Each question is a separate supervised or unsupervised problem with its own modelling table. All three are built from the same cleaned, wide district data.

### Question 1 — Regression: real cost per m² of new houses

**Label (y):** real $/m² of new houses in district *d*, quarter *q*:

$$
y_{d,q} = \frac{\sum_{m \in q} \text{Value}_{d,m}}{\sum_{m \in q} \text{FloorArea}_{d,m}} \times \frac{1000}{\text{CGPI}_q}
$$

Sum value and floor area over the 3 months first, then divide (not an average of monthly ratios). Dividing by the CGPI residential-buildings index turns nominal dollars into constant-price dollars. Consider modelling log(y) because costs are right-skewed.

**Candidate features (X):** district and region (categorical), year / time trend, quarter (seasonality), number of new houses consented (market size), average m² per house, multi-unit share of new dwellings, recent growth in consents, lagged $/m² (last quarter or last year).

**Leakage warning:** never use that quarter's `Value` as a feature; it is part of the label. Lagged values are fine.

**Split:** train 1990 Q2–2019 Q4, test 2020 Q1–2026 Q2. For tuning (lasso λ, tree depth, RF mtry), use time-ordered CV inside the training years, not random k-fold.

**Models:** multiple linear regression (`lm`), lasso (`glmnet`, α = 1), regression tree (`rpart`), random forest (`randomForest` or `ranger`). Always also report a **naïve baseline**: "predict last quarter's value for that district".

**Metrics:** test RMSE and MAE (in $/m²), R². Interpret: lasso coefficients, tree splits, RF variable importance answer "what *drives* cost".

**Data quality:** quarters with very few houses (or zero floor area) give unstable ratios. Decide a rule, e.g. drop district-quarters with < 5 houses, or weight by number of houses.

### Question 2 — Clustering: types of building markets

**No label.** One row per district (67 rows). Build a profile from a fixed window (for example 2015–2025):

- type mix: share of new dwellings that are houses, townhouses/flats, apartments, retirement units;
- growth: trend or CAGR in new dwellings consented;
- volatility: coefficient of variation (sd ÷ mean) of quarterly counts;
- cost: median real $/m²;
- optionally: alterations share of total value, average house size.

**Method:** standardise all features (`scale()`), because k-means uses distances. k-means (`kmeans`, many `nstart`) with k chosen by elbow, silhouette or gap statistic; hierarchical (`hclust`, Ward.D2) with a dendrogram. Compare the two partitions (adjusted Rand index, cross-tab) and **describe** each cluster in words ("fast-growing high-cost resort markets", "stable rural house-only markets"). A map or PCA biplot helps.

### Question 3 — Classification: will consents rise next year?

**Label (y):** 1 = "rising" if new dwellings consented in district *d* in year *t+1* > year *t*, else 0. About 51% are rising, so classes are balanced.

**Features (X), known at end of year t only:** last year's growth, 3-year growth, level of consents, multi-unit share, real $/m², volatility, region, national growth that year.

**Split:** earlier years train, later years test (1,742 / 536 district-years per slide).

**Models:** logistic regression (`glm`, family = binomial), LDA (`MASS::lda`), classification tree (`rpart`).

**Metrics:** confusion matrix, accuracy, sensitivity/specificity, ROC AUC (`pROC`). Baseline to beat: always predict "rising" (≈ 51%) and "same direction as last year".

## 5. Traps to watch for

Most mistakes in this project will be data-preparation mistakes, not modelling mistakes. Check each of these explicitly in your Rmd.

| Trap | Why it bites | What to do |
| --- | --- | --- |
| `Period` read as a number | `2026.10` (October) becomes `2026.1` and looks like January. | Read `Period` as character: `col_types = cols(Period = col_character())`, then split into year and month. |
| Nested building types | "All buildings" already includes "Residential", which includes "New dwellings", which includes "Houses". Summing them double counts. | Pick one level per analysis; list the unique `Series_title_2` values first and map the hierarchy. |
| Long format | Value, count and floor area are separate rows. | `tidyr::pivot_wider(names_from = Units, values_from = Data_value)` after filtering. |
| Nominal vs real dollars | $/m² rose 4.7× nominally, only 14% in real terms. | Deflate with the CGPI residential-buildings index (quarterly; Stats NZ *Business price indexes* release). Note its rebasing (Sept 2022 quarter = 1000). |
| Small-number noise | 1–2 houses in a quarter give extreme $/m². | Minimum-houses filter or weights; report how many rows you drop. |
| Zero or missing values | Zero floor area → division by zero; some series may be blank. | Count NAs/zeros per series before ratios; `filter(floor_area > 0)`. |
| Incomplete periods | August release: 2026 Q3 has 2 of 3 months; 2026 as a year is incomplete. | Drop 2026 Q3 in Q1; in Q3 only use complete years. |
| Data leakage | Using information from the future or the label itself. | Features at time *t* use data up to *t* only; split by time; scale using training-set statistics only. |
| Structural breaks | COVID 2020, the 2021–22 building boom, Auckland zoning changes. | Expect the test period (2020+) to be harder; discuss in the report rather than hide it. |
| Boundary changes | Auckland's seven councils merged in 2010. | Check whether the file shows 67 current districts back to 1990 (it appears to, since 9,715 = 67 × 145). Confirm with the Stats NZ metadata. |
| Revisions | Recent months are revised in later releases. | Freeze the August 2026 release; all three of you use the same files. |
| Consent ≠ completed building | A consent may never be built; value is the applicant's estimate. | State this limitation in the report. |

## 6. Glossary

| Term | Meaning |
| --- | --- |
| Building consent | Council approval to carry out building work, issued before construction. |
| Territorial authority (TA) / district | One of New Zealand's 67 city or district councils; the "district" in our modelling tables. |
| SA2 | Statistical Area 2, a suburb-sized Stats NZ geography (≈2,400 areas). |
| Series reference | Stats NZ code identifying one place × type × measure time series. |
| New dwelling | A new home: house, townhouse/flat/unit, apartment or retirement village unit. |
| Multi-unit home | Any new dwelling that is not a stand-alone house. |
| Alteration | Work on an existing building (additions, renovations). |
| CGPI | Capital Goods Price Index: Stats NZ index of prices paid for capital assets, including residential buildings; used to convert nominal $ to real $. |
| Real vs nominal | Nominal = dollars as recorded; real = adjusted to a constant price level. |
| GST | Goods and Services Tax (15%), included in consent values. |
| Long vs wide format | Long: one row per series × period. Wide: one row per entity × period with measures as columns. |
| Data leakage | Letting the model see information it would not have at prediction time. |
| Chronological split | Training on earlier periods and testing on later ones, as in real forecasting. |

**Sources:** [Stats NZ — Building consents issued: August 2026](https://www.stats.govt.nz/information-releases/building-consents-issued-August-2026/) · [Stats NZ — Building topic page](https://www.stats.govt.nz/topics/building/) ·
