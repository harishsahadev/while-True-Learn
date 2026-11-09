"""
communication/slides/build_slides.py   (version 2: pitch-deck style)

Builds the final-presentation deck from ONE specification, in two forms:
  * slides.pptx : editable in PowerPoint or Google Slides (File > Import slides)
  * slides.html : the same layout as web pages, printed to slides.pdf with
                  `Rscript communication/render_pdf.R slides`

The look follows the group's pitch deck (extra/whileTrue_learn_Pitch.pptx): its peach wave
background, Open Sauce One font, orange accent circle behind each title, small orange dot with
"while True: learn() · GROUP 8" at top left, presenter at top right, and translucent white
cards with a thin orange border.

Run from the project folder:   python communication/slides/build_slides.py
Needs: pip install python-pptx
The earlier version is kept in communication/earlier_versions/v1_slate_theme/.
"""
from pathlib import Path
import html as htmllib
from PIL import Image
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.oxml.ns import qn

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
FIG = ROOT / "outputs" / "figures" / "communication"
ASSETS = ROOT / "communication" / "assets"
BG = ASSETS / "pitch_background.png"

W, H = 13.333, 7.5            # 16:9, same size as the pitch deck
FONT = "Open Sauce One"       # the pitch deck's font (files in communication/assets/fonts)
# pitch-deck theme colours
C = dict(ink="2B2B2B", muted="5C5148", orange="FBAC4D", dark="C76B0A", border="EDB46E",
         light="FFF3E5", tint="FFF8EF", white="FFFFFF", brown="9A5200")

PRESENTERS = {"andrew": "Andrew Boulton", "harish": "Harish Sahadev M", "niwesh": "Niwesh Baraj"}
TEAM = "while True: learn()   ·   GROUP 8"

ALT = {"c01_cost_by_district_2025.png": "Bar chart: real cost per square metre of new houses in 2025, five dearest and five cheapest districts",
       "c02_inflation.png": "Line chart: new-house value per square metre in nominal and real dollars, 1991 to 2025",
       "c03_rq1_accuracy.png": "Bar chart: average prediction error 2020 to 2026 for two baselines and two models",
       "c04_rq1_drivers.png": "Bar chart: change in cost per square metre from a low to a high value of each factor",
       "c05_rq2_markets.png": "Scatter plot: 66 districts coloured by market, on the first two principal components",
       "c06_rq2_profiles.png": "Bar charts: median district of each market on four features",
       "c07_rq3_together.png": "Bar chart: share of districts building more homes than the year before, by year",
       "c08_rq3_accuracy.png": "Bar chart: share of district-years where next year's direction was called correctly",
       "qr_app.png": "QR code linking to the interactive app at niwesh.shinyapps.io/nz-building-consents"}
APP_URL = "niwesh.shinyapps.io/nz-building-consents"

# ---------------------------------------------------------------- element helpers
def run(text, size=17, bold=False, color="ink", italic=False):
    return dict(text=text, size=size, bold=bold, color=color, italic=italic)

def para(*runs, bullet=False, align="left", after=6):
    return dict(runs=list(runs), bullet=bullet, align=align, after=after)

def text(x, y, w, h, paras, valign="top"):
    return dict(t="text", x=x, y=y, w=w, h=h, paras=paras, valign=valign)

def shape(x, y, w, h, fill, kind="round", alpha=None, line=None):
    """kind: round | rect | ellipse. alpha: 0-1 opacity of the fill. line: border colour (1 pt)."""
    return dict(t="shape", x=x, y=y, w=w, h=h, fill=fill, kind=kind, alpha=alpha, line=line)

def card(x, y, w, h, fill="white"):
    """The pitch deck's card: translucent white, rounded, thin orange border."""
    return shape(x, y, w, h, fill, "round", alpha=0.55 if fill == "white" else None, line="border")

def img(name, x, y, w=None, h=None):
    path = Path(name) if Path(name).is_absolute() else FIG / name
    iw, ih = Image.open(path).size
    ar = ih / iw
    if w is not None and h is not None:
        nw, nh = (h / ar, h) if w * ar > h else (w, w * ar)
        x, y, w, h = x + (w - nw) / 2, y + (h - nh) / 2, nw, nh
    elif w is not None:
        h = w * ar
    else:
        w = h / ar
    return dict(t="img", path=str(path), x=x, y=y, w=w, h=h)

