# Building Consents Issued — New Zealand (Stats NZ)

_Dataset README for the STAT462 A1 pitch. Written 2026-10-12 from the August 2026 release._
_Every number below was profiled directly from the released files unless it's marked [CONFIRM]._

---

## 1. One-paragraph summary

Stats NZ collects every building consent issued by New Zealand's building consent authorities each month. It publishes them as **monthly counts, values and floor areas** of new and altered buildings — 26 building types, 67 territorial authorities (plus the area outside any TA), 16 regions and 21 Auckland local boards. Totals run back to 1965, and the TA series to April 1990.

A companion file gives monthly new-dwelling counts for **2,396 small areas (SA2)**. Together they describe 36 years of where New Zealand builds, what it builds, how big, and at what consented cost.

**Important:** these are **aggregated statistics, not one row per consent**. That shapes what questions the data can answer (see §6).

---

## 2. Why this dataset fits the brief

Scored against the selection criteria in `WORKING_BRIEF.md`:

| # | Criterion (from the brief) | Fit | Evidence |
|---|---|---|---|
| 1 | Continuous response for regression | ✔ | Value ($), floor area (m²), and derived **value per m²** and **m² per dwelling** for every TA-month. Also new dwellings per 1,000 residents |
| 2 | Supports a Module 4+ method (cluster / discriminant / tree) | ✔ | **Clustering:** 67 TAs or 2,396 SA2s on their building profile. **Trees:** cost-per-m² models. **Discriminant analysis:** derived classes such as intensifying vs stand-alone districts, or rising vs falling markets (§7) |
| 3 | Adequate size | ✔ | TA file 4,348,384 rows → **29,716 TA-months** (68 areas × 437 months). SA2 file **1,047,052 SA2-months**. Big enough to model, small enough for a laptop once filtered |
| 4 | Room for cleaning and feature engineering | ✔✔ | Long "Infoshare" format to pivot wide; nested building-type hierarchy (double counting risk); GST-inclusive nominal dollars to deflate; staged-consent artefacts; imputed floor areas; two SA2 boundary versions; the `Period` text trap (§5.3) |
| 5 | Not a course dataset | [CONFIRM] | Not an ISLR/MASS-style teaching set. Check against the course list |
| 6 | Clear provenance and licence | ✔ | Official statistics from Stats NZ, **CC BY 4.0**, with a set attribution statement (§9) |
| 7 | Explainable to a non-technical audience | ✔ | Housing cost and supply are national talking points. Results map well by district |
| 8 | Whole group interested | Boulton ✔ · group [CONFIRM] | The pitch is marked on every member having explored the data |

**Why it beats the council-level data** (`council-consent-level-data.md`): national coverage, a consistent definition across all councils, 36 years, CC BY 4.0. The council files are one district each, with different fields and no licence statement. They remain useful as a local **zoom-in** (Queenstown Lakes) to sanity-check the national picture.

---

## 3. Where to download

| What | Link |
|---|---|
| Release page (August 2026) | https://www.stats.govt.nz/information-releases/building-consents-issued-August-2026/ |
| **Main CSV zip** (24 MB zipped, ~1.45 GB unzipped, 11 CSVs) | https://www.stats.govt.nz/assets/Uploads/Building-consents-issued/Building-consents-issued-August-2026/Download-data/building-consents-issued-august-2026.zip |
| **SA2 new-dwellings zip** (7.4 MB zipped, 2 CSVs) | https://www.stats.govt.nz/assets/Uploads/Building-consents-issued/Building-consents-issued-August-2026/Download-data/new-dwellings-consented-by-statistical-area-2-august-2026.zip |
| Release tables with notes (Excel, 180 KB) | https://www.stats.govt.nz/assets/Uploads/Building-consents-issued/Building-consents-issued-August-2026/Download-data/building-consents-issued-august-2026.xlsx |
| Stats NZ CSV catalogue (all topics) | https://www.stats.govt.nz/large-datasets/csv-files-for-download/ |
| Infoshare (being replaced by Aotearoa Data Explorer) | Subject: Industry sectors › Group: Building consents – BLD |

**Download notes:**
- The zips use **bzip2** compression. Stats NZ says to extract them with **7-Zip** — Windows' built-in extractor may fail.
- The next release (September 2026) is due **3 November 2026**. Pin one release (August 2026) for the whole project so numbers don't shift under us.
- Save raw files to `04_Analysis/data-local-only/` only. The brief forbids data in the submission zip.

