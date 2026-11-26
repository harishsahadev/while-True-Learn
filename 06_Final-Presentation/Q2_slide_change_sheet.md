# Change sheet: slides 1, 2, 7, 8 and the appendix

_18 Nov 2026. From Boulton, for Niwesh to apply. Written against branch `niwesh` at commit `37cd136` (15 Nov): `communication/slides/build_slides.py` and `communication/make_figures.R`. This replaces `Q2_slide_change_sheet_DRAFT.md`, which can be deleted._

**What it does.** Slide 8 gains the reason for three groups. Slide 7's labels stop colliding and its outlines are explained. Slide 2 says why 67 districts become 66 and carries the inflation numbers. The appendix names the distance and linkage, and gains two pages on how three groups were chosen. Counted pages stay at 10.

**Preview:** `Q2_slides_preview_changed_pages.pdf` (seven pages: slides 1, 2, 7, 8 and appendix pages 12 to 14). **Numbers:** all in `Claude outputs/q2_slides_A/check_table.md` (38 checks).

## How to apply

Either route gives the same result.

1. **Patches.** From the repo root: `git apply path/to/make_figures.R.diff path/to/build_slides.py.diff` (both files are in `for_Niwesh/`). Both apply cleanly to `37cd136`. If your working copy has moved on and they do not apply, use route 2.
2. **By hand,** from tables A and B below.

Then, from `building-consents/`: `Rscript communication/make_figures.R`, `python communication/slides/build_slides.py`, `Rscript communication/render_pdf.R slides`.

## A. Text, in `build_slides.py`

| # | Slide and element | Old | New | Why |
|---|---|---|---|---|
| T1 | 2 Data, second card (`steps[1]`, body) | Months added up into quarters and years, for 67 districts | Months added up into quarters and years for 67 districts; 66 for questions 2 and 3, without the Chatham Islands | Slide 2 says 67 and slides 7 and 10 say 66, with no reason given |
| T2 | 7 RQ2, subtitle | Grouping 66 districts by how they build, 2016–2026 | 66 districts grouped by nine measures of how they build, 2016–2026 | Nothing on the slide said what "how they build" rests on |
| T3 | 8 RQ2, layout | Chart card 8.3 wide; two cards at x = 9.0, 3.85 wide | Chart card 7.4 wide, using the new slide-sized chart (F5); three cards at x = 8.1, 4.75 wide, the same column as slide 7 | Room for a third card at 14 pt |
| T4 | 8 RQ2, new card between the other two | (none) | **Why three groups?** Two or three groups fit about equally well. Three held up best when we repeated the grouping on 100 re-drawn samples, and each group is one we can name. | The slide gave no reason for three. This is the reason in section 4 of the RQ2 notebook: fit 0.22 at two and 0.21 at three; stability 0.74 at two and 0.84 at three |
| T5 | 8 RQ2, "But the edges are soft" | unchanged | unchanged | The card only moves and widens |
| T6 | 12 Appendix, RQ2 Methods (`rows[2][2]`) | k-means; hierarchical (single, complete, average, Ward) | k-means on nine standardised measures (Euclidean distance); hierarchical clustering with single, complete, average and Ward linkage | The Week 8 class asked for the distance and the linkage to be named |
| T7 | 12 Appendix, RQ2 Validation (`rows[3][2]`) | Silhouette, CH, gap, bootstrap stability | Silhouette, Calinski–Harabasz, gap statistic, stability over 100 resamples; no test set | "CH" was unexpanded. The class asked each result to say whether it is training, cross-validation or test |
| T8 | 12 Appendix, RQ2 Result (`rows[4][2]`) | k = 3; ARI 0.75 between methods | Three groups; k-means and Ward agree on 60 of 66 districts (adjusted Rand index 0.75) | Says what the 0.75 compares |
| T9 | 12 Appendix, references | (two entries) | Add: Stats NZ. (2026). Business price indexes: June 2026 quarter [Data set]. CC BY 4.0. https://www.stats.govt.nz/information-releases/business-price-indexes-june-2026-quarter/ | Slide 2 relies on this index and the poster cites it. The link is the one in the repo README; please open it once |
| T10 | 12 Appendix, table rows | body rows 0.6 high; references at y = 5.55 | body rows 0.68 high; card 3.95 high; references at y = 5.72 | The longer RQ2 cells need the room |
| T11 | Notes for the title and slides 1, 2, 7, 8 | 289 words | 469 words: see `Q2_speaker_notes.md` | Two lines on slide 8 did not match the chart ("mostly townhouses" against 39.1%; "the most commercial building" against a 39.3% share). The deck's notes also ran about 6 minutes in a 9-to-11-minute slot |

## B. Figures, in `make_figures.R`

`c01` and `c05` are also the poster's figures, so F1 and F3 change the poster too. `c06` keeps its size for the poster; slide 8 uses the new `c06s`.

