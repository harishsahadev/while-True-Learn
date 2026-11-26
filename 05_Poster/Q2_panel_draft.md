# Q2 panel: draft for the group meeting on Tue 17 Nov

_Poster plan steps P4 to P6. Prepared 17 Nov from Boulton's knit of `04_RQ2_v2.Rmd` (`04_Analysis/Boulton/04_RQ2_v2.html`) and Niwesh's `poster.pptx` from the 15 Nov branch. Niwesh's files were read and not changed. The numbers come from the "Draft words" section of `Poster_Q2_Plan.md`, and each one was re-checked by script against `04_Analysis/outputs/rq2/rq2_types.csv` (23 checks, all pass)._

| File | What it is |
|---|---|
| `poster_Q2_draft_Boulton.pptx` | A copy of Niwesh's `poster.pptx` with **only the Q2 row changed**. Shape names are unchanged, so running `python communication/poster/pptx/compare_pptx.py <this file>` lists exactly the Q2 edits for him to carry into `poster.html`. The two figures in it are **previews** drawn in Claude's workspace. Swap in your own run once slot mode (section 2) is approved |
| `poster_Q2_draft_Boulton_Q2row.png` | The Q2 row as LibreOffice renders it. PowerPoint wraps text slightly differently |
| `../Claude outputs/rq2_v2_checks/rq2_poster_figures_slot_mode.diff` | The proposed change to `rq2_poster_figures.R`. **Not applied** |
| `../Claude outputs/rq2_v2_checks/preview_slot_*.png` | The two figures as the proposed script draws them, at slot size |

## 1. The words, shape by shape

Niwesh's layout sets the text card at 11 pt, with a fixed line spacing of 4.96 mm. The card has room for 11 lines below the hypothesis, and this draft uses all 11.

| Shape in his file | His version | Draft |
|---|---|---|
| `Text 76` tag | RQ2 · Clustering | unchanged |
| `Text 77` question | What kinds of building markets does New Zealand have? | unchanged |
| `Text 78` hypothesis | Hypothesis: districts form a few distinct market types. | unchanged. His Conclusions box refers back to it as H2 |
| `Text 79` data and method (3 lines) | 66 districts, nine features (2016–2026): … | 65 districts with at least 100 new homes, 2016–2025, described by the seven measures at right. Grouped by k-means (k = 3); hierarchical clustering as a check. |
| `Text 80` bullet (3 lines) | House-building (30): … | ● **Slow provincial** (25): fewest new homes (3.4 per 1,000 people a year), most spent on renovation (23%), 7% below the NZ cost per m². Whanganui, Invercargill, West Coast. |
| `Text 81` bullet (3 lines) | Slow provincial (21): … | ■ **Urban multi-unit** (14): 48% of new homes are townhouses, apartments or retirement units; 69% of all new homes. Auckland, Wellington, Christchurch. |
| `Text 82` bullet (2 lines) | Urban medium-density (15): … | ▲ **House-building** (26): fastest building (8.5 per 1,000) and biggest houses (192 m²). Selwyn, Tasman, Central Otago. |
| `Chart c05_rq2_markets` | PCA scatter, nine features | `rq2_scatter_log.png`, slot mode, 122.5 x 67.7 mm |
| `Text 85` caption | Axes: first two principal components of the nine features. | Solid: same type in every run and every team build (32 of 65). |
| `Chart c06_rq2_profiles` | medians of four features, 122.5 x 56.1 mm | `rq2_profile_types.png`, slot mode, resized to 122.5 x 67.7 mm to match the scatter |
| `Text 88` caption | Four of the nine clustering features. | Each type against the average district, in standard deviations. Moved down to y = 380.6 mm, level with `Text 85` |
| `Text 90` answer strip (2 lines, 13 pt) | Answer: three markets. k-means and Ward's clustering agree on 60 of 66 … | **Answer:** three types on a continuum (silhouette 0.21): slow provincial is clear, urban and house-building blur. 40 of 65 districts keep their type in all four of our runs; 53 get the same type in all three team builds. |

The words come to 112 in the text card and 39 in the answer strip. Niwesh's version has about 65 and 32.

**Other changes in the draft file**
- The bullets are ● ■ ▲ in each type's colour. These match the scatter's markers, so each bullet points to its points on the chart. They are set in Arial, which draws them.
- Both ² glyphs are set in Arial. Open Sauce One draws ² as a blank.
- The bullets are reordered as slow, urban, house-building. That is the order of the figures' legends and panels.

