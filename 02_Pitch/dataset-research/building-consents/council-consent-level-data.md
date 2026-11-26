# Idea — Building consents: processing time, RFIs, cost and complexity

_Researched 2026-10-12. Counts below are live queries against each council's public ArcGIS layer on that date. [CONFIRM] = not yet verified._

## The idea as proposed
How long does it take to issue a building consent? Use consent-level data with:
- requests for further information (RFI)
- floor area
- location
- private vs commercial
- cost and complexity

Stats NZ data should link to an MBIE dataset somewhere.

## Headline finding
**No public dataset has all of those fields together, and the MBIE link doesn't exist publicly.**

- **MBIE** collects consent data from every building consent authority — 69 of them; 16,532 consent applications in Q1 2026 alone — including RFI days. The medians it reports imply record-level data, though MBIE doesn't say so outright.
  - It **only publishes PDF reports** with BCA-level summary tables: median processing days, % within 20 working days, median RFI response (9.0 working days in Q1 2026), residential vs commercial.
  - No CSV, no record-level data.
- **Stats NZ** building consents are monthly aggregates (counts, value, floor area by area and building type). No processing time, no RFI.
- **Context from MBIE data, via Infometrics:** 64.3% of applications get an RFI. Median processing is 6 days without one vs 11.4 days with one.

## What *is* public at consent level
Three councils publish consent-level records through ArcGIS. Each has a different slice of what you want.

| | **Queenstown Lakes DC (QLDC)** | **Far North DC** | **Timaru DC** |
|---|---|---|---|
| Records | 45,290 (1992–2026) | 45,231 (from Oct 1991, updated daily) | 48,418 |
| Lodged date | ✘ | ✔ `lodgeddate` | ✘ |
| Decision / issue date | ✔ `COMPLETED_DATE` (19,525 populated) | ✔ `decisiondate` (45,016 with both dates) | ✔ `Application_Granted_Date` |
| **Processing time** | ✘ | **✔ decision − lodged** | ✘ |
| RFI | Only as a current status (`AwaitInfo` among 43 status codes) — no history | ✘ | ✘ |
| Cost | ✔ `ESTIMATED_COST` (45,236 > 0) | ✘ | ✔ `Cost` |
| Floor area | ✔ `Floor_Area` (35,078 > 0) | ✘ | ✔ `Floor_Area`, `build_area`, `new_area` |
| Building type | ✔ 10 categories (new dwelling, alteration, commercial, industrial, multi-unit, outbuilding…) | ✔ 8 application types + free-text description | ✔ `build_type`, storeys, dwellings |
| **Complexity** | **✔ `CATEGORY` R1–R3 / C1–C3** on 22,427 records (older records use a different code set) | ✘ | ✘ |
| Materials | ✘ | ✘ | ✔ floor, roof, wall and frame type |
| Completion | ✔ `CCC_Issued` date (35,721) | ✘ | ✔ `CCC_Status` |
| Location | ✔ address + point | ✔ point | ✔ address + coordinates |
| Licence | Not stated on the item | Not stated | Not stated |

Records from different councils can't be joined to each other — different consents, different districts.

## Fit against the selection criteria
- **QLDC** is the best all-round dataset. It has continuous targets (cost, build duration), a real complexity class for discriminant analysis, location for clustering, ~45k rows, plenty of cleaning (two generations of category codes, status codes, cost/area outliers). It's also local, which helps the "reason for choosing" slide.
- **Far North** is the only one that answers *your* question (processing time). But apart from type and status, the only predictors are free-text descriptions, so most features would have to come from text mining.
- **Timaru** is the best for a construction-cost model (materials, storeys, area), but has no timing.

## Problems with the idea as stated
1. **The RFI question can't be answered from public data at consent level.** MBIE holds it but doesn't release it.
   - The only route is an Official Information Act request (MBIE or a council). That takes 20 working days plus possible extension — too slow for the pitch, and the outcome isn't guaranteed.
   - It could run in parallel as an upside, but drafting or sending one in your name needs your go-ahead.
2. **Elapsed days ≠ statutory days.** Far North's lodged → decision includes weekends, holidays and RFI clock-stops. Statutory working days can't be reconstructed without RFI dates. Say so on the slide.
3. **Build-duration bias (QLDC).** Issue → CCC is only observed for finished builds. Recent consents are under-represented, so naive models understate duration (right-censoring). Restrict to older cohorts, or acknowledge it.
4. **No licence statement** on any of the three layers. They're publicly published, which is usually fine for coursework, but cite each council and note it.

## Reframed research questions
**QLDC (recommended):**
1. **Regression:** what drives estimated build cost — floor area, building type, complexity category, location (Wānaka vs Queenstown vs rural), year?
2. **Discriminant / trees:** can complexity category (R1–R3, C1–C3) be predicted from cost, area and type? Does it line up with what the council assigned?
3. **Regression:** how long from consent issue to code compliance certificate, by type and complexity (with the censoring caveat)?
4. **Clustering:** spatial and type clusters of development across the district.

**Far North (if processing time is the must-have):**
1. **Regression:** what predicts days from lodgement to decision — application type, description keywords (new dwelling, fireplace, relocation, commercial), season, council workload (engineered from lodgements in the prior 30 days), year?

## Verdict
**Good candidate — but not as originally framed.** Pitch QLDC as "cost and complexity of building in the Queenstown Lakes District", with Far North processing time as a second angle or a fallback. Drop RFI unless an OIA comes back in time.

## Open questions
- Is processing time the core interest, or would cost/complexity carry the project? This decides QLDC vs Far North.
- Do you want an OIA drafted to QLDC or MBIE for lodged dates and RFI days? (Needs your approval before anything is sent.)
- QLDC `CATEGORY` mapping: confirm R01–R03/C01–C03 are the national BCA complexity categories, and what the older codes (1.1–3.2, R, C) mean [CONFIRM].
- QLDC `COMPLETED_DATE` — confirm it is the consent issue date, not the CCC date [CONFIRM].

## Sources
- QLDC Building Consents layer: https://services1.arcgis.com/9YyqaQtDdDR8tupG/arcgis/rest/services/Building_Consents/FeatureServer
- QLDC hub page: https://gis-qldc.hub.arcgis.com/datasets/QLDC::building-consents/about
- Far North DC layer: https://services5.arcgis.com/H4FlrMy6xTBd6Ywx/arcgis/rest/services/BuildingConsents_public_FNDC/FeatureServer
- Timaru DC layer: https://maps.timaru.govt.nz/server/rest/services/Vector/Building_Consents/MapServer/0
- MBIE performance monitoring (PDF reports): https://www.mbie.govt.nz/building-and-energy/building/building-system-insights-programme/building-consent-system-performance-monitoring
- MBIE Q1 2026 report: https://www.mbie.govt.nz/dmsdocument/32005-building-consent-system-performance-monitoring-q1-january-to-march-2026
- Building.govt.nz on RFI and statutory clock: https://www.building.govt.nz/getting-started/how-the-building-system-protects-you/building-consent-system-performance-monitoring
- Infometrics on consent delays: https://economics.infometrics.co.nz/article/2025-04-shining-a-light-on-building-consent-delays
- Auckland Council high-value consents layer (issue date and value only): https://mapspublic.aucklandcouncil.govt.nz/arcgis3/rest/services/NonCouncil/LINZBuildingConsent/MapServer/layers