def fig_card(name, x, y, w, h, pad=0.18):
    return [card(x, y, w, h), img(name, x + pad, y + pad, w - 2 * pad, h - 2 * pad)]

def title(t, sub=None):
    els = [shape(0.42, 0.66, 0.78, 0.78, "orange", "ellipse"),           # accent circle behind the title
           text(0.6, 0.72, 12.2, 0.75, [para(run(t, 30, True, "ink"), after=0)], valign="middle")]
    if sub:
        els.append(text(0.6, 1.5, 12.2, 0.42, [para(run(sub, 15, False, "muted"), after=0)]))
    return els

def stat(x, y, w, number, label):
    return [text(x, y, w, 0.85, [para(run(number, 40, True, "dark"), after=0)]),
            text(x, y + 0.85, w, 0.75, [para(run(label, 14, False, "muted"), after=0)])]

def bullets(x, y, w, h, items, size=17):
    return text(x, y, w, h, [para(*(i if isinstance(i, list) else [run(i, size)]), bullet=True, after=10) for i in items])

def text_card(x, y, w, h, heading, body, size=15):
    return [card(x, y, w, h),
            text(x + 0.25, y + 0.2, w - 0.5, h - 0.35, [para(run(heading, size + 3, True, "ink"), after=6),
                                                       para(*(body if isinstance(body, list) else [run(body, size)]))])]

def numbered(x, y, n):
    return [shape(x, y, 0.46, 0.46, "orange", "ellipse"),
            text(x, y, 0.46, 0.46, [para(run(str(n), 15, True, "ink"), align="center", after=0)], valign="middle")]

# ---------------------------------------------------------------- the deck
slides = []

# 0. Title (in the pitch deck's title-slide style)
slides.append(dict(presenter="andrew", topic=None, els=[
    shape(0.5, 0.4, 0.15, 0.15, "orange", "ellipse"),
    text(0.74, 0.34, 4, 0.28, [para(run("GROUP 8", 12, False, "ink"), after=0)]),
    text(8.83, 0.34, 4, 0.28, [para(run("November 2026", 12, False, "ink"), align="right", after=0)]),
    shape(10.95, 1.75, 1.75, 1.75, "orange", "ellipse"),
    text(0.8, 1.55, 9.9, 2.6, [para(run("What New Zealand builds,", 50, True, "ink"), after=0),
                               para(run("where, and at what cost", 50, True, "ink"), after=0)]),
    text(0.8, 4.25, 9.5, 0.9, [para(run("What 36 years of building consents tell us about cost, building markets "
                                        "and what comes next", 19, False, "muted"))]),
    shape(0.8, 6.22, 0.4, 0.4, "orange", "ellipse"),
    shape(1.04, 6.22, 0.4, 0.4, "white", "ellipse", alpha=0.0, line="orange"),
    text(1.62, 6.1, 7, 0.26, [para(run("Presented by", 11, False, "ink"), after=0)]),
    text(1.62, 6.36, 7.6, 0.36, [para(run("Andrew Boulton   ·   Harish Sahadev M   ·   Niwesh Baraj", 15, True, "ink"), after=0)]),
    text(8.33, 6.39, 4.5, 0.32, [para(run("STAT462 Data Mining   ·   Final presentation", 12, False, "ink"), align="right", after=0)])],
    notes="Andrew: Kia ora, we're Group 8, while True: learn(). I'm Andrew, with Harish and Niwesh. In ten minutes we'll "
          "show what thirty-six years of building consents tell us about the cost of building, our kinds of building market, "
          "and whether we can see next year coming."))

