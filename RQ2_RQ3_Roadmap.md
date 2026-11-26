# RQ2 / RQ3 Roadmap — course-style replication

_Live checklist. Tick (`[x]`) as we go. Owner: Boulton + Claude. Created 2026-11-10._
_Companion to `RQ1_Roadmap.md`. Target: Friday 13 Nov group comparison; poster and slides Sun 22 Nov._

## PRD (approved 10 Nov, "proceed")

**Problem.** Friday needs Boulton's own Q2 and Q3. Niwesh's exist, but nobody can yet explain them and they choose k with criteria outside the labs (Calinski–Harabasz, BIC). Nothing existed on our side beyond the EDA.

**Success criteria.**
- Both notebooks knit on Boulton's machine from `data/rq1_district_quarter_full.csv` with no edits, in the lab house style.
- Every method comes from Labs M3–M7. RQ2: `kmeans()`, silhouette, `hclust()` with complete, single and average linkage. RQ3: `glm()` logistic, `lda()`, `qda()`, classification `tree()` with pruning, `randomForest()`, `gbm()`.
- RQ3 ends with one table of accuracy, sensitivity, specificity and AUC on the 402 test district-years beside the rules of thumb, and says plainly whether anything beats the best rule.
- RQ2 ends with silhouette by k, three dendrograms, each group named with its members, the outliers named, and a test of whether groups differ in relative cost.
- Numbers in the prose match an independent Python rebuild of the tables.

**Scope.** In: both tables built inside the notebooks, the ±10% sensitivity for RQ3, the cost-in re-run for RQ2, this roadmap. Out: PCA, Ward linkage, SA2 or Auckland-board clustering, national indicators, the Shiny app, poster figures, any change to `03_RQ1.Rmd`.

**Constraints.** Lab packages only (`tidyverse`, `GGally`, `gridExtra`, `cluster`, `MASS`, `pROC`, `tree`, `randomForest`, `gbm`); seed 462.

## Decisions (Boulton, 10 Nov)

1. RQ3 class = as pitched (rising if next calendar year's new dwellings exceed this year's), all district-years, plus one sensitivity section on moves over ±10%.
2. RQ3 split = 2019/2020, the same cut as RQ1 (train outcomes to 2019, test outcomes 2020–25).
3. RQ2 inputs = relative cost left out of the headline clustering, then test whether groups differ in cost; one section re-runs with cost in for the comparison with Niwesh.
4. RQ2 picture = lab style, clusters drawn on two original variables; no PCA.
5. Accepted as defaults with "proceed": the 52 ties count as not rising; `nat_g1` stays in the feature set with a results row without it; RQ2 window 2016–25 with 2011–25 and 2021–25 as the stability check; RQ2 written first.

## Stage 0 — Setup

- [x] 0.1 PRD approved.
- [x] 0.2 `rq1_district_quarter_full.csv` (9,715 × 43, 4.5 MB) copied to `04_Analysis/Boulton/data/`; byte-identical to the copy on branch `niwesh` (`cmp`). New file, nothing overwritten.
- [x] 0.3 R 4.3.3 installed in Claude's cloud workspace with every lab package except `tree` (not in the Ubuntu archive; a source install from GitHub was refused by the workspace's safety check and not pursued). Both notebooks were test-knitted there.

## Stage 1 — `04_RQ2.Rmd` (clustering, Lab M7)

