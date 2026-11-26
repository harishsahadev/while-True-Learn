# RQ2 — the three builds side by side

_Stage 1 of `RQ2_Rebuild_Plan.md`. A note for the group meeting of Tue 17 Nov, not part of the notebook. Written 2026-11-16 from the two branches as downloaded that day: `niwesh` at commit `37cd136` and Harish's at `4e9f105` (both in `04_Analysis/`, see `BRANCH_EXTRACTS.md`)._

**How to read the Boulton column.** It is the rebuild design (65 districts, cost in), recomputed in Python on 16 Nov from `rq1_district_quarter_full.csv`. It reproduces the first look exactly. It is not yet the R knit: every Boulton number here is replaced from `04_RQ2_v2.Rmd` once that exists. Niwesh's members are read from his `outputs/tables/rq2/t08_district_membership.csv`; Harish's from the members table in his knitted `q2_clustering.html`, because his derived data are not in the branch.

## 1. What each build did

| | Boulton (rebuild) | Niwesh | Harish |
|---|---|---|---|
| Notebook | `04_RQ2_v2.Rmd` (planned) | `analysis/rq2_clustering/01_rq2_district_features.Rmd`, `02_rq2_clustering.Rmd` | `R/scripts/04_q2_profiles.R`, `R/analysis/q2_clustering.Rmd` |
| Data | Niwesh's district-quarter table | His district-quarter table | His own cleaning of the Stats NZ files |
| Districts | **65**: a district is in if it consented 100 or more new dwellings in 2016–25. Drops Chatham Islands (34) and Kawerau (92) | **66**: Chatham Islands dropped by name. Kawerau kept ("small but kept; we keep an eye on it") | **67** in the headline. A sensitivity run drops the districts under 100 dwellings (the same two) and the other 65 keep their cluster |
| Window | 2016–2025, calendar years | 2016Q3–2026Q2, the last 40 quarters; volatility from 2006–2025 | 2015–2025, 11 calendar years |
| Inputs | 7: `multi_share`, `retire_share`, `house_m2`, `per1000`, `growth`, `alt_share`, `rel_cost` | 9: `apt_share`, `retire_share`, `town_share`, `dwell_per_1000`, `growth`, `volatility`, `rel_cost`, `house_m2`, `nonres_share`. `house_share` and `alt_share` dropped on VIF | 10: `share_townhouses`, `share_apartments`, `share_retirement`, `real_m2`, `m2_per_house`, `alt_share`, `nonres_area_share`, `growth`, `volatility`, `per1000` |
| Cost as an input | Yes: log of district real $/m² over New Zealand's | Yes: the same, against all other districts | Yes: real $/m² as a level |
| Transformations | None | Square root of the shares; log of `dwell_per_1000` and `volatility` | None |
| Scaling | `scale()` | `scale()` | `scale()` |
| `nstart` | 20 as the lab, 50 if 20 is not stable | 50 | 100 |
| Silhouette at k = 2 / 3 / 4 | 0.230 / 0.213 / 0.192 | 0.216 / 0.208 / 0.178 | 0.217 / 0.222 / 0.224 |
| How k was chosen | Three is the group's choice. The lab's rule (highest silhouette) gives two | Five criteria. Silhouette and Calinski–Harabasz are highest at two; bootstrap stability is highest at three (0.84), so three | Best silhouette among solutions whose smallest cluster has five or more districts. k = 4 has a cluster of three, so three. The gap statistic picks one |
| k | 3 | 3 | 3 |
| Sizes: slow / urban / house-building | **25 / 14 / 26** | **21 / 15 / 30** | **26 / 9 / 32** |
| Names | slow provincial / urban multi-unit / house-building | Slow provincial districts / Urban medium-density / House-building districts | Regional low-intensity / Urban multi-unit / House-building belt |
| Silhouette by type, same order | 0.29 / 0.02 / 0.25 | 0.19 / 0.09 / 0.28 | Plotted, not printed |
| Cost by type, same order | −7% / +7% / −3% against NZ (means) | −8.3% / +4.9% / −4.2% against other districts (medians) | $3,026 / $3,389 / $3,155 per m² (medians, real) |
| Trees cut at 3 | Complete 55 / 8 / 2; single and average 63 / 1 / 1 | Single 64 / 1 / 1; complete 44 / 20 / 2; average 62 / 2 / 2; Ward 34 / 20 / 12 | Ward 31 / 28 / 8; complete 38 / 28 / 1; average 65 / 1 / 1 |
| What it says about the structure | Flat curve, 0.19–0.23 | "The cluster structure is weak"; a continuum | "A continuum, not islands" |

This settles open question 1 of the plan. The sizes heard on 15 Nov added to 66 and 67 because neither headline drops both small districts: Niwesh drops one and Harish drops none.

## 2. District by district

Compared on the 65 districts all three builds cluster. Kawerau is slow in Niwesh's and Harish's builds; Chatham Islands is slow in Harish's.

**All three builds give the same type to 53 of the 65 districts (82%)**: 20 slow, 8 urban, 25 house-building. In the other 12, two builds always agree and one differs; there is no district the three place in three different types.

| Pair | Same type | Of |
|---|---|---|
| Boulton and Niwesh | 57 | 65 |
| Boulton and Harish | 58 | 65 |
| Niwesh and Harish | 56 | 65 |

Rows are Boulton's types; columns are the other build's.