# 1. Why consents
slides.append(dict(presenter="andrew", topic="Background", els=
    title("Why look at building consents?", "Every new building starts with a council permit, recorded by Stats NZ since 1990")
    + [card(0.5, 2.15, 4.75, 4.65),
       bullets(0.8, 2.4, 4.2, 4.2, [
           [run("A consent comes ", 17), run("before", 17, True), run(" anything is built: an early signal of what is coming", 17)],
           [run("Each records ", 17), run("how many", 17, True), run(" homes, their ", 17), run("value", 17, True), run(" and ", 17), run("floor area", 17, True)],
           [run("Cost per square metre varies a lot between districts, and nobody fully knows why", 17)]])]
    + fig_card("c01_cost_by_district_2025.png", 5.5, 2.15, 7.35, 4.65),
    notes="Andrew: Before anything is built, a council issues a building consent, and Stats NZ has recorded every one, by "
          "district, every month since 1990. So consents are an early signal. In 2025 a square metre of new house cost about "
          "4,600 dollars in Queenstown but about 2,700 in Selwyn. That gap is where our story starts."))

# 2. Data preparation
steps = [("10.4 million rows", "13 Stats NZ tables: one row per district, building type and month"),
         ("One row per district", "Months added up into quarters and years, for 67 districts"),
         ("Fair dollars", "Inflation and the 2010 GST change removed, so 1995 and 2025 compare")]
els = title("From 10 million rows to a fair comparison", "Most of the work was making the numbers comparable")
for i, (h, b) in enumerate(steps):
    y = 2.15 + i * 1.57
    els += [card(0.5, y, 5.3, 1.4)] + numbered(0.72, y + 0.22, i + 1) + \
           [text(1.38, y + 0.17, 4.25, 1.15, [para(run(h, 18, True, "ink"), after=3), para(run(b, 14, False, "muted"))])]
els += fig_card("c02_inflation.png", 6.05, 2.15, 6.8, 4.65)
slides.append(dict(presenter="andrew", topic="Data", els=els,
    notes="Andrew: The raw data is over ten million rows in thirteen tables; we turned it into one row per district per "
          "quarter or year. The key step was removing inflation. The grey line, in the dollars of each year, rises almost "
          "five-fold; after removing building-cost inflation the real rise is only about twenty percent. Harish will now "
          "explain our questions."))

# 3. Three questions
qs = [("What makes some districts dearer to build in?", "RQ1 · prediction models, from simple averages to tree ensembles"),
      ("What kinds of building markets does New Zealand have?", "RQ2 · grouping similar districts (clustering)"),
      ("Will a district build more or less next year?", "RQ3 · yes-or-no prediction (classification)")]
els = title("Three questions, three kinds of method")
for i, (q, m) in enumerate(qs):
    y = 1.75 + i * 1.18
    els += [card(0.5, y, 12.35, 1.04)] + numbered(0.75, y + 0.29, i + 1) + \
           [text(1.45, y + 0.12, 11.2, 0.85, [para(run(q, 19, True, "ink"), after=2), para(run(m, 14, False, "muted"), after=0)])]
els += [shape(0.5, 5.4, 12.35, 1.35, "tint", "round", line="border"),
        text(0.8, 5.5, 11.8, 1.15, [para(run("Keeping it honest:  ", 17, True, "dark"),
                                         run("every model learns from the past and is tested once on recent years it never saw. "
                                             "When two models were about as good, we kept the simpler one.", 17))], valign="middle")]
slides.append(dict(presenter="harish", topic="Our questions", els=els,
    notes="Harish: We asked three questions, each needing a different kind of method. One: what makes some districts dearer "
          "to build in? Two: what kinds of building markets does New Zealand have? Three: will a district build more or less "
          "next year? One rule throughout: learn from the past, then test once on recent years the model never saw, and keep "
          "the simpler model when two are about as good."))

# 4. RQ1 measuring fairly
els = title("Comparing like with like", "Cost moves with the whole country, so we compare each district with the rest of New Zealand")
els += [card(0.5, 2.15, 3.85, 2.05), card(4.55, 2.15, 3.85, 2.05)]
els += stat(0.8, 2.3, 3.4, "41%", "of the differences in cost are simply which year it is")
els += stat(4.85, 2.3, 3.4, "19%", "are which district it is")
els += text_card(8.6, 2.15, 4.25, 2.05, "So we asked a fairer question",
                 [run("How much dearer or cheaper is this district than the rest of New Zealand ", 15),
                  run("in the same quarter", 15, True), run("?", 15)])