- [x] 1.1 Set up: read the table; `build_profile(first_year, last_year)` → one row per district; six inputs (`multi_share`, `retire_share`, `house_m2`, `per1000`, `growth`, `alt_share`); `rel_cost` built but kept out; `.boxNote` on what was left out and on the Chatham Islands.
- [x] 1.2 First impression: histograms, three lowest / highest districts per input, `ggpairs`, the two-variable "cluster data" picture.
- [x] 1.3 k-means: why scale (unscaled clusters are house-size bands), why `nstart` (30 single starts → 14 answers), k = 3, the criterion that only rises, silhouette for k = 2…8 with display math, silhouette by district, group means and members, k = 2 and k = 4 beside it.
- [x] 1.4 Hierarchical: complete, single, average — dendrogram, `rect.hclust`, `cutree`; one table of sizes and silhouettes for k = 2…5; the eight districts furthest from the average.
- [x] 1.5 Evaluate: k-means vs complete linkage; stability to the start, to the window (2011–25, 2021–25) and to removing four outliers; groups vs cost with `lm()`; cost-in re-run; answer, limitations, sources.
- [x] 1.6 Test knit in the cloud: clean, 14 figures, about 10 seconds. Every number in the prose was read from that knit.
- [x] 1.7 Python rebuild of the profile matches R on all 67 districts (largest difference 5e-13).
- [ ] 1.8 Knit on Boulton's machine; compare with `Claude outputs/rq23_checks/04_RQ2_reference_knit.html`. Report any difference in a table or any error with the chunk's first line.
- [ ] 1.9 Boulton reads it end to end after Module 7 and marks anything he could not explain in Q&A.

## Stage 2 — `05_RQ3.Rmd` (classification, Labs M3 / M4 / M6)

- [x] 2.1 Set up: quarters → 2,345 district-years (1991–2025); class (2,278 rows, 51.2% rising, 52 ties → Fall); nine features known at the end of year t; 2,009 modelling rows; split 1,607 / 402.
- [x] 2.2 First impression: the national cycle, the "moved with the majority" yardstick, features by class, four rules of thumb on the test set.
- [x] 2.3 Logistic regression: one feature by hand and by `glm()`; nine features; confusion matrix read cell by cell; thresholds; ROC and AUC.
- [x] 2.4 Discriminant analysis: one-feature QDA by hand vs `qda()`; LDA and QDA on nine features; class spreads.
- [x] 2.5 Trees: classification tree, `cv.tree(FUN = prune.misclass)`, bagging, random forest, boosting with the number of trees chosen on five blocks of years.
- [x] 2.6 Evaluate: one results table and chart, ROC overlay, accuracy by year and by district size, the same models on five earlier blocks of years, three sensitivity runs, three importance rankings, answer, limitations, sources.
- [x] 2.7 Test knit in the cloud with a stand-in for `tree` built on `rpart` (test copy only; the delivered file calls `library(tree)`). Everything else ran for real: 12 figures, about 20 seconds.
- [x] 2.8 Python rebuild of the modelling table matches R on all 2,009 rows (largest difference 7e-15), and reproduces the class balance, the cycle yardstick and the four rules.
- [ ] 2.9 **Knit on Boulton's machine. The three `tree` chunks (sections 5.1 and 5.2) run for the first time there.** Report any error with the chunk's first line.
- [ ] 2.10 After that knit: align the tree prose (5.1, 5.2 and the tree rows of 6.1) to the numbers, and check the forest and boosting figures — a different `randomForest` / `gbm` version can move them by a point.
- [ ] 2.11 Boulton reads it end to end after Module 6 and marks anything he could not explain in Q&A.

## Stage 3 — Share and compare

- [ ] 3.1 Commit `04_RQ2.Rmd`, `05_RQ3.Rmd` and their knitted HTML to branch `boulton`. No data in the repo.
- [ ] 3.2 Download branch `niwesh` again once his RQ2 / RQ3 notebooks are pushed — into a new folder, not over the 9 Nov extract.
- [ ] 3.3 Compare with Niwesh on Friday: his clustering inputs and k against section 5.5 of `04_RQ2.Rmd`; his 58% against section 6.1 of `05_RQ3.Rmd`; ask which years his 58% is measured on.
- [ ] 3.4 Weekly summary (due Sun 15 Nov) drafted from this file.

## Results at 10 Nov (cloud knit, R 4.3.3)

