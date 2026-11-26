# STAT462 A1 — Dataset Shortlist

_Research date: 2026-10-12. Facts checked against the sources listed. Anything marked [CONFIRM] is unverified — check it on download._

## How candidates were judged

Against the eight criteria in `WORKING_BRIEF.md`. The ones that actually separated candidates:

- **Continuous response** — the course outcomes are framed around regression.
- **Module 4+ fit** — the poster needs at least one of cluster analysis, discriminant analysis or trees. Best case: a continuous target *and* a natural categorical grouping *and* something worth clustering.
- **Cleaning / feature-engineering headroom** — the workflow is what gets assessed.
- **Provenance and licence** — the pitch must state origin; APA 7 citation needed.

## Long list (breadth first)

| # | Dataset | Domain | Size | Continuous target? | Module 4 fit | Cleaning headroom | Provenance | Verdict |
|---|---------|--------|------|--------------------|--------------|-------------------|------------|---------|
| 1 | **NZ International Visitor Survey (MBIE)** | Tourism | ~8,900 respondents/yr target; Q3 2022–Q2 2026 | ✔ spend per visitor | ✔ trees, LDA, clustering all natural | ✔✔ relational CSVs, multi-response tables, survey weights | ✔ Govt, CC BY 3.0 NZ | **Shortlist** |
| 2 | **USAID Supply Chain Shipment Pricing (SCMS)** | Freight / logistics | 10,324 rows × 33 cols | ✔ freight cost; delivery delay | ✔ trees, LDA on shipment mode | ✔✔ text in numeric fields, cross-row references | ~ USAID wound down in 2025; licence metadata inconsistent | **Shortlist** |
| 3 | **NZTA Crash Analysis System (CAS)** | Road safety | 707,449 rows × 70 cols | ~ counts only, unless aggregated | ✔✔ severity class for LDA/trees; cluster TLAs | ✔ many categoricals, heavy class imbalance | ✔ Govt, CC BY 4.0 | **Shortlist** |
| 4 | DataCo Smart Supply Chain (Mendeley) | E-commerce logistics | 180,519 × 53 | ~ shipping days (integer), sales (deterministic) | ✔ late-delivery class | ~ fairly clean | ~ origin vague, licence not stated | Reject — see below |
| 5 | LAWA river water quality (raw, 2004–2024) | Environment | Large, long-format | ✔ nitrate, E. coli, clarity | ✔ cluster sites | ✔✔ pivoting, site joins | ~ some LAWA files not explicitly licensed | Reserve |
| 6 | Electricity Authority EMI wholesale prices | Energy | Half-hourly × nodes | ✔ spot price | ~ clustering/LDA forced | ✔ | ~ no licence stated on page | Reject alone — **promoted** once combined with demand + weather (see below) |
| 7 | Inside Airbnb (Australian cities; no NZ city in the A–L part of the listing — rest not checked) | Housing / tourism | Thousands per city | ✔ nightly price | ✔ | ✔ | ✔ CC BY 4.0 | Reserve (generic) |
| 8 | GeoNet earthquake catalogue | Geoscience | Large | ✘ magnitude barely predictable | ✔ clustering only | ~ | ✔ CC BY 3.0 NZ | Reject as prediction — see NZGMDB reframe below |
| 9 | DUV ultramarathon results | Sport | ~10.7M results, 2.6M runners | ✔ average speed | ✔ | ✔ | ✘ no bulk download or licence; Kaggle mirrors of unclear standing | Reject |

## Shortlist — detail for the pitch

Pitch needs per dataset: datapoints · interesting features · origin · table screenshot · reason · research questions.

### 1. NZ International Visitor Survey (IVS) — recommended lead