| Boulton ↓ | Niwesh: slow | urban | house-building | | Harish: slow | urban | house-building |
|---|---|---|---|---|---|---|---|
| slow (25) | 20 | 2 | 3 | | 24 | 1 | 0 |
| urban (14) | 0 | 12 | 2 | | 0 | 8 | 6 |
| house-building (26) | 0 | 1 | 25 | | 0 | 0 | 26 |

### The 12 districts the builds place differently

| District | Boulton | Niwesh | Harish | Odd one out |
|---|---|---|---|---|
| Hastings | urban | urban | house-building | Harish |
| Napier | urban | urban | house-building | Harish |
| Nelson | urban | urban | house-building | Harish |
| Tauranga | urban | urban | house-building | Harish |
| Horowhenua | urban | house-building | house-building | Boulton |
| Kapiti Coast | urban | house-building | house-building | Boulton |
| Dunedin | slow | urban | urban | Boulton |
| Palmerston North | house-building | urban | house-building | Niwesh |
| Gisborne | slow | urban | slow | Niwesh |
| Central Hawke's Bay | slow | house-building | slow | Niwesh |
| Southland | slow | house-building | slow | Niwesh |
| Timaru | slow | house-building | slow | Niwesh |

Seven of the twelve are on the line between urban and house-building, and all seven are provincial cities or the Kapiti–Horowhenua coast. Two (Dunedin, Gisborne) are on the line between slow and urban. Three are slow in two builds and house-building in Niwesh's.

### The 53 districts all three agree on

- **Slow (20):** Buller, Clutha, Gore, Grey, Invercargill, Opotiki, Otorohanga, Rangitikei, Rotorua, Ruapehu, South Taranaki, South Waikato, Stratford, Tararua, Waimate, Wairoa, Waitomo, Westland, Whakatane, Whanganui.
- **Urban (8):** Auckland, Christchurch, Hamilton, Lower Hutt, Porirua, Queenstown-Lakes, Upper Hutt, Wellington.
- **House-building (25):** Ashburton, Carterton, Central Otago, Far North, Hauraki, Hurunui, Kaikoura, Kaipara, Mackenzie, Manawatu, Marlborough, Masterton, Matamata-Piako, New Plymouth, Selwyn, South Wairarapa, Tasman, Taupo, Thames-Coromandel, Waikato, Waimakariri, Waipa, Waitaki, Western Bay of Plenty, Whangarei.

## 3. What matters for Tuesday

1. **The three builds are one picture.** Different districts kept, different windows, 7, 9 and 10 inputs, and 53 of 65 districts still land in the same type. That is the evidence behind "our three separate builds each produced the same three kinds of market" (slides question 1).
2. **The urban type is where the builds differ.** It has 14, 15 and 9 districts. Eight are common to all three: the four big cities, the Hutt Valley and Porirua, and Queenstown-Lakes. Harish's nine are those eight plus Dunedin. Whether Hastings, Napier, Nelson and Tauranga are urban is the main thing a single group list has to decide.
3. **Dropping both small districts is my rule, not yet the group's.** Niwesh's notebook keeps Kawerau; Harish's headline keeps both. The effect is small either way: both districts are slow wherever they are included, and Harish's run without them moves nobody else. If the group adopts the 100-dwelling rule, the poster says 65; otherwise it says 66 or 67 and my notebook's count will not match it.
4. **Do Niwesh's inputs or window differ from D1 and D2 in a way that matters?** Not for the story. Cost is an input in all three builds, so D2 brings mine into line with the other two. His window is six months later than mine, he adds volatility and the non-residential share, splits multi-unit into townhouses and apartments, leaves out the alteration share and transforms the skewed inputs. Together that moves 8 of 65 districts against mine.
5. **None of the three picks k = 3 on the silhouette alone.** In mine and Niwesh's it is highest at two. In Harish's it is flat (0.217, 0.222, 0.224) and highest at four. All three notebooks say the structure is weak. The honest line for the poster is the one all three support: three useful types on a continuum.
6. **"Core" and "agreed by all three" are different sets.** My four runs (headline, cost out, 2011–25, 2021–25) leave 40 districts that never change type. 32 of those are also among the 53 the three builds agree on. In the urban type the two diverge. My core urban districts are Lower Hutt, Porirua and Wellington plus Hastings, Horowhenua, Kapiti Coast, Napier and Nelson, which the other builds dispute. Auckland, Christchurch, Hamilton, Queenstown-Lakes and Upper Hutt are urban in all three builds but not core: all five come out as house-building when only 2021–25 is used, and Queenstown-Lakes does in the other two re-runs as well.

## 4. Decisions this raises

1. **Which member list goes on the poster and in the app** (brief Q81). The three lists differ in 12 districts. Niwesh's app shows his.
2. **Districts: 65, 66 or 67** (point 3 above).
3. **What "firm" means on the poster and the slide** (plan open question 3, brief Q86). Options: my four-run core (40 of 65); agreement of the three builds (53 of 65); or both, with the 32 in common as the firmest. The slide currently says "40 of 65 districts keep their type however we slice it", and the scatter marks core districts solid.
4. **Type names**: three sets are in use (row "Names" above).

## 5. What was not checked

- The Boulton column against an R knit (Stage 4.1 and 4.2 of the plan).
- Neither teammate's notebook was re-run. Their numbers are as knitted in their branches.
- Harish's silhouette by type, which his notebook plots but does not print.