**RQ2.** Silhouette 0.207–0.244 for k = 2…8 (best k = 2 at 0.244; k = 4 0.241; k = 3 0.227) — at or under the 0.25 read as "no substantial structure". k = 3: slow provincial 22 districts (3.4 dwellings per 1,000, 23% alteration share, 174 m², silhouette 0.41); dense urban 16 (46% multi-unit, silhouette 0.04, six districts negative); building for growth 29 (9.0 per 1,000, 190 m², silhouette 0.19). All 22 slow districts stay together at k = 2 and k = 4. Complete linkage cut at 3 = 62 / 4 / 1 (Queenstown-Lakes, Selwyn, Central Otago, Mackenzie; Chatham Islands); single = 65 / 1 / 1; average = 63 / 3 / 1. Same group as 2016–25: 60 of 67 with 2011–25, 52 of 67 with 2021–25, 47 of 63 with four outliers removed. Cost: slow group 7% below NZ; dense +11% and growth +6% relative to it; the two upper groups not distinguishable (p = 0.13); 3 groups R² 0.18 (adj 0.16) vs region 0.41 (adj 0.23). With cost as an input: silhouettes lower (0.19–0.22), 60 of 67 keep their group, second group = 15 districts, 46% multi-unit, 7% above NZ ("denser and dearer").

**RQ3.** Test (402 rows, 45% rising): logistic 61.4% / AUC 0.631; LDA 61.2% / 0.629; boosting 60.0% / 0.631; QDA 59.0% / 0.621; random forest 58.7% / 0.603; bagging 58.0%; rules: below-3-year-average 58.5%, opposite 54.0%, same direction 46.0%, always rise 45.0%; one-feature logistic 47.3%. Five earlier blocks of years pooled (1,607 rows): logistic 54.8% (47–66% by block), LDA 54.6%, QDA 53.8%, forest 55.3%, below-3-year-average rule 51.3%; logistic without `nat_g1` 57.2%. By test year: logistic 57 / 55 / 63 / 70 / 76 / 48%. By size: 65% smallest third, 59% largest. Sensitivity (logistic, test): without `nat_g1` 60.0%; with relative cost 59.9%; moves over ±10% only 65.2% / AUC 0.69. LDA and logistic agree on 395 of 402 test rows. `region` is last in the forest's importance.

## Corrections to what was said before the build

- The first look called the mean-reversion rule's 58.5% the bar and "about 60%" the ceiling. Those are test-period figures. On 1995–2018 the rule scores 51.3% and the models about 55%. Quote the pair, not the 61%.
- The first look gave k = 3 groups of roughly 24 / 27 / 16 with cost as an input. With cost out and growth measured per year the groups are 22 / 16 / 29. The slow group is the same districts; the split of the rest moved.
- The first look said k = 4 changes with the random seed. That was with 20 starts in Python. In R with `nstart = 50` every k from 2 to 4 is reproducible; with a single start k = 3 gives 14 different answers in 30 runs.

## Three lines per question for Friday

**RQ2.** Districts do not fall into natural types: silhouette is 0.21–0.24 whatever k. One group is real — 22 slow provincial districts — and a handful of districts (Queenstown-Lakes, Selwyn, Mackenzie, Central Otago, Chatham Islands, Wellington City) are unlike any other. The slow group is 7% cheaper per m² even though cost was not used to form it.

**RQ3.** 61% on the test years, 55% on earlier years, against 58.5% and 51% for a one-line rule. The national cycle is two-thirds of the answer and no district feature sees it coming. Logistic, LDA, QDA, forest and boosting are within three points of each other.

**Across all three.** RQ1: location ≫ drivers ≫ algorithm. RQ2: locations sit on a continuum. RQ3: national cycle ≫ district features ≫ algorithm.

## Open questions

1. `04_Analysis/Boulton/README.md` still describes RQ1 only. Extend it to cover the two new notebooks? It is an existing file, so it needs a yes.
2. `nat_g1`: it stays in the headline model as decided. The evidence is now split — +1.4 points on the test years, −2.4 points on the five earlier blocks. Keep, or make the model without it the headline? [CONFIRM]
3. Poster k for RQ2: three named groups (as pitched; one of them has silhouette 0.04) or two (highest silhouette)? The notebook carries three and shows two and four. [CONFIRM]
4. Is PCA taught in the Module 7 lectures? If so a `prcomp()` view could be added as one figure.
5. Niwesh's clustering inputs, window and k, and the years his 58% is measured on — needed for 3.3.
6. Three single-tree statements in `05_RQ3.Rmd` are written without numbers until 2.9 is done.
