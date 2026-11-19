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
         light="FDE3C0", tint="FFF8EF", white="FFFFFF", brown="9A5200")

PRESENTERS = {"andrew": "Andrew Boulton", "harish": "Harish Sahadev M", "niwesh": "Niwesh Baraj"}
TEAM = "while True: learn()   ·   GROUP 8"

ALT = {"c01_district_relative_cost.png": "Bar chart: five dearest and five cheapest districts, cost per square metre compared with the rest of New Zealand, 1990 to 2019",
       "c09_rq1_why_relative.png": "Two density charts: real cost per square metre rose after 2020, while cost relative to the rest of New Zealand barely moved",
       "c10_rq2_choose_k.png": "Line charts: silhouette and stability for 2 to 8 clusters, with 3 clusters highlighted",
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
def run(text, size=17, bold=False, color="ink", italic=False, link=None):
    return dict(text=text, size=size, bold=bold, color=color, italic=italic, link=link)

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

# Numbers on these slides come from outputs/tables (rq1/t05, t08, t09, t12; rq2/t02, t04; rq3/t04, t05) and
# outputs/tables/communication (written by communication/make_figures.R).

def result(x, y, w, h, label, body, size=14.5):
    """The answer to a research question: tinted box with a bold orange label."""
    return [shape(x, y, w, h, "tint", "round", line="border"),
            text(x + 0.22, y + 0.08, w - 0.44, h - 0.16, [para(run(label + "  ", size, True, "dark"), run(body, size), after=0)],
                 valign="middle")]

def fig_head(name, x, y, w, h, heading, pad=0.18, size=13):
    """Chart card with a short bold heading above the picture (for charts whose title is not in the image)."""
    return [card(x, y, w, h), text(x + pad, y + 0.12, w - 2 * pad, 0.3, [para(run(heading, size, True, "ink"), after=0)]),
            img(name, x + pad, y + 0.48, w - 2 * pad, h - 0.48 - pad)]

def table(x, y, colw, rows, rowh=0.3, size=10.5, bold_rows=(), first_col_left=True):
    """Simple table from shapes and text boxes: orange header row, thin rules, chosen rows tinted."""
    els = []
    for r, row in enumerate(rows):
        cx = x
        if r in bold_rows:
            els.append(shape(x, y, sum(colw), rowh, "light", "rect"))
        for c, cell in enumerate(row):
            if r == 0:
                els.append(shape(cx, y, colw[c] - 0.03, rowh, "orange", "rect"))
            align = "left" if (c == 0 and first_col_left) else "right"
            els.append(text(cx + 0.06, y, colw[c] - 0.14, rowh, [para(run(cell, size, r == 0 or r in bold_rows, "ink"),
                                                                    align=align, after=0)], valign="middle"))
            cx += colw[c]
        y += rowh
    return els

# 1. Why consents
slides.append(dict(presenter="andrew", topic="Background", els=
    title("Why look at building consents?", "Every new building starts with a council permit, recorded by Stats NZ since 1990")
    + [card(0.5, 2.15, 4.75, 4.65),
       bullets(0.8, 2.4, 4.2, 4.2, [
           [run("A consent comes ", 16), run("before", 16, True), run(" anything is built: an early signal of what is coming", 16)],
           [run("Each records ", 16), run("how many", 16, True), run(" homes, their ", 16), run("value", 16, True), run(" and ", 16), run("floor area", 16, True)],
           [run("Over 1990–2019, Queenstown-Lakes was typically ", 16), run("16% dearer", 16, True),
            run(" per square metre than the rest of NZ, and Opotiki ", 16), run("18% cheaper", 16, True), run(". Why?", 16)]], size=16)]
    + fig_head("c01_district_relative_cost.png", 5.5, 2.15, 7.35, 4.65,
               "Some districts cost far more to build in than others (medians, 1990–2019)"),
    notes="Andrew: Before anything is built, a council issues a building consent, and Stats NZ has recorded every one, by "
          "district, every month since 1990. So consents are an early signal. The chart compares each district with the rest "
          "of New Zealand in the same quarter. Queenstown-Lakes was typically sixteen percent dearer per square metre, about "
          "3,100 dollars in today's money, while Opotiki was eighteen percent cheaper. That gap is where our story starts."))

# 2. Data: files, how combined, which dataset feeds which question
cols = [("1 · Files we used", [
            "Building consents by district: monthly, April 1990 to June 2026 (Stats NZ)",
            "New homes per 1,000 residents by district: yearly",
            "Consents by region: quarterly, used as a check",
            "Capital Goods Price Index (Stats NZ business price indexes, June 2026)",
            "SA2 dwelling files: explored, not used (no value or floor area)"]),
        ("2 · How we combined them", [
            "Joined on district and date; 10.4 million rows added up to 9,715 district-quarters (67 districts)",
            "2010 GST change removed; costs adjusted for building-cost inflation to June-2026 dollars",
            "Quarters with fewer than 5 new houses left out; nothing built from house value"]),
        ("3 · One dataset per question", [
            "RQ1 cost: district × quarter, 1996–2026 (7,305 rows)",
            "RQ2 markets: one profile per district, 2016–2026 (66 districts)",
            "RQ3 next year: district × year, 1996–2024 (1,914 rows)"])]
els = title("From 10 million rows to three datasets", "What we used, how we combined it, and which question each dataset answers")
xs = [0.5, 4.7, 8.9]; ws = [3.95, 3.95, 3.95]
for (h, items), x, w in zip(cols, xs, ws):
    els += [card(x, 2.15, w, 3.65), text(x + 0.22, 2.3, w - 0.44, 0.4, [para(run(h, 16, True, "dark"), after=0)]),
            bullets(x + 0.22, 2.78, w - 0.44, 2.95, items, size=13)]
for x in (4.47, 8.67):
    els.append(text(x, 3.75, 0.25, 0.4, [para(run("›", 22, True, "dark"), align="center", after=0)], valign="middle"))
els += [shape(0.5, 5.98, 12.35, 0.82, "tint", "round", line="border"),
        text(0.75, 6.03, 11.85, 0.72, [para(run("Keeping it honest:  ", 15, True, "dark"),
                                            run("every model learns from earlier years and is tested once on later years it never saw. "
                                                "When two models were about as good, we kept the simpler one.", 15))], valign="middle")]
slides.append(dict(presenter="harish", topic="Data", els=els,
    notes="Harish: We used the Stats NZ building consents by district, every month since 1990, plus new homes per thousand "
          "residents. We added up over ten million rows into one row per district per quarter, removed the 2010 GST change and "
          "building-cost inflation, so all costs are in June-2026 dollars. From that we built three datasets, one per question: "
          "district by quarter for cost, one profile per district for the kinds of market, and district by year for next year's "
          "direction. Every model learns from the past and is tested once on later years it never saw."))

# 3. RQ1: why relative cost
els = title("Comparing like with like", "RQ1 · What drives the real cost per square metre of new houses across districts?")
els += fig_card("c09_rq1_why_relative.png", 0.5, 2.15, 7.9, 4.65)
els += [card(8.6, 2.15, 4.25, 4.65)]
els += [text(8.85, 2.3, 3.85, 0.7, [para(run("41%", 34, True, "dark"), after=0)]),
        text(8.85, 2.98, 3.85, 0.62, [para(run("of the ups and downs in real cost is just which quarter it is", 12.5, False, "muted"), after=0)]),
        text(8.85, 3.6, 3.85, 0.7, [para(run("19%", 34, True, "dark"), after=0)]),
        text(8.85, 4.28, 3.85, 0.4, [para(run("is which district it is", 12.5, False, "muted"), after=0)]),
        text(8.85, 4.75, 3.85, 1.95, [para(run("So we compare each district with the rest of NZ ", 13.5),
                                           run("in the same quarter", 13.5, True),
                                           run(". After 2020 real costs jumped, but this relative cost barely moved, so "
                                               "patterns learnt before 2020 still apply.", 13.5), after=0)])]
slides.append(dict(presenter="harish", topic="RQ1 · Cost per square metre", els=els,
    notes="Harish: Our first question is about cost. Forty-one percent of the ups and downs in real cost is simply which quarter "
          "it is, because the whole country gets dearer together; only nineteen percent is which district. The chart shows "
          "why that matters: after 2020 real costs jumped, the typical district-quarter going from about 2,700 to 3,200 dollars "
          "per square metre, but compared with the rest of New Zealand almost nothing moved. So we asked a fairer question: how "
          "much dearer or cheaper is a district than the rest of the country at the same time?"))

# 4. RQ1 drivers
els = title("What makes a district dearer to build in?")
els += fig_card("c04_rq1_drivers.png", 0.5, 1.75, 7.5, 4.0)
els += [text(0.6, 5.85, 7.3, 0.95, [para(run("Each bar: how much a district's predicted cost changes, compared with the rest of NZ, when one "
                                             "factor goes from a low to a high value (10th to 90th percentile) and the rest stay the same. "
                                             "Renovation spending going from $1.4M to $14.1M a quarter adds about 10%.", 11.5, False, "muted"), after=0)])]
els += [card(8.2, 1.75, 4.65, 5.05),
        bullets(8.45, 1.95, 4.2, 4.75, [
            [run("What went in: ", 15, True), run("renovation spending, homes per resident, number and size of houses, change on "
                                                   "last year, home types, commercial work, region", 15)],
            [run("Left out: ", 15, True), run("anything built from house value (it would give the answer away) and last quarter's cost", 15)],
            [run("Renovation spending", 15, True), run(" is the strongest sign: wealthy, busy markets build dearer houses", 15)],
            [run("Volume builders", 15, True), run(" make high-building districts cheaper, but any district gets dearer in its own busy years", 15)]],
            size=15)]
slides.append(dict(presenter="harish", topic="RQ1 · Cost per square metre", els=els,
    notes="Harish: Each bar shows what happens to a district's predicted cost when one factor goes from a low to a high value. "
          "The strongest sign of a dear district is renovation spending: going from about 1.4 to 14 million dollars a quarter "
          "comes with about ten percent higher cost per square metre. Places building lots of homes per resident are four "
          "percent dearer. Building many houses makes a district cheaper, thanks to volume builders, but any one district gets "
          "dearer in its own busy years. We left out anything built from house value, because that would give the answer away."))

# 5. RQ1 accuracy and result
els = title("How well can we predict cost?", "Average error on 2020–2026, years the models never saw")
els += fig_card("c03_rq1_accuracy.png", 0.5, 2.15, 7.4, 3.3)
els += text_card(8.1, 2.15, 4.75, 3.3, "Why two sets of factors?",
                 [run("Measured factors only, then the same plus the district's name. The name adds location: the error falls from "
                      "8.6% to 7.9%. The district's own past average alone gets 8.0%. Ten models compared; a plain linear "
                      "regression matched boosted trees and SVMs (appendix).", 15.5)], size=15.5)
els += result(0.5, 5.62, 12.35, 1.18, "Result (RQ1):",
              "location matters most. Renovation spending (+10%) and homes per resident (+4%) explain only about 15% of the gap "
              "between districts; our best model, linear regression with the district, is off by 7.9% on years it never saw "
              "(guessing the national average: 10.1%).")
slides.append(dict(presenter="harish", topic="RQ1 · Cost per square metre", els=els,
    notes="Harish: We tried each model twice: with measured factors only, and with the district's name added. Guessing the "
          "national average is off by about ten percent. With measured factors only, our chosen model, a random forest, is off "
          "by 8.6 percent; adding the district brings a plain linear regression to 7.9. And each district's own history already "
          "gets you to 8.0. So our answer to RQ1: location matters most. The factors we measured explain only about fifteen "
          "percent of the gap between districts. Andrew will now show the markets we found."))

# 6. RQ2 clusters and how k was chosen
els = title("Three kinds of building market", "RQ2 · What kinds of building markets does New Zealand have?")
els += fig_card("c05_rq2_markets.png", 0.5, 2.15, 7.25, 4.65)
els += text_card(7.95, 2.15, 4.9, 1.72, "How we grouped them",
                 [run("66 districts, each described by 9 features over 2016–2026: home types, building rate, growth, ups and "
                      "downs, cost, house size, commercial share. Grouped with k-means; hierarchical clustering as a check.", 12.5)],
                 size=12.5)
els += fig_card("c10_rq2_choose_k.png", 7.95, 4.02, 4.9, 2.78, pad=0.12)
slides.append(dict(presenter="andrew", topic="RQ2 · Building markets", els=els,
    notes="Andrew: Our second question: what kinds of building markets does New Zealand have? We described 66 districts by "
          "nine things, such as what homes they build, how fast and at what cost, and let k-means group similar districts. "
          "To choose how many groups, we looked at two scores. Three groups were the most stable when we resampled the data, "
          "0.84, with almost the best separation, so we chose three. A second method, hierarchical clustering, agreed on 60 of "
          "the 66 districts."))

# 7. RQ2 profiles and result
mk = [("Cluster 1 · House-building (30)", "Most homes per resident and the biggest houses. Commuter belts and lifestyle areas: "
                                           "Selwyn, Waikato, Waimakariri, Waipa", "muted"),
      ("Cluster 2 · Slow provincial (21)", "Fewest new homes, up-and-down building, most renovation, cheapest: Rotorua, "
                                            "Invercargill, Whanganui", "dark"),
      ("Cluster 3 · Urban medium-density (15)", "Most townhouses and apartments (39% of new homes), dearest: Auckland, "
                                                 "Christchurch, Queenstown-Lakes, Hamilton", "orange")]
els = title("How the three clusters differ")
els += fig_card("c06_rq2_profiles.png", 0.5, 1.75, 7.9, 3.7)
els += result(0.5, 5.6, 7.9, 1.2, "Result (RQ2):",
              "three kinds of market. Two methods agree on 60 of 66 districts and the clusters are stable, but the edges are "
              "soft: a summary of a continuum.", size=13.5)
for i, (h, b, col) in enumerate(mk):
    y = 1.75 + i * 1.72
    els += [card(8.6, y, 4.25, 1.58), shape(8.8, y + 0.2, 0.28, 0.28, col, "ellipse"),
            text(9.2, y + 0.12, 3.5, 1.4, [para(run(h, 14, True, "ink"), after=3), para(run(b, 13.5, False, "muted"))])]
slides.append(dict(presenter="andrew", topic="RQ2 · Building markets", els=els,
    notes="Andrew: Each bar is the typical, or median, district in a cluster. House-building districts like Selwyn and "
          "Waimakariri, the commuter belt around Christchurch, build the most homes per resident and the biggest houses. Slow "
          "provincial districts like Rotorua and Whanganui build the least, spend most on renovation and are cheapest. Urban "
          "districts, the cities and Queenstown, build the most townhouses and apartments and are dearest. So our answer: three "
          "kinds of market, but with soft edges. Niwesh will now look ahead to next year."))

# 8. RQ3 together
els = title("Districts rise and fall together", "RQ3 · Will a district's consents rise or fall next year?")
els += fig_card("c07_rq3_together.png", 0.5, 2.15, 7.9, 4.65)
els += [card(8.6, 2.15, 4.25, 1.95)]
els += stat(8.85, 2.25, 3.85, "12% → 88%", "of districts built more than the year before: 12% in 2009, after the financial crisis; "
                                          "88% in 2021, in the post-COVID boom")
els += text_card(8.6, 4.3, 4.25, 2.5, "The national cycle rules",
                 [run("When New Zealand as a whole builds more, most districts do too, whatever is happening locally: if the "
                      "country is building above its 5-year average, a district's odds of rising are 1.8× higher. So calling one "
                      "district means first calling the whole country, whose turning points follow interest rates and migration, "
                      "which are not in consent data.", 13)], size=13.5)
slides.append(dict(presenter="niwesh", topic="RQ3 · Next year", els=els,
    notes="Niwesh: Our third question: will a district build more or less next year? Each bar is a year, showing the share of "
          "districts that built more than the year before. In 2009, after the global financial crisis, only twelve percent "
          "did; in 2021, in the post-COVID boom, eighty-eight percent did. The colour shows whether the national total rose. "
          "Districts rise and fall with the country, so predicting one district really means first predicting New Zealand."))

# 9. RQ3 accuracy and result
els = title("Can we see next year coming?", "Calling up or down for 66 districts, 2018–2025 (years the model never saw)")
els += fig_card("c08_rq3_accuracy.png", 0.5, 2.15, 7.0, 3.3)
els += [card(7.7, 2.15, 5.15, 3.3),
        bullets(7.92, 2.3, 4.75, 3.1, [
            [run("How: ", 13, True), run("11 facts known at year end, about the district and all of NZ; trained on 1996–2016, "
                                         "tested on 2017–2024", 13)],
            [run("Helps: ", 13, True), run("NZ building above its 5-year average (odds of a rise 1.8× higher)", 13)],
            [run("Warning signs: ", 13, True), run("districts relying on apartment projects, which come in big one-off batches, "
                                                   "or already building unusually hard", 13)],
            [run("Seven models compared: ", 13, True), run("LDA and the lasso tied; trees and forests did no better (appendix)", 13)]],
            size=13)]
els += result(0.5, 5.62, 12.35, 1.18, "Result (RQ3):",
              "only modestly predictable. Logistic regression called 58% of district-years correctly (test AUC 0.63), against 50% "
              "for a coin toss and 53% for the best simple rule; the direction mostly follows the national cycle.")
slides.append(dict(presenter="niwesh", topic="RQ3 · Next year", els=els,
    notes="Niwesh: Our model uses eleven facts known at the end of each year, about the district and the whole country. It "
          "learnt from 1996 to 2016 and was tested on later years. Logistic regression was right fifty-eight percent of the "
          "time, against fifty for a coin toss and fifty-three for the best simple rule. It helps when the country is building "
          "above its five-year average. Warning signs are districts relying on apartment projects, which come in big batches, "
          "so a big year is often followed by a smaller one. Seven models were compared and the fancier ones did no better."))

# 10. Limitations and next steps
lims = [("Consents are not completions", "Values are estimates at consent time and leave out land, so we study planned cost.",
         "Completion and land-value data"),
        ("One national price index", "Places where building costs rose faster than NZ look dearer than they are.",
         "Regional building-cost indexes"),
        ("District averages hide detail", "A district is treated as one place; SA2 files have home counts only.",
         "Value and floor area by SA2"),
        ("Missing economic drivers", "No land prices, interest rates or migration: likely causes of turning points and location gaps.",
         "Add Reserve Bank and population data"),
        ("Soft clusters, few districts", "Only 66 districts; the urban cluster has 15, and some districts sit between clusters.",
         "More years or finer areas"),
        ("Patterns, not causes", "Models find associations, and relationships drifted after 2023.",
         "Refit as new data arrives")]
els = title("Limitations and next steps", "What each limit means for our results, and what would fix it")
for i, (h, why, fix) in enumerate(lims):
    x = 0.5 + (i % 3) * 4.18; y = 2.15 + (i // 3) * 2.38
    els += [card(x, y, 3.95, 2.22),
            text(x + 0.22, y + 0.17, 3.55, 1.95, [para(run(h, 17, True, "ink"), after=7), para(run(why, 14.5, False, "muted"), after=9),
                                                  para(run("Fix: ", 14.5, True, "dark"), run(fix, 14.5, False, "ink"), after=0)])]
slides.append(dict(presenter="niwesh", topic="Limitations", els=els,
    notes="Niwesh: A few honest limits. Consents are not completions, and their values leave out land. We deflated every "
          "district with one national building-cost index. District averages hide what happens inside a district. And the big "
          "economic drivers, land prices, interest rates and migration, are not in consent data; adding them is the most "
          "promising next step."))

# 11. Conclusion
take = [("RQ1 · Place matters most", "Where you build matters more than anything we measured: our factors explain only about 15% "
                                "of why some districts cost more."),
        ("RQ2 · Three soft-edged markets", "House-building, slow provincial and urban districts, which blur into each other."),
        ("RQ3 · The country sets the pace", "Districts rise and fall with NZ, so next year is only a little better than a coin toss (58%).")]
els = title("What we learned")
for i, (h, b) in enumerate(take):
    x = 0.5 + i * 4.18
    els += [card(x, 1.75, 3.95, 2.75)] + numbered(x + 0.25, 1.98, i + 1) + \
           [text(x + 0.25, 2.6, 3.5, 1.8, [para(run(h, 17.5, True, "ink"), after=6), para(run(b, 14.5, False, "muted"))])]
els += text_card(0.5, 4.75, 7.6, 2.05, "Simple was enough",
                 [run("Plain linear and logistic regression did as well as boosted trees, SVMs and forests on years they never "
                      "saw, and they are easy to explain.  ", 13.5),
                  run("Hypotheses: ", 13.5, True),
                  run("busy markets cost more: partly (location dominates); a few distinct market types: partly (soft edges); "
                      "momentum predicts next year: weakly (national momentum helps, a district's own reverses).", 13.5)], size=13.5)
els += [shape(8.3, 4.75, 4.55, 2.05, "orange", "round"),
        text(8.5, 4.9, 2.75, 1.8, [para(run("Try it yourself", 18, True, "ink"), after=4),
                                   para(run("Pick a district and ask \"what if\"", 13, False, "ink"), after=6),
                                   para(run("niwesh.shinyapps.io/", 11, True, "ink", link=f"https://{APP_URL}/"), after=0),
                                   para(run("nz-building-consents", 11, True, "ink", link=f"https://{APP_URL}/"), after=0)]),
        shape(11.3, 4.92, 1.38, 1.38, "white", "round"),
        img(str(ASSETS / "qr_app.png"), 11.36, 4.98, 1.26, 1.26)]
slides.append(dict(presenter="niwesh", topic="Conclusion", els=els,
    notes="Niwesh: To sum up: where you build matters more than anything we could measure; New Zealand has three soft-edged "
          "building markets; and districts rise and fall with the country, so next year is hard to call. Simple models were "
          "enough. Finally, a quick look at our app, which is live online. [Demo, about 35 seconds, at "
          "niwesh.shinyapps.io/nz-building-consents: open the RQ1 tab, pick Selwyn, drag renovation spending up and show the "
          "predicted cost rise; switch to the RQ3 tab to show 2026 probabilities.] Thank you, we're happy to take questions."))

# 12. Appendix A: every model on the test years
rq1 = [["RQ1: test error, MAPE (%)", "Drivers only", "+ district"],
       ["Guess the national average", "10.1", "10.1"], ["District's own past average", "8.0", "8.0"],
       ["Linear regression", "8.7", "7.9 ★"], ["Polynomial regression", "8.6", "7.9"],
       ["Ridge / lasso / elastic net", "8.7", "8.0"], ["GAM (splines)", "8.6", "7.9"], ["Regression tree", "8.9", "7.9"],
       ["Random forest", "8.6 ★", "8.5"], ["XGBoost", "8.5", "8.1"], ["SVM (radial)", "8.3", "7.9"]]
rq3 = [["RQ3: test, 2018–2025 (%)", "Accuracy", "Precision", "Recall", "AUC", "CV AUC"],
       ["Always say \"rise\"", "47.7", "47.7", "100", "0.50", "0.500"], ["Opposite of this year", "53.0", "50.7", "54.8", "0.53", "0.548"],
       ["Logistic regression ★", "58.3", "55.3", "65.9", "0.63", "0.676"], ["Lasso logistic", "58.5", "55.5", "66.3", "0.63", "0.677"],
       ["LDA", "58.0", "54.8", "67.5", "0.63", "0.675"], ["QDA", "54.9", "52.0", "70.6", "0.61", "0.649"],
       ["Classification tree", "53.0", "50.9", "46.8", "0.52", "0.599"], ["k-nearest neighbours", "56.4", "53.1", "75.4", "0.63", "0.626"],
       ["Random forest", "58.0", "55.9", "56.7", "0.62", "0.645"]]
els = title("Appendix A: every model on the test years")
els += [card(0.5, 1.65, 5.75, 4.05), card(6.45, 1.65, 6.4, 4.05)]
els += table(0.62, 1.78, [2.75, 1.35, 1.35], rq1, rowh=0.34, size=10.5)
els += table(6.57, 1.78, [2.15, 0.85, 0.9, 0.8, 0.7, 0.75], rq3, rowh=0.374, size=10.5, bold_rows=(3,))
els += [text(0.6, 5.85, 12.2, 1.0, [
    para(run("Test sets: RQ1 2020–2026 (1,611 district-quarters, never used in training); RQ3 2018–2025 outcomes (528 "
             "district-years). ★ chosen by cross-validation (CV): the simplest model within one standard error of the best CV "
             "score, not the best test score. Test R-squared: 0.36 for linear regression with the district, 0.27 for the forest. "
             "Precision and recall are for \"rise\".", 11, False, "muted"), after=4),
    para(run("RQ2 (clustering) has no test set: k = 3 chosen by stability (0.84 vs 0.74 for k = 2, 0.80 for k = 4) and silhouette "
             "(0.21 vs 0.22 and 0.18); Ward's hierarchical clustering agrees on 60 of 66 districts (ARI 0.75).", 11, False, "muted"), after=0)])]
slides.append(dict(presenter="niwesh", topic="Appendix", els=els, notes="Appendix for questions: every model's test results."))

# 13. Appendix B: methods and references
rows = [["", "RQ1 Cost per square metre", "RQ2 Markets", "RQ3 Next year"],
        ["Unit", "District × quarter (5,694 train, 1,611 test)", "District (66)", "District × year (1,386 train, 528 test)"],
        ["Methods", "Baselines, linear, polynomial, ridge, lasso, elastic net, GAM, regression tree, random forest, XGBoost, SVM",
         "k-means; hierarchical (single, complete, average, Ward)", "Logistic, lasso, LDA, QDA, classification tree, KNN, random forest"],
        ["Validation", "Forward-chaining CV; test 2020–26", "Silhouette, CH, gap, bootstrap stability", "Forward-chaining CV (AUC); test 2017–24"],
        ["Result", "Linear regression: test MAPE 7.9%, test R-squared 0.36", "k = 3; ARI 0.75 between methods", "Logistic: test accuracy 58%, test AUC 0.63"]]
els = title("Appendix B: methods and references")
cw = [1.5, 3.9, 3.3, 3.45]; y0 = 1.65
els.append(card(0.5, y0 - 0.1, 12.35, 3.45))
for r, row in enumerate(rows):
    x = 0.6; rh = 0.42 if r == 0 else (0.9 if r == 2 else 0.56)
    for c, cell in enumerate(row):
        if r == 0:
            els.append(shape(x, y0, cw[c] - 0.05, rh - 0.05, "orange", "rect"))
        els.append(text(x + 0.1, y0 + 0.03, cw[c] - 0.25, rh - 0.1, [para(run(cell, 11, r == 0 or c == 0, "ink"), after=0)], valign="middle"))
        x += cw[c]
    y0 += rh
BC = "https://www.stats.govt.nz/information-releases/building-consents-issued-august-2026/"
SA2 = ("https://www.stats.govt.nz/assets/Uploads/Building-consents-issued/Building-consents-issued-August-2026/Download-data/"
       "new-dwellings-consented-by-statistical-area-2-august-2026.zip")
BPI = "https://www.stats.govt.nz/information-releases/business-price-indexes-june-2026-quarter/"
els.append(text(0.6, 5.1, 12.2, 2.1, [
    para(run("References", 12, True, "ink"), after=3),
    para(run("Stats NZ. (2026). Building consents issued: August 2026 [Data set]. CC BY 4.0. ", 10, False, "muted"),
         run(BC, 10, False, "dark", link=BC), after=2),
    para(run("Stats NZ. (2026). New dwellings consented by statistical area 2: August 2026 [Data set]. CC BY 4.0. ", 10, False, "muted"),
         run(SA2, 10, False, "dark", link=SA2), after=2),
    para(run("Stats NZ. (2026). Business price indexes: June 2026 quarter [Data set]. CC BY 4.0. ", 10, False, "muted"),
         run(BPI, 10, False, "dark", link=BPI), after=2),
    para(run("James, G., Witten, D., Hastie, T., & Tibshirani, R. (2021). An introduction to statistical learning (2nd ed.). Springer.", 10, False, "muted"), after=2),
    para(run("Interactive app: ", 10, True, "ink"), run(f"https://{APP_URL}/", 10, True, "dark", link=f"https://{APP_URL}/"),
         run("   ·   AI use: Claude (Anthropic) helped write and debug R code and edit text; all analysis choices and results "
             "were reviewed by the group.", 10, False, "muted"), after=0)]))
slides.append(dict(presenter="niwesh", topic="Appendix", els=els, notes="Appendix for questions: methods, validation and references."))

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
                        if r.get("link"): rr.hyperlink.address = r["link"]; f.color.rgb = rgb(r["color"])
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
                    def span(r):
                        sp = (f"<span style='font-size:{r['size']}pt;font-weight:{'bold' if r['bold'] else 'normal'};"
                              f"font-style:{'italic' if r['italic'] else 'normal'};color:#{C.get(r['color'], r['color'])}'>"
                              f"{htmllib.escape(r['text'])}</span>")
                        return (f"<a href='{htmllib.escape(r['link'], quote=True)}' style='text-decoration:none'>{sp}</a>"
                                if r.get("link") else sp)
                    runs = "".join(span(r) for r in pd["runs"])
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