---

## 4. Files in the main zip

| File | Unzipped | Rows | Coverage | `Series_title_1` holds |
|---|---|---|---|---|
| Building consents by territorial authority (Monthly).csv | 757 MB | 4,348,384 | 68 areas 1990-04 → 2026-08; NZ total from 1965-04 | 67 TAs + "Area Outside Territorial Authority" + "New Zealand" |
| Building consents by region (Monthly).csv | 234 MB | 1,396,468 | 1965-04 → 2026-08 | 16 regions, "Area outside region", island and grouped totals (22 values) |
| Building consents by region (Quarterly).csv | 78 MB | 462,736 | 1965-Q2 → 2026-Q2 | As above |
| Building consents by Auckland local board (Monthly).csv | 245 MB | 1,321,488 | 1990-04 → 2026-08 | 21 local boards |
| Building consents by institutional sector (Monthly).csv | 83 MB | 458,771 | 1965-04 → 2026-08 | Total, households, non-financial business, financial business, general government, non-profits, rest of world |
| Building consents by institutional control (Monthly).csv | 42 MB | 235,270 | 1965-04 → 2026-08 | Total, national private, foreign, central government, local government |
| New dwellings consented per 1000 residents by territorial authority (Annual).csv | 3.8 MB | 25,382 | Rolling annual, 1966 → 2026-08 | 67 TAs + NZ |
| New dwellings consented per 1000 residents by region (Annual).csv | 0.9 MB | 6,614 | Rolling annual | Regions |
| New dwellings consented per 1000 residents by Auckland local board (Annual).csv | 1.2 MB | 7,728 | Rolling annual | Local boards |
| Non-residential outliers.csv | 0.1 MB | 912 | 1990 → 2026 | Consents of $100m and above (plus two discontinued $25m+ / $50m+ series) |
| NZ percentage change (Monthly).csv | 0.3 MB | 1,483 | 1966 → 2026 | National dwelling and house % changes |

The SA2 zip holds `New dwellings consented by 2026 statistical area 2 (Monthly).csv` (61.7 MB, 1,047,052 rows, 2,396 SA2s) and the same on **2023** SA2 boundaries (61.6 MB, 1,046,615 rows, 2,395 SA2s). Both run 1990-04 → 2026-08 (437 months).

---

## 5. Column dictionary

### 5.1 Main zip — every file uses the same 14 columns (long "Infoshare" format)

One row = one series × one period. A "series" is one geography × building type × work type × measure.

| Column | Type | Meaning | Values seen (TA file) |
|---|---|---|---|
| `Series_reference` | text | Infoshare series ID. 9,937 distinct series in the TA file. Pattern for new-dwelling counts by TA is `BLDM.SY&&&1100A1` (`&&&` = TA code) | e.g. `BLDM.SY0000001A1` |
| `Period` | **text** `YYYY.MM` | Month (the quarterly file uses the quarter-end month). **Read as text** — see §5.3 | `1965.04` → `2026.08` |
| `Data_value` | number | The value of the series in that period | 0 → 3,346,946,662 |
| `Suppressed` | flag | Suppression flag | `n` in every row |
| `Status` | flag | `F` = final | `F` in every row |
| `Units` | text | Unit of `Data_value` | `Dollars` (2,206,513 rows), `Number` (1,447,944), `SQM` (693,927) |
| `Magnitude` | int | Power-of-ten multiplier | `0` everywhere (values are as-is) |
| `Subject` | text | Infoshare subject | `Building Consents - BLD` |
| `Group` | text | Which table | e.g. `Building consents by territorial authority` |
| `Series_title_1` | text | **Geography or sector** | 69 values in the TA file (§4) |
| `Series_title_2` | text | **Building type** — 26 nested categories (§5.2) | `Houses`, `Apartments`, `Commercial buildings`, … |
| `Series_title_3` | text | **Nature of work** | `New`, `Altered`, `New plus altered` |
| `Series_title_4` | text | **Measure** | `Number`, `Value`, `Floor area` |
| `Series_title_5` | text | **Adjustment** — region files only; empty in the TA file (actuals only) | `Actual`, `Seasonally adjusted`, `Trend` |

