# Data dictionary — `rq1_district_quarter`

The modelling table for research question 1 (*what drives the real cost per square metre of new houses across New Zealand's districts?*), built by `04_Analysis/R/02_cleaning.Rmd` from Stats NZ's *Building consents issued: August 2026* release (published 1 October 2026) and the *Business price indexes: June 2026 quarter* release. Both are Crown copyright, CC BY 4.0.

**Grain:** one row per territorial authority (district) per calendar quarter. 67 districts × 145 complete quarters (1990-Q2 to 2026-Q2) = 9,715 rows, no gaps. Auckland is one district. The partial 2026-Q3 (July–August) is excluded. **No minimum house count is applied in the table**; the modelling document filters on `houses` (agreed minimum: 5, leaving 8,662 rows).

**Source series.** Unless stated, a column is the sum over the quarter's three months of one series in *Building consents by territorial authority (Monthly)*, identified by its `Series_title_2` (building type), `Series_title_3` (work) and `Series_title_4` (measure). Dollar values are nominal and include GST (12.5% to September 2010, 15% from October 2010). Consents under $5,000 are excluded by Stats NZ. Floor area is reported for new work only and imputed by Stats NZ when a consent does not state it.

**Leakage rule.** No feature contains the consented value of new houses (the response's numerator). Mix and activity features are ratios of counts. Rolling features use the current and earlier quarters only. Nothing is averaged or standardised over the whole period.

| Column | Type | Unit | Source / formula | Notes |
|---|---|---|---|---|
| `area` | character | — | `Series_title_1` of the TA file | Name as Stats NZ writes it in Infoshare files (no macrons, e.g. `Opotiki District`). 67 values |
| `region` | character | — | `lookups/ta_region_2026.csv` | 17 levels. 60 districts lie wholly in one region; the 7 that straddle a boundary (Rotorua, Taupō, Waitomo, Stratford, Rangitīkei, Tararua, Waitaki) go to the region holding most of their new dwellings 1990–2026, from the SA2 file and Stats NZ's Meshblock Higher Geographies 2026 layer. Chatham Islands is its own level |
| `island` | character | — | from `region` | `North Island`, `South Island`, `Chatham Islands` |
| `year` | integer | — | from `Period` | Calendar year of the quarter |
| `quarter` | integer | 1–4 | from `Period` | Calendar quarter |
| `yq` | character | — | `paste0(year, "Q", quarter)` | e.g. `2025Q2` |
| `is_train` | logical | — | `year <= 2019` | Time-ordered split as pitched: 7,973 train rows (to 2019-Q4), 1,742 test rows (2020-Q1 to 2026-Q2) |
| `houses` | double | count | Houses · New · Number | New stand-alone houses consented. **Filter and weight column.** 215 rows are 0 |
| `floor_area` | double | m² | Houses · New · Floor area | |
| `value_nominal` | double | NZ$ | Houses · New · Value | Nominal, GST inclusive |
| `nominal_ppm2` | double | NZ$/m² | `value_nominal / floor_area` | NA when `houses == 0` or `floor_area == 0` (215 rows) |
| `m2_per_house` | double | m² | `floor_area / houses` | Average size of a new house. NA when `houses == 0`. Feature |
| `cgpi` | double | index | CGPI residential buildings, `CEPQ.S61101`, quarterly, *Business price indexes* (Stats NZ) | Joined on the quarter-end month in `Period`. Base September 2022 = 1000 in the file; rebased in use to the latest quarter. **NA throughout if the price index file is not in `data_root`** |
| `value_real` | double | NZ$ (latest quarter's dollars) | `value_nominal * cgpi_base / cgpi` | `cgpi_base` = index of the latest quarter in the file (June 2026) |
| `real_ppm2` | double | NZ$/m² (real) | `value_real / floor_area` | NA as for `nominal_ppm2` |
| `log_real_ppm2` | double | log | `log(real_ppm2)` | **Response A** — the question as pitched |
| `nz_excl_ppm2_nominal` | double | NZ$/m² | `(V_NZ − value_nominal) / (A_NZ − floor_area)` where `V_NZ`, `A_NZ` are the `New Zealand` rows of the same series, same quarter | Cost per m² in the rest of the country, the district excluded. Never NA |
| `log_rel_ppm2` | double | log ratio | `log(nominal_ppm2) − log(nz_excl_ppm2_nominal)` | **Response B** — the district's cost relative to the rest of NZ in the same quarter. Deflator cancels, so needs no CGPI. 0 = same as rest of NZ; +0.3 ≈ 35% dearer; −0.2 ≈ 18% cheaper. NA as for `nominal_ppm2` |
| `dwelling_units` | double | count | Dwelling units · New · Number | All new dwellings (houses + multi-unit). Used in the ratios below; the hierarchy identity `Dwelling units = Houses + Apartments + Retirement village units + Townhouses…` holds to within 1 |
| `multi_share` | double | share | `1 − houses / dwelling_units` | Share of new dwellings that are not stand-alone houses. NA when `dwelling_units == 0` (190 rows). Feature |
| `apart_share` | double | share | Apartments · New · Number ÷ `dwelling_units` | Part of `multi_share`. Use one level: `multi_share`, or its three parts, not both |
| `retire_share` | double | share | Retirement village units · New · Number ÷ `dwelling_units` | Part of `multi_share` |
| `town_share` | double | share | Townhouses, flats, units, and other dwellings · New · Number ÷ `dwelling_units` | Part of `multi_share` |
| `nonres_share_n` | double | share | Non-residential buildings · New · Number ÷ All buildings · New · Number | Count-based, so it does not contain house value. NA when no new building at all (74 rows). Feature |
| `alter_per_new` | double | ratio | Residential buildings · Altered · Number ÷ `dwelling_units` | Residential alteration consents per new dwelling: renovate vs build. NA when `dwelling_units == 0`. Feature |
| `log_dwellings` | double | log | `log1p(dwelling_units)` | Scale of the market. Feature; also the district-level descriptor that stands in for district identity in tree models |
| `houses_yoy` | double | log change | `log1p(houses) − log1p(houses four quarters earlier)`, within district | Year-on-year momentum. NA for each district's first 4 quarters (268 rows). Feature |
| `houses_vol8` | double | sd of log | `sd(log1p(houses))` over the trailing 8 quarters ending at the current one, within district | Volatility. NA for each district's first 7 quarters (469 rows). Feature |
| `per1000_lag` | double | dwellings per 1,000 residents | *New dwellings consented per 1000 residents by territorial authority (Annual)*, the rolling-year value whose year ends in the last month of the **previous** quarter (for 2025-Q2: year to March 2025) | Market heat, strictly past. District series start with the year to January 1996, so NA for 1990-Q2 to 1996-Q1 in every district (1,608 rows). Population is Stats NZ's 2023-base subnational estimates; values from January 2024 are provisional. Feature |
| `log_real_ppm2_lag1` | double | log | `log_real_ppm2` one quarter earlier, within district | **Persistence benchmark only** — not for the headline model |
| `log_real_ppm2_lag4` | double | log | `log_real_ppm2` four quarters earlier, within district | As above |
| `log_rel_ppm2_lag1` | double | log ratio | `log_rel_ppm2` one quarter earlier, within district | As above |
| `log_rel_ppm2_lag4` | double | log ratio | `log_rel_ppm2` four quarters earlier, within district | As above |

**Files.** `04_Analysis/data-local-only/processed/rq1_district_quarter.rds` (column types preserved; the modelling document reads this) and `.csv` (missing values written as empty). Neither is part of the supplementary submission — the submission holds code only, and the table is rebuilt from the Stats NZ downloads by knitting `02_cleaning.Rmd`.

**Cross-check.** `Claude outputs/cleaning_checks/build_rq1_pycheck.py` builds the same table independently in Python from the release zips (without the price index). `02_cleaning.Rmd` compares every shared numeric column against it when its output is present and stops if any value differs by more than 1e-6 or any missing-value pattern differs.

**Attribution.** This work is based on/includes Stats NZ's data which are licensed by Stats NZ for reuse under the Creative Commons Attribution 4.0 International licence.