- **Origin:** Ministry of Business, Innovation & Employment. Visitors are approached at departure in Auckland, Wellington, Christchurch and Queenstown airports, then complete an online questionnaire. Target 8,900 sampled visitors a year. Released quarterly.
- **Download:** MBIE "International Visitor Survey data download" page — ZIP of CSVs, Q3 2022 to Q2 2026 (8.6 MB). Older archive to March 2020 (31 MB) also available, but the 2022 method change makes mixing the two risky.
- **Datapoints:** Respondent-level. Exact row count not published — at the target rate, four years is in the order of 35,000 respondents. **[CONFIRM on download]**
- **Interesting features:** `treated_spend` (outlier-treated spend, NZD), country of residence, purpose of visit, age, length of stay, `first_nz_trip`, plus one-to-many tables for activities, accommodation, transport, itinerary (overnight locations), travel party, expenditure by product.
- **Licence:** CC BY 3.0 NZ.
- **Research questions:**
  - Regression: what predicts a visitor's total spend in NZ? (log spend on trip and visitor characteristics)
  - Clustering: are there distinct visitor types by activity and itinerary profile, and do they spend differently?
  - Discriminant / trees: can behaviour distinguish first-time from returning visitors, or holiday from visiting-friends-and-relatives trips?
- **Why it fits:** keeps all three Module 4 methods open with no forcing. The multi-table structure gives a real feature-engineering story (joins, multi-response → indicator features). Easy to explain to a non-technical audience.
- **Watch-outs:**
  - Spend is already outlier-treated (Statistics Canada Banff process) — the target is not raw spend. Say so.
  - Survey weights (`population_weight`) matter for population estimates; for prediction we can model unweighted but must justify it.
  - Recoded variables and recalculated 2024–2025 weights in the 1 Sep 2026 release.
  - Itinerary is one-to-many: naive joins double-count high-spenders (a known trap with this data).

### 2. USAID Supply Chain Shipment Pricing Data (SCMS)

- **Origin:** USAID Supply Chain Management System project — line-item shipments of HIV/AIDS medicines and lab supplies to 43 countries, roughly 2006–2015.
- **Download:** Originally data.usaid.gov (`a3rc-nmf6`). USAID was wound down in 2025 (functions moved to the State Department); a mirror record exists on the AmeriGEOSS DataHub (created Nov 2025) but still points at the USAID URLs. Copies are widely used in student and Kaggle projects. **[CONFIRM a working download]**
- **Datapoints:** 10,324 line items, 33 columns (one secondary source counts 31 — check).
- **Interesting features:** `Freight Cost (USD)`, `Weight (Kilograms)`, `Shipment Mode` (Air / Truck / Air Charter / Ocean), `Country`, `Vendor INCO Term`, `Product Group`, `Line Item Value`, `Line Item Insurance (USD)`, and five date fields (PO sent, scheduled, delivered, recorded).
- **Licence:** Metadata is inconsistent — the rights statement says CC BY with attribution to the partner; the licence URL points at CC BY-ND 4.0. Fine for analysis either way; cite carefully.
- **Research questions:**
  - Regression: what drives freight cost per shipment — weight, mode, destination, Incoterm, product type?
  - Regression: what predicts delivery delay (delivered minus scheduled date)?
  - Discriminant / trees: can shipment mode be predicted from shipment characteristics — when does air win over ocean or truck?
- **Why it fits:** strongest cleaning story of the three. In one published analysis about 40% of freight costs are not numeric as delivered — 1,442 "Freight Included in Commodity Cost", 239 "Invoiced Separately", and cross-references like "See DN-304 (ID#:10589)" that point to another row. Resolving those references is genuine feature engineering. Freight is also your day job, which helps in Q&A.
- **Watch-outs:**
  - Usable n for the freight-cost model drops to about 6,200 once non-numeric costs are removed, unless cross-references are resolved.
  - Freight is often recorded at shipment (ASN/DN) level and repeated across line items — risk of double counting.
  - Availability risk is real; get the file now before it's needed.
  - Your domain knowledge is an advantage, but the whole group has to be able to defend it.

### 3. NZTA Crash Analysis System (CAS)