### 5.2 Building-type hierarchy (`Series_title_2`)

These categories are **nested** — summing all 26 double-counts. Pick one level.

- **All construction**
  - **All buildings**
    - **Residential buildings**
      - **Dwelling units**
        - Houses
        - Apartments, townhouses, units, and other dwellings → Apartments · Retirement village units · Townhouses, flats, units, and other dwellings
      - Domestic outbuildings
    - **Non-residential buildings**
      - Hotels, motels, boarding houses, and prisons → Hostels, boarding houses, and prisons · Hotels, motels, and other short-term accommodation
      - Hospitals, nursing homes, and other health buildings
      - Education buildings
      - Social, cultural, and religious buildings
      - Commercial buildings → Shops, restaurants, and bars · Office, administration, and public transport buildings
      - Factories, industrial, and storage buildings → Storage buildings · Factories and industrial buildings
      - Farm buildings
      - Miscellaneous buildings _(300 rows only)_
  - **Non-building construction** (retaining walls, swimming pools, etc.)

The nesting above is inferred from the category names and release notes. Confirm the sums on download — e.g. Houses + Apartments, townhouses… = Dwelling units [CONFIRM]. Retirement village units count as **dwellings**; hostels, boarding houses and nursing homes are **non-residential**.

### 5.3 Traps found while profiling
- **`Period` must be read as text.** October is `2025.10`. Read as a number it becomes `2025.1`, and turning that back into a month gives January. In R: `data.table::fread(..., colClasses = list(character = "Period"))`.
- **Floor area exists only for new buildings** (`Series_title_3 = New`), and from 1973 nationally / 1990 by TA. Alterations have value but no floor area.
- **Dollars include GST and are not inflation-adjusted.** Deflate with the Capital Goods Price Index (§8) before comparing years.
- **Staged consents:** value is recorded at each stage, but floor area and unit counts are normally recorded at the largest stage. Value ÷ floor area can spike in individual months. Aggregate to quarters or years.
- **Floor areas are imputed** by Stats NZ when a consent doesn't state one.
- **Small districts are noisy:** 7.8% of TA-months have zero new dwellings. Ratios like $/m² need a minimum count or a longer window.
- **The TA file is 757 MB** unzipped. Read only the columns needed, filter to the series you want, and save a small `.rds` or `.parquet` copy.

### 5.4 SA2 files — tidy wide format (one row per SA2 per month)

| Column | Type | Meaning |
|---|---|---|
| `month` | date `YYYY-MM-01` | Month consented (1990-04-01 → 2026-08-01) |
| `SA2_code` | int (6-digit) | Statistical area 2 code (100100 → 400016) |
| `SA2_name` | text | SA2 name, e.g. `North Cape`, `Kaitāia East` |
| `territorial_authority` | text | Parent TA (68 values) |
| `total_dwelling_units` | int | New dwelling units consented (max 417 in one SA2-month) |
| `houses` | int | Stand-alone houses |
| `apartments` | int | Apartments |
| `retirement_village_units` | int | Retirement village units |
| `townhouses_flats_units_other` | int | Townhouses, flats, units, other |

Counts only — no value or floor area at SA2 level. Use the **2026** boundary file unless joining to 2023 Census data, which needs the **2023** file.

---

## 6. What the data can and can't answer

| Can answer | Can't answer |
|---|---|
| How much, what type, where and when NZ consents to build | Anything about an **individual** consent |
| Consented **cost per m²** and **size per dwelling** by district and period | **Processing time**, RFIs, approval or refusal rates — Stats NZ only sees issued consents |
| Shifts from houses to townhouses/apartments (intensification) | Whether the building was actually built (consents are intentions; see Value of Building Work Put in Place) |
| Differences between districts and between small areas | Who applied, or the actual final build cost |

**Original idea vs this data:** the processing-time / RFI question needs record-level data that MBIE holds but doesn't publish (MBIE releases PDF summaries by consent authority). This dataset moves the project from *"how long does a consent take?"* to *"what drives what we build, where, and at what cost?"* Processing time could come back as a stretch goal (§7, RQ5).

---

## 7. Suggested research questions (aligned to the brief)

The brief needs: research questions in **regression** (course learning outcome 1); at least one **Module 4+ method** (cluster analysis, discriminant analysis, or trees) on the poster; a variety of methods compared critically; and a story a non-technical audience can follow.