**What was cut to fit, and where it can go**
- **The link line to Q1.** The plan says to cut this first if space is short. Proposed for the Conclusions box (section 3, item 8).
- **The hook** ("14 districts consent 7 in every 10 new homes"). It is folded into the urban bullet as "69% of all new homes".
- **Why k = 3.** Proposed for the Approach table (section 3, item 6).
- **Some example districts.** Each type now has two or three: Hamilton, Whakatane and Waimakariri were dropped. Every slow and house-building example is firm on both tests. The urban examples are discussed in section 3, item 2.
- **Cost on the urban and house-building bullets.** Cost was a clustering input, so "urban is 7% dearer" describes how the type was formed and is not a finding about it. Only the slow provincial gap survives the cost-out check (−7.1% without cost), so only the slow bullet gives a cost figure.

**Checks on the wording**
- "every run" and "all four of our runs" both mean the notebook's four runs: the headline run, cost left out, 2011–25 and 2021–25. "Every team build" means Boulton's, Niwesh's and Harish's builds.
- The urban 48% is the mean of the 14 districts' own shares. Auckland's own share is 63%.
- "Slow provincial is clear" rests on three numbers: a silhouette of 0.29, no district below zero, and 21 of its 25 districts core. "Urban and house-building blur" rests on an urban silhouette of 0.02 with 6 districts below zero, and 12 house-building districts that become urban when cost is left out.

## 2. Figures: a slot mode for `rq2_poster_figures.R`. Needs your "proceed"

**Problem.** Your run of 17 Nov draws the figures at 200 x 140 mm and 180 x 150 mm with 18 pt text. Niwesh's slots are 122.5 x 67.7 mm. Shrunk to fit, the text prints at about 8 pt and a third of each slot is left empty. Your run also showed two faults on the scatter:
- **Labels on the wrong points.** `hjust = "inward"` anchors each label at one end, so five of the six labels sit on a neighbour: Dunedin on Napier, Wairoa on Waitomo, Selwyn on Mackenzie, Auckland on Hamilton, and Queenstown-Lakes at Christchurch.
- **Borderline points fade too far.** At alpha 0.3, the pale-orange urban points almost vanish on cream. Only 3 of the 14 urban districts are solid, so the urban type looked nearly empty, and Auckland's point was among the faded ones.

**The proposed change** (one file, about 60 lines; the diff is in `Claude outputs/rq2_v2_checks/`):
1. A `fig_mode` setting. `"slot"` draws both figures at 122.5 x 67.7 mm with 9 pt text and 10.5 pt titles, which matches the chart text in Niwesh's own figures (8–10 pt at print). `"large"` keeps today's sizes for the slides. In slot mode the legend goes on the right and the note and source line move out of the figure into the poster's caption box. The script prints the caption text for you to copy.
2. Scatter labels come from a small table with a fixed position for each. Each position was checked against every other point. The Wairoa label is dropped.
3. Borderline districts get a pale fill with the full dark outline, so the type can still be read. Previously the whole mark was faded.

Both modes were run in Claude's workspace (R 4.3.3, tidyverse) and both draw cleanly. The previews use Liberation Sans, which has the same metrics as Arial, so a Windows run should wrap the same way.

**What is reversible.** Everything. The diff can be reversed, OneDrive keeps earlier versions of the file, and re-running the script only overwrites the two PNGs in `04_Analysis/outputs/rq2/`, which the script regenerates. **What needs you:** "proceed" for Claude to apply the diff to `rq2_poster_figures.R`, then your own run on your machine (Session > Set Working Directory > To Source File Location, then Source). After that, swap the two pictures in the draft file: right-click > Change Picture.

**Not changed:** the figures use your machine's default font (Arial), while Niwesh's figures use Open Sauce One. Matching his would need the `systemfonts` package and a font registration, as in his `make_figures.R`. It is optional and cosmetic.

## 3. Tuesday sheet (P5)

