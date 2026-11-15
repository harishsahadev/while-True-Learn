# Data dictionary

This document describes every input file and every table our scripts build. The derived tables are written to `<STAT462_DATA>/derived/` (outside the repo; see [README.md](README.md), "Linking the data"). Row counts and ranges are from the Stats NZ August 2026 release and the June 2026 quarter price indexes.

## Conventions

| Item | Convention |
|---|---|
| **Dollars** | Consent values are as declared by the applicant, **GST inclusive**, excluding land. Consents under $5,000 are not in the data. |
| **Nominal vs real** | *Nominal* = dollars as recorded. *Real* = deflated by the Capital Goods Price Index for residential buildings (`CEPQ.S61101`) into **June 2026 quarter dollars**: real = nominal × CGPI(2026 Q2) / CGPI(quarter). |
| **Logs** | All logs are natural logs. `log(x + 1)` is used where a count can be 0. |
| **Growth** | Log growth: log(later / earlier). A value of 0.10 is about +10%. |
| **Quarters** | Calendar quarters (Q1 = Jan–Mar). A quarter is kept only if all three months are present, which drops 2026 Q3 (only Jul–Aug released). |
| **Years** | Calendar years, complete years only. |
| **District** | One of 67 territorial authorities (`area`), using Stats NZ's names (e.g. "Selwyn District", "Auckland"). Auckland is one district. "Area Outside Territorial Authority" is dropped. |
| **Building types** | Stats NZ's types are nested (Houses ⊂ Dwelling units ⊂ Residential buildings ⊂ All buildings). Each type is used on its own and never summed with another. |
| **New vs altered** | Unless a column says *alt*, it counts **new** building work only. |
| **Time split** | Q1 trains on 1996–2019 and tests on 2020–2026 Q2. Q3 trains on feature years 1996–2016 and tests on 2017–2024 (labels 2018–2025). |

---

## 1. Input files (not in the repo)

| File | Download | Grain | Used for |
|---|---|---|---|
| `Building consents by territorial authority (Monthly).csv` | Building consents issued: August 2026 | series × month (long format, 4.35 M rows) | All three questions: counts, values, floor areas |
| `Building consents by region (Quarterly).csv` | same | series × quarter | Check only: district totals must reproduce the national quarterly figure |
| `New dwellings consented per 1000 residents by territorial authority (Annual).csv` | same | district × month (rolling 12-month rate) | Building intensity features |
| `New dwellings consented by 2026 statistical area 2 (Monthly).csv` | New dwellings by SA2: August 2026 | SA2 × month (wide) | Q1 concentration feature `sa2_top3_share` |
| `business-price-indexes-june-2026-csv.csv` | Business price indexes: June 2026 quarter | series × quarter | Deflators: CGPI `CEPQ.S61101` (main) and PPI `PPIQ.SQUEE1120` (sensitivity check) |

The territorial authority file is in Stats NZ's "Infoshare" long format: one row per series and month, with `Series_title_1` = district, `_2` = building type, `_3` = New / Altered / New plus altered, `_4` = Number / Value / Floor area. `Period` is `YYYY.MM` and is always read as **text** (read as a number, October `2025.10` becomes `2025.1`).

The EDA (`R/analysis/eda.Rmd`) also profiles the other nine files in the release. They are not used by the models.

---

## 2. `district_quarters.rds`

**Grain:** district × calendar quarter (wide). **Rows:** 9,715 (67 districts × 145 quarters, 1990 Q2 – 2026 Q2). **Key:** `area`, `year`, `quarter`.
**Written by:** `R/scripts/02_clean.R`. **Read by:** `03_features.R`, `04_q2_profiles.R`, `05_q3_frame.R`.

Months are summed to quarters, then pivoted wide. Each building type has three measures for **new** work: `_n` (count), `_value` (nominal $), `_area` (floor area, m²).

