# RQ2 rebuild plan — `04_RQ2_v2.Rmd`

_Plan 1 of 3 (with `Poster_Q2_Plan.md` and `Slides_Q2_Plan.md`). Created 2026-11-16 from the group meeting of Sun 15 Nov, the knitted `04_RQ2.Rmd` and a first look run the same day. **Revised 2026-11-16 (later)** on Boulton's answers: the Lab 7 solution is the template, the under-100 rule is confirmed, PCA is out, the supplementary zip is one per member. Owner: Boulton. Target: member list and figures to the group before the Tue 17 Nov meeting._

**To use in a new chat:** open a chat in the STAT462 project with the project folder connected and say _"Work through `RQ2_Rebuild_Plan.md` from Stage 0. Stop at each gate."_ Before writing anything the chat reads, in this order: `Course_Labs/LabM7_Clustering_solution.Rmd` (the template), `04_Analysis/Boulton/04_RQ2.Rmd` (v1), and the R Markdown conventions and Tool notes in `WORKING_BRIEF.md`.

## PRD

**Problem.** I own Q2 on the poster and the slides, and my notebook is not fit for that yet. Two changes are mine to make: drop the two smallest districts, and bring the notebook back to the Lab 7 pattern. v1 is 1,098 lines and 51 chunks against the lab's 474 and 31, with helpers and whole sections the lab does not have, and I have to be able to explain every line in Q&A. Two more came out of the meeting: the three of us have three different sets of groups (mine 22 / 16 / 29 on 67 districts; Niwesh's 21 / 15 / 30 and Harish's 26 / 9 / 32 as heard), and groups 1 and 3 sit on top of each other in my scatter.

**Success criteria.**
- Someone who has done Lab 7 can read `04_RQ2_v2.Rmd` top to bottom without meeting a function or a section the lab did not teach, apart from the additions listed in one `.boxNote` with the reason for each.
- Sections 1 to 3 follow `LabM7_Clustering_solution.Rmd` in order, in code and in the way each step is explained.
- The under-100 rule is applied in code as a rule, not by naming two districts.
- One headline result: three named market types on 65 districts, with a member list I have sense-checked.
- It knits on my machine from `data/rq1_district_quarter_full.csv` with no edits. Every number in the prose is read from the knit.
- Three figures for the poster and slides in `04_Analysis/outputs/rq2/`.
- I can answer the twelve questions in `Slides_Q2_Plan.md` without notes.

**Scope.** In: `04_RQ2_v2.Rmd`; a short figures script, `rq2_poster_figures.R`; a one-page comparison of the three builds for Tuesday; updates to `RQ2_RQ3_Roadmap.md` and `WORKING_BRIEF.md`. Out: PCA in any form; any change to `04_RQ2.Rmd`, `04_RQ2.html`, `03_RQ1.Rmd` or `05_RQ3.Rmd`; Ward linkage, gap statistic, Calinski–Harabasz, BIC; Auckland local boards; the Shiny app; the poster and slide files (plans 2 and 3).

**Constraints.** The notebook loads the lab's three packages and no others: `tidyverse`, `GGally`, `cluster`. Methods are the lab's: `scale()`, `kmeans()`, `silhouette()`, `dist()`, `hclust()` with complete, single and average linkage, `cutree()`, `rect.hclust()`. `sf` appears only in the figures script. No data in the repo or the zip. The group finalises the poster Tue 17 Nov; poster and slides are due Sun 22 Nov; my supplementary zip is due Sun 29 Nov.

## Decisions (Boulton, 16 Nov)

| # | Decision | Status |
|---|---|---|
| D1 | **65 districts, by rule** (below). | Confirmed. Was: all 67 kept. |
| D2 | **Cost is a clustering input.** `rel_cost` is the seventh input. "The types differ in cost" is description, not a finding; one cost-out run stays as the check that is not circular. | Reverses 10 Nov decision 3. |
| D3 | **Three pictures**: NZ map by type, type profile chart, scatter with a log axis. **No PCA anywhere** — Module 7 does not teach it. | Amended the same day; the PCA scatter chosen earlier is withdrawn. |
| D4 | **k = 3, named types.** Slow = lowest mean `per1000`; urban = higher mean `multi_share` of the other two; the third is house-building. Working names: slow provincial · urban multi-unit · house-building. | Stands. See the note on the lab's rule below. |
| D5 | **New file.** `04_RQ2.Rmd` and its HTML are what the group saw on 15 Nov and are not touched. | Stands. |
| D6 | **`LabM7_Clustering_solution.Rmd` is the template** for design, code and explanations. | New. |
| D7 | **Supplementary zip is one per member.** | New. Closes brief Q85. |