els += [card(0.5, 4.45, 12.35, 2.35),
        text(0.8, 4.62, 11.8, 2.05, [
            para(run("What went into the models", 18, True, "ink"), after=6),
            para(run("Nine measurable factors per district and quarter: ", 16),
                 run("renovation spending, new homes per resident, number of houses, house size, apartment and townhouse "
                     "share, commercial building, growth", 16, False, "muted"), after=6),
            para(run("Eleven models compared, from \"guess each district's past average\" to random forests and boosted "
                     "trees; trained on 1996–2019, tested on 2020–2026", 16))])]
slides.append(dict(presenter="harish", topic="RQ1 · Cost per square metre", els=els,
    notes="Harish: Our first question is about cost. Forty-one percent of the differences in cost are just which year it is, "
          "because the whole country gets dearer together; only nineteen percent is which district. So we asked a fairer "
          "question: how much dearer or cheaper is a district than the rest of New Zealand at the same time? We built nine "
          "measurable factors and compared eleven models, trained up to 2019 and tested on 2020 to 2026."))

# 5. RQ1 drivers
els = title("What makes a district dearer to build in?")
els += fig_card("c04_rq1_drivers.png", 0.5, 1.75, 7.5, 5.05)
els += [card(8.2, 1.75, 4.65, 5.05),
        bullets(8.45, 1.97, 4.2, 4.7, [
            [run("Renovation spending", 16, True), run(" is the strongest sign: wealthy, busy markets build dearer houses", 16)],
            [run("Fast-growing places", 16, True), run(" cost more, especially where renovation is also high", 16)],
            [run("Volume builders", 16, True), run(" make high-building districts cheaper, but any district gets dearer in its busy years", 16)],
            [run("Location still matters most: ", 16, True), run("these factors explain about a fifth of the gap; Queenstown is still about 15% dearer", 16)]], size=16)]
slides.append(dict(presenter="harish", topic="RQ1 · Cost per square metre", els=els,
    notes="Harish: The strongest sign of a dear district is renovation spending: places where people renovate a lot are "
          "wealthy, busy markets, and new houses there cost about nine percent more. Fast growth adds cost too. Building lots "
          "of houses makes a district cheaper, thanks to volume builders, but any one district gets dearer in its own busy "
          "years. Still, location matters most: these factors explain only about a fifth of the gap, and Queenstown is still "
          "about fifteen percent dearer after them."))

# 6. RQ1 accuracy
els = title("How well can we predict cost?", "Average error on 2020–2026, years the models never saw")
els += fig_card("c03_rq1_accuracy.png", 0.5, 2.15, 7.7, 4.65)
els += [card(8.4, 2.15, 4.45, 1.95)]
els += stat(8.7, 2.27, 4.0, "7.9%", "average error of our best model (ridge regression with the district)")
els += text_card(8.4, 4.3, 4.45, 2.5, "Simple beat fancy",
                 "A straight-line model matched boosted trees and support vector machines. But knowing each district's own "
                 "history already gets you to 8.0%.")
slides.append(dict(presenter="harish", topic="RQ1 · Cost per square metre", els=els,
    notes="Harish: Guessing the national average is off by about ten percent. Our best model, a ridge regression that knows "
          "the district, is off by 7.9 percent on years it never saw. Two lessons: simple beat fancy, and each district's own "
          "history already gets you to eight percent, so place is most of the story. Andrew will now show the markets we "
          "found."))

# 7. RQ2 markets
els = title("Three kinds of building market", "Grouping 66 districts by how they build, 2016–2026")
els += fig_card("c05_rq2_markets.png", 0.5, 2.15, 7.4, 4.65)
mk = [("House-building districts  (30)", "Commuter belts, lifestyle and retirement areas: Selwyn, Waipa, Tasman", "muted"),
      ("Slow provincial districts  (21)", "Little and up-and-down building, cheapest: Gore, Wairoa, Grey", "dark"),
      ("Urban medium-density  (15)", "Cities and Queenstown, many townhouses, dearest", "orange")]