| # | Figure | Change | Why |
|---|---|---|---|
| F1 | `c01_cost_by_district_2025` | subtitle "Cost per square metre of new houses in 2025: the five dearest and five cheapest districts"; new caption "Districts with 50 or more new houses in 2025. June-2026 dollars." | Nothing said the dark bars are the five dearest and the light bars the five cheapest (meeting, 31:04). "Real" was used a slide before inflation is explained |
| F2 | `c02_inflation` (slide version) | The two lines are labelled "After removing building-cost inflation: up 20%" and "In the dollars of each year: 4.7 times", in place of the legend. Subtitle gains "1991 to 2025". `rise` is now computed once, above `p2`, and `p2b` uses it | Meeting, 1:08:06. The poster's `c02b` already carried both numbers |
| F3a | `c05_rq2_markets`, labels | Labels the ten districts that slide 7's cards and notes name: Auckland, Wellington, Christchurch, Queenstown-Lakes, Selwyn, Waipa, Tasman, Gore, Wairoa, Grey. Drops Thames-Coromandel, Hamilton and Clutha | So the listener can find the examples. Removes the Christchurch–Hamilton collision |
| F3b | `c05`, label positions | A small table, `lab_pos`, gives each label its own `hjust`, `vjust` and nudge. No label touches a point or another label. The y scale gets a little more room at the bottom (`expansion(mult = c(0.12, 0.12))`) for the label under Selwyn | Wairoa sat on its own two points and Tasman on Selwyn |
| F3c | `c05`, subtitle | "Each dot is a district; nearby dots build in similar ways." and, on a second line, "Dashed outlines show where most of each kind sit" | The outlines are 80% ellipses. Unexplained, they read as borders, and slide 8 says the edges are soft |
| F4 | `c06_rq2_profiles`, title | "How the three markets differ (the middle district of each kind)" | "Median" was the one technical word on slide 8 |
| F5 | new `c06s_rq2_profiles_slide` | The same chart saved at 9.6 by 6.2 with a smaller legend, as `c02` and `c02b` are a pair | In slide 8's narrower card the wide version printed its labels at about 9 pt. This one prints them at about 11 pt |
| F6 | new `c09_rq2_choose_k` | Two bar panels from `outputs/tables/rq2/t02_choose_k.csv`: fit and stability for two to eight groups, three highlighted | For the new appendix page |

**Two things to know about F3b.** The positions were worked out on the picture as it is now, with Wairoa at the far left and Queenstown-Lakes at the far right. If `prcomp()` ever flips an axis on your machine, the labels will need another look. And the preview was drawn with ggplot2 3.4.4, so spacing may differ slightly from yours: check the scatter after you regenerate it.

## C. Two new appendix pages, after page 12. Neither is counted in the 10.

**Page 13: How we chose three groups.** Presenter: Andrew Boulton. Subtitle: k-means on 66 districts and nine measures. Every district is used, so there is no test set. Chart: `c09_rq2_choose_k.png`.

| Card | Text |
|---|---|
| Fit | How well districts fit their group (silhouette, from −1 to 1): 0.22 with two groups, 0.21 with three, lower from four up. No clear winner. |
| Repeatability | Agreement between the grouping and 100 re-runs on re-drawn samples (adjusted Rand index; 1 is identical): 0.74 with two groups, 0.84 with three, 0.80 with four, 0.69 with five. |
| Why "soft edges" | A fit near 0.2 is weak, and the gap statistic prefers one group. The three kinds summarise a range. They are not separate islands. |

**Page 14: A second method: Ward's tree.** Presenter: Andrew Boulton. Subtitle: Hierarchical clustering of the same 66 districts. The height of a join is how far apart the two branches are. Picture: `outputs/figures/rq2/fig05_dendrogram.png`, as it is.

| Card | Text |
|---|---|
| What it shows | Ward's linkage, cut into three, gives groups of 34, 20 and 12 and agrees with k-means on 60 of 66 districts. Single and average linkage chain: 64/1/1 and 62/2/2. |
| How to read it | Closeness is the height where two branches join, not how near they sit left to right. |

The draft had these on one page. The tree is unreadable at half a slide, so it has its own.

## D. Left as they are

- Slide 1: the three bullets.
- Slide 7: the title and the three cards. The six examples are in the right kind (checked).
- Slide 8: the title, the chart's twelve numbers (checked), the "60 of 66" card and the wording of "But the edges are soft".
- Slides 3 to 6 and 9 to 11.

## E. For the group on Friday. Outside these slides.

1. **Slide 3:** "every model learns from the past and is tested once on recent years it never saw" is not true of RQ2, which has no test set. "Every prediction model" would make it true.
2. **Poster, Q2 answer strip:** "stable (0.85)". `t02_choose_k.csv` gives 0.8446, which rounds to 0.84. The poster change sheet fixes it.
3. **Timing:** the 15 Nov notes are 794 spoken words, about 5.7 minutes, plus the 35-second app demo: about 6.3 minutes in a 9-to-11-minute slot. With these notes the total is about 7.5 minutes. Harish's and Niwesh's parts need lengthening too.
4. **Slide 10 and the appendix:** the slide says 2018–2025 and the appendix says "test 2017–24".
5. **RQ2 notebook, leave-one-out paragraph:** it says seven of the nine features leave the clusters almost unchanged (ARI 0.86 to 1). `t07_leave_one_feature_out.csv` has six at 0.86 or more; apartments is 0.80.

## Checked before this was written

- Every "old" string above occurs exactly once in the 15 Nov files.
- Both patches apply cleanly to the 15 Nov files.
- The preview deck has 15 pages: title, 10 counted, conclusion, three appendix.
- Slide 8's new card is 29 words. All new slide text is 14 pt or larger. The appendix table and references keep their existing 11.5 and 10.5 pt.
- On the redrawn scatter, no label touches a point or another label.