| Column | Type | Unit | Definition |
|---|---|---|---|
| `area` | text | | District (territorial authority) name |
| `year` | integer | | Calendar year (1990–2026) |
| `quarter` | integer | | Calendar quarter (1–4) |
| `qtr_index` | integer | | `year × 4 + quarter`: consecutive quarters differ by 1 (used for lags) |
| `houses_n`, `_value`, `_area` | numeric | count, $, m² | New stand-alone **houses** |
| `dwellings_n`, `_value`, `_area` | numeric | count, $, m² | All new **dwelling units** (houses + townhouses + apartments + retirement units) |
| `townhouses_n`, `_value`, `_area` | numeric | count, $, m² | New townhouses, flats, units and other dwellings |
| `apartments_n`, `_value`, `_area` | numeric | count, $, m² | New apartments |
| `retirement_n`, `_value`, `_area` | numeric | count, $, m² | New retirement village units |
| `res_n`, `_value`, `_area` | numeric | count, $, m² | New residential buildings (all) |
| `nonres_n`, `_value`, `_area` | numeric | count, $, m² | New non-residential buildings |
| `allbld_n`, `_value`, `_area` | numeric | count, $, m² | All new buildings |
| `alt_res_value` | numeric | $ | Value of **alterations** to residential buildings (renovations, additions) |

Checks in the script: every district has an unbroken run of quarters, and the district totals of new houses equal Stats NZ's national quarterly figure in all 145 quarters (maximum difference 0).

---

## 3. `price_index.rds`

**Grain:** calendar quarter. **Rows:** 147 (1989 Q4 – 2026 Q2). **Key:** `year`, `quarter`.
**Written by:** `R/scripts/03_features.R`. **Read by:** `04_q2_profiles.R`, `05_q3_frame.R`, so every question uses the same deflator and base.
**Attributes:** `base_period` = `"2026.06"`; `base` = the CGPI and PPI values in that quarter.

| Column | Type | Unit | Definition |
|---|---|---|---|
| `year`, `quarter` | integer | | Calendar quarter |
| `cgpi` | numeric | index (Sept 2022 Q = 1000) | Capital Goods Price Index, residential buildings (`CEPQ.S61101`). **Main deflator.** |
| `ppi` | numeric | index | Producer price index, residential building construction outputs (`PPIQ.SQUEE1120`). Starts 1994 Q2 (18 earlier quarters are NA). Sensitivity check only. |
| `cgpi_growth_lag1` | numeric | log growth | Construction-cost inflation over the year to the **previous** quarter: log(CGPI(q−1) / CGPI(q−5)). Known before quarter q starts, so it causes no leakage. |

---

## 4. `q1_frame.rds` / `.csv` (Q1 regression)

**Grain:** district × quarter. **Rows:** 6,255 (train 4,814 / test 1,441), 65 districts, 1996 Q2 – 2026 Q2. **Key:** `area`, `year`, `quarter`.
**Written by:** `R/scripts/03_features.R`. **Read by:** `R/analysis/q1_regression.Rmd`.

**Row filter:**
- at least `min_houses` = 10 new houses in the district-quarter (smaller counts give unstable ratios);
- every feature available. Eight quarters of history are needed, and the per-1,000 series starts in 1996.

Two districts never meet both conditions. The report also drops Wairoa, which appears only in the training years.

**Leakage rule:** no feature uses the current quarter's dollar values. Activity features use previous quarters only.

### Response and reference columns

| Column | Type | Unit | Definition | Range |
|---|---|---|---|---|
| `area` | factor | | District | 65 levels |
| `year`, `quarter` | integer | | Calendar quarter | 1996–2026 |
| `quarter_f` | factor | | Quarter as a factor (seasonality) | 1–4 |
| `split` | text | | `train` (year ≤ 2019) or `test` | |
| **`log_real_m2`** | numeric | log $/m² | **RESPONSE.** log of real $ per m² of new houses: log(`houses_value` / `houses_area` × CGPI base / CGPI quarter) | 7.40 – 8.63 |
| `real_m2` | numeric | $/m² (June 2026) | The response before logging | $1,631 – $5,574 |
| `dollars_per_m2` | numeric | $/m² (nominal) | `houses_value` / `houses_area`, not deflated | $491 – $5,420 |
| `log_nom_m2` | numeric | log $/m² | log of `dollars_per_m2`. Used only to show the effect of inflation. | |
| `log_real_m2_ppi` | numeric | log $/m² | The response deflated by the PPI instead of the CGPI. Sensitivity check only. | |
| `last_log_real_m2` | numeric | log $/m² | The district's most recent earlier `log_real_m2` (any earlier quarter with ≥ 10 houses). Used only for the persistence baseline. 3 NA. | |
| `cgpi`, `ppi` | numeric | index | Price index values for the quarter | |
| `houses_n` | numeric | count | New houses in the quarter | 10 – 2,099 |

