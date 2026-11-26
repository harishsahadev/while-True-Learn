# Change sheet: slides 1, 2, 7, 8 and the appendix — DRAFT for Boulton's read

_PRD step 2, 18 Nov 2026. Wording only: no figure has been drawn and no slide built. Written against Niwesh's branch as downloaded 15 Nov (commit `37cd136`): `communication/slides/build_slides.py` and `communication/make_figures.R`. Every number below is in `Claude outputs/q2_slides_A/check_table.md` (33 checks; `check_numbers.py` reproduces them)._

**How to read it.** "Old" is the exact string in his file. "New" is what replaces it. Nothing here has been sent to Niwesh or changed in his files.

## A. Text, in `build_slides.py`

| # | Slide and element | Old | New | Why |
|---|---|---|---|---|
| T1 | 2 Data, second card (`steps[1]`, body) | Months added up into quarters and years, for 67 districts | Months added up into quarters and years for 67 districts; 66 for questions 2 and 3, without the Chatham Islands | Slide 2 says 67 and slides 7 and 10 say 66, with no reason given. Both notebooks drop the Chatham Islands (34 new homes in ten years). You present both numbers |
| T2 | 7 RQ2, subtitle | Grouping 66 districts by how they build, 2016–2026 | 66 districts grouped by nine measures of how they build, 2016–2026 | Nothing on the slide says what "how they build" rests on. Your notes will name the nine (step 5) |
| T3 | 8 RQ2, layout | Chart card 8.3 wide; two cards at x = 9.0, 3.85 wide | Chart card 7.4 wide; three cards at x = 8.1, 4.75 wide (slide 7's column) | Room for a third card at 14 pt. The chart has blank bands either side of its four panels |
| T4 | 8 RQ2, new card between the two | (none) | **Why three groups?** Two or three groups fit about equally well. Three held up best when we repeated the grouping on 100 re-drawn samples, and each group is one we can name. | The slide gives no reason for three. This is the reason in his notebook (section 4): fit 0.22 at two and 0.21 at three; repeatability 0.74 at two and 0.84 at three. 29 words |
| T5 | 8 RQ2, "But the edges are soft", body | Districts form a smooth range rather than separate boxes; some places (Palmerston North, Tauranga) sit between two markets. | A smooth range, not separate boxes: Palmerston North and Tauranga sit between two. Three separate analyses, one by each of us, agree on 53 of 65 districts. | Adds the cross-check from option A. The two examples stay: they have the two lowest fit scores (−0.08 and −0.05) |
| T6 | 12 Appendix, RQ2 Methods (`rows[2][2]`) | k-means; hierarchical (single, complete, average, Ward) | k-means on nine standardised measures (Euclidean distance); hierarchical clustering with single, complete, average and Ward linkage | The class asked for the distance and the linkage to be named |
| T7 | 12 Appendix, RQ2 Validation (`rows[3][2]`) | Silhouette, CH, gap, bootstrap stability | Silhouette, Calinski–Harabasz, gap statistic, stability over 100 resamples; no test set | "CH" is unexpanded. The class asked each result to say whether it is training, cross-validation or test |
| T8 | 12 Appendix, RQ2 Result (`rows[4][2]`) | k = 3; ARI 0.75 between methods | Three groups; k-means and Ward agree on 60 of 66 districts (adjusted Rand index 0.75) | Says what the 0.75 compares |
| T9 | 12 Appendix, references | (two entries) | Add: Stats NZ. (2026). _Business price indexes: June 2026 quarter_ [Data set]. CC BY 4.0. https://www.stats.govt.nz/information-releases/business-price-indexes-june-2026-quarter/ | Slide 2 relies on this index and the poster cites it. The link is the one in his README; not opened by me |

## B. Figures, in `make_figures.R`

`c01`, `c05` and `c06` are also the poster's figures, so F1, F3 and F4 change the poster too.

| # | Figure | Old | New | Why |
|---|---|---|---|---|
| F1 | `c01_cost_by_district_2025`, subtitle and caption | subtitle = "Real cost per square metre of new houses, 2025 (districts with 50+ new houses)" | subtitle = "Cost per square metre of new houses in 2025: the five dearest and five cheapest districts"; caption = "Districts with 50 or more new houses in 2025. June-2026 dollars." | Nothing says the dark bars are the five dearest and the light bars the five cheapest (meeting, 31:04). "Real" is used a slide before inflation is explained |
| F2 | `c02_inflation` (slide version) | Legend only | Label the line ends as `c02b` does: "in each year's dollars: 4.7 times" and "after removing inflation: up 20%" | Meeting, 1:08:06. Both numbers are already computed in his script as `rise` (4.74 and 20.5%, 1991 to 2025) |
| F3a | `c05_rq2_markets`, `show_names` | Auckland, Wellington, Christchurch, Queenstown-Lakes, Selwyn, Tasman, Thames-Coromandel, Wairoa, Hamilton, Clutha | Auckland, Wellington, Christchurch, Queenstown-Lakes, Selwyn, Waipa, Tasman, Gore, Wairoa, Grey | Label the districts the three cards name, so the listener can find them. Drops the Christchurch–Hamilton collision |
| F3b | `c05`, label positions | `geom_text(..., vjust = -0.9)` for every label | Each label placed so it touches no point and no other label. Positions come with the redrawn figure | Wairoa sits on its own two points; Tasman on Selwyn; Thames-Coromandel picks up a stroke of an outline |
| F3c | `c05`, subtitle | Each dot is a district (2016–2026); nearby dots build in similar ways | Each dot is a district; nearby dots build in similar ways. Dashed outlines show where most of each kind sit | The outlines are `stat_ellipse(level = 0.8)`. Unexplained, they read as borders, and slide 8 says there are none |
| F4 | `c06_rq2_profiles`, title (optional) | How the three markets differ (median district) | How the three markets differ (the middle district of each kind) | "Median" is the one technical word on slide 8. Leave it if the group prefers it for the poster |

## C. One new appendix page, after page 12. Not counted in the 10.

Presenter: Andrew Boulton. Title: **How we chose three groups**. Subtitle: k-means on 66 districts and nine measures. Every district is used, so there is no test set.

| Card | Text |
|---|---|
| Fit | How well districts fit their group (silhouette, from −1 to 1): 0.22 with two groups, 0.21 with three, lower from four up. No clear winner. |
| Repeatability | Agreement between the grouping and 100 re-runs on re-drawn samples (adjusted Rand index; 1 is identical): 0.74 with two groups, 0.84 with three, 0.80 with four, 0.69 with five. |
| A second method | Ward's hierarchical clustering, cut into three, gives groups of 34, 20 and 12 and places 60 of 66 districts as k-means does. Single and average linkage chain: 64/1/1 and 62/2/2. |
| Why "soft edges" | A fit near 0.2 is weak, and the gap statistic prefers one group. The three kinds summarise a range. They are not separate islands. |

Figures: a new two-panel chart of fit and repeatability by number of groups, drawn from his `outputs/tables/rq2/t02_choose_k.csv`; and his `outputs/figures/rq2/fig05_dendrogram.png` as it is. If both do not fit at 14 pt, this becomes two appendix pages.

## D. Left as they are

- Slide 1: the three bullets.
- Slide 7: the title and the three cards. The six examples are in the right kind (checked).
- Slide 8: the title, the chart's twelve numbers (checked), and the "60 of 66" card.
- Your notes for all five pages. They are rewritten in step 5, including the two lines that do not match the chart ("mostly townhouses": 39.1%; "the most commercial building": the highest share, 39.3%).

## E. For the group on Friday. Outside your slides, so not in this sheet's changes.

1. **Slide 3 (Harish):** "every model learns from the past and is tested once on recent years it never saw" is not true of RQ2, which has no test set. "Every prediction model" would make it true.
2. **Poster, Q2 answer strip:** "the grouping is stable (0.85)". His table gives 0.8446, which rounds to 0.84. The slides will say 0.84.
3. **Timing:** the deck's notes are 794 spoken words, about 5.7 minutes at 140 words a minute, plus a 35-second app demo: about 6.3 minutes in a 9-to-11-minute slot. (Andrew 289 words, Harish 290, Niwesh 215 and the demo.)
4. **Slide 10 and the appendix (Niwesh):** the slide says 2018–2025 and the appendix says "test 2017–24".
5. **The cross-check in T5** speaks for all three of you. Harish's types were read from his knitted notebook of 15 Nov. He and Niwesh should agree to the line.

## Decisions for you before I draw anything

1. **The outlines on slide 7.** I told you they were drawn by eye and you accepted "ask Niwesh to remove them". That was wrong: they are 80% ellipses computed by `stat_ellipse()`. F3c now keeps them and says what they are. Keep and explain, or remove?
2. **T4**, the wording of "Why three groups?".
3. **T5**, saying on a slide that the three of you each ran a separate analysis.
4. **T3**, the narrower chart on slide 8.