- **Origin:** Waka Kotahi NZ Transport Agency. Every traffic crash reported to NZ Police on public roads. Updated monthly. Public open-data layer.
- **Download:** NZTA open data portal (ArcGIS FeatureServer `CAS_Data_Public`); also listed on data.govt.nz. ArcGIS Hub layers normally offer a CSV export. [CONFIRM]
- **Datapoints:** 707,449 crashes, 70 fields, crash years 2006–2026 in the public layer (checked 12 Oct 2026; layer last edited 5 Oct 2026). The service description says "from 1 January 2000" but the layer holds nothing before 2006.
- **Severity split:** Non-injury 486,582 (68.8%) · Minor 173,272 (24.5%) · Serious 41,397 (5.9%) · Fatal 6,198 (0.9%).
- **Interesting features:** `crashSeverity`, injury counts by severity, `speedLimit`, `light`, `weatherA/B`, `roadSurface`, `roadCharacter`, `flatHill`, `urban`, `holiday`, region and TLA, vehicle-type counts (car, truck, motorcycle, bicycle, pedestrian…), and object-struck flags (tree, ditch, guard rail, cliff/bank…). Queenstown-Lakes District alone has 7,215 crashes.
- **Licence:** CC BY 4.0 International.
- **Research questions:**
  - Discriminant / trees: which road, weather, light and vehicle factors separate severe (fatal + serious) crashes from the rest?
  - Clustering: do TLAs group into distinct crash profiles (rural high-speed vs urban)?
  - Regression (weaker): injuries per crash, or crash rates aggregated by TLA and year.
- **Why it fits:** big, NZ, well documented, very easy to explain. Best dataset of the three for discriminant analysis.
- **Watch-outs:**
  - **Regression is the awkward part.** The natural target is categorical. If the facilitator wants a regression-led project, this is the weakest of the three.
  - Severe class imbalance (fatal under 1%) — needs resampling or class weights, and accuracy alone will mislead.
  - Police-reported only — non-injury crashes are under-reported, so it's not a census of crashes.
  - Live data that changes after publication — record the download date as the snapshot.

## Rejected — and why

- **DataCo Smart Supply Chain** — closest to your job, but semi-synthetic: `Sales` is arithmetic on price and quantity, shipping days are driven almost entirely by shipping mode, and `Delivery Status` / `Late_delivery_risk` leak the obvious target. Origin is one sentence ("used by the company DataCo Global"). Widely used on Kaggle, so it reads as a canned choice. SCMS covers the same interest with real data.
- ~~**EMI wholesale electricity** — a time-series problem. Random-split CV is invalid, and clustering/discriminant analysis would be forced.~~ **Reversed 2026-10-12:** price alone is still weak, but once demand, generation and weather are added, load-profile clustering and price-spike discriminant analysis fit naturally, and time-ordered validation answers the CV objection. See `Idea_Energy_Demand_Price.md`.
- **GeoNet earthquake catalogue** — good for clustering, but no credible regression question on the catalogue alone. The NZ Ground-Motion Database offers one (predict shaking) — see `Idea_Earthquakes.md`.
- **DUV ultramarathon** — great variables, but no clean bulk download or licence; the Kaggle copies have unclear standing.
- **LAWA water quality** and **Inside Airbnb** — held in reserve. LAWA is strong but heavy (long-format, spatio-temporal, partial licensing). Airbnb is solid but generic, and NZ coverage is unconfirmed — none in the A–L part of the listing [CONFIRM].

## Boulton's three ideas (added 2026-10-12)

Full notes: `Idea_Energy_Demand_Price.md`, `building-consents/` (README + council-level notes), `Idea_Earthquakes.md`.

| Idea | Best data found | As proposed | Reframed | Verdict |
|------|-----------------|-------------|----------|---------|
| Energy demand/supply + weather → demand and price | EMI half-hourly grid export (2010+), generation by plant/fuel (2008+), final prices by node (2014+); hydro storage daily 1980–2022 (free to 2022 only); Open-Meteo hourly weather (CC BY 4.0) | Price-from-weather will be weak (hydro and gas drive price); time series needs time-ordered validation | Demand regression on temperature and calendar; cluster daily load shapes; LDA/trees for price-spike periods | **Strong** |
| Building consents — processing time, RFI, area, cost, complexity | QLDC: 45,290 consents, cost, floor area, type, complexity R1–C3, CCC date, location. Far North: 45,231 with lodged + decision dates. Timaru: 48,418 with cost, area, materials | No public consent-level RFI data; MBIE publishes PDFs only; no single dataset has processing time *and* cost/area | QLDC: cost and complexity drivers, LDA on complexity, build duration to CCC. Far North: processing-time regression | **Good** (as QLDC) |
| Earthquakes — predict future location and size | GeoNet catalogue (~20k events/yr, CC BY 3.0 NZ); NZ Ground-Motion Database (UC; ~70k records, 6,040 quakes, 393 stations) | Not achievable or defensible — earthquake prediction isn't possible; the model would learn base rates | Predict ground shaking (PGA) from magnitude, distance, depth, site; LDA on tectonic class; cluster seismicity | **Weak as proposed; conditional** on the NZGMDB download |

