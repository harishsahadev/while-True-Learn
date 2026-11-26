# Change sheet: the poster's RQ2 row

_18 Nov 2026. From Boulton, for Niwesh to apply. Written against branch `niwesh` at commit `37cd136` (15 Nov): `communication/poster/poster.html`. The figure changes are in the slides sheet (`06_Final-Presentation/Q2_slide_change_sheet.md`), because the poster and the slides share `c01`, `c05` and `c06`._

**What it does.** The answer is given in the question's own words. The reason for three groups goes into the free lines of the RQ2 card. The distance is named and "no test set" is said. "Stable (0.85)" becomes 0.84. The poster's height does not change.

**Previews:** `poster_preview_RQ2_changes.pdf` (the whole poster), `poster_Q2_row_preview_A_four_measures.png` and `poster_Q2_row_preview_B_nine_measures.png`. **Numbers:** all in `Claude outputs/q2_slides_A/check_table.md`.

## How to apply

From the repo root: `git apply path/to/poster.html.diff` (the file is in `for_Niwesh/`). It applies cleanly to `37cd136`. Or make the five edits below by hand. Then regenerate the figures and the PDF as usual.

## A. Text, in `poster.html`

| # | Where | Old | New | Why |
|---|---|---|---|---|
| PA1 | Approach table, RQ2 row, "Methods compared" | **k-means** and **hierarchical** (4 linkages); k chosen by 5 criteria | **k-means** and **hierarchical** (4 linkages) on standardised features, Euclidean distance; k chosen by 5 criteria; no test set | The Week 8 class asked for the distance to be named and for each result to say whether it is training, cross-validation or test. The paragraph above the table says models are tested on years they never saw, which is not true of RQ2 |
| PA2 | RQ2 card, new paragraph under the three bullets | (none) | **Why three?** Two or three groups fit about equally well (silhouette 0.22 and 0.21). Three was the most stable over 100 resamples (0.84, against 0.74 for two). | Meeting, 09:52: say why k = 3 on the poster, in the free space of this card. Three lines |
| PA3 | Scatter caption | Axes: first two principal components of the nine features. | Axes: principal components 1 and 2. Dashed: 80% ellipses. | The figure's subtitle now says in plain words what the outlines show; the caption names them for a technical reader. One line, as before |
| PA4 | Answer strip | **Answer:** three markets. k-means and Ward's clustering agree on 60 of 66 districts and the grouping is stable (0.85), but separation is weak (silhouette 0.21): a useful summary of a continuum. | **Answer:** New Zealand has three kinds of building market: house-building, slow provincial and urban medium-density. k-means and Ward's clustering agree on 60 of 66 districts, but the kinds overlap (silhouette 0.21). | Meeting, 38:56 and 40:38: the answer in the question's own words, with a number. The stability figure moves to PA2 as 0.84; `t02_choose_k.csv` gives 0.8446. Two lines, as before |
| PA5 | RQ2 card, data line | 66 districts, nine features (2016–2026): … | 66 districts (Chatham Islands left out), nine features (2016–2026): … | The Data card says 67 districts and this card 66, with no reason given |

## B. Figures that change with the slides sheet

- **Scatter (`c05`):** ten labels, placed so none touches a point or another label; a second subtitle line saying what the dashed outlines show.
- **Background chart (`c01`):** the subtitle now says these are the five dearest and five cheapest districts (meeting, 31:04).
- **Profile chart (`c06`):** the title says "the middle district of each kind" in place of "median district".

## C. One choice for the group: which profile chart

The meeting compared two charts for the right-hand slot and leaned towards the profile chart from Boulton's draft (20:37), then could not explain its axis (21:16). B is that chart redrawn on this poster's data, with the axis in words. A is the poster's own.

| | A: four measures in real units (the poster's own chart) | B: all nine measures against the average district |
|---|---|---|
| File | `c06_rq2_profiles.png` | `c06b_rq2_profiles_all.png` (new, in the figure patch) |
| Shows | 39.1% townhouses and apartments, 7.5 homes per 1,000, −8.3% cost: the numbers behind "cheapest" and "dearest" | Every feature the card lists, on one scale |
| Axis | Each panel has its own unit | "below, average, above": standard deviations from the average district |
| Caption | Four of the nine clustering features. | All nine features: each kind's average, in standard deviations from the average district. |

Boulton's view: A, because the bullets say "cheapest" and "dearest" and only A gives the sizes. B is one line to switch on: swap the image and the caption.

## D. Checked

- The patched poster is one A2 page, and its bottom margin is the same as the 15 Nov poster's (15.5 mm from the last block to the page edge), so nothing is pushed off.
- Every "old" string occurs exactly once in the 15 Nov file, and the patch applies cleanly.
- The preview figures were drawn with ggplot2 3.4.4. Spacing may differ slightly from yours.

## E. Seen on the poster, outside the RQ2 row

1. **Approach, first paragraph:** "Models are trained on earlier years and tested once on the most recent years they never saw" is true of RQ1 and RQ3 only.
2. **RQ3:** the text says "test 2017–2024" and the chart title says 2018–2025.
3. **References:** "Full references in the report" points to something that is not submitted with the poster. The Business price indexes entry has no link; the repo README has one.
4. **Conclusions:** the meeting agreed to rewrite these as full sentences by hand (41:45). Not touched here.