### The rule (D1)

> A district is clustered only if it consented **at least 100 new dwellings in the profile window, 2016–2025**. The test is made once, on that window, and the same districts are used in every other run.

- **Why 100.** The profile's shares are dwellings divided by dwellings. Under 100, one dwelling moves a share by more than one percentage point: 2.9 points at 34 dwellings, 1.1 at 92.
- **What it removes.** Chatham Islands (34) and Kawerau (92): 126 of 377,199 new dwellings. 65 of 67 districts stay. The next smallest is Wairoa at 151, so nothing sits near the line.
- **Why one window.** Applied window by window the set would change: Kawerau has 105 over 2011–25, and Wairoa only 103 over 2021–25.
- **In code**, after `build_profile()` has run on all 67 so that `rel_cost` stays relative to the whole country:

```r
min_dwellings <- 100
profile <- profile_all %>% dplyr::filter(dwellings >= min_dwellings)
```

## How v2 follows the lab (D6)

| Lab 7 solution | v2 | What differs for our data |
|---|---|---|
| Opening paragraphs | Same | The question, the data, the two methods, Euclidean distance throughout |
| 1 Set up — load `flea`, two-variable plots, `plot_func()` | 1 Set up | Read the table, `build_profile()`, the rule, `dat` with seven inputs; "Cluster Data" on `per1000` × `multi_share`; `plot_func(data, label, title)` in the lab's form |
| 2 k-means Clustering — the algorithm in three bullets, `kmeans(dat, 3)`, the printed model, the objective, `nstart` | 2 k-means Clustering | Same order, unscaled first as the lab does |
| 2.1 Scaling | 2.1 Scaling | The ranges of the seven inputs, `scale()`, re-run |
| 2.2 Silhouette coefficient — criterion against k, the definition, `silhouette()`, loop over k = 2…8 | 2.2 Silhouette coefficient | Same, then what the curve says about k |
| 3 Hierarchical Clustering — 3.1 complete, 3.2 single, 3.3 group average; each a dendrogram, `rect.hclust()`, `cutree()`, `plot_func()` | 3 Hierarchical Clustering | Same three, each closed with one sentence naming what the tree set apart |
| — | 4 The three market types | Ours: means, members, silhouette by type, the cost-out check, two other windows, limitations, sources |

**Kept from the lab as written:** object names (`dat`, `scaled_dat`, `k.clus`, `dist_matrix`, `sil`, `sils`, `kmeans.criterion`, `hc.complete`, `hc.single`, `hc.average`), the `for (k in 2:8)` loops, `summary(sil)$avg.width`, base `plot()` for dendrograms, and the rhythm of a short paragraph, a chunk, and a sentence reading the output. The lab is acknowledged in the sources.

**Deviations, each stated in the notebook:** seed 462, the project seed, where the lab uses 1. `nstart`: try the lab's 20 over thirty seeds first and keep it if every seed agrees; otherwise 50, with one sentence saying why. No ground truth, so nothing to compare the clusters against. Seven inputs, so a cluster plot shows two of the seven. Types are named, not numbered.

**Leaves v1:** the histogram grid and the table of extremes; the thirty-run `nstart` demonstration if 20 passes; `relabel()` and `cluster_plot()`; "Two and four clusters beside it" (one cross-table stays); `small_clusters()` and the twelve-cut table; the outliers table; `agreement()` with its permutations; the four-outlier run; the region R² table and the `lm()` cost regressions; the separate cost-in section, which is now the headline.

**The lab's rule and k = 3.** The lab ends its silhouette section with "highest at k = 3, which means 3 clusters is the most appropriate choice". Read the same way, ours says two: 0.230 at k = 2 against 0.213 at k = 3 in the first look. Two groups are the slow provincial districts against everyone else (26 and 39). The notebook says this in so many words, then gives the reasons for reporting three: the curve is flat (0.19–0.23 for every k), the slow group is the same districts either way, and three adds the split the question asks about. In the meeting I called 3 the best score; that is the line to fix.

## What the first look found (16 Nov, Python, scratch — confirm in the R knit)

It reproduces the knitted v1 exactly on 67 districts (22 / 16 / 29; silhouette 0.244 / 0.227 / 0.241 at k = 2 / 3 / 4; complete linkage 62 / 4 / 1).