### RQ1 — Regression + trees (lead question)
**What drives the cost per square metre of new houses across New Zealand's districts, and how has it changed since 1990?**
- **Unit:** TA × quarter (monthly is too noisy in small districts). About 68 × 146 ≈ 9,900 rows.
- **Response:** real value per m² of new houses = `Value` ÷ `Floor area` for `Houses` / `New`, deflated by CGPI Residential Buildings.
- **Candidate features:**
  - region / TA, quarter, year
  - average house size (m² per house)
  - market heat (new dwellings per 1,000 residents)
  - share of multi-unit dwellings
  - share of alterations in total residential value
  - non-residential activity
  - lagged values
- **Methods:** linear regression (log response), ridge/lasso, regression tree, random forest. Compare on a **time-ordered hold-out** (train to 2019, test 2020–2026) so the test is genuinely unseen.
- **Non-technical hook:** "Why does a square metre of new house cost more in Queenstown-Lakes than in Southland?" In 2025 Queenstown-Lakes consented 592 new houses: $535.8m for 118,644 m², i.e. about **$4,516/m²** (GST incl.) and **200 m²** per house.

### RQ2 — Cluster analysis
**What kinds of building markets does New Zealand have?**
- Cluster the 67 TAs (or the 2,396 SA2s) on standardised profiles: dwelling-type mix, growth trend, volatility, cost per m², house size, non-residential share, alteration share.
- **Methods:** k-means and hierarchical clustering; choose k with silhouette/gap; show on a map and in a PCA plot.
- **Story:** "growth cities intensifying", "lifestyle/tourism districts", "steady rural districts"… then ask whether cluster membership improves RQ1.

### RQ3 — Discriminant analysis vs trees
**Can a district's recent consent profile tell us whether its market will rise or fall next year?**
- **Class per TA-year:** new-dwelling consents in the next 12 months higher than the last 12 (rising) or not (falling).
- **Features:** lagged volumes, growth rates, type mix, cost per m², region.
- **Methods:** LDA vs QDA vs classification tree; confusion matrix on a time-ordered test set.
- An alternative class to swap in: **intensifying** (≥50% of new dwellings multi-unit) vs **stand-alone** — but leave the mix features out so the target doesn't leak.

### RQ4 — Small-area regression (optional, SA2)
**Where will new homes be built?** Predict each SA2's new dwellings next year from its previous three years and its TA, with regression vs regression tree. Many zeros, so model log(1 + count) or compare against a classification of "any new dwellings / none".

### RQ5 — Stretch: bring processing time back, nationally
**Do busier or more complex consent workloads mean slower processing?** Join MBIE's quarterly figures by consent authority (median processing days, % within 20 working days, residential vs commercial) to this dataset's consent volume and type mix for the same TA and quarter.
- Only about 69 authorities × ~10 quarters ≈ 690 rows, and the MBIE tables have to be extracted from PDFs.
- Workable as a secondary regression, not the lead.

### Zoom-in (optional)
Use Queenstown Lakes' consent-level layer (`council-consent-level-data.md`) to check whether the national $/m² for Queenstown-Lakes matches what individual consents show — and to show the audience a real consent.

---

## 8. Joinable Stats NZ datasets (same CSV catalogue)