for i, (h, b, col) in enumerate(mk):
    y = 2.15 + i * 1.6
    els += [card(8.1, y, 4.75, 1.45), shape(8.32, y + 0.25, 0.3, 0.3, col, "ellipse"),
            text(8.78, y + 0.15, 3.9, 1.2, [para(run(h, 16, True, "ink"), after=4), para(run(b, 13.5, False, "muted"))])]
slides.append(dict(presenter="andrew", topic="RQ2 · Building markets", els=els,
    notes="Andrew: Our second question: what kinds of building markets does New Zealand have? We described 66 districts by "
          "nine things, such as what homes they build, how fast and at what cost, and two clustering methods grouped similar "
          "districts. House-building districts like Selwyn build lots of big stand-alone houses; slow provincial districts "
          "like Gore build little and unevenly and are cheapest; urban markets, the cities and Queenstown, build townhouses "
          "and are dearest."))

# 8. RQ2 profiles
els = title("How the markets differ, and how sure we are")
els += fig_card("c06_rq2_profiles.png", 0.5, 1.75, 8.3, 5.05)
els += [card(9.0, 1.75, 3.85, 2.0)]
els += stat(9.25, 1.87, 3.5, "60 of 66", "districts placed the same by two different grouping methods")
els += text_card(9.0, 3.95, 3.85, 2.85, "But the edges are soft",
                 "Districts form a smooth range rather than separate boxes; some places (Palmerston North, Tauranga) sit "
                 "between two markets.", size=14)
slides.append(dict(presenter="andrew", topic="RQ2 · Building markets", els=els,
    notes="Andrew: Urban markets build mostly townhouses and cost about five percent more; house-building districts build the "
          "most homes per resident; provincial districts have the most commercial building and are about eight percent "
          "cheaper. Two different methods agreed on 60 of 66 districts, but the edges are soft. Niwesh will now look ahead "
          "to next year."))

# 9. RQ3 together
els = title("Districts rise and fall together", "Share of districts building more homes than the year before")
els += fig_card("c07_rq3_together.png", 0.5, 2.15, 8.1, 4.65)
els += [card(8.8, 2.15, 4.05, 1.95)]
els += stat(9.05, 2.27, 3.7, "12% → 88%", "of districts rose, depending on the year")
els += text_card(8.8, 4.3, 4.05, 2.5, "The national cycle rules",
                 "When New Zealand builds more, most districts do. Predicting one district means first predicting the "
                 "whole country.")
slides.append(dict(presenter="niwesh", topic="RQ3 · Next year", els=els,
    notes="Niwesh: Our third question: will a district build more or less next year? Each bar is a year, showing the share of "
          "districts that built more than the year before. It swings from twelve to eighty-eight percent: districts rise and "
          "fall together with the national cycle. So predicting one district really means first predicting the whole country. "
          "That is the key to understanding our result."))

# 10. RQ3 accuracy
els = title("Can we see next year coming?", "Calling up or down for 66 districts, 2018–2025")
els += fig_card("c08_rq3_accuracy.png", 0.5, 2.15, 7.5, 4.65)
els += [card(8.2, 2.15, 4.65, 4.65),
        bullets(8.45, 2.35, 4.2, 4.35, [
            [run("Right ", 16), run("58%", 16, True), run(" of the time: a coin toss gets 50%, the best simple rule 53%", 16)],
            [run("Helps: ", 16, True), run("the country building above its recent average and finishing the year strongly", 16)],
            [run("Warning signs: ", 16, True), run("a district already building unusually hard, or relying on big apartment projects", 16)],
            [run("Fancier models did no better: the turning points depend on interest rates and migration, which this data lacks", 16)]], size=16)]
slides.append(dict(presenter="niwesh", topic="RQ3 · Next year", els=els,
    notes="Niwesh: Our best model, a logistic regression, was right fifty-eight percent of the time, against fifty for a coin "
          "toss and fifty-three for the best simple rule. It helps when the whole country is building above its recent "
          "average and finished the year strongly. Warning signs are a district already building unusually hard, or relying "
          "on big apartment projects. Fancier models did no better, because the turning points depend on interest rates and "
          "migration, which aren't in consent data. That's why we report fifty-eight percent honestly rather than tuning "
          "until it looks better."))

