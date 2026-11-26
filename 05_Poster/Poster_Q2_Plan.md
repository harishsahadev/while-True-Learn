# Poster plan — the Q2 panel

_Plan 2 of 3 (with `RQ2_Rebuild_Plan.md` and `Slides_Q2_Plan.md`). Created 2026-11-16 from the group meeting of Sun 15 Nov; revised the same day (no PCA figure; figures come from `rq2_poster_figures.R`). Owner: Boulton. Poster due Sun 22 Nov as a PDF, A2 portrait; the group finalises it on Tue 17 Nov and aims to submit by Fri 20 Nov._

> **Note, 16 Nov (after the v2 build).** "Firm" is now reported both ways: 40 of 65 districts keep their type in all four runs of the notebook, and 53 of 65 get the same type from all three group members' builds; 32 do both and are the solid points on the scatter. Replace any line here that gives only "40 of 65". The profile chart and the scatter are 200 x 140 mm and 180 x 150 mm at 18 pt, and the profile chart's labels are the short ones in `rq2_poster_figures.R`. Numbers from the knit: `Claude outputs/rq2_v2_checks/README.md`.

> **Note, 17 Nov (P0 and P1 done).** Every number under "Draft words" is now read from Boulton's own knit, `04_Analysis/Boulton/04_RQ2_v2.html` (17 Nov), and its `04_Analysis/outputs/rq2/rq2_types.csv`, which match the reference knit exactly. P0 found that Niwesh's poster sets body text at 11 pt and gives each figure a slot of 122.5 x 68 mm, so the 18 pt and 24 pt figures in this plan cannot hold inside his layout: see "Panel space in Niwesh's file" and item 7 under "To raise". The panel draft fitted to his layout is `05_Poster/Q2_panel_draft.md`.

**To use in a new chat:** open a chat in the STAT462 project with the folder connected, after `04_RQ2_v2.Rmd` has knitted, and say _"Work through `Poster_Q2_Plan.md`. Fill the numbers from the v2 knit first."_ The chat should also read `Style_Guide/Project_Style_Brief.md` (section 7 is the poster).

## PRD

**Problem.** Niwesh's poster is the agreed base. Its Q2 panel carries his clustering and his numbers. I own Q2, so the panel has to be rebuilt from `04_RQ2_v2.Rmd`, say the same thing as my slides, and be readable by someone who walks up knowing nothing about the project. The poster is also where the group meets the brief's requirement for a method from Module 4 onwards, and clustering is one of the three we can point to.

**Success criteria.**
- A stranger can say what the three market types are after about twenty seconds in front of the panel.
- Every number on the panel matches the v2 knit and the slides.
- The panel names its method, says how firm the result is, and connects to Q1.
- The rubric's top band is covered for this panel: methods justified, figures well integrated and labelled, clear explanation, limitations stated.
- Nothing prints under 18 pt. No blank glyphs where m² should be.

**Scope.** In: the Q2 panel's headline, two figures, three type cards, method line, limits line, link line; exported figures; my notes for Tuesday on the poster-wide points that touch Q2. Out: the Q1 and Q3 panels, the background and data sections, and the layout of the whole poster, which are group decisions on Niwesh's file.

**Constraints.** A2 portrait PDF. Title, group name and all members' names on the poster. Sections the brief lists: background or motivation, research question, data and methods, results, conclusions, limitations or future work. Style brief palette and type sizes (section headings 44–54 pt, body 24–28 pt, captions 18–20 pt). APA 7 references and a line acknowledging AI use. Open Sauce One has no ², ≥, ≤, ≈ or →; set those in Arial. R figures are allowed on the poster if styled to the palette.

## What the meeting agreed (15 Nov)

- Layout: how the data was prepared at the top, then each question with two graphs and a short explanation, sources at the bottom.
- Stick with Niwesh's concept and theme. He uploads the editable file; each of us proposes changes; Tuesday finalises the poster and the graphs.
- Replace the large stat tiles (×4.7, 20%) with the nominal-against-real cost chart in a small box and put the numbers in as pointers. Harish's point: the tiles look machine-made.
- Design for the walk-up reader. Boulton suggested, for Q2, one picture of the three groups with an explanation of each group underneath.
- Carry the pitch feedback forward: spell-check, and test every link.

## The Q2 panel