**Decide tonight**
1. **Which Q2 clustering is the group's (Q81).** All three builds agree on 53 of the 65 common districts. Pairwise agreement: you and Niwesh 57, you and Harish 58, Niwesh and Harish 56. The 12 disputed districts are Hastings, Napier, Nelson and Tauranga (only Harish says house-building); Horowhenua, Kapiti Coast and Dunedin (you differ); and Palmerston North, Gisborne, Central Hawke's Bay, Southland and Timaru (Niwesh differs). No district gets three different types. If the group keeps Niwesh's build, this draft's numbers do not apply and his "60 of 66, stability 0.85" stays.
2. **Urban examples.** Auckland, Christchurch and Hamilton are agreed by all three builds but are not core: they come out house-building on 2021–25. Wellington, Lower Hutt and Porirua are the only urban districts that are firm on both tests. The draft keeps the big cities because they are what the type is (Auckland alone is 40% of new homes), and the pale point on the scatter shows it honestly.
3. **65, 66 or 67 districts (Q97).** Kawerau and the Chatham Islands are slow provincial in every build that includes them. The choice moves one district at most.
4. **Type names (Q83).** "Urban multi-unit" (yours) or "Urban medium-density" (Niwesh's). Yours is defined on the multi-unit share, which counts retirement units as well as townhouses and apartments. Use one name everywhere: poster, slides and app.
5. **Type scale of the whole poster (plan item 7).** Niwesh's file prints body text at 11 pt, headings at 19 pt and captions at 9–10 pt. The style brief says 24–28, 44–54 and 18–20. This draft fits his scale. Re-setting to the brief's sizes would cut every panel to about half its words. The poster is submitted and viewed as a PDF, which favours keeping his scale. Either way, decide it once for all three questions.
6. **The RQ2 row of the Approach table.** Proposed: `RQ2 clustering · 65 districts` | `k-means; hierarchical (complete, single, average) as a check` | `k-means, k = 3 (silhouette flat for k = 2–8)`. This is the panel's only place to justify k = 3 in a few words.
7. **Limitations box, one Q2 line.** Proposed: "Market types summarise a continuum: other years, or leaving out cost, move 9 to 17 of the 65 districts." (56, 50 and 48 of 65 keep their type.)
8. **Conclusions box, the link to Q1.** Proposed addition: "Slow provincial districts are about 7% cheaper per m² however the types are formed." His "H2 partly (three types, weakly separated)" already matches the result.
9. **His PCA scatter (`c05`) has to go** whichever member list is adopted. Module 7 does not teach PCA (D3).
10. **The app.** It shows Niwesh's 66-district clusters. If the poster's QR code stays and Q2 uses your build, the two disagree on 8 of the 65 common districts plus Kawerau. Either update the app or add a line saying it shows an earlier build.
11. **The map.** There is still no boundary file (Q90), so the scatter is Figure 1, as the plan's fallback says. A map would read faster for a walk-up reader. It needs the clipped territorial authority layer from the Stats NZ Geographic Data Service, which requires an account to download.

**Bring:** this file, `poster_Q2_draft_Boulton.pptx` (or the PNG of the Q2 row), and `04_Analysis/Boulton/RQ2_three_builds.md` for the district-by-district comparison.

## 4. Rubric pass on the panel (P6)

Top band for the poster (10%): "comprehensive well-organized content, methods clearly justified and sophisticated, high-quality figures well-integrated, polished professional design, excellent clarity of explanation and compelling narrative".

| Criterion | The draft | Gap |
|---|---|---|
| Method named | k-means (k = 3), with hierarchical clustering as a check, on 65 districts and seven measures | none |
| Method justified | The panel says what the method was run on, not why k = 3 | Item 6 above puts the justification in the Approach table. Without it, k = 3 is unjustified on the poster |
| Figures labelled | Titles state the finding; axes labelled with units; legend with counts; captions say what solid means and what a bar is | none |
| Figures integrated | The bullets' ● ■ ▲ match the scatter's markers; the profile chart's measures are the ones the data line refers to | none |
| Clear explanation | Each type in one line of plain numbers and places people know; the answer strip states the result and how firm it is | The "Recent growth" bar is highest for slow provincial (up about 40% between the two halves of the decade, from a low base). A reader may find "slow" and "growth" at odds. Be ready to explain it; there is no room to explain it on the panel |
| Limitation stated | Continuum, silhouette 0.21, 40 of 65 and 53 of 65 | The limitations box line (item 7) adds the scale of the movement |
| Link to the other questions | Cut for space | Item 8, in Conclusions |

**Plan success criteria.** Met: every number matches the knit; the panel names the method and says how firm the result is; there are no blank glyphs. Not met inside the panel: the link to Q1 (moved to Conclusions), "nothing under 18 pt" (item 5), and the 20-second read without a map. Whether a stranger can name the three types in 20 seconds is for the group to judge on the night.