# 11. Conclusion
take = [("Place matters most", "Our measured factors explain about a fifth of why some districts cost more to build in."),
        ("Three soft-edged markets", "House-building, slow provincial and urban medium-density."),
        ("The national cycle rules", "Next year's direction is only a little better than a coin toss.")]
els = title("What we learned")
for i, (h, b) in enumerate(take):
    x = 0.5 + i * 4.18
    els += [card(x, 1.75, 3.95, 2.75)] + numbered(x + 0.25, 1.98, i + 1) + \
           [text(x + 0.25, 2.6, 3.45, 1.8, [para(run(h, 19, True, "ink"), after=6), para(run(b, 15, False, "muted"))])]
els += text_card(0.5, 4.75, 7.6, 2.05, "Limits and next steps",
                 "Consent values are estimates and exclude land. Adding land prices, interest rates and migration is the most "
                 "promising next step.")
els += [shape(8.3, 4.75, 4.55, 2.05, "orange", "round"),
        text(8.5, 4.9, 2.75, 1.8, [para(run("Try it yourself", 18, True, "ink"), after=4),
                                   para(run("Pick a district and ask \"what if\"", 13, False, "ink"), after=6),
                                   para(run("niwesh.shinyapps.io/", 11, True, "ink"), after=0),
                                   para(run("nz-building-consents", 11, True, "ink"), after=0)]),
        shape(11.3, 4.92, 1.38, 1.38, "white", "round"),
        img(str(ASSETS / "qr_app.png"), 11.36, 4.98, 1.26, 1.26)]
slides.append(dict(presenter="niwesh", topic="Conclusion", els=els,
    notes="Niwesh: To sum up: place matters most, New Zealand has three soft-edged building markets, and the national cycle "
          "rules next year's direction. Consent values are estimates that leave out land, and the big economic drivers aren't "
          "in the data. Finally, a quick look at our app, which is live online. [Demo, about 35 seconds, at niwesh.shinyapps.io/nz-building-consents: open the RQ1 tab, pick Selwyn, drag "
          "renovation spending up and show the predicted cost rise; switch to the RQ3 tab to show 2026 probabilities.] "
          "Thank you, we're happy to take questions."))

# 12. Appendix
rows = [["", "RQ1 Cost per square metre", "RQ2 Markets", "RQ3 Next year"],
        ["Unit", "District × quarter (5,694 train)", "District (66)", "District × year (1,914)"],
        ["Methods", "Baselines, linear, polynomial, ridge, lasso, elastic net, GAM, regression tree, random forest, XGBoost, SVM",
         "k-means; hierarchical (single, complete, average, Ward)", "Logistic, lasso, LDA, QDA, classification tree, KNN, random forest"],
        ["Validation", "Forward-chaining CV; test 2020–26", "Silhouette, CH, gap, bootstrap stability", "Forward-chaining CV (AUC); test 2017–24"],
        ["Result", "Ridge: MAPE 7.9%, R-squared 0.36", "k = 3; ARI 0.75 between methods", "Logistic: 58% accuracy, AUC 0.63"]]
els = title("Appendix: methods and references")
cw = [1.6, 3.95, 3.35, 3.45]; y0 = 1.75
els.append(card(0.5, y0 - 0.1, 12.35, 3.75))
for r, row in enumerate(rows):
    x = 0.6; rh = 0.45 if r == 0 else (0.95 if r == 2 else 0.6)
    for c, cell in enumerate(row):
        if r == 0:
            els.append(shape(x, y0, cw[c] - 0.05, rh - 0.05, "orange", "rect"))
        els.append(text(x + 0.1, y0 + 0.03, cw[c] - 0.25, rh - 0.1, [para(run(cell, 11.5, r == 0 or c == 0, "ink"), after=0)], valign="middle"))
        x += cw[c]
    y0 += rh
