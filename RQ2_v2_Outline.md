# `04_RQ2_v2.Rmd` — outline for the Stage 2.0 gate

_Written 2026-11-16 in the build chat, for item 2.0 of `RQ2_Rebuild_Plan.md`. Outline only: no notebook, script or figure has been written. Read first, in the plan's order: `Course_Labs/LabM7_Clustering_solution.Rmd`, `04_Analysis/Boulton/04_RQ2.Rmd` (v1), and the R Markdown conventions and Tool notes in the folder copy of `WORKING_BRIEF.md`. **Waiting on "proceed".** The status table and the points to settle were updated later the same day, after the two branches arrived and Stage 1 was done; the outline itself is unchanged._

## Where Stages 0 and 1 stand

| Item | State | Evidence |
|---|---|---|
| 0.1 Module 7 does not teach PCA | Done (Boulton, 16 Nov) | — |
| 0.2 Lab 7 solution in `Course_Labs/` | Done | 474 lines, 31 chunks, three packages; matches the plan |
| 0.3 Fresh zips of branch `niwesh` and Harish's branch | Done (16 Nov, later) | Extracted to `04_Analysis/while-True-Learn-niwesh_2026-11-15/` and `while-True-Learn-harish_2026-11-15/`; index in `04_Analysis/BRANCH_EXTRACTS.md` |
| 0.4 Boundary file | **Not done** | No `data-local-only/boundaries/`; no `.gpkg`, `.shp` or `.geojson` anywhere in the folder. Neither teammate's branch has one or draws a map |
| Stage 1, the three builds side by side | Done (16 Nov, later) | `04_Analysis/Boulton/RQ2_three_builds.md`: all three builds give the same type to 53 of 65 districts |
| Data for the build | Ready | `Boulton/data/rq1_district_quarter_full.csv`: 9,715 × 43, 67 districts, 1990Q2 to 2026Q2, every column `build_profile()` reads, no missing values in 2016–25 |
| The rule's numbers (D1) | Hold | Chatham Islands 34, Kawerau 92, Wairoa 151; 126 of 377,199; 65 districts at 100 or more. Kawerau 105 over 2011–25, Wairoa 103 over 2021–25 |

