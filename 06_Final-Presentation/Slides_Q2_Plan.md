# Slides plan — presenting Q2

_Plan 3 of 3 (with `RQ2_Rebuild_Plan.md` and `Poster_Q2_Plan.md`). Created 2026-11-16 from the group meeting of Sun 15 Nov; revised the same day (no PCA; the notebook follows Lab 7). Owner: Boulton. Slides PDF due Sun 22 Nov with the poster; the group meets on the slides Fri 20 Nov; live presentation in week 9 (slot not yet issued)._

> **Note, 16 Nov (after the v2 build).** "Firm" is now reported both ways: 40 of 65 districts keep their type in all four runs of the notebook, and 53 of 65 get the same type from all three group members' builds; 32 do both and are the solid points on the scatter. Replace any line here that gives only "40 of 65". The profile chart and the scatter are 200 x 140 mm and 180 x 150 mm at 18 pt, and the profile chart's labels are the short ones in `rq2_poster_figures.R`. Numbers from the knit: `Claude outputs/rq2_v2_checks/README.md`.

> **Note, 17 Nov (S1 done).** Every number below is now from Boulton's own knit of `04_RQ2_v2.Rmd` (17 Nov, `04_Analysis/Boulton/04_RQ2_v2.html`), which matches the reference knit exactly. The "solid" counts (core and agreed by all three builds) come from `outputs/rq2/rq2_types.csv` joined to `Boulton/data/rq2_teammates_types.csv`. Two lines are flagged, not rewritten: the "my own read" sentence on slide 2 and the overclaim in slide 3's on-slide line. Question 13 is new.

**To use in a new chat:** open a chat in the STAT462 project with the folder connected, after `04_RQ2_v2.Rmd` has knitted, and say _"Work through `Slides_Q2_Plan.md`. Fill the numbers from the v2 knit first."_ The chat should also read `Style_Guide/Project_Style_Brief.md`.

## PRD

**Problem.** I present Q2. The audience is non-technical, the whole group has 10 minutes (±1) and at most 10 pages excluding the title, conclusion and appendix, and there are about 5 minutes of questions in which each of us is expected to answer. Clustering is the method I know least, and my current notebook says something more hedged than the group's poster does. The slides have to tell one story a general listener can follow and I can defend.

**Success criteria.**
- Three slides, about three minutes, that someone with no statistics can retell: there are three kinds of building market, here is where they are, here is how sure we are.
- Each slide shows my name as presenter. No jargon on a slide that I do not say aloud in plain words.
- Numbers match the v2 knit and the poster.
- A spoken script of about 420 words, rehearsed to time twice.
- Short, practised answers to the twelve questions below.

**Scope.** In: the Q2 slides, appendix slides for Q&A, my script, Q&A preparation. Out: the other sections of the deck, the deck's master and template, and who presents what, which the group settles on Friday.

**Constraints.** PDF, landscape, 16:9 or 16:10. Title page with group name and all members. Body text 14 pt or larger and few words per slide (style brief, final presentation). Header right: `Presenter: Andrew Boulton`. The style brief prefers native charts on slides; the map and the scatter have to be images, so export them from R in the palette with a transparent background. Open Sauce One has no ², ≥, ≤, ≈ or →.

## Assumptions to confirm on Friday

1. **I present Q2 only**, not the background as in Niwesh's earlier draft. At the end of the meeting Harish took Q3; the transcript then has him say "Niwesh, you can do the second", which I read as Q1. Confirm who has Q1, the background and the conclusion.
2. **Three slides and about three minutes for Q2.** Ten minutes across three people is 3 min 20 s each. If the group gives each question two slides, drop to the two-slide version below.
3. Speakers present in blocks with one hand-over each. This was discussed, not settled: Harish and Niwesh liked alternating so anyone can answer any question, but the pitch only just made time and every hand-over costs seconds.

## The three slides