els.append(text(0.6, 5.55, 12.2, 1.4, [
    para(run("References", 12, True, "ink"), after=3),
    para(run("Stats NZ. (2026). Building consents issued: August 2026 [Data set]. CC BY 4.0. "
             "https://www.stats.govt.nz/information-releases/building-consents-issued-august-2026", 10.5, False, "muted"), after=2),
    para(run("James, G., Witten, D., Hastie, T., & Tibshirani, R. (2021). An introduction to statistical learning (2nd ed.). Springer.", 10.5, False, "muted"), after=2),
    para(run(f"Interactive app: https://{APP_URL}/", 10.5, True, "ink"), after=2),
    para(run("AI use: Claude (Anthropic) helped write and debug R code and edit text; all analysis choices and results were reviewed by the group.",
             10.5, False, "muted"), after=0)]))
slides.append(dict(presenter="niwesh", topic="Appendix", els=els, notes="Appendix for questions: methods, validation and results in technical terms."))

# ---------------------------------------------------------------- header (as in the pitch) and page number
for i, s in enumerate(slides):
    if i == 0:
        continue
    s["els"] = [shape(0.5, 0.35, 0.15, 0.15, "orange", "ellipse"),
                text(0.74, 0.3, 5.5, 0.28, [para(run(TEAM, 11, False, "ink"), after=0)]),
                text(5.8, 0.3, 7.05, 0.28, [para(run(f"{s['topic']}   |   Presenter: {PRESENTERS[s['presenter']]}", 11, False, "ink"),
                                                 align="right", after=0)])] + s["els"] + \
              [text(11.85, 7.03, 1.0, 0.25, [para(run(str(i), 10, False, "muted"), align="right", after=0)])]

# ---------------------------------------------------------------- PPTX renderer
def rgb(name): return RGBColor.from_string(C.get(name, name))

def add_bullet(p):
    pPr = p._p.get_or_add_pPr()
    pPr.set("marL", str(Inches(0.28))); pPr.set("indent", str(-Inches(0.28)))
    bu = pPr.makeelement(qn("a:buChar"), {"char": "•"}); pPr.append(bu)

def set_alpha(shp, alpha):
    srgb = shp.fill._xPr.find(qn("a:solidFill")).find(qn("a:srgbClr"))
    a = srgb.makeelement(qn("a:alpha"), {"val": str(int(alpha * 100000))}); srgb.append(a)

def build_pptx(path):
    prs = Presentation()
    prs.slide_width, prs.slide_height = Inches(W), Inches(H)
    for s in slides:
        sl = prs.slides.add_slide(prs.slide_layouts[6])
        bg = sl.shapes.add_picture(str(BG), 0, 0, Inches(W), Inches(H))
        bg._element.nvPicPr.cNvPr.set("descr", "Decorative background")
        for e in s["els"]:
            x, y, w, h = (Inches(e[k]) for k in ("x", "y", "w", "h"))
            if e["t"] == "shape":
                kind = {"round": MSO_SHAPE.ROUNDED_RECTANGLE, "rect": MSO_SHAPE.RECTANGLE, "ellipse": MSO_SHAPE.OVAL}[e["kind"]]
                shp = sl.shapes.add_shape(kind, x, y, w, h)
                if e["kind"] == "round": shp.adjustments[0] = 0.08
                shp.shadow.inherit = False
                shp.fill.solid(); shp.fill.fore_color.rgb = rgb(e["fill"])
                if e["alpha"] is not None: set_alpha(shp, e["alpha"])
                if e["line"]:
                    shp.line.color.rgb = rgb(e["line"]); shp.line.width = Pt(1)
                else:
                    shp.line.fill.background()
            elif e["t"] == "img":
                pic = sl.shapes.add_picture(e["path"], x, y, w, h)
                pic._element.nvPicPr.cNvPr.set("descr", ALT.get(Path(e["path"]).name, ""))
            else:
                tb = sl.shapes.add_textbox(x, y, w, h); tf = tb.text_frame; tf.word_wrap = True
                tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
                tf.vertical_anchor = MSO_ANCHOR.MIDDLE if e["valign"] == "middle" else MSO_ANCHOR.TOP
                for i, pd in enumerate(e["paras"]):
                    p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
                    p.alignment = {"left": PP_ALIGN.LEFT, "center": PP_ALIGN.CENTER, "right": PP_ALIGN.RIGHT}[pd["align"]]
                    p.space_after = Pt(pd["after"]); p.line_spacing = 1.12
                    if pd["bullet"]: add_bullet(p)
                    for r in pd["runs"]:
                        rr = p.add_run(); rr.text = r["text"]; f = rr.font
                        f.name = FONT; f.size = Pt(r["size"]); f.bold = r["bold"]; f.italic = r["italic"]; f.color.rgb = rgb(r["color"])
        if s.get("notes"):
            sl.notes_slide.notes_text_frame.text = s["notes"]
    prs.save(path)

