# Raw data (not in the repository)

The raw files are about 1.5 GB, too large for GitHub. All are public Stats NZ releases (CC BY 4.0).
Only `01_rq1_data_preparation.Rmd` reads them; the later notebooks start from `data/processed/`,
which is in the repository.

To re-run Step 1, place the files like this:

```
data/raw/
├── building-consents-issued-august-2026.zip
├── new-dwellings-consented-by-statistical-area-2-august-2026.zip
├── extracted/                      ← unzip both zips here (13 CSV files)
│   ├── Building consents by territorial authority (Monthly).csv
│   ├── Building consents by region (Quarterly).csv
│   ├── New dwellings consented per 1000 residents by territorial authority (Annual).csv
│   └── ... (10 more)
└── external/cgpi/
    └── business-price-indexes-june-2026-csv.csv   ← from the CGPI zip
```

Sources:

* Building consents issued: August 2026
  <https://www.stats.govt.nz/information-releases/building-consents-issued-august-2026>
* Business price indexes: June 2026 quarter (Capital Goods Price Index)
  <https://www.stats.govt.nz/information-releases/business-price-indexes-june-2026-quarter/>
