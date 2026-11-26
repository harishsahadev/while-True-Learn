# Idea — Earthquakes (GeoNet)

_Researched 2026-10-12. [CONFIRM] = not yet verified._

## The idea as proposed
Use location, depth and magnitude history to predict future earthquakes — where they'll happen and how big.

## Straight answer: as framed, this won't stand up
- A real earthquake prediction has to give **time, location and magnitude**. The USGS position is that no scientist has ever predicted a major earthquake, and none is expected to be possible in the foreseeable future. What is possible is a probability of an earthquake in an area over a period.
- A model trained on the catalogue will mostly learn **where earthquakes usually happen** and that small ones outnumber big ones (Gutenberg–Richter). It will look accurate without predicting anything.
- Earthquakes cluster in time (aftershocks). Random cross-validation puts aftershocks of the same event in both training and test sets, which inflates skill badly.
- The facilitator is a statistician and Q&A is 30% of the grade. This framing is hard to defend.

## The data itself is good
- **GeoNet earthquake catalogue** (Earth Sciences NZ). CC BY 3.0 NZ. Download via QuakeSearch (CSV/GeoJSON), WFS, or FDSN web service.
  - Fields: origin time, latitude, longitude, depth, magnitude and magnitude type, event type, evaluation status, phase and station counts, azimuthal gap, uncertainties.
  - Volume: GeoNet locates ~20,000 earthquakes a year. The last 365 days show 22,086, of which 673 were M4+ and 83 were M5+.
- **NZ Ground-Motion Database (NZGMDB)** — built at UC (Bradley group) with QuakeCoRE.
  - v4.3: ~70,000 ground-motion records from 6,040 earthquakes (Mw > 3) at 393 stations, up to Dec 2024.
  - Intensity measures: PGA, PGV, spectral acceleration, Arias intensity, significant duration. Mainshock/aftershock flags.
  - Described as publicly available, but the download link isn't in the papers I could read [CONFIRM — ask the facilitator; it's UC's own database].

## Defensible versions
**A. Predict shaking, not earthquakes (NZGMDB) — recommended if you want earthquakes**
- **Regression:** given magnitude, distance, depth and site conditions, how strong is the ground shaking (PGA/PGV) at a station? This is how building codes set design loads — it's the honest version of "predict the size".
- **Discriminant analysis:** classify events as shallow crustal / subduction interface / deep slab from location and depth.
- **Trees:** shaking models; compare with linear regression.
- **Clustering:** stations by site response.

**B. Describe and classify seismicity (GeoNet catalogue)**
- **Clustering:** spatial-depth clusters → recover NZ's tectonic zones (Hikurangi subduction, Taupō Volcanic Zone, Alpine Fault, Fiordland).
- **Regression:** aftershock productivity — the number of M3+ aftershocks within 30 days and 50 km of a mainshock, on its magnitude, depth and region. Only a few hundred mainshocks, so n is small.
- **Forecast framing:** probability of an M4+ in a grid cell next year from past rates — explicitly a probability, not a prediction.

## Fit against the selection criteria
| | As proposed | Version A (NZGMDB) | Version B (catalogue) |
|---|---|---|---|
| Continuous target | ✘ not meaningfully predictable | ✔ PGA/PGV | ~ counts, small n |
| Module 4 methods | ~ clustering only | ✔ LDA, trees, clustering | ✔ clustering, LDA |
| Size | ✔ | ✔ ~70k records | ✔ events / ~ mainshocks |
| Cleaning / feature engineering | ~ | ✔ distance metrics, site joins | ✔ declustering, windows |
| Provenance | ✔ | ✔ (download [CONFIRM]) | ✔ |
| Non-technical story | ✔ but over-promises | ✔ "how hard will it shake here?" | ✔ |

## Verdict
**Drop "predict future earthquakes."** Keep earthquakes only as Version A, and only if the NZGMDB download is confirmed. The domain is also the furthest from anyone's existing expertise, which matters for Q&A.

## Sources
- USGS — Can you predict earthquakes?: https://www.usgs.gov/faqs/can-you-predict-earthquakes
- GeoNet earthquake catalogue: https://geonet.org.nz/data/types/eq_catalogue
- GeoNet earthquake statistics: https://www.geonet.org.nz/earthquake/statistics
- QuakeSearch: https://quakesearch.geonet.org.nz/
- NZGMDB 2023 (BSSA 114(1), doi:10.1785/0120230184): https://researchportal.northumbria.ac.uk/en/publications/the-2023-new-zealand-ground-motion-database/
- NZGMDB 2024 update (NZSEE 2025): https://repo.nzsee.org.nz/handle/nzsee/2790
- NZ Strong-Motion Database (older, 2017): https://www.geonet.org.nz/data/supplementary/nzsmdb