| # | Headline on the slide | Visual | Words on the slide | What I say | Time |
|---|---|---|---|---|---|
| 1 | **New Zealand has three kinds of building market** | NZ map by type (`rq2_map_types.png`), legend with counts: slow provincial 25 · urban multi-unit 14 · house-building 26. **Not drawn yet: no boundary file (Q90).** Kawerau and the Chatham Islands grey, "not clustered" | The question, in one line. "65 districts · 2016–25" | The question. We described each district by seven things: how fast it builds for its size, how much is townhouses and apartments, retirement units, house size, whether building is speeding up, how much spending is renovation, and cost per square metre. A grouping method put districts that build alike together. It was never told where a district is, yet the map makes sense. | 55 s |
| 2 | **What each market builds** | Three cards, one per type, one large number each; or the profile chart (`rq2_profile_types.png`) | Slow provincial · **3.4** new homes per 1,000 people a year · Invercargill, Whanganui, the West Coast. Urban multi-unit · **7 in 10** of NZ's new homes · Auckland, Christchurch, Wellington. House-building · **8.5** new homes per 1,000 people a year · Selwyn, Waimakariri, Central Otago | One sentence per type with one number and places people know. Slow provincial (25 districts): 3.4 new homes per 1,000 people a year, the lowest; 23% of residential building spending goes on existing homes; about 7% below the national cost per m². Urban multi-unit (14): 48% of new homes are not stand-alone houses, and these 14 districts consented 69% of the country's new homes (261,158 of 377,199, 2016–25). House-building (26): 8.5 new homes per 1,000 people a year, the fastest, in the biggest houses, 192 m². My own read of who they are: farming districts; cities and their satellites; lifestyle, holiday and commuter districts. **[Flag 17 Nov — this read does not fit the member list: the slow type includes four cities (Dunedin, Invercargill, Rotorua, Whanganui), and the satellites of Christchurch, Hamilton and Tauranga (Selwyn, Waimakariri, Waikato, Waipa, Western Bay of Plenty) are house-building, not urban. The notebook's own wording (section 4.3) fits: provincial New Zealand — the West Coast, Southland, the centre and east of the North Island, and some older cities; the big cities and the Wellington region; the commuter belts round Christchurch, Hamilton and Tauranga, and lifestyle and holiday districts.]** Examples on the slide are core and agreed by all three builds, except Auckland and Christchurch: all three builds call them urban, but on 2021–25 alone they come out house-building (question 13). | 70 s |
| 3 | **A spectrum, with one clear type** | Log-axis scatter (`rq2_scatter_log.png`). Solid = core in all four runs and agreed by all three builds: 32 districts (18 slow, 3 urban, 11 house-building). Faint = the other 33 (the script draws them faint, not hollow) | "40 of 65 keep their type in all four of our runs · 53 of 65 get the same type from all three of us" **[Flag 17 Nov: the old line, "keep their type however we slice it", claimed more than the four runs test.]** | The types are regions of a spectrum, not boxes with walls. The slow provincial group is firm: 21 of its 25 districts keep their type in every run, and it fits its group best (0.29). The line between the other two moves: 9 to 17 districts change type when we leave cost out or change the years, and the urban type's fit score is 0.02. Why it matters: Q1 found location matters most for cost, and market type is part of what location means: slow provincial districts are about 7% cheaper per m², with or without cost among the measures. Hand over to Q3. | 55 s |

Two-slide version: merge 2 into 1 (map on the left, three one-line type descriptions on the right) and keep 3.

Appendix, not counted in the 10 pages, for questions:

- A1 How we chose three: silhouette by k, 2 to 8.
- A2 The trees: one dendrogram and the districts it sets apart.
- A3 Full member list, core and borderline marked.
- A4 The cost-out check and the three-build comparison.

## Plain-language swaps

| Notebook term | Say |
|---|---|
| k-means clustering | a grouping method |
| standardised inputs | seven measures put on the same scale |
| silhouette coefficient | how well each district fits its group |
| `multi_share` | townhouses, apartments and retirement units |
| `alt_share` | share of spending that is renovation |
| `per1000` | new homes per 1,000 people a year |
| `rel_cost` | cost per square metre against the national figure |
| territorial authority | district |

## Questions to be ready for

Numbers from Boulton's knit of `04_RQ2_v2.Rmd` (17 Nov). Section references are to that notebook.

| # | Question | Short answer |
|---|---|---|
| 1 | Why three groups? | The fit score is nearly flat from 2 to 8 groups (0.19–0.23; 0.230 at two, 0.213 at three), so the data does not choose. Three is the smallest number that separates how much a district builds from what it builds, and our three separate builds agree on the type of 53 of the 65 districts (20 slow, 8 urban, 25 house-building; `RQ2_three_builds.md`). Do not say three had the best score. |
| 2 | What does a score of 0.21 mean? | It runs from −1 to 1. Around 0.25 or below is read as no strong natural grouping (Kaufman & Rousseeuw, 1990). So we present types on a spectrum. By type it is 0.29 slow provincial, 0.25 house-building, 0.02 urban multi-unit, where six of the 14 districts are below zero (§4.4). Optional, only if comfortable (Q99c): the same seven measures shuffled at random score 0.15 on average, so 0.21 is more than noise but not much more. |
| 3 | Cost was an input. Isn't "urban is dearer" circular? | For that label, yes: it describes the type, it does not test it. The check that is not circular (§4.5): leave cost out and the slow provincial group is still 7% cheaper (−7.1%), while the other two are both level with the national figure (0.0% and +0.1%). So "slow is cheaper" survives; "urban is dearer" needs cost as an input. Say both halves. |
| 4 | Why drop Chatham Islands and Kawerau? | 34 and 92 new dwellings in ten years, 126 of 377,199. Below 100, one dwelling moves a share by more than a percentage point. The rule is set once, on 2016–25. Including them changes the type of one district in 65 (first look, 16 Nov; not run in the notebook). |
| 5 | Why does hierarchical clustering disagree? | It answers a different question. It sets the most unusual districts apart first and leaves the rest as one body: complete linkage 55 / 8 / 2, single and average 63 / 1 / 1. The two always set apart are Queenstown-Lakes (27.6 new homes per 1,000 people a year, the highest) and Wellington City (73% multi-unit, the highest). |
| 6 | Why put the measures on the same scale? | House size runs from 130 to 211 m², building rate over a range of about 26, and the other five measures over less than 2. Unscaled, the three groups (11 / 33 / 21) differ only by house size (155, 183 and 200 m²) and hardly at all in anything else (§2, §2.1). |
| 7 | Why these measures and not district size? | So Auckland is not a type of its own for being large. Each measure is a rate, a share or an average, never a total. |
| 8 | How stable is it? | 56 of 65 keep their type with a 15-year window (2011–25), 48 with the last five years (2021–25), 50 with cost left out. 40 never change across those four runs (21 slow, 8 urban, 11 house-building). Separately, 53 of 65 get the same type from all three of us; 32 are both. |
| 9 | Is Auckland one district? | Yes, one of 65, though it consented 40% of the country's new dwellings in 2016–25 (152,439 of 377,199). A limitation we state. |
| 10 | What is k-means doing, and what is `nstart`? | It places three centres, assigns each district to the nearest, and moves the centres until nothing changes. It starts at random and can stop at a poor answer, so we run it from 20 starts (`nstart = 20`, as in the lab) and keep the best. Thirty single starts gave ten different answers; with 20 starts, thirty different seeds all give the same three groups. |
| 11 | The lab picks the number of groups with the highest score, and yours is highest at two. What would two groups be? | The 25 slow provincial districts plus Lower Hutt (26), against the other 39 (§2.2). It is the same firm group either way. Three adds the split between urban and house-building districts, which is the less certain one, and we say so. |
| 12 | Consents or completed buildings? | Consents: intentions to build. Some are never built. |
| 13 | _(added 17 Nov)_ You show Auckland as urban. Is it one of your firm districts? | No. All three of our builds put Auckland, Christchurch and Hamilton in the urban type, but on the last five years alone (2021–25) they come out house-building (§4.6), so they are not core. They are faint on the scatter. Only 3 urban districts are solid: Wellington City, Lower Hutt and Porirua. |

## Plan

- [ ] S0 Get the current group deck and confirm which file is the master. Build from `Style_Guide/whileTrue_learn_StyleTemplate.pptx` if the master is PowerPoint. _(17 Nov: looked, not settled. Two drafts exist. Niwesh's `communication/slides/slides.pptx` (13 pages) is generated by his `build_slides.py` in our style; Harish's `Group8_Final_Presentation_DRAFT.pdf` (11 pages) is a dark teal design with no editable file in the branch. Both give Q2 **two** slides. Niwesh's has me on background, data and Q2, and already has exactly 10 counted pages, so a third Q2 slide puts it at 11. The master is still the group's call, Fri 20 Nov.)_
- [x] S1 After the v2 knit: fill the numbers in the slide table and the question table. _(17 Nov, from Boulton's knit.)_
- [x] S2 Build the three slides and the appendix. Type names and colours as agreed for the poster. _(17 Nov, draft: `Claude outputs/q2_slides/Q2_slides_3slide.pptx` and `Q2_slides_2slide.pptx`, each with A1–A4, and PDFs. Niwesh's geometry, header and card style so they paste into his deck. Working type names and the colours already on his poster (slow `#C76B0A` circle, urban `#FBAC4D` square, house-building `#5C5148` triangle); change if Tuesday decides otherwise. Slide 1's map is a placeholder (Q90). The scatter is your own run of `rq2_poster_figures.R` with its title cropped off.)_
- [ ] S3 Write the script from the "What I say" column, about 420 words. Read it aloud, cut anything I would not say in conversation. _(17 Nov: written, not yet read aloud. 414 words for three slides, 321 for two, in the speaker notes and in `Claude outputs/q2_slides/Q2_script_draft.md`. Slide 3 runs about 67 s against 55 s planned.)_
- [ ] S4 **Friday 20 Nov meeting** — settle the assumptions above, the hand-overs, and the presenter name on every page.
- [ ] S5 Rehearse twice with a timer; once more with the group in week 9.
- [ ] S6 Answer the twelve questions aloud. Any I cannot answer goes back to Stage 5 of the rebuild plan.
- [ ] S7 Checks before PDF export: 16:9; no more than 10 counted pages across the group; presenter on each page; text 14 pt or larger; no blank glyphs; links opened; spell-check.

## Open questions

1. Who holds the slide master, and is it PowerPoint or Canva?
2. Does the group want one shared "how sure are we" slide across the three questions instead of one inside each?
3. _(17 Nov)_ **Two slides or three?** Both group drafts give Q2 two slides, and Niwesh's is at the 10-page limit with them. Three slides for Q2 means another section loses one. The two-slide draft needs no map, so it is complete today; the three-slide one waits on the boundary file.
4. _(17 Nov)_ **Scatter labels in `rq2_poster_figures.R`.** With `hjust = "inward"` and `vjust = -1.1`, several labels sit over the wrong point on your Windows run: "Auckland" reads as labelling Lower Hutt, "Queenstown-Lakes" sits over Christchurch, "Selwyn" over Mackenzie, "Wairoa" over its neighbours. Same figure on the poster. Fix is in the script (per-label `hjust`/`nudge_x`, or fewer labels); it is your file, so not edited.
5. _(17 Nov)_ Niwesh's deck still shows his own Q2 (66 districts, "60 of 66 placed the same by two methods") and Harish's shows his (67, "64 of 67"). Once Q81 settles whose clustering is the group's, the Q2 slides in the master are replaced by these, and the conclusion and appendix slides in the master need the same numbers.