| Element | Content | Source in `04_RQ2_v2.Rmd` |
|---|---|---|
| Question | What kinds of building markets does New Zealand have? | — |
| Headline (states the finding) | **Three kinds of building market: one clear, two that blur** | §4 The three market types |
| Figure 1 (hero) | NZ map, 65 districts coloured by market type, legend with the count in each type | `rq2_map_types.png` |
| Figure 2 | Profile chart: one small panel per type, bars showing how it differs from the average district on each of the seven measures, labels in plain English | `rq2_profile_types.png` |
| Three type cards | Name · districts · share of new homes · two or three defining numbers · four example districts | §4, means and members tables |
| Method line | k-means clustering (k = 3) on seven standardised measures of each district's consents, 2016–25, for the 65 districts that consented at least 100 new homes; hierarchical clustering (complete, single and average linkage) as a cross-check. Why three: the silhouette is nearly flat from 2 to 8 (0.19–0.23, highest at 2, 0.230 against 0.213), and k = 2 only splits the 25 slow districts and Lower Hutt from the rest | §2 and §3 |
| Limits line | How firm the types are: silhouette, and how many districts are core | §2.2 and §4 |
| Link line | How market type relates to cost (Q1) | §4, the cost-out check |

Alternates if the map is not ready by Tuesday: Figure 1 becomes the log-axis scatter (`rq2_scatter_log.png`) with core districts solid and borderline ones hollow. There is no PCA figure: Module 7 does not teach it (confirmed 16 Nov).

### Draft words — numbers from the v2 knit (17 Nov)

Type cards:

| Type | Districts | Share of new homes | What marks it out | Examples |
|---|---|---|---|---|
| **Slow provincial** | 25 | 6% | 3.4 new homes per 1,000 people a year, the lowest. 23% of residential building spending goes on existing homes, the highest. About 7% below the national cost per m², with or without cost as an input. | Whanganui, Invercargill, Whakatane, the West Coast |
| **Urban multi-unit** | 14 | 69% | 48% of new homes are not stand-alone houses, including 9% retirement-village units. About 7% above the national cost per m². | Auckland, Wellington, Hamilton, Christchurch |
| **House-building** | 26 | 24% | 8.5 new homes per 1,000 people a year, the highest. The biggest houses, 192 m². The smallest share of spending on existing homes, 13%. | Selwyn, Waimakariri, Tasman, Central Otago |

Source of each number (knit section): districts 4.1; share of new homes and cost against NZ 4.2 (6.4 / 69.3 / 24.3% and −6.9 / +6.9 / −3.0%); means 4.2 (`per1000` 3.35 / 7.74 / 8.52, `multi_share` 0.155 / 0.477 / 0.165, `retire_share` 0.016 / 0.095 / 0.063, `house_m2` 175 / 183 / 192, `alt_share` 0.227 / 0.152 / 0.131); members 4.3; cost without the cost input 4.5.

