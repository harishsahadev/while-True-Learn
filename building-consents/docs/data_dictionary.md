# Data dictionary

The processed tables are written by the notebooks into `data/processed/`. The data are not included in the
submission; run the notebooks (see the README) to recreate them from the public Stats NZ releases.

All money is in **real June-2026 dollars, including 15% GST**. It is converted from dollars of the day by removing
the GST rate of the day and deflating with the Capital Goods Price Index (CGPI) for dwelling units.

---

## 1. `rq1_district_quarter_full.csv` / `rq1_model_data.rds`

One row per district and quarter.

* **Full file:** 67 districts × 145 complete quarters (1990Q2–2026Q2) = 9,715 rows.
* **Model file:** only the 8,662 rows with at least 5 new houses (`in_model = TRUE`). District, region, island and
  split are stored as factors.

| Column | Meaning |
|---|---|
| `ta` | Territorial authority (district or city), Stats NZ spelling |
| `region`, `island` | Regional council area (by majority population) and island |
| `is_city` | TRUE for city councils (name ends in "City") and Auckland |
| `year`, `quarter`, `yq`, `t_index` | Calendar year, quarter (1–4), label such as 2019Q3, quarter number (1990Q1 = 1) |
| `split` | `train` (to 2019Q4) or `test` (2020Q1–2026Q2) |
| `in_model` | TRUE if at least 5 new houses, so the row is used for modelling |
| `real_cost_m2` | Consented value per m² of new houses, real dollars |
| `log_real_cost_m2` | Natural log of `real_cost_m2` (secondary response) |
| **`rel_log_cost_m2`** | **Main RQ1 response:** log(real $/m²) minus log(real $/m² of all *other* districts in the same quarter) |
| `nominal_cost_m2` | Value ÷ floor area in dollars of the day (reference only) |
| `houses_n`, `houses_m2`, `houses_val` | New houses: count, floor area (m²), value (nominal $) |
| `dwell_n`, `apt_n`, `retire_n`, `town_n` | New dwellings: total, apartments, retirement-village units, townhouses/flats/units |
| `resid_new_val`, `resid_alt_val`, `nonres_new_val` | Nominal value of new residential work, residential alterations, new non-residential work |
| `avg_house_m2`, `rel_house_m2` | Average new-house size; its log ratio to the rest of NZ in the same quarter |
| `log_houses_n` | log(number of new houses) |
| `multiunit_share`, `apt_share`, `retire_share` | Share of new dwellings that are not stand-alone houses / apartments / retirement units |
| `dwell_per_1000` | New dwellings in the 12 months to the quarter end, per 1,000 residents (from 1996) |
| `houses_yoy` | log((houses + 1) ÷ (houses in the same quarter last year + 1)) |
| `log_resid_alt_real`, `log_nonres_real` | log(1 + real $) of residential alterations and of new non-residential work |
| `real_cost_m2_lag1`, `_lag4` | `real_cost_m2` one and four quarters earlier (not used in the main models) |
| `loo_cost_m2`, `loo_house_m2` | Real $/m² and average house size of all other districts in the same quarter |
| `gst`, `cgpi_dwell`, `cgpi_resid`, `cgpi_nonres`, `real_factor` | GST rate of the day, price indices, nominal → real multiplier |

The same descriptions are in `rq1_data_dictionary.csv`, which notebook 01 writes.

---

## 2. `rq2_district_features.csv` / `.rds`

One row per district (66; the Chatham Islands are excluded). Window 2016Q3–2026Q2 unless stated otherwise. The
`.rds` also holds the transformed features and the list of the nine clustering features.

| Column | Meaning | Used for clustering? |
|---|---|---|
| `ta`, `region`, `island`, `is_city` | Identifiers | no |
| `dwellings`, `houses` | Total new dwellings and houses in the window | no (describes size) |
| `apt_share`, `retire_share`, `town_share` | Share of new dwellings that are apartments / retirement units / townhouses, flats and units | yes (square root) |
| `house_share` | Share that are stand-alone houses | no: equals 1 minus the other three |
| `dwell_per_1000` | Average new dwellings per 1,000 residents per year | yes (log) |
| `growth` | log(new dwellings 2021Q3–2026Q2 ÷ 2016Q3–2021Q2) | yes |
| `volatility` | Standard deviation of the yearly log change in new dwellings, 2006–2025 | yes (log) |
| `rel_cost` | log(district real $/m² ÷ real $/m² of all other districts), pooled over the window | yes |
| `house_m2` | Average floor area of a new house | yes |
| `nonres_share` | New non-residential value ÷ (new non-residential + new residential value) | yes (square root) |
| `alt_share` | Residential alterations ÷ (alterations + new residential value) | no: largely repeats `dwell_per_1000` |

---

## 3. `rq3_model_data.csv` / `.rds`

One row per district and calendar year: 66 districts × feature years 1996–2024 = 1,914 rows. The `.rds` also holds
the 2025 rows (`forecast`), used by the app to predict 2026.

| Column | Meaning |
|---|---|
| `ta`, `region`, `island`, `is_city`, `year` | Identifiers; `year` is the feature year *t* |
| `split` | `train` (feature years 1996–2016) or `test` (2017–2024) |
| **`rise`** | **Label:** 1 if new dwellings in year *t* + 1 exceed year *t* (ties = 0) |
| `dwellings`, `next_dwellings` | New dwellings in year *t* and *t* + 1 |
| `log_dwellings` | log(1 + dwellings in year *t*) |
| `growth_1y`, `growth_2y` | log change in dwellings over one and two years (`growth_2y` not used in models) |
| `dev_5y` | log dwellings minus the mean log of the previous five years |
| `h2_vs_h1` | log(1 + July–December dwellings) − log(1 + January–June dwellings) |
| `alt_growth`, `nonres_growth` | Change in log real residential alterations / non-residential value |
| `multiunit_share`, `dwell_per_1000` | Share of new dwellings that are not houses; dwellings per 1,000 residents |
| `nat_growth_1y`, `nat_dev_5y`, `nat_h2_vs_h1` | The same measures for New Zealand as a whole |
| `nat_rise_next` | 1 if the national total rose in year *t* + 1 (description only, not a feature) |
| `rise_f` | `rise` as a factor (fall / rise) |

---

## 4. Reference table: `data/reference/ta_region_concordance.csv`

67 districts → region and island, compiled by the group. A district that crosses a regional boundary is assigned to
the region holding most of its population. It is checked against Stats NZ's regional totals in RQ1 notebook 01
(table t01).

## 5. Results tables: `outputs/tables/rq1|rq2|rq3/`

Every table in the report is a CSV here (t01 … t14 for RQ1, t01 … t08 for RQ2, t01 … t05 for RQ3), written by the
notebook that computes it. File names describe the content (for example `t09_test_results.csv`).