### Features

| Column | Type | Unit | Definition | Range |
|---|---|---|---|---|
| `multi_unit_share` | numeric | share | 1 − `houses_n` / `dwellings_n`: share of new dwellings that are not stand-alone houses | 0 – 0.92 |
| `m2_per_house` | numeric | m² | `houses_area` / `houses_n`: average new-house size | 70 – 363 |
| `log_houses` | numeric | log count | log(`houses_n`): size of the quarter's market | 2.30 – 7.65 |
| `nonres_area_share` | numeric | share | `nonres_area` / `allbld_area`: non-residential share of new floor area (area, not value) | 0 – 0.95 |
| `per1000_lag1` | numeric | per 1,000 residents | New dwellings per 1,000 residents, year ending the **previous** quarter | 0.3 – 46.1 |
| `dw_growth` | numeric | log growth | log((dwellings in previous 4 quarters + 1) / (dwellings in the 4 before those + 1)) | −1.34 – 1.30 |
| `log_dw_trail4` | numeric | log count | log(1 + dwellings in the previous 4 quarters): recent local activity | 2.20 – 10.0 |
| `sa2_top3_share` | numeric | share | Share of the quarter's new dwellings in the district's three busiest SA2s (concentration). It is 1 by construction for districts with three or fewer SA2s. | 0.05 – 1 |
| `time_trend` | numeric | years | `year + (quarter − 1) / 4` | 1996.25 – 2026.25 |
| `cgpi_growth_lag1` | numeric | log growth | Construction-cost inflation over the year to the previous quarter (see `price_index`) | −0.01 – 0.15 |

---

## 5. `q2_profiles.rds` / `.csv` (Q2 clustering)

**Grain:** district. **Rows:** 67. **Key:** `area`. **Window:** `q2_years` = 2015–2025 (complete years).
**Written by:** `R/scripts/04_q2_profiles.R`. **Read by:** `R/analysis/q2_clustering.Rmd`.

Counts and values are **pooled over the 11 years before dividing**, so small districts' ratios are stable. The ten clustering features are all shares, rates or ratios, so district size does not drive the clusters. The report standardises them (mean 0, SD 1) before clustering.

| Column | Type | Unit | Definition | Range | Clustered? |
|---|---|---|---|---|---|
| `area` | text | | District | 67 | |
| `dwellings_total` | numeric | count | New dwellings, 2015–2025 | 37 – 161,682 | no (size, for description) |
| `houses_total` | numeric | count | New houses, 2015–2025 | 34 – 61,007 | no |
| `share_townhouses` | numeric | share | Townhouses, flats & units / all new dwellings | 0.03 – 0.51 | yes |
| `share_apartments` | numeric | share | Apartments / all new dwellings | 0 – 0.38 | yes |
| `share_retirement` | numeric | share | Retirement village units / all new dwellings | 0 – 0.19 | yes |
| `real_m2` | numeric | $/m² (June 2026) | Σ real house value / Σ house floor area; each quarter deflated by the CGPI **before** pooling | $2,758 – $4,274 | yes |
| `m2_per_house` | numeric | m² | Σ house floor area / Σ houses | 125 – 213 | yes |
| `alt_share` | numeric | share | Σ residential alteration value / (Σ alteration value + Σ new residential value) | 0.04 – 0.34 | yes |
| `nonres_area_share` | numeric | share | Σ non-residential floor area / Σ all new floor area | 0.16 – 0.72 | yes |
| `growth` | numeric | log growth | log((dwellings 2021–25 + 1) / (dwellings 2015–19 + 1)) | −0.89 – 1.11 | yes |
| `volatility` | numeric | SD of log growth | SD of year-on-year log changes in dwellings, 2015–2025 | 0.14 – 1.17 | yes |
| `per1000` | numeric | per 1,000 residents | Mean of the December-year new dwellings per 1,000 residents, 2015–2025 | 1.1 – 27.3 | yes |