Changed from the first look, and why:
- Urban retirement units 10% → **9%** (0.0948).
- House-building **"84% stand-alone" dropped**: the slow provincial type is 84% stand-alone too (83.5% and 84.5%), so it does not mark the type out. Replaced with the renovation share, 13%, the lowest of the three.
- Slow provincial example **Timaru → Whakatane**. Timaru is core but Niwesh's build gives it another type. Whanganui, Invercargill, Whakatane and the West Coast (Buller, Grey, Westland) are core and agreed by all three builds. Revert if you want Timaru.
- Urban examples kept, with a caveat: **Auckland, Christchurch and Hamilton are not core** (they come out house-building on 2021–25), though all three builds agree on them. Wellington is core and agreed. Only three urban districts pass both tests: Wellington, Lower Hutt and Porirua. The big cities stay as examples because they are what the type is (Auckland alone is 40% of the country's new homes).
- The slow card's cost line now ends **"with or without cost as an input"**. That is the part of the cost difference that is not circular (knit 4.5).

Limits line: _"The types are parts of one continuum, not separate groups: the silhouette coefficient is 0.21 (0.25 or less reads as no strong structure), and hierarchical clustering sets only Queenstown-Lakes and Wellington City apart. 40 of the 65 districts keep their type in all four of our runs (other years, cost left out), and 53 get the same type from all three team members' builds. The slow provincial type is the firm one."_ Changed: the first-look line said "whichever years, measures or districts"; no v2 run changes the districts, so "districts" is gone. Both counts are given (D9).

Link line: _"Q1 found that location matters most for cost. Market type is part of what location means: slow provincial districts are about 7% cheaper per m² than the country, whether or not cost is used to form the types."_ Changed: the first-look line also said urban multi-unit districts are the dearest. Knit 4.5 shows that gap appears only when cost is an input (types formed without cost: −7.1%, 0.0% and +0.1% against NZ), so it describes how the types were formed and is not a finding. Only the slow provincial gap survives the check.

Hook, if the panel has room for one large figure: _"14 districts consent 7 in every 10 new homes."_ (69.3%: 261,158 of 377,073 new dwellings, 2016–25.)

Word budget for the panel: about 120 words outside the cards. If it does not fit at 24 pt, cut the link line first and keep the limits line. **17 Nov:** in Niwesh's layout the Q2 text card takes about 110 words at 11 pt and the answer strip two lines at 13 pt; the fitted draft is in `Q2_panel_draft.md`.

### Figure specifications (produced by `rq2_poster_figures.R`, Stage 3 of the rebuild)

| File | Size at print | Notes |
|---|---|---|
| `rq2_map_types.png` | 150 × 200 mm | Three fills, thin district outlines dark enough that the lightest fill still reads against the cream background, no axes or gridlines. Five districts labelled. Kawerau grey, "not clustered". **Not drawn: no boundary file (Q90).** |
| `rq2_profile_types.png` | 200 × 140 mm (script) | Same three colours. Bars from a zero line. Measure labels as in the script: "Homes per 1,000", "Multi-unit homes", "Retirement units", "House size", "Renovation share", "Building cost", "Recent growth". Drawn on Boulton's machine 17 Nov. |
| `rq2_scatter_log.png` | 180 × 150 mm (script) | Homes per 1,000 people (log scale) against multi-unit share. Solid = core and agreed by all three builds (32 of 65). Drawn on Boulton's machine 17 Nov; the district labels need fixing (P3). |

All at 300 dpi, transparent background, text no smaller than 18 pt at print size, a title that states the finding and a source line (Stats NZ, Building consents issued, August 2026). Colour is never the only cue: label the types directly on the figure.

### Panel space in Niwesh's file (P0, 17 Nov)

From `04_Analysis/while-True-Learn-niwesh_2026-11-15/building-consents/communication/poster/poster.pptx`, read without changing it.

- **Format and master.** One PowerPoint slide, 420 x 594 mm (A2 portrait). The master is `poster.html`; the pptx and the PDF are generated from it by `pptx/build_poster_pptx.py`. Hand edits to the pptx are carried back with `pptx/compare_pptx.py`, which matches shapes by name, so an edited copy must keep the shape names.
- **The Q2 row** (y 309–408 mm): a text card 130 x 99 mm on the left (`Box 74`, text boxes `Text 76`–`Text 82`); two figure cards 128 x 79 mm (`Box 83` with picture `Chart c05_rq2_markets`, 122.5 x 67.7 mm; `Box 86` with `Chart c06_rq2_profiles`, 122.5 x 56.1 mm), each with a 10 pt caption box under it (`Text 85`, `Text 88`); an answer strip 261 x 17 mm (`Box 89`, `Text 90`, 13 pt, two lines).
- **Type sizes actually used:** title 42 pt, section headings 19 pt, question 14.5 pt, body 11 pt, captions 10 pt, references 9 pt. The style brief's poster sizes (title 120–150, headings 44–54, body 24–28, captions 18–20) are about 2.2 times larger.
- **Consequence for the figures.** Our profile chart (200 x 140 mm) shrunk into a 122.5 x 67.7 mm slot is limited by height: 48%, so 18 pt prints at 8.7 pt. The scatter (180 x 150 mm): 45%, 8.1 pt. That is close to the chart text in Niwesh's own figures, but leaves 25–40 mm of each slot empty, because our figures are taller than his slots. Re-exporting at the slot's shape (about 1.8 : 1) would use the slot properly.
- **What his Q2 panel says now:** 66 districts, nine features, a PCA scatter (`c05`, "Axes: first two principal components"), medians of four features (`c06`), types House-building (30), Slow provincial (21), Urban medium-density (15), and "k-means and Ward's clustering agree on 60 of 66 districts ... (silhouette 0.21)". The Approach table's RQ2 row says "66 districts", "k-means and hierarchical (4 linkages); k chosen by 5 criteria". The Conclusions say "H2 partly (three types, weakly separated)", which our result supports.
- **Colours in his file** (`communication/make_figures.R`): slow provincial `#C76B0A`, urban `#FBAC4D`, house-building `#5C5148`. `rq2_poster_figures.R` already uses the same three.

## Plan

- [x] P0 Get Niwesh's editable poster file and note its format and the size of the Q2 panel. Adjust the figure sizes above to fit. _Done 17 Nov: see "Panel space in Niwesh's file". The figures are not yet re-sized: that waits on Tuesday item 7._
- [x] P1 After the v2 knit: replace every first-look number in the tables above. One pass, one source. _Done 17 Nov from Boulton's knit; changes listed under the type cards, the limits line and the link line._
- [ ] P2 Agree type names and one colour per type with the group. Proposal from the existing palette: slow provincial light orange `#FFBE73`, house-building deep orange `#C76B0A`, urban multi-unit muted ink `#5C5148`. Check the three for contrast and colour-blind separation before fixing them; if Niwesh's file already has three, use his. _17 Nov: his file has three (slow `#C76B0A`, urban `#FBAC4D`, house-building `#5C5148`), so by this step's own rule his win and the proposal above is superseded. The script already uses them. Palette check (16 Nov): distinguishable, including for colour-blind readers; `#FBAC4D` is 1.7 : 1 against cream, so every mark keeps a dark outline and its own shape. Names still open: his "Urban medium-density" against our "Urban multi-unit"._
- [ ] P3 Run `rq2_poster_figures.R` to export the figures. Look at each at 100% and again shrunk to A4. _17 Nov: Boulton ran it (profile chart and scatter in `04_Analysis/outputs/rq2/`; map skipped, no boundary file). Looked at: the profile chart reads well. On the scatter, `hjust = "inward"` anchors each label at one end, so five of the six land on a neighbour: "Dunedin" sits over Napier, "Wairoa" over Waitomo, "Selwyn" over Mackenzie, "Auckland" over Hamilton, and "Queenstown-Lakes" starts at the Christchurch point, far from its own. Only "Wellington" is clear. Fix with the slot re-export._
- [x] P4 Draft the panel in the editable file, or hand Niwesh the words and figures if he holds the master. Changing his file is his call or the group's. _Done 17 Nov: `05_Poster/poster_Q2_draft_Boulton.pptx` is a copy of his file with only the Q2 row changed (shape names kept, so his `compare_pptx.py` lists the edits); the words shape by shape are in `05_Poster/Q2_panel_draft.md`. Figures in it are slot-size previews; the script change behind them (`Claude outputs/rq2_v2_checks/rq2_poster_figures_slot_mode.diff`) waits on "proceed"._
- [ ] P5 **Tuesday 17 Nov meeting** — take: the panel draft, the member list, the three-build comparison table, and the items under "To raise" below. _Sheet ready: `Q2_panel_draft.md` section 3._
- [x] P6 Rubric pass on the panel: method named and justified, figure labelled, explanation clear, limitation stated. _Done 17 Nov (`Q2_panel_draft.md` section 4). Gap: k = 3 is not justified inside the panel; the proposed Approach-table row carries it._
- [ ] P7 Whole-poster checks before PDF export: A2 portrait; title, group name, three names; all six sections present; references in APA 7 including Kaufman and Rousseeuw (1990) and Stats NZ; AI acknowledgement; every link opened; spell-check; no blank glyphs.
- [ ] P8 Submit, then complete the peer review, which opens once the group submission is uploaded.

## To raise on Tuesday

1. Which clustering is the group's Q2. My rebuild uses 65 districts with cost as an input, which the first look puts close to Niwesh's result. Bring the district-by-district comparison.
2. Type names: slow provincial / urban multi-unit / house-building, or Niwesh's or Harish's wording.
3. One colour per type, used on the map, the cards, the slides and the app.
4. The methods box should name clustering explicitly as the Module 7 method, alongside trees for Q1 and discriminant analysis for Q3.
5. The limitations box should carry the Q2 caveat in one line.
6. The Shiny app shows Niwesh's clusters. If the poster links to it, the app and the poster have to agree.
7. **The type scale of the whole poster.** Niwesh's file prints body text at 11 pt, headings at 19 pt and captions at 9–10 pt on A2; the style brief says 24–28, 44–54 and 18–20. Either the group keeps his scale, and the Q2 figures are re-exported for his 122.5 x 68 mm slots with chart text at about 9 pt to match his, or the poster is re-set larger and every panel loses about half its words. This plan's "nothing under 18 pt" cannot hold in his layout as it is.
8. **The RQ2 row of the Approach table:** "66 districts" becomes 65 (or whatever Q97 settles); "k-means and hierarchical (4 linkages); k chosen by 5 criteria" becomes "k-means; hierarchical (complete, single, average) as a check; k by silhouette, 2 to 8".
9. **His Q2 scatter is a PCA plot** (`c05`, "Axes: first two principal components"). It has to go whichever member list is the group's: Module 7 does not teach PCA (D3).
10. **References:** add Kaufman and Rousseeuw (1990) if the panel cites the "0.25 or less" reading. His references already carry an AI line.

## Open questions

1. ~~Format of the editable poster and who holds the master.~~ _Answered 17 Nov: PowerPoint generated from `poster.html`; Niwesh holds the master; pptx edits go back through `compare_pptx.py`._
2. ~~Is there room for both figures?~~ _Answered 17 Nov: his layout has two figure slots per question, so both figures go in, at slot size (122.5 x 67.7 and 122.5 x 56.1 mm), not at the sizes above. The three type cards become the three bullets in his text card._
3. Final type names and colours (rebuild plan, open question 4).
