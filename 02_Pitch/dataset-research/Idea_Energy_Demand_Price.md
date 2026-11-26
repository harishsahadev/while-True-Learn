# Idea — Electricity demand, supply and price + weather

_Researched 2026-10-12. [CONFIRM] = not yet verified; check on download._

## The idea as proposed
Find data on electricity usage and supply at given times, add weather and temperature, and predict
future demand and the cost of power at different times of day.

## Where the data actually is
Stats NZ's energy topic is the wrong place. Its energy statistics are aggregated surveys, not
half-hourly market data. The half-hourly data is on the Electricity Authority's EMI site.

| Need | Source | What's there (checked) |
|------|--------|------------------------|
| Demand | EMI › Wholesale › Datasets › Metered_data › `Grid_export` | Monthly CSVs `YYYYMM_Grid_export.csv`, ~1.6–3.6 MB each, back to at least Jan 2010. Half-hourly by grid point [CONFIRM column layout] |
| Supply (generation) | EMI › Generation › `Generation_MD` | Monthly CSVs from at least Jul 2008. Estimated generation (kWh) by plant, in trading periods TP1–TP48 (46 or 50 on daylight-saving days), with `Fuel_Code` and `Tech_Code` → hydro/wind/gas/geothermal share |
| Price | EMI › DispatchAndPricing › `FinalEnergyPrices/ByMonth` | `YYYYMM_FinalEnergyPrices.csv`, ~9–10 MB each, back to at least Nov 2014. Price per node per trading period |
| Hydro storage | EMI › Hydrological Modelling Dataset (HMD) | **Daily** storage for the 10 largest hydro lakes (incl. Wānaka, Hāwea, Pūkaki, Tekapo, Taupō), **1980–2022 only**. Current storage isn't free — the Authority pays for it and can't republish (EMI forum) |
| Weather | Open-Meteo Historical Weather API | Hourly temperature, wind, precipitation from ERA5 (0.25°, from 1940) / ERA5-Land (0.1°, from 1950). CC BY 4.0. R packages exist (`openmeteo`, `ropenmeteo`) |
| Weather (alt.) | Earth Sciences NZ DataHub (replaces CliFlo) | Station data, free for non-commercial use with registration. Minimum download is one parameter × one station, and you can't pick a date range |

Licence for EMI data isn't stated on the dataset pages — cite the Electricity Authority, and check terms [CONFIRM].

## Fit against the selection criteria
- Continuous target: ✔ demand (MWh per half hour) and price ($/MWh).
- Module 4+ methods: ✔ natural fits all round.
  - **Clustering:** k-means or hierarchical on daily 48-period load shapes (weekday/weekend/winter/summer profiles). A textbook use.
  - **Discriminant analysis:** price-spike vs normal trading periods.
  - **Trees:** demand and price.
- Size: ✔ 2015–2022 national half-hourly ≈ 140,000 rows; more if regional.
- Cleaning / feature engineering: ✔✔ wide trading-period columns, daylight-saving 46/50-period days, grid-point aggregation, joining hourly weather to half-hourly data, holiday flags.
- Story for a non-technical audience: ✔ "why power costs more on a cold, still winter evening".

## Problems with the idea as stated — and how to fix them

1. **It's a time series.** Random k-fold cross-validation trains on the future and tests on the past, which inflates accuracy. Validation has to be time-ordered (train 2015–2020, test 2021–2022, or rolling-origin). Not a blocker, and a good thing to justify in Q&A.
2. **"Predict future demand" needs future weather.** With historical weather, the model answers "what demand do we expect *given* this weather and time", not a true forecast. Word the research question that way, or say plainly that it's a what-if model.
3. **Weather is a weak driver of price.** NZ wholesale price is driven mainly by hydro storage and inflows, gas availability, and outages. Temperature moves demand, which moves price a little. A price model with weather alone will look poor.
   - Fix: limit the price question to 2015–2022 so free hydro storage can be included, plus wind-generation share from `Generation_MD`.
   - Price has extreme spikes, so frame it as classification (spike vs normal period) rather than point regression.
4. **Data assembly is the biggest workload risk.** Four sources, three time resolutions (daily lakes, hourly weather, half-hourly market). Budget a week for joins before any modelling.

## Reframed research questions
1. **Regression:** how much of half-hourly national demand is explained by temperature, time of day, day type (weekday/weekend/holiday) and season?
2. **Clustering:** what distinct daily demand profiles exist, and what weather/calendar conditions produce each one?
3. **Discriminant / trees:** which conditions (low hydro storage, low wind, cold peak, time of day) separate price-spike trading periods from normal ones?

## Verdict
**Strong candidate — if reframed** away from "predict the future price". Best Module 4 fit of everything researched so far.
The main risk is assembly effort, not suitability.

## Open questions
- Which weather points: one national average, or the three main load centres (Auckland, Wellington, Christchurch) population-weighted?
- National or regional demand? Regional adds clustering options but multiplies data size.
- Check the `Grid_export` column layout and whether it includes embedded generation (rooftop solar is invisible to grid data).

## Sources
- EMI wholesale datasets: https://www.emi.ea.govt.nz/Wholesale/Datasets
- Grid export: https://www.emi.ea.govt.nz/Wholesale/Datasets/Metered_data/Grid_export
- Generation_MD: https://www.emi.ea.govt.nz/Wholesale/Datasets/Generation/Generation_MD
- Final energy prices by month: https://www.emi.ea.govt.nz/Wholesale/Datasets/DispatchAndPricing/FinalEnergyPrices/ByMonth
- HMD storage description (2022): https://emi.ea.govt.nz/Environment/Datasets/HydrologicalModellingDataset/3_StorageAndSpill_20221231/HMD_Report3_StorageAndSpillDescription_2022.pdf
- EMI forum — hydro storage availability: https://forum.emi.ea.govt.nz/thread/hydro-storage-data/
- Open-Meteo historical API: https://open-meteo.com/en/docs/historical-weather-api
- Open-Meteo licence: https://open-meteo.com/en/licence
- Earth Sciences NZ DataHub / CLIDB: https://data.niwa.co.nz/pages/clidb-on-datahub
