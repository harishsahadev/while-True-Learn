# Building Consents Issued — structure profile of the downloaded data

_Profiled 13 Oct 2026 from the local copy of the **August 2026** release. Every number here comes from the files on disk. Companion to `README.md` (download links, column dictionary, metadata)._

## 1. Where the data lives (outside OneDrive)

`C:\Users\AndrewBoulton\stat462-data\` — not synced, never goes in the submission zip.

| Path | What |
|---|---|
| `*.zip` | The 3 downloads as received: main release (25.3 MB), SA2 new dwellings (7.8 MB), Business price indexes Jun-2026 qtr (0.6 MB, for CGPI) |
| `raw/` | All 14 CSVs unzipped (≈1.58 GB). CRC-checked on extract |
| `processed/ta_quarter_new_houses.csv` | **Modelling frame for RQ1** — 9,715 rows: district × quarter, new houses: count, value, floor area, $/m², m²/house |
| `processed/ta_month_wide_key_series.csv` | 30,453 rows × 68 cols — district × month, 12 key building types × work × measure, pivoted wide |
| `processed/nz_annual_new_houses.csv` | National annual 1991–2025 — nominal and CGPI-real $/m², house size, multi-unit share |
| `profile/` | JSON profile of every CSV |

The processed extracts were built in Python for the pitch. **The assessed cleaning pipeline has to be rebuilt in R** (supplementary materials = commented R/Rmd). R can't unzip bzip2 with base `unzip()`. Either extract with 7-Zip or read straight from the zip with the `archive` package [CONFIRM it works on a group member's machine].

## 2. Files and sizes

| File | Rows | Periods | Varies by |
|---|---:|---|---|
| Building consents by territorial authority (Monthly) | 4,348,384 | 1990-04 → 2026-08 (NZ total from 1965-04) | 69 areas × 26 building types × 3 work × 3 measures |
| Building consents by region (Monthly) | 1,396,468 | 1965-04 → 2026-08 | 22 areas; **also seasonally adjusted and trend** (`Series_title_5`) |
| Building consents by region (Quarterly) | 462,736 | 1965-Q2 → 2026-Q2 | as above |
| Building consents by Auckland local board (Monthly) | 1,321,488 | 1990-04 → 2026-08 | 21 boards × 25 types |
| Building consents by institutional sector (Monthly) | 458,771 | 1965-04 → 2026-08 | 7 sectors |
| Building consents by institutional control (Monthly) | 235,270 | 1965-04 → 2026-08 | 5 owner types |
| New dwellings per 1000 residents — TA / region / Auckland board (Annual, rolling) | 25,382 / 6,614 / 7,728 | 1966 → 2026-08 | Status F **and P (provisional)** |
| Non-residential outliers | 912 | 1990 → 2026-08 | $100m+ consents |
| NZ percentage change (Monthly) | 1,483 | 1966 → 2026-08 | National % changes |
| New dwellings by 2026 SA2 (Monthly) | 1,047,052 | 1990-04 → 2026-08 | 2,396 SA2s, 68 TAs |
| New dwellings by 2023 SA2 (Monthly) | 1,046,615 | 1990-04 → 2026-08 | 2,395 SA2s |
| **Total, consents files** | **10,358,903** | | |

## 3. Structure of the main (TA) file — verified

- **Long "Infoshare" format**: 14 columns, one row = one series × one month. 9,937 series.
- **A complete grid.** Each building type × work × measure combination has exactly 30,153 rows = 69 areas × 437 months. There are no gaps and no nulls in `Data_value`. `Suppressed` = `n` and `Status` = `F` in every row.
- **145 combinations, not 26 × 3 × 3 = 234**:
  - Floor area exists only for `New`.
  - Alterations carry Number and Value.
  - **Domestic outbuildings have no `New` series** — they are counted only as alterations.
  - `Miscellaneous buildings` appears in 300 rows, all NZ-level before 1990.
- `Units` maps 1:1 to the measure: Floor area → SQM, Number → Number, Value → Dollars.
- The **region files mix F / P / R** status (provisional and revised). If we use them, filter `Series_title_5 = Actual`.

### Hierarchy check — closes open question 17
At district level every subtotal adds up exactly (difference ≤ 1) for all 29,716 TA-months:

- Dwelling units = Houses + "Apartments, townhouses, units, and other dwellings" (number, value and floor area)
- "Apartments, townhouses…" = Apartments + Retirement village units + "Townhouses, flats, units, and other dwellings"
- Residential (new + altered value) = Dwelling units + Domestic outbuildings
- All buildings = Residential + Non-residential
- Non-residential = its 7 sub-types
- All construction = All buildings + Non-building construction
- New + Altered = New plus altered
- New Zealand = sum of the 67 TAs + Area Outside TA (houses, all 437 months)

The only mismatches are NZ-level rows **before April 1990**, when the sub-categories don't exist yet. That's a structural break, not an error. **Rule: pick one level of the hierarchy and never sum across levels.**

## 4. The RQ1 modelling frame (district × quarter, new houses)

- 67 districts × 145 complete quarters (1990-Q2 → 2026-Q2) = **9,715 rows**. The partial 2026-Q3 (Jul–Aug) is dropped.
- Small-number problem:
  - 2.2% of district-quarters have **zero** new houses.
  - 10.8% have fewer than 5, where $/m² is unreliable.
  - That leaves 8,662 rows with ≥ 5 houses.
- Nominal $/m² (≥ 5 houses): median $1,281; 1st–99th percentile $551–$3,810; extremes $225 (Ōpōtiki 1995-Q3, 6 houses) and $5,449 (Ōpōtiki 2024-Q1, 5 houses). Both are small-count noise.
- **Real $/m²** in June-2026 dollars, deflated by CGPI Residential Buildings `CEPQ.S61101`: median $2,815; 1st–99th percentile $2,015–$4,149.
- **Baseline variance check:**
  - Year + district fixed effects explain **63%** of the variance in log real $/m².
  - Year alone explains 43%; district alone 19%.
  - Adding average house size doesn't move it (still 63%).
  - About **37% is left for real features to explain**, and size alone isn't one of them.

## 5. First-look findings (good pitch material)

- **Nominal vs real cost:** the national $/m² for new houses rose **4.7×**, from $681 (1991) to $3,226 (2025). After CGPI deflation it rose only **+14%**, from $2,915 to $3,309 in June-2026 dollars. Inflation adjustment isn't optional.
- **District spread in 2025** (47 districts with ≥ 50 new houses):
  - Highest: Queenstown-Lakes **$4,516/m²**, Thames-Coromandel $4,202, Wellington City $4,106, Lower Hutt $3,802, Tauranga $3,766.
  - Lowest: Selwyn **$2,593**, Waimakariri $2,665, Ashburton $2,719, Whanganui $2,788, Masterton $2,838.
  - Queenstown is **1.7×** Selwyn.
- **Intensification:** multi-unit dwellings (apartments, townhouses, retirement units) went from 29% of new dwellings in 1991, down to 16% in 2010, up to 58% in 2023 and 55% in 2025. In 2025, 13 of 67 districts were majority multi-unit; Lower Hutt was highest at 77%, then Wellington City at 73%.
- **House size:** the average new house was 153 m² in 1991, peaked at 218 m² in 2005, and was 178 m² in 2025.
- **SA2:** 67.1% of SA2-months have zero new dwellings, so the data is zero-inflated. The dwelling-type parts sum to the total in 100% of rows.
- **Rising vs falling markets:** across 2,278 district-years (1991–2024, next year vs this year), 51.2% were rising. The classes are balanced, which suits discriminant analysis.

## 6. Research questions mapped to the brief

| RQ | Question | Unit / rows | Methods | Brief requirement met |
|---|---|---|---|---|
| **1 (lead)** | What drives the real cost per m² of new houses across NZ districts? | District-quarter, 9,715 (8,662 with ≥ 5 houses) | Linear / lasso on log real $/m² vs regression tree and random forest; train ≤ 2019, test 2020–26 | Regression (CLO 1) + trees (Module 4+) + compare methods |
| 2 | What kinds of building markets does NZ have? | 67 districts | k-means vs hierarchical clustering on type mix, growth, volatility, cost, size | Clustering (Module 4+); feeds RQ1 as a feature |
| 3 | Will a district's dwelling consents rise or fall next year? | District-year, 2,278; 51% rising | LDA / QDA vs classification tree; time-ordered test | Discriminant analysis (Module 4+) vs trees |
| 4 (optional) | Where will new homes be built? | SA2-year | log(1 + count) regression vs tree; or hurdle (any / none) | Extra regression; zero-inflation is a talking point |

**Questions we still need to settle before analysis:**
1. Does the **lead target** stay $/m² of new houses, or switch to total dwellings consented per 1,000 residents (supply rather than cost)?
2. Nominal or real dollars? Real is recommended — the CGPI is already downloaded.
3. Minimum houses per district-quarter for a valid $/m² — 5? 10? Or pool to year in small districts?
4. Which features avoid leakage? For example, don't use dwelling-units value to predict houses value, because they share components.
5. Validation design: time-ordered split vs leave-districts-out. Random splits are out because of panel correlation.
6. Is Auckland a single TA or its 21 local boards? Auckland dominates the volume.
7. Does the course rule out any official-statistics datasets? (Open question 1 in the working brief.)

## 7. Traps confirmed on the local copy

- `Period` is text (`2025.10`). Read it as character.
- Floor area exists for **new work only**.
- Dollars are **GST-inclusive and nominal**.
- 10.8% of district-quarters have fewer than 5 new houses, so ratios there are noisy.
- The TA file is 757 MB. Read only the needed columns. Python (pandas, category dtypes) loads it in about 25 s using about 1 GB of RAM.
