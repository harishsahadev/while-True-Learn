# RQ1 Roadmap — independent replication in course style

_Live checklist. Tick (`[x]`) as we go. Owner: Boulton + Claude. Created 2026-11-09._
_Plan C: **A** (this file) first, for Monday 10 Nov; **B** (audit of Niwesh's pipeline) after the group decides what to submit._

## PRD (half page)

**Problem.** Niwesh's branch holds a complete RQ1 pipeline (11 models, `glmnet`/`ranger`/`xgboost`/`e1071`/`mgcv`) that none of the group can yet explain line by line. The poster and live Q&A mark understanding, not model count. We have no independent check of his numbers and no version written the way the course teaches.

**Success criteria.**
- One Rmd, `04_Analysis/Boulton/03_RQ1.Rmd`, in the lab house style (brief §*R Markdown conventions*), that knits on Boulton's machine from Niwesh's `rq1_model_data.csv` with no edits.
- Every model is one Boulton can explain in the Q&A without notes.
- A results table (train R² / adj R², test RMSE, test R²) on the **same rows and split as Niwesh** so the two builds are directly comparable; any difference > 0.005 RMSE on a like-for-like model is explained.
- A clear ridge-vs-lasso readout: which drivers survive at the CV-chosen λ, with coefficient paths.

**Scope.** In: import, modelling table, first-impression plots, SLR→MLR→forward selection, ridge vs lasso, regression tree, random forest, boosting, evaluation, bootstrap SE on headline coefficients, a short extension section for the three new features (below). Out: RQ2/RQ3, poster figures, rewriting Niwesh's notebooks, any feature derived from house value (leakage), SVM/GAM/XGBoost.

**Constraints.** No R reachable from either of my shells — static checks only, first knit is yours (same as `01_EDA.Rmd` and `02_cleaning.Rmd`). Course-lab packages only (`tidyverse`, `MASS`, `caret`, `leaps`, `gridExtra`, `GGally`, `tree`, `randomForest`, `gbm`) **plus `glmnet`** — ridge/lasso are not in any lab; `glmnet` is the ISLR2 §6.5 recipe the course textbook uses, so it is the defensible choice (flagged, needs your OK). Stats NZ downloads are blocked for me, so any new series is a manual download by you.

**Plan.** Stages 0–8 below, in order. Sign-off ("proceed") needed before stage 1 code is written.

**Open questions.** Q1–Q6 at the end of this file.

---

## Stage 0 — Decisions and setup (today, before any code)

- [x] 0.1 Approve this roadmap ("proceed").
- [x] 0.2 Seed: `set.seed(462)` throughout (brief Q35). **[CONFIRM]**
- [x] 0.3 Approve `glmnet` as the one non-lab package. **[CONFIRM]**
- [x] 0.4 Rows: **decided 9 Nov: ours** (1990+, 67 districts, 7,051 / 1,611) with a note block on the differences. Was: replicate Niwesh exactly — `in_model == TRUE`, `year >= 1996`, drop Chatham Islands and Kawerau → **5,694 train / 1,608 test, 65 districts, 1996Q1–2026Q2** (checked from his CSV today). Alternative: our 1990+ rule (7,051 / 1,611) — not comparable to his tables. **[CONFIRM]**
- [x] 0.5 Response (confirmed 9 Nov): headline `rel_log_cost_m2` (his and our relative response); `log_real_cost_m2` as the secondary section, as he did. **[CONFIRM]**
- [x] 0.6 Copy `rq1_model_data.csv` (4.1 MB) and `rq1_data_dictionary.csv` from `while-True-Learn-niwesh/building-consents/data/processed/` to `04_Analysis/Boulton/data/` (decided 9 Nov: everything for this Rmd lives in `04_Analysis/Boulton/`) so the Rmd has one stable path independent of where the clone ends up. New files, nothing overwritten. (Claude)
- [x] 0.7 Data path: one line, `data_root <- Sys.getenv("STAT462_RQ1_DATA", unset = "data")` — same pattern as the other two Rmds. (Claude)
- [x] 0.8 Update `WORKING_BRIEF.md` (local + project copy) with Friday's decisions, the repo inventory and this plan. (Claude)

## Stage 1 — Set up (Rmd §1)

- [x] 1.1 YAML + `.boxNote` CSS + `setup` chunk per house style; one-paragraph intro.
- [x] 1.2 Read `rq1_model_data.csv`; `ta`, `region`, `island`, `quarter` as factors; print `dim()` and a `glimpse()`.
- [x] 1.3 Build `df` = the modelling table: rows per 0.4; columns = responses + the 11 drivers Niwesh used (`t_index`, `avg_house_m2`, `rel_house_m2`, `log_houses_n`, `multiunit_share`, `apt_share`, `retire_share`, `dwell_per_1000`, `houses_yoy`, `log_resid_alt_real`, `log_nonres_real`) + `region`, `ta`. A `.boxNote` listing what was dropped and why (lags = persistence only; `nominal_cost_m2`, `houses_val`, `loo_*` = leakage/derived).
- [x] 1.4 Split by the `split` column (not `sample()` — time-ordered); `df_train`, `df_test`; print sizes and check against 5,694 / 1,608.
- [x] 1.5 Data dictionary table rendered from `rq1_data_dictionary.csv` (kable).

## Stage 2 — First impression (Rmd §2)

- [x] 2.1 Histogram of both responses; boxplot of `rel_log_cost_m2` by region (ggplot, `labs()` every time).
- [x] 2.2 `GGally::ggpairs()` on the drivers (sub-sample for speed) + correlation heatmap; name the two pairs over |0.7| (`avg_house_m2`/`rel_house_m2`, `log_houses_n`/`log_resid_alt_real`).
- [x] 2.3 Variance-explained baselines: district mean, year mean, both — reproduce his t05 (0.32 / 0.03 / 0.35 on the relative response).

## Stage 3 — Linear regression (Rmd §3, Labs M1–M2)

- [x] 3.1 SLR on `log_resid_alt_real` by hand (`b1`, `b0` formulas) vs `lm()`; confirm equal. Once only.
- [x] 3.2 MLR, drivers set: `mlr.fit <- lm(rel_log_cost_m2 ~ ., data = df_train_drivers)`; `summary()`, `confint()`; `plot(mlr.fit)` diagnostics read out loud (the labs list them and never run them).
- [x] 3.3 MLR, district set: `+ ta` (65-level factor — the fixed-effects ceiling; `lm` handles it, trees won't).
- [x] 3.4 Forward selection: `leaps::regsubsets(..., nvmax = 11, method = "forward")`; choose size by blocked-validation MSE; plot.
- [x] 3.5 Transformations worth one try each: `poly(dwell_per_1000, 2)`, `log_resid_alt_real:log_houses_n` interaction (his fig25 says it exists).

## Stage 4 — Ridge vs lasso (Rmd §4, ISLR2 §6.5)

- [x] 4.1 Display math for the two penalties before the code (house style).
- [x] 4.2 `x <- model.matrix(rel_log_cost_m2 ~ . - 1, df_train_drivers)`; standardise inside `glmnet` (default).
- [x] 4.3 Blocked CV, not random folds: `foldid` from year blocks 1996–2003 / 04–07 / 08–11 / 12–15 / 16–19 (brief Q59) — `cv.glmnet(x, y, alpha = 0, foldid = foldid)` and `alpha = 1`; report `lambda.min` and `lambda.1se`.
- [x] 4.4 Coefficient-path plots (`plot(fit, xvar = "lambda", label = TRUE)`) side by side with `grid.arrange`.
- [x] 4.5 **The readout the poster needs:** table of standardised coefficients at `lambda.1se` for OLS / ridge / lasso; which drivers lasso zeroes; one paragraph on why ridge shrinks the collinear pair while lasso picks one.
- [x] 4.6 Repeat 4.2–4.5 with `+ region` dummies (district set proxy a penalised model can hold).

## Stage 5 — Tree-based models (Rmd §5, Lab M6)

- [x] 5.1 `tree::tree()` on drivers + `region`; `cv.tree()` → `prune.tree(best = )`; `plot(); text(pretty = 0, cex = 0.7)`.
- [x] 5.2 `randomForest(..., mtry = 4, ntree = 500, importance = TRUE)`; `varImpPlot()` (%IncMSE); `set.seed(462)` before the call.
- [x] 5.3 `gbm(..., distribution = "gaussian", n.trees = 1000, interaction.depth = 2, shrinkage = 0.05)`; `summary()` relative influence; `predict(n.trees = , type = "response")`.
- [x] 5.5 (added 9 Nov, on request) **Tuning subsection**: RF grid `mtry` {4,12} × `nodesize` {5,20,50}; gbm grid shrinkage {0.01,0.05} × depth {2,4} with `n.trees` chosen every 100 up to 3,000; elastic-net `alpha` {0,.25,.5,.75,1} at `lambda.min` on drivers + region. All on the §4.2 `foldid` blocks; test touched once per model. Chunks `tune-rf` / `tune-gbm` are `cache = TRUE` (expect 5–10 min first knit). Not done: regrowing the single tree with `mindev = 0.002` (offered, not requested).
- [x] 5.4 One `.boxNote`: trees can't extrapolate `t_index` past 2019 — why the relative response matters for them (his fig23).

## Stage 6 — Evaluate performance (Rmd §6)

- [x] 6.0 Sensitivity row: headline MLR without `dwell_per_1000` and `houses_yoy` on all 7,051 / 1,611 rows (Q7 decision).
- [x] 6.1 Goodness-of-fit: train R² / adjusted R² for the `lm` family.
- [x] 6.2 Test RMSE and test R² for every model, one `kable`; same formula as the labs (`mean((y - pred)^2)`).
- [x] 6.3 (`t09_test_results.csv` copied to `Boulton/data/`; the chunk skips itself if the file is absent) Side-by-side with Niwesh's `t09_test_results.csv` for the models we share (OLS, ridge, lasso, tree, RF); differences explained (his `ranger` vs our `randomForest`, his 1-SE tuning vs ours).
- [x] 6.4 Bootstrap SE (Lab M5, 100 draws) for the top-3 OLS coefficients vs `confint()`.
- [x] 6.5 Secondary response `log_real_cost_m2`: OLS + RF only, to show the extrapolation gap.

## Stage 7 — Extensions: the three features you asked about (Rmd §7, short)

See the note under Q4–Q6 before deciding. If they go in:

- [~] 7.1 ~~`govt` factor~~ **dropped 9 Nov** (time blocks already carried by `t_index` / year; see Q5). Was: `govt` factor: National 1990Q2–1999Q4 · Labour 2000Q1–2008Q4 · National 2009Q1–2017Q4 · Labour 2018Q1–2023Q4 · National 2024Q1– (election quarter assigned to the incoming government from the next quarter; rule stated in a `.boxNote`).
- [ ] 7.2 Materials: PPI inputs, construction industry (Stats NZ Infoshare, quarterly, national) — manual download by Boulton.
- [ ] 7.3 Labour: LCI salary & wage rates, construction (quarterly from 1992Q4, national) — manual download by Boulton.
- [ ] 7.4 Fit on the **real** response only; report whether they add anything beyond `t_index`; show they contribute zero to the relative response by construction.

## Stage 8 — Knit, check, share

_Seed convention (9 Nov): `set.seed(462)` in setup and immediately before each chunk that draws random numbers (ggpairs sample, cv.tree, bagging, RF ×2, gbm, bootstrap); none before `cv.glmnet`, which takes `foldid` and draws nothing._

- [x] 8.1 Static checks on my side (fences, brackets, dangling pipes, non-ASCII, `=` assignments) + independent second-agent read.
- [x] 8.2 (knitted 9 Nov; one error — interaction row name — fixed; tree plot redrawn) First knit on Boulton's machine; report any error with the chunk's first line; fix.
- [x] 8.3 (9 Nov: seven paragraphs rewritten to the knitted tables; Niwesh-rows check chunk added in §6.4) Numbers in the prose confirmed against the knitted output.
- [ ] 8.4 Get the real `git clone` working (credential issue from Sunday) and commit `03_RQ1.Rmd` + knitted HTML to branch `boulton`. No data in the repo.
- [ ] 8.5 Weekly summary (due Sun 15 Nov) drafted from this file.
- [ ] 8.6 Monday 10 Nov meeting: show §4 and §6.3; propose which pipeline the group submits → starts plan B.

## Results at 9 Nov (from the knit)

Test RMSE, relative response, 1,611 rows: bagging 0.1065 · RF 0.1068 · MLR + district 0.1086 · boosting 0.1106 · lasso/ridge (min) + region 0.1165 · tree 0.1189 · MLR drivers 0.1208 · forward-3 0.1227 · lasso/ridge (1se) 0.127–0.129. Two bands: geography in (0.106–0.111) vs drivers only (0.121–0.129). Forward selection → `log_resid_alt_real`, `dwell_per_1000`, `log_houses_n`. Lasso 1se keeps the first two only; 1se is too aggressive (five time-block folds, wide SE). Importance top-2 agree across lasso / RF / gbm; `region` first where allowed. Adj R² 0.194 → 0.401 with district. Bootstrap SE / formula SE = 1.08–1.13. Real response: forest bias −4%, MLR +1%; real $/m² nearly flat 2020–26 in June-2026 $. vs Niwesh: district MLR 0.1086 vs 0.1066; drivers MLR 0.1208 vs 0.1162 — **on his 1,608 rows still 0.1202 / 0.1084: gap of 0.004 / 0.002 persists, so it is upstream of the model** (Q8). **Tuning (§5.4):** forest insensitive (six settings within 0.001, default best); boosting depth 4 > depth 2, chosen 0.05 × depth 4 × 1,100 trees → test 0.1067 (was 0.1106), now level with the forests; elastic net flat across alpha (0.0958–0.0961), lasso by a hair.; our RF 0.1068 vs his 0.1134 (ours has region).

## Open questions

_1-6 answered 9 Nov: seed 462 · glmnet yes · rows = ours with a note · materials/labour = short §7 on the real response · government = out · everything in `04_Analysis/Boulton/`._

7. **Pre-1996 rows (new, from stage 1):** `dwell_per_1000` is NA for all 1,355 pre-1996 rows and `houses_yoy` for the first year of each district (238). Any model using them fits on 5,696 train / 1,611 test rows — i.e. Niwesh's frame plus Chatham + Kawerau. Options for stage 3: (a) accept that and say so; (b) drop those two drivers to keep 1990+; (c) fit both and show the difference. **Decided 9 Nov: (a) for the headline (5,696 / 1,611, stated in a note block in §3.1), (b) as one sensitivity row in §6.**

1. Seed 462? (0.2)
2. `glmnet` allowed as the one non-lab package? (0.3) If not, ridge can be done by hand with `lm.ridge()` from `MASS`, but lasso cannot — it would drop out.
3. Rows: Niwesh's 1996+/65-district subset for comparability, or our 1990+/67? (0.4)
4. **Materials and labour cost — my recommendation is no for the headline, yes as a short §7 if you want it on the poster.** Reason: both series are national and quarterly, so they vary only with time. Against the relative response they cancel exactly (every district in a quarter sees the same value, and the response is already district-minus-rest-of-NZ). Against the real response they are nearly the deflator itself — the CGPI dwelling-units index is built from materials and labour prices — so they would mostly re-explain what `real_factor` already removed. They'd show as "important" and mean nothing. Only a district-level cost series would carry information, and Stats NZ doesn't publish one.
5. **Government in power — same structure, same answer.** Five blocks of time, national; zero by construction on the relative response, and on the real response it is confounded with the GFC (2008), the Christchurch rebuild (2011–), and COVID (2020–22), each of which falls inside one government's term. A tree will split on it happily and the poster will read as a political claim we can't support. If the group wants it for the non-technical audience, it goes in §7 with that caveat in the text.
8. **Niwesh gap — confirmed upstream (9 Nov knit):** on his 1,608 test rows ours is 0.1202 vs his 0.1162 (drivers) and 0.1084 vs 0.1066 (district). Chatham 2020Q4 (error 0.49) was worth 0.0006 only. Monday: ask what columns his `Linear regression / drivers` fitted (same 11 as the VIF table?), any standardisation, exact train rows. Was: §6.4 scores ours on his rows; if the gap persists, the difference is in data preparation (his `t_index`? standardisation? row set?) and must be found before either number goes on the poster. Ask Niwesh Monday what rows and columns his `Linear regression / drivers` used.
6. Where should `03_RQ1.Rmd` sit long-term — `04_Analysis/R/` (our convention) or inside the clone at `building-consents/analysis/rq1_cost_per_m2/` beside his? I'd write it in `R/` now and move it on commit (8.4).