| | v1 as built (67, cost out) | 65, cost out | **65, cost in (chosen)** |
|---|---|---|---|
| k = 3 sizes: slow / urban / house-building | 22 / 16 / 29 | 23 / 27 / 15 | **25 / 14 / 26** |
| Silhouette at k = 2 / 3 / 4 | 0.244 / 0.227 / 0.241 | 0.254 / 0.229 / 0.217 | **0.230 / 0.213 / 0.192** |
| Silhouette by type at k = 3 | 0.41 / 0.04 / 0.19 | 0.36 / 0.12 / 0.24 | **0.29 / 0.02 / 0.25** |
| Cost against NZ by type | −7% / +3% / −1% | −7% / 0% / 0% | **−7% / +7% / −3%** |
| Complete linkage cut at 3 | 62 / 4 / 1 | 56 / 5 / 4 | **55 / 8 / 2** |

Chosen design, type by type (means): **slow provincial**, 25 districts — 3.4 dwellings per 1,000 residents a year, 23% of residential spending on alterations, 175 m² houses, 16% multi-unit, 6% of the 65 districts' new dwellings. **Urban multi-unit**, 14 — 48% multi-unit, 10% retirement units, 69% of new dwellings; its 7.7 per 1,000 is pulled up by Queenstown-Lakes (27.6). **House-building**, 26 — 8.5 per 1,000, 192 m² houses, 13% alterations, 24% of new dwellings.

Members in the first look. Slow: Buller, Central Hawke's Bay, Clutha, Dunedin, Gisborne, Gore, Grey, Invercargill, Opotiki, Otorohanga, Rangitikei, Rotorua, Ruapehu, South Taranaki, South Waikato, Southland, Stratford, Tararua, Timaru, Waimate, Wairoa, Waitomo, Westland, Whakatane, Whanganui. Urban: Auckland, Christchurch, Hamilton, Hastings, Horowhenua, Kapiti Coast, Lower Hutt, Napier, Nelson, Porirua, Queenstown-Lakes, Tauranga, Upper Hutt, Wellington. House-building: Ashburton, Carterton, Central Otago, Far North, Hauraki, Hurunui, Kaikoura, Kaipara, Mackenzie, Manawatu, Marlborough, Masterton, Matamata-Piako, New Plymouth, Palmerston North, Selwyn, South Wairarapa, Tasman, Taupo, Thames-Coromandel, Waikato, Waimakariri, Waipa, Waitaki, Western Bay of Plenty, Whangarei.

Three more things the notebook has to say plainly:

1. **Dropping the two districts was never the problem.** With cost in, 64 of the 65 keep their type whether or not they are included. With cost out, dropping them moves 14 of 65.
2. **The trees will not come out as three balanced groups.** On the chosen design they set Queenstown-Lakes and Wellington City apart (complete 55 / 8 / 2, single and average 63 / 1 / 1). Section 3 is a cross-check and an outlier finder.
3. **The urban type is a label, not a tight cluster.** Its silhouette is 0.02 and six of its fourteen are negative (Hastings, Horowhenua, Kapiti Coast, Porirua, Queenstown-Lakes, Tauranga). The slow provincial type is the firm one.

Stability: the same type as the headline for 56 of 65 with a 2011–25 window, 48 of 65 with 2021–25, 50 of 65 with cost out. 40 of 65 kept their type in all five first-look runs — 21 slow, 8 urban, 11 house-building.

## Plan

### Stage 0 — Before the build chat (Boulton)

- [x] 0.1 Module 7 does not teach PCA (16 Nov). Closes brief Q73.
- [x] 0.2 The Lab 7 solution is in `Course_Labs/LabM7_Clustering_solution.Rmd` (16 Nov).
- [x] 0.3 Download fresh zips of branch `niwesh` and of Harish's branch into **new** folders under `04_Analysis/`. Claude cannot reach the private repo. Needed: each RQ2 notebook with its member list, inputs, window and how k was chosen; Niwesh's editable poster file; the draft slides. The build does not wait for this; Stage 1 does. _Done 16 Nov: `04_Analysis/while-True-Learn-niwesh_2026-11-15/` (commit `37cd136`) and `04_Analysis/while-True-Learn-harish_2026-11-15/` (commit `4e9f105`); index in `04_Analysis/BRANCH_EXTRACTS.md`._
- [ ] 0.4 Boundary file for the map into `04_Analysis/data-local-only/boundaries/`. Check Niwesh's repo and app first; if there is none, download the Territorial Authority 2026 clipped, generalised layer from the Stats NZ Geographic Data Service (datafinder.stats.govt.nz) as a GeoPackage — confirm the exact layer title on the site. stats.govt.nz is blocked for Claude's shells, so this is a manual download. _16 Nov: neither teammate's branch holds a boundary file or draws a map, so this is the manual download._