# ---------------------------------------------------------------- HTML renderer (for the PDF)
def build_html(path):
    fonts = "".join(
        f"@font-face {{ font-family: '{FONT}'; src: url('{(ASSETS / 'fonts' / f'OpenSauceOne-{w}.ttf').as_uri()}'); "
        f"font-weight: {wt}; font-style: {st}; }}\n"
        for w, wt, st in [("Regular", 400, "normal"), ("Italic", 400, "italic"), ("Bold", 700, "normal"), ("ExtraBold", 800, "normal")])
    css = f"""{fonts}
    @page {{ size: {W}in {H}in; margin: 0; }}
    body {{ margin: 0; font-family: '{FONT}', Arial, sans-serif; }}
    .slide {{ position: relative; width: {W}in; height: {H}in; overflow: hidden; page-break-after: always;
              background: url('{BG.as_uri()}') center / cover no-repeat; }}
    .el {{ position: absolute; box-sizing: border-box; }}
    .tx {{ display: flex; flex-direction: column; }}
    .tx p {{ margin: 0; line-height: 1.12; }}
    .tx p.b {{ padding-left: 0.28in; text-indent: -0.28in; }}
    .tx p.b::before {{ content: "•"; display: inline-block; width: 0.28in; text-indent: 0; }}
    img.el {{ display: block; }}"""
    out = [f"<!doctype html><html><head><meta charset='utf-8'><title>Final presentation slides</title><style>{css}</style></head><body>"]
    for s in slides:
        out.append("<div class='slide'>")
        for e in s["els"]:
            pos = f"left:{e['x']}in;top:{e['y']}in;width:{e['w']}in;height:{e['h']}in;"
            if e["t"] == "shape":
                rad = {"round": "0.1in", "rect": "0", "ellipse": "50%"}[e["kind"]]
                r, g, b = (int(C[e["fill"]][i:i + 2], 16) for i in (0, 2, 4))
                a = 1 if e["alpha"] is None else e["alpha"]
                border = f"border:1pt solid #{C[e['line']]};" if e["line"] else ""
                out.append(f"<div class='el' style='{pos}background:rgba({r},{g},{b},{a});border-radius:{rad};{border}'></div>")
            elif e["t"] == "img":
                alt = htmllib.escape(ALT.get(Path(e["path"]).name, ""), quote=True)
                out.append(f"<img class='el' style='{pos}' src='{Path(e['path']).as_uri()}' alt='{alt}'>")
            else:
                jc = "center" if e["valign"] == "middle" else "flex-start"
                ps = []
                for pd in e["paras"]:
                    runs = "".join(
                        f"<span style='font-size:{r['size']}pt;font-weight:{'bold' if r['bold'] else 'normal'};"
                        f"font-style:{'italic' if r['italic'] else 'normal'};color:#{C.get(r['color'], r['color'])}'>"
                        f"{htmllib.escape(r['text'])}</span>" for r in pd["runs"])
                    size = pd["runs"][0]["size"]; col = C.get(pd["runs"][0]["color"], pd["runs"][0]["color"])
                    cls = " class='b'" if pd["bullet"] else ""
                    ps.append(f"<p{cls} style='text-align:{pd['align']};margin-bottom:{pd['after']}pt;font-size:{size}pt;color:#{col}'>{runs}</p>")
                out.append(f"<div class='el tx' style='{pos}justify-content:{jc}'>{''.join(ps)}</div>")
        out.append("</div>")
    out.append("</body></html>")
    Path(path).write_text("\n".join(out), encoding="utf-8")

if __name__ == "__main__":
    build_pptx(OUT / "slides.pptx")
    build_html(OUT / "slides.html")
    print(f"{len(slides)} slides written to {OUT}")