## Recommendation (updated)

Ranked on fit across everything researched:

1. **Energy** — reframed
2. **IVS**
3. **QLDC building consents**
4. **CAS crashes**
5. **SCMS shipments** — availability risk
6. **NZGMDB ground motion** — only if the download is confirmed

Earthquake *prediction* is dropped.

If the pitch is built around your ideas: **Energy + QLDC consents**, plus one of IVS or CAS as the third. That gives three domains and keeps a strong regression option and a strong discriminant-analysis option in play. This is a proposal for the group to decide, not a decision.

**Pitch-format note:** 6 slides maximum including the title. Title + one dense slide per dataset (technical audience, so detail is allowed) + one comparison/recommendation slide = 5, with one spare. If each group member owns one dataset, that also covers "every slide shows its presenter" and roughly even speaking time.

## Update 2026-10-12 — Boulton prefers building consents

Boulton has picked **building consents** and wants national coverage. The lead source is now **Stats NZ Building Consents Issued** (all 67 TAs, 2,396 SA2s, 1990–2026, CC BY 4.0). The council consent-level layers are kept as a local zoom-in.

Full dataset README with download links, column dictionary and research questions: `building-consents/README.md`.

This changes the question from processing time and RFIs (record-level data MBIE doesn't publish) to cost, type and location of building.

Still open: the pitch needs 2–3 datasets, and the group hasn't confirmed.

## Next steps

1. Group to confirm interest — the pitch is marked on every member having explored the data.
2. Download all three into `04_Analysis/data-local-only/`. Do it by hand in a browser: under the current network settings, both my workspace and your computer's shell were blocked from the MBIE download. I didn't try the other two.
3. Once the files are there, profile each one locally: row counts, missingness, target distributions, the real column list. That replaces every [CONFIRM] above with a number and gives you the table screenshots for the slides.

## Sources

- MBIE — IVS data download: https://www.mbie.govt.nz/immigration-and-tourism/tourism-research-and-data/tourism-data-releases/international-visitor-survey-ivs/international-visitor-survey-data-download/
- MBIE — IVS methodology: https://www.mbie.govt.nz/immigration-and-tourism/tourism-research-and-data/tourism-data-releases/international-visitor-survey-ivs/international-visitor-survey-methodology
- Ellis, P. (2018) — IVS data quirks: https://freerangestats.info/blog/2018/02/03/ivs
- AmeriGEOSS — Supply Chain Shipment Pricing Data: https://data.amerigeoss.org/dataset/supply-chain-shipment-pricing-data
- SCMS field list (Journal of Big Data, Table 2): https://journalofbigdata.springeropen.com/articles/10.1186/s40537-024-01049-7/tables/2
- SCMS cleaning counts (Sundi, shipment price prediction): https://shashank-sundi.github.io/HEALTH-COMMODITY-SHIPMENT-PRICE-PREDICTION/
- NZTA CAS public layer (fields, licence, counts): https://services.arcgis.com/CXBb7LAjgIIdcsPt/ArcGIS/rest/services/CAS_Data_Public/FeatureServer
- data.govt.nz — CAS listing: https://catalogue.data.govt.nz/dataset/crash-analysis-system-cas-data5
- Mendeley — DataCo: https://data.mendeley.com/datasets/8gx2fvg2k6/5
- DataCo dimensions (Univ. Trieste ML lab): https://medvet.inginf.units.it/teaching/2526-ml/labs/lab2/
- LAWA download page: https://www.lawa.org.nz/download-data
- EMI final energy prices: https://www.emi.ea.govt.nz/Wholesale/Datasets/DispatchAndPricing/FinalEnergyPrices
- Inside Airbnb: https://insideairbnb.com/get-the-data/
- GeoNet earthquake catalogue: https://geonet.org.nz/data/types/eq_catalogue
- DUV archive front end: https://duv-thesis.duckdns.org/about