### Stage 1 — The three builds side by side (a note for Tuesday, not part of the notebook)

- [x] 1.1 One table, three columns (Boulton, Niwesh, Harish): districts kept, window, inputs, scaling, `nstart`, how k was chosen, k, sizes, names.
- [x] 1.2 District-by-district cross-table of the three member lists; count the districts all three place in the same type.
- [x] 1.3 Save as `04_Analysis/Boulton/RQ2_three_builds.md`. If Niwesh's inputs or window differ from D1–D2 in a way that matters, say so before Tuesday. _Done 16 Nov: all three builds give the same type to 53 of 65 districts; the differences from D1–D2 move 8 districts against Niwesh's build and do not change the story._

### Stage 2 — Build `04_RQ2_v2.Rmd`

- [x] 2.0 **Gate.** Write the outline only — headings and one line per chunk — beside the lab's, and wait for my "proceed". _Outline written 16 Nov (`RQ2_v2_Outline.md`); waiting on "proceed"._ **"Proceed" given 16 Nov, with the `ggpairs()` chunk kept.**
- [x] 2.1 **Opening and Set up.** Opening paragraphs in the lab's manner. Read the table; `build_profile()` kept as it is; the rule; `dat` with seven inputs and district names as row names; `summary(dat)`. One `.boxNote` with the rule and its numbers, one listing the deviations from the lab. "Cluster Data" scatter. `plot_func()`.
- [x] 2.2 **k-means Clustering.** The algorithm in three bullets; `kmeans(dat, 3)` unscaled and what it found; the printed model; the objective in display math; the `nstart` test. _16 Nov: `nstart = 20` gives one answer from thirty seeds, so the lab's 20 is kept and there is no demonstration chunk._
- [x] 2.3 **Scaling.** Ranges of the seven inputs; `scale()`; `set.seed(462)`; re-run and plot.
- [x] 2.4 **Silhouette coefficient.** Criterion against k; the definition with cohesion and separation; `silhouette()` and `summary(sil)`; the loop for k = 2…8; the plot; the paragraph on two against three; a cross-table of the k = 2 groups against the k = 3 types.
- [x] 2.5 **Hierarchical Clustering.** Complete, single, group average, each as the lab does it: formula, `hclust()`, dendrogram, `rect.hclust(k = 3)`, `plot_func()` on `cutree()`. One closing paragraph on what the three trees have in common.
- [x] 2.6 **The three market types.** Name the types by the D4 rule. Means in original units; members; silhouette by type and the districts below zero; the cost-out run on the same 65; the same clustering on 2011–25 and 2021–25 with a count of districts that keep their type; a `core` column. Answer to RQ2 in three short paragraphs. Limitations in a `.boxNote`. Sources in APA 7 with the line on AI use the brief requires.
- [x] 2.7 Last chunk writes `04_Analysis/outputs/rq2/rq2_types.csv` (district, the seven inputs, type, silhouette, core) for the figures script. It is an output kept on my machine, not something for the zip.
- [x] 2.8 Size check against the lab: v2 should land nearer the lab's 474 lines and 31 chunks than v1's 1,098 and 51. If it runs well past about 650 lines, say what is driving it. _16 Nov: 737 lines and 37 chunks. Past 650: sections 1 to 3 with the opening are 505 lines and 28 chunks, close to the lab; section 4, which the lab does not have, is 233 lines and 9 chunks._

### Stage 3 — Figures script `rq2_poster_figures.R`

Kept out of the notebook so the notebook reads like the lab. Rejected: a figures section inside the notebook, which keeps one file but puts `sf` and palette code into it.

