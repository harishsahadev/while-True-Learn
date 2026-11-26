# Q&A sheet for RQ2 (option A): ten questions, one page

_PRD step 5, 18 Nov 2026. These answer for Niwesh's build, the one on the slides and the poster: 66 districts, nine measures, k-means with three groups. Every number is in `Claude outputs/q2_slides_A/check_table.md`. Each answer is 60 words or fewer. Say them aloud once; anything you cannot say without the page goes back to Niwesh's notebook, `analysis/rq2_clustering/02_rq2_clustering.Rmd`._

**1. Why three groups and not two?**
Fit is about the same at two and three: 0.22 and 0.21, on a scale from −1 to 1. Three was the most repeatable: over 100 re-drawn samples the grouping came back most alike at three (0.84, against 0.74 at two). From five groups up, the smallest group has four districts or fewer.

**2. What does a fit of 0.21 mean?**
The silhouette runs from −1 to 1. Near 1 means tight, separate groups; near 0 means they overlap. 0.21 is weak, so we call these three kinds along a range, with soft edges. By kind it is 0.28 for house-building, 0.18 for slow provincial and 0.09 for urban, where four of the fifteen districts are below zero.

**3. What is k-means doing?**
It places three centres, puts each district with its nearest centre, moves each centre to the average of its districts, and repeats until no district moves. The start is random and it can stop at a poor answer, so the notebook runs 50 starts with a fixed seed and keeps the best.

**4. How did you measure "alike"?**
Straight-line (Euclidean) distance across the nine measures, after putting them on one scale. Without that, house size in square metres would swamp shares that run from 0 to 1. Skewed measures were square-rooted or logged first, so a few extreme districts do not decide the groups.

**5. What is the second method, and why Ward's linkage?**
Hierarchical clustering: every district starts alone and the two closest groups keep joining. With single or average linkage it chains: one giant group and a few strays (64/1/1 and 62/2/2). Ward's linkage joins the pair that adds the least spread, the same aim as k-means, and gives 34, 20 and 12.

**6. Which districts do the two methods place differently?**
Six: Gisborne, Invercargill, Lower Hutt, Palmerston North, South Taranaki and Whanganui. They sit on the border between two kinds. Agreement corrected for chance, the adjusted Rand index, is 0.75, where 1 is identical.

**7. What are the axes on the scatter?**
A two-dimensional summary of the nine measures, called principal components, used only to draw the picture. Together the two axes show about half the variation (52%). The grouping itself uses all nine measures. The dashed outlines are 80% ellipses: where most of each kind sit.

**8. Cost is one of the nine measures. Isn't "urban is dearest" circular?**
For that label, yes: cost helped form the kinds, so "dearest" describes the urban kind and does not test it. But the kinds do not depend on cost. Leaving it out gives almost the same grouping (agreement 0.96, where 1 is identical). The commercial share matters most: 0.55 without it.

**9. Why 66 districts, and why these ten years?**
Sixty-seven districts report consents. The Chatham Islands consented 34 new homes in ten years, too few for shares and growth rates to mean anything, so it is left out. The window is the latest ten years, mid-2016 to mid-2026: long enough to smooth small districts, recent enough to describe today's markets.

**10. There is no test set. How do you know it isn't noise?**
A grouping has no right answer to test against, so we checked it three ways. It came back much the same on 100 re-drawn samples (0.84). A second method agreed on 60 of 66 districts. Leaving out any one of six of the nine measures changes little. And we say plainly that the fit is weak.

## Three things to have ready

- **Ward's linkage is not one of Module 7's three** (complete, single, group average). The notebook ran those too; the appendix page gives their sizes.
- **Tauranga, the slide's second example, is not one of the six in question 6.** It is on the slide for its fit: −0.05, the second lowest, after Palmerston North (−0.08).
- **Why is the commercial share highest in slow provincial districts (39%)?** It is a share of building value. Where few homes are built, other building is a larger part of the total. That reading is mine, not the notebook's; say "probably".