Nothing exists yet for v2: no `04_RQ2_v2.Rmd`, no `rq2_poster_figures.R`, and `04_Analysis/outputs/` is empty. `Claude outputs/rq23_checks/build_rq2_profile_pycheck.py` (10 Nov, v1's design) is the base for the independent check at 4.2.

## Outline, beside the lab's

Chunk counts are R chunks. "Same" means the lab's code with our object in place of `flea`.

### Front matter and opening

| Lab 7 solution | v2 |
|---|---|
| YAML: title, subtitle, `html_document` with toc, numbered sections, floating toc | Same, plus `author`. Title and subtitle as v1 |
| Style block: `.boxTask`, `.fill-in-blank`, `.answer` | `.boxNote` only |
| `setup`: chunk options, `library(tidyverse)`, `library(GGally)`, `library(cluster)` | Same three, then `set.seed(462)` and `data_root <- Sys.getenv("STAT462_RQ1_DATA", unset = "data")`, the line `03_RQ1.Rmd` and v1 already use |
| Three paragraphs: supervised against unsupervised; the `flea` data and its ground truth; the two methods, Euclidean distance throughout | Three paragraphs: the same turn from supervised to unsupervised, with our question; one profile per district from ten years of consents, and no ground truth to compare against; the two methods, Euclidean distance throughout |

### 1 Set up — lab 4 chunks, v2 7

| # | Lab 7 solution | v2: one line per chunk |
|---|---|---|
| 1 | `library(GGally)`; `data(flea)` | `quarters <- read.csv(file.path(data_root, "rq1_district_quarter_full.csv"))`; `dim(quarters)`. Reading: 9,715 rows, 67 districts by 145 quarters |
| 2 | — | A table of the seven inputs (what each measures, how it is built), then `build_profile(first_year, last_year)`: v1's function, unchanged apart from the comment on `rel_cost`, which is now an input |
| 3 | — | `profile_all <- build_profile(2016, 2025)`; `min_dwellings <- 100`; print the districts under it with their `dwellings`; `profile <- profile_all %>% dplyr::filter(dwellings >= min_dwellings)`; `dim(profile)`. **`.boxNote` 1: the rule and its numbers** |
| 4 | — | `inputs` (the seven names); `dat <- as.data.frame(profile[, inputs])`; `rownames(dat) <- profile$district`; `summary(dat)`. **`.boxNote` 2: what differs from the lab, with the reason for each** |
| 5 | — | `ggpairs(dat)`, defaults only: how the seven inputs relate. **Open question 1** |
| — | "Ground Truth" scatter coloured by `species` | None. There is no ground truth |
| 6 | "Cluster Data" scatter of `aede1` against `aede2` | `plot_data <- dat[, c("per1000", "multi_share")]`; the lab's chunk on those two columns |
| 7 | `plot_func(data, label, title)` | The lab's function |

### 2 k-means Clustering — lab 3 chunks, v2 3

| # | Lab 7 solution | v2: one line per chunk |
|---|---|---|
| — | The algorithm in three bullets | Same three steps |
| 8 | `dat <- flea[, c("aede1", "aede2")]`; `k.clus <- kmeans(dat, 3)`; `plot_func(dat, k.clus$cluster, ...)` | `set.seed(462)`; `k.clus <- kmeans(dat, 3)` on the seven inputs, unscaled as the lab starts; `plot_func(plot_data, k.clus$cluster, "k-means clustering result")` |
| 9 | `k.clus` | `k.clus`. Reading: sizes, cluster means, `tot.withinss`; then the objective in display math |
| 10 | `k.clus <- kmeans(dat, 3, nstart=20)`; plot; `k.clus$tot.withinss` | Same, with `set.seed(462)` first |

### 2.1 Scaling — lab 2 chunks, v2 2 (3 if `nstart = 20` fails)

| # | Lab 7 solution | v2: one line per chunk |
|---|---|---|
| 11 | "Ground Truth (Equal Scale on Both Axes)", with `coord_fixed()` | `apply(dat, 2, range)`: the range of each input. Reading: `house_m2` spans tens of square metres and the shares span fractions, and the unscaled clusters in chunk 9 are bands of house size |
| 12 | `set.seed(1)`; `scaled_dat <- scale(dat)`; `k.clus <- kmeans(scaled_dat, 3, nstart = 20)`; plot | Same with seed 462. **This `k.clus` is the clustering section 4 reports** |
| (12b) | — | Only if 20 starts do not give one answer from thirty seeds at build: one chunk that runs thirty seeds at 20 starts and at 50 and counts the different values of `tot.withinss`. Then 50 in every call, with one sentence saying why |

### 2.2 Silhouette coefficient — lab 5 chunks, v2 6

| # | Lab 7 solution | v2: one line per chunk |
|---|---|---|
| 13 | `kmeans.criterion` loop for k = 2…8 and its plot | Same, on `scaled_dat` |
| — | Cohesion, separation, $s(x_j)$ and $S(C)$ | Same definitions and formulas |
| 14 | `dist_matrix <- dist(scaled_dat)`; `sil <- silhouette(k.clus$cluster, dist_matrix)`; `sil` | Same |
| 15 | `summary(sil)` | Same |
| 16 | `summary(sil)$avg.width` | Same |
| 17 | `sils` loop for k = 2…8 and its plot | Same; `plot_dat` is also printed, so the seven values are in the knit |
| — | "highest at k = 3, which means 3 clusters is the most appropriate choice" | One paragraph: read the lab's way the curve says two; how flat and how low it is (0.25 or less is no substantial structure: Kaufman & Rousseeuw, 1990); why three is reported |
| 18 | — | `set.seed(462)`; `k.clus2 <- kmeans(scaled_dat, 2, nstart = 20)`; `table(k2 = k.clus2$cluster, k3 = k.clus$cluster)`. Reading: where each of the three clusters goes when there are two |

### 3 Hierarchical Clustering — lab 9 chunks, v2 8

| # | Lab 7 solution | v2: one line per chunk |
|---|---|---|
| — | What the method does, in two bullets; the three linkages | Same |
| — | **3.1 Complete linkage**: formula | Same |
| 19 | Prepare the data again; `hc.complete <- hclust(dist_matrix, method = "complete")`; dendrogram | `hc.complete <- hclust(dist_matrix, method = "complete")` on the `dist_matrix` from 2.2; dendrogram in a wide figure at `cex = 0.7`, so 65 names can be read |
| — | `abline()` at six heights | Left out (plan 2.5) |
| — | `rect.hclust(hc.complete, h = 3.6, ...)` | Left out (plan 2.5) |
| 20 | Dendrogram with `rect.hclust(hc.complete, k = 3, border = "red")` | Same |
| 21 | — | `table(cutree(hc.complete, 3))` and the names of the districts outside the largest cluster |
| 22 | `plot_func(scaled_dat, cutree(hc.complete, 3), "Complete Linkage")` | `plot_func(plot_data, cutree(hc.complete, 3), "Complete Linkage")`. One sentence naming what the tree set apart |
| — | **3.2 Single linkage**: formula | Same |
| 23 | `hc.single`; dendrogram; `rect.hclust(k = 3)` | Same |
| 24 | `plot_func(...)` | Sizes and names as in chunk 21, then `plot_func(plot_data, cutree(hc.single, 3), "Single Linkage")`. One sentence |
| — | **3.3 Group average linkage**: formula | Same |
| 25 | `hc.average`; dendrogram; `rect.hclust(k = 3)` | Same |
| 26 | `plot_func(...)` | Sizes and names, then `plot_func(plot_data, cutree(hc.average, 3), "Average Linkage")`. One sentence |
| — | — | Closing paragraph, no chunk: what the three trees have in common. They set unusual districts apart first, so this section is a cross-check and an outlier finder |
| — | "Give it a go" on `tars1` and `tars2`, 7 chunks | None |

### 4 The three market types — ours, 9 chunks

| # | v2: one line per chunk |
|---|---|
| 27 | `name_types(cluster, data)`, the D4 rule as a short function: slow provincial is the cluster with the lowest mean `per1000`; urban multi-unit is the one of the other two with the higher mean `multi_share`; the third is house-building. `profile$type <- name_types(k.clus$cluster, dat)`; `table(profile$type)` |
| 28 | Means by type in original units: `profile %>% group_by(type) %>% summarise(...)` with `n()`, `sum(dwellings)` and the seven means written out one per line; then each type's share of the 65 districts' new dwellings and its cost against the country as a percentage |
| 29 | The members of each type, printed in full |
| 30 | `sil <- silhouette(k.clus$cluster, dist_matrix)` again; `profile$sil`; the mean by type; the names of the districts below zero |
| 31 | Cost left out, same 65 districts: six inputs, `scale()`, `set.seed(462)`, `kmeans()`, `name_types()`; `table(profile$type, type_nocost)`; the number that keep their type; mean `rel_cost` by the cost-out types. This is the check that is not circular |
| 32 | 2011–25: `build_profile(2011, 2025)`, kept to the same 65 districts with `ta %in% profile$ta`, then the same four steps; cross-table and the number that keep their type |
| 33 | 2021–25: the same |
| 34 | `profile$core`: `TRUE` where the type is the same in all four runs (headline, cost out, 2011–25, 2021–25); `table(profile$type, profile$core)` |
| — | The answer to RQ2 in three short paragraphs. **`.boxNote` 3: limitations.** Sources in APA 7: Stats NZ, Kaufman & Rousseeuw (1990), the lab acknowledged, and the line on AI use the brief requires |
| 35 | `dir.create("../outputs/rq2", ...)`; `write.csv()` of `district`, `ta`, the seven inputs, `type`, `sil`, `core` to `../outputs/rq2/rq2_types.csv`. `*End of document*` |

## Size against the lab

| | Lab 7 solution | v2 (estimate) | v1 |
|---|---|---|---|
| R chunks, with `setup` | 31 (24 without the "Give it a go" block) | 36; 37 with chunk 12b; 35 without `ggpairs()` | 51 |
| Of which sections 1–3 | 24 | 27 | — |
| Of which section 4 | — | 9 | — |
| Lines | 474 | about 550 | 1,098 |
| Packages loaded | 3 | 3 | 4 |
| Functions defined | 1 (`plot_func`) | 3 (`build_profile`, `plot_func`, `name_types`) | 9 |

The three extra chunks in sections 1–3 are the data build (chunks 2 to 4), which the lab does not need because `flea` arrives ready. The line estimate assumes prose on long lines, one paragraph per line, as Lab 7 has it. v1 is wrapped at 72 characters, which is part of its 1,098, so wrapping v2 the same way would add roughly 150 lines without adding content.

## What the plan says leaves v1 — checked against the outline

Gone: the histogram grid and the table of extremes; `relabel()` and `cluster_plot()`; "Two and four clusters beside it" (the one cross-table kept is chunk 18); `small_clusters()` and the twelve-cut table; the outliers table; `agreement()` and its permutations; the four-outlier run; the region R² table and both `lm()` regressions; the separate cost-in section. The thirty-run `nstart` demonstration is gone unless chunk 12b is needed.

Also gone, though the plan does not list them: `gridExtra`, `knitr::kable()`, `map_dfr()`, `pivot_longer()`, `across()`, `tapply()`, `stopifnot()`, the per-district silhouette bar chart and the cost box plot. None of them is in the lab, and the outline does not need them.

## Functions v2 uses that the Lab 7 solution does not call

This is the draft of the list for `.boxNote` 2, checked against the code chunks of all eleven lab files. The final list is generated from the parsed code at 4.3, not by eye.

- **Taught in another course lab:** `read.csv()`, `write.csv()`, `group_by()`, `summarise()`, `n()`, `mutate()`, `dplyr::filter()`, `dplyr::select()`, `%in%`, `dim()` (Lab 1); `as.data.frame()` (Lab 0); `table()` (Lab 1, M3); `apply()` (M3, M4); `range()` (M5); `which.min()` (M5, M6); `paste()`, `round()`, `log()`, `exp()` (M1 to M4).
- **In no course lab, each with its reason:** `rownames()` (puts district names on the dendrograms and in the `kmeans()` output); `str_remove()`, `n_distinct()` and `%/%` (inside `build_profile()`, kept as v1 has it); `which.max()` (in `name_types()`, the twin of `which.min()`); `file.path()` and `Sys.getenv()` (the project's one-line data path); `dir.create()` (the output folder); `ggpairs()` if it stays.

## Design choices made in the outline, and what was rejected

1. **`plot_func()` gets a two-column data frame, `plot_data`, never `dat`.** The lab's function takes the label from `colnames(data)[3]` after adding a `label` column, so it works only on two columns. On the seven-column `dat` it would colour by the third input and fail. Rejected: changing the lab's function.
2. **`set.seed(462)` goes before every `kmeans()` call.** The lab leaves its first two calls unseeded so students see the result change. Ours has to give the same knit twice, because the prose quotes it.
3. **Section 4 recomputes `sil`.** The lab's loop in 2.2 assigns `sil` inside the loop, so after it `sil` holds k = 8. v2 keeps the lab's loop as written and recomputes in chunk 30.
4. **One helper in section 4, `name_types()`, and the three re-runs written out longhand.** Rejected: a second helper that scales, clusters and names in one call. It would save about ten lines and hide the four steps I have to explain. Because every run is named by the same rule, "keeps its type" is `sum(type == type_other)`, which is what lets `agreement()` and its permutations go.
5. **Group means with the seven `mean()` lines written out.** Rejected: `across()`, `aggregate()` and `tapply()`, none of which is in a course lab.
6. **`read.csv()` and `write.csv()`, as Lab 1 teaches,** where v1 used `read_csv()`. `build_profile()` works on either.
7. **Plain printed tables, no `knitr::kable()`.** No course lab uses it.
8. **The cross-table in chunk 18 shows cluster numbers, not type names.** The plan puts it in 2.2 and the naming in section 4. The reading sentence says which cluster is which; section 4 gives it its name.
9. **`rq2_types.csv` carries `ta` as well as `district`.** The plan lists `district` only; the map joins to the boundary file on the full name ("Selwyn District"), which is `ta`.
10. **"Core" is defined on four runs.** The first look's 40 of 65 was on five, the fifth being the 67-district run that v2 does not make. Expect a number at or above 40; it is read from the knit.

## Points to settle at the gate

1. **`ggpairs()`: keep or drop** (plan open question 2, brief Q91). New fact: no course lab calls `ggpairs()`. Lab 7 loads `GGally` only to get the `flea` data, so in v2 `ggpairs()` would be the only thing `GGally` does. Keep it, and the package earns its place but the function is an addition to explain. Drop it, and either `library(GGally)` stays as an unused line or v2 loads two packages. Recommendation: keep one chunk with default arguments. Every cluster picture shows two of the seven inputs, and this is the only view of all seven; it also shows the `per1000` and `alt_share` relationship that makes the slow provincial type the firm one.
2. **How closely the explanations follow the lab's wording.** The convention of 3 Nov says lab code is a pattern, not a source, and is rewritten in our own words. D6 says the Lab 7 solution is the template for design, code and explanations. Proposed reading: the lab's code patterns and object names, acknowledged in the sources; the lab's order and rhythm of paragraph, chunk, reading sentence; every sentence written fresh about our data, none carried over. Say if D6 meant closer than that.
3. **`nstart`.** Tested at build on `scaled_dat` with k = 3, thirty seeds. Expect 20 to fail: on v1's design (67 districts, six inputs) single starts reached the best answer in 4 of 30 runs, which puts the chance that twenty starts all miss it at about 6% per run. The new design may behave differently, which is why it is tested. If it fails, chunk 12b goes in and every call uses 50.
4. **The map is waiting on 0.4.** Without the boundary file, the figures script exports the profile chart and the scatter and skips the map (plan open question 5). Stage 1 is done (`RQ2_three_builds.md`).
5. **What "core" means, now that the three builds can be compared** (plan open question 3). The four-run core in chunk 34 is 40 districts; the three builds agree on 53; 32 are in both. In the urban type the two sets differ (see section 3, point 6 of `RQ2_three_builds.md`). Chunk 34 stays as outlined unless you want the teammates' types read in as well, which would need their two member lists as small CSV inputs beside the data.

## After "proceed"

R is not installed in the cloud workspace this session, so the first step is the install from the Ubuntu archive (about 15 minutes, as on 10 Nov). Then 2.1 to 2.8 in order, a test knit, every number in the prose read from it, the Python check at 4.2, and the file is committed to `04_Analysis/Boulton/04_RQ2_v2.Rmd`. Stage 3 follows the knit.