- [x] 3.1 Read `rq2_types.csv`. Type profile chart: one panel per type, bars in standard deviations from the average district, plain-English labels.
- [x] 3.2 Scatter of `per1000` (log axis) against `multi_share`, coloured by type, core districts solid and borderline hollow, about eight districts labelled. _16 Nov: solid means firm on both tests (four-run core and three-build agreement, 32 of 65); six districts labelled, because 18 pt text leaves room for no more._
- [ ] 3.3 Map: `sf::st_read()`, join on the ASCII name field, 65 districts filled by type, Kawerau grey as "not clustered", Chatham Islands outside the frame with a caption line. Skipped with a message if the boundary file is absent. _16 Nov: written, and run only on a made-up grid of squares. Not ticked until it has run on the real boundary file (0.4)._
- [ ] 3.4 `ggsave()` to `04_Analysis/outputs/rq2/` at the sizes in `Poster_Q2_Plan.md`: `rq2_map_types.png`, `rq2_profile_types.png`, `rq2_scatter_log.png`. _16 Nov: the profile chart and the scatter export; at 18 pt they need 200 x 140 mm and 180 x 150 mm, not the poster plan's 200 x 110 and 180 x 120. Previews in `Claude outputs/rq2_v2_checks/`. Not ticked until run on Boulton's machine with the map._

### Stage 4 — Verify

- [x] 4.1 Test knit in Claude's cloud workspace (R from the Ubuntu archive, as on 10 Nov; `r-cran-sf` for the script). Read every table before writing prose.
- [x] 4.2 Independent check of the membership in Python against the knit; expect 25 / 14 / 26. A difference is investigated, not explained away.
- [x] 4.3 Style check against the lab and the house conventions: `<-`, `%>%`, `dplyr::select()`, no non-ASCII in chunks, no package beyond the three. Open each figure and look at it.
- [x] 4.4 Knit on my machine. Report any error with the chunk's first line. _17 Nov: knitted by Boulton (`04_RQ2_v2.html`). His `rq2_types.csv` matches the reference knit exactly: 65 districts, the same types, the same core, numeric difference 0. `rq2_poster_figures.R` has not been run on his machine yet (3.4)._

### Stage 5 — Understand and defend (Boulton)

- [ ] 5.1 Read v2 beside the lab solution, section by section. Mark any chunk I could not explain; Claude simplifies or removes it.
- [ ] 5.2 Sense-check the member list against what I know of the districts.
- [ ] 5.3 Answer the questions in `Slides_Q2_Plan.md` aloud.

### Stage 6 — Share

- [ ] 6.1 Commit `04_RQ2_v2.Rmd`, its HTML and `rq2_poster_figures.R` to branch `boulton`. No data, no boundary file.
- [ ] 6.2 Send the group the member list, the three-build note and the figures before Tuesday's meeting.
- [ ] 6.3 Tick `RQ2_RQ3_Roadmap.md`, update `WORKING_BRIEF.md`, draft the week 8 summary.

### Stage 7 — My supplementary zip (due Sun 29 Nov; its own short plan nearer the date)

One zipped folder per member (D7), 500 MB at most, code commented, files well named. In: my Rmd files and their HTML, `rq2_poster_figures.R`, the exported figures, a README, the data dictionary. Out: every CSV including `rq2_types.csv`, the `data/` folder, the boundary file. `04_Analysis/Boulton/README.md` still covers RQ1 only; extending it edits an existing file and needs my go-ahead.

## Open questions

1. Niwesh's sizes as heard (21 + 15 + 30) add to 66 and Harish's to 67, though both said they dropped the two districts. Take the real numbers from their notebooks in Stage 1. **Answered 16 Nov:** Niwesh clusters 66 districts (Chatham Islands out, Kawerau in): 21 / 15 / 30. Harish's headline clusters all 67: 26 / 9 / 32; he drops the two only in a sensitivity run.
2. One `ggpairs()` chunk in Set up, to show how the seven inputs relate: keep it as the one first-impression step the lab does not have, or drop it? **Answered 16 Nov: keep it.**
3. "Core" is defined on four runs (headline, 2011–25, 2021–25, cost out). Add the two teammates' builds if their lists arrive in time? **16 Nov:** their lists are in. The four-run core is 40 districts, the three builds agree on 53, and 32 are in both; see `RQ2_three_builds.md`, section 3, point 6. **Decided 16 Nov: do both.** The notebook keeps the four-run core; the figures script marks a district solid only if it is core and agreed by all three builds (32); the poster and slide give both numbers (40 and 53).
4. Type names and colours: agree on Tuesday, then write the three hex codes into `Style_Guide/Project_Style_Brief.md` so the map, the cards and the app match.
5. If the boundary file is not in hand by Tuesday, the poster uses the profile chart and the log-axis scatter, and the map follows for the slides.
6. Does v1 go into my zip beside v2, as the record of what changed, or only v2?