---

## 6. `q3_frame.rds` / `.csv` (Q3 classification)

**Grain:** district × calendar year. **Rows:** 1,943 (train 1,407 / test 536), 67 districts, feature years 1996–2024. **Key:** `area`, `year`.
**Written by:** `R/scripts/05_q3_frame.R`. **Read by:** `R/analysis/q3_classification.Rmd`.

**Timing rule:** every feature describes the district at the **end of year t**. Only the label uses year t+1. Feature years start in 1996 because the per-1,000 series and the five-year volatility need history. They end in 2024 because the label needs 2025.

### Label and reference columns

| Column | Type | Unit | Definition | Range |
|---|---|---|---|---|
| `area` | text | | District | 67 |
| `year` | integer | | Feature year t | 1996–2024 |
| `split` | text | | `train` (t ≤ 2016) or `test` (t ≥ `q3_test_start` = 2017) | |
| **`rising`** | integer | 0/1 | **LABEL.** 1 if new dwellings in t+1 > new dwellings in t. A tie counts as 0. 53% rising in train, 47% in test. | |
| `rising_f` | factor | | `rising` as a factor (`fall`, `rise`) | |
| `dw` | numeric | count | New dwellings in year t | 0 – 21,301 |
| `dw_next` | numeric | count | New dwellings in year t+1. Used only to build the labels, never as a feature. | |
| `rose_last` | integer | 0/1 | 1 if dwellings in t > t−1. Used only for the "same as last year" baselines. | |
| `real_m2` | numeric | $/m² (June 2026) | Real $/m² of new houses in year t. A year with no houses carries the last known value forward. | $976 – $8,582 |

The **relative label** `outperform` is built inside `q3_classification.Rmd`, not stored. It is 1 if the district's log growth from t to t+1, log((`dw_next` + 1)/(`dw` + 1)), is greater than national log growth over the same years.

### Features

| Column | Type | Unit | Definition | Range |
|---|---|---|---|---|
| `log_dw` | numeric | log count | log(1 + `dw`): market size | 0 – 9.97 |
| `growth_1y` | numeric | log growth | log(1 + dw(t)) − log(1 + dw(t−1)) | −1.66 – 2.30 |
| `growth_3y` | numeric | log growth | log(1 + dw(t)) − log(1 + dw(t−3)) | −2.08 – 2.20 |
| `momentum_h2` | numeric | log ratio | log(1 + dwellings Jul–Dec) − log(1 + dwellings Jan–Jun) of year t: within-year momentum | −1.95 – 1.67 |
| `volatility` | numeric | SD | SD of the last five yearly values of `growth_1y` | 0.04 – 1.56 |
| `multi_unit_share` | numeric | share | 1 − houses / dwellings in year t (carried forward if no dwellings) | 0 – 1 |
| `log_real_m2` | numeric | log $/m² | log(`real_m2`) | 6.88 – 9.06 |
| `per1000` | numeric | per 1,000 residents | New dwellings per 1,000 residents, year ending December t | 0 – 37.3 |
| `nat_growth` | numeric | log growth | National log growth in new dwellings, t−1 → t (same for every district in a year) | −0.33 – 0.28 |
| `cgpi_growth` | numeric | log growth | Construction-cost inflation, log(CGPI Dec t / CGPI Dec t−1) (same for every district in a year) | −0.01 – 0.13 |

---

## 7. Settings that change these tables

All in `R/config.R`. Change them there only, then re-run the scripts from `02_clean.R` onward.

| Setting | Value | Affects |
|---|---|---|
| `min_houses` | 10 | Q1 row filter; `last_log_real_m2` |
| `train_end_year` | 2019 | Q1 `split` |
| `q2_years` | 2015:2025 | Q2 profile window |
| `q3_test_start` | 2017 | Q3 `split` |
| `seed` | 462 | All random steps in the reports |