| Dataset | Use | Link |
|---|---|---|
| Business price indexes (June 2026 qtr) — **CGPI Residential Buildings** `CEPQ.S61101`, quarterly 1989-12 → 2026-06 (base Sep 2022 = 1000); Non-residential `CEPQ.S61102` | Deflate consent values to real dollars | https://www.stats.govt.nz/assets/Uploads/Business-price-indexes/Business-price-indexes-June-2026-quarter/Download-data/business-price-indexes-june-2026-quarter.zip |
| Value of building work put in place (June 2026 qtr) | What actually got built vs what was consented | https://www.stats.govt.nz/assets/Uploads/Value-of-building-work-put-in-place/Value-of-building-work-put-in-place-June-2026-quarter/Download-data/value-of-building-work-put-in-place-june-2026-quarter.zip |
| Dwelling and household estimates (Dec 2024 qtr) | Housing stock context | https://www.stats.govt.nz/assets/Uploads/Dwelling-and-household-estimates/Dwelling-and-household-estimates-December-2024-quarter/Download-data/dwelling-and-household-estimates-december-2024-quarter.zip |
| 2018 Census occupied/unoccupied/under-construction dwellings (TA, SA2) | Static district covariates | https://www3.stats.govt.nz/2018census/Occupied-dwellings-unoccupied-dwellings-dwellings-under-construction-private-and-non-private-dwellings-2006-2013-2018-Censuses-RC-TA-SA2-DHB.zip |
| Property transfer statistics (June 2024 qtr) | Housing market activity | https://www.stats.govt.nz/assets/Uploads/Property-transfer-statistics/Property-transfer-statistics-June-2024-quarter/Download-data/property-transfer-statistics-june-2024-quarter.zip |
| Local authority statistics (June 2026 qtr) | Council finances by quarter | https://www.stats.govt.nz/assets/Uploads/Local-authority-statistics/Local-authority-statistics-June-2026-quarter/Download-data/local-authority-statistics-june-2026-quarter.csv |

Population for per-capita features is already built into the "per 1000 residents" files. Stats NZ notes these use 2023-base population estimates from June 2023.

---

## 9. Metadata, definitions and licence

**From the release notes (Excel) and Stats NZ definitions:**
- **Collection:** monthly, from building consent authorities.
- **Scope:** consents valued **under $5,000 are excluded**, as are those mainly for demolition. Only work needing a building consent is counted, so civil works needing only a resource consent (e.g. roads) are out.
- **Values:** include **GST**; **not inflation adjusted**.
- **Floor area:** new buildings only; **imputed** when the consent doesn't state it.
- **Staged consents:** value at each stage; floor area and units at the largest stage.
- **Counting:** each dwelling in a multi-unit project is counted separately.
- **Residential alterations** include relocated dwellings and domestic outbuildings (garages, sheds).
- **Seasonal adjustment:** seasonally adjusted and trend series are revised every month. The non-residential trend excludes consents of $100m or more.
- **Purpose:** consents measure **intention** to build — an early indicator of construction activity.

**Stats NZ metadata pages (DataInfo+).** My fetch tool is blocked from this site, so these weren't read for this README — worth a read by the group:
- Current methodology from March 2015: https://datainfoplus.stats.govt.nz/item/nz.govt.stats/f7fe9444-6dba-4e6d-b62d-3f334816debf
- Concepts from March 2015: https://datainfoplus.stats.govt.nz/item/nz.govt.stats/a1d9b0d0-4cbf-4cce-b905-ce6c2e86eff4/10
- Limitations and changes over time: https://datainfoplus.stats.govt.nz/Item/nz.govt.stats/ee083b32-8c10-4ccf-b1ee-a4990b27273c/
- FAQ: https://datainfoplus.stats.govt.nz/item/nz.govt.stats/be810157-f03f-4dc7-a215-3e97b34c0b69/

**Licence:** Crown copyright, licensed under **Creative Commons Attribution 4.0 International**. Because we adapt the data, the required attribution is:
> This work is based on/includes Stats NZ's data which are licensed by Stats NZ for reuse under the Creative Commons Attribution 4.0 International licence.

**APA 7 reference (draft):**
Stats NZ. (2026, October 1). *Building consents issued: August 2026* [Data set]. https://www.stats.govt.nz/information-releases/building-consents-issued-August-2026/

---

## 10. Limitations to say out loud in the pitch
1. **Aggregated, not record-level** — conclusions are about districts and periods, not individual projects (ecological inference).
2. **Panel / time series** — neighbouring months and districts are correlated. Use time-ordered or grouped validation, never a plain random split.
3. **Consented value is the applicant's estimate**, not the final build cost, and includes GST.
4. **Intentions, not completions** — some consented buildings are never built.
5. **Boundary and definition changes** — methodology changed from March 2015; SA2 boundaries changed between 2023 and 2026.

---

## 11. How this README was produced
- I couldn't download the files to this computer — the network blocks stats.govt.nz from both my workspace and your computer's shell. Instead I streamed them in the built-in browser and profiled every CSV in memory: headers, row counts, value domains, period ranges. **Nothing is saved locally yet.**
- The release notes came from the table footnotes in the Excel workbook. The licence wording came from https://www.stats.govt.nz/about-us/copyright/.
