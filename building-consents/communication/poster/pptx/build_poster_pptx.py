"""
communication/poster/pptx/build_poster_pptx.py

Makes communication/poster/poster.pptx, an editable A2 PowerPoint copy of poster.html.
It opens poster.html in headless Chrome (extract_layout.R), reads where every box, chart and
piece of text sits, and redraws them as ordinary PowerPoint shapes, pictures and text boxes,
so the two versions match. poster.html stays the master copy: after changing it, run this again.

Run from the project folder:   python communication/poster/pptx/build_poster_pptx.py [output.pptx]
Needs: pip install python-pptx, and R with the chromote package.
For the right font, install the five files in communication/assets/fonts (double-click each).
"""
import json, subprocess, sys, tempfile
from pathlib import Path
from lxml import etree
from pptx import Presentation
from pptx.util import Emu, Pt
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE, MSO_CONNECTOR
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR, MSO_AUTO_SIZE
from pptx.oxml.ns import qn

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "communication" / "poster" / "poster.pptx"
FONT = "Open Sauce One"
PX = 9525                                  # EMU per CSS pixel (96 per inch)
SLACK = 1.01                               # text boxes 1% wider: PowerPoint wraps slightly earlier than Chrome


def emu(v): return Emu(int(round(v * PX)))


def get_layout():
    out = Path(tempfile.mkdtemp()) / "layout.json"
    subprocess.run(["Rscript", "communication/poster/pptx/extract_layout.R", str(out)], cwd=ROOT, check=True)
    return json.loads(out.read_text())


def set_alpha(fill_fmt, alpha):
    srgb = fill_fmt._xPr.find(qn("a:solidFill")).find(qn("a:srgbClr"))
    srgb.append(srgb.makeelement(qn("a:alpha"), {"val": str(int(alpha * 100000))}))


def set_background(slide, image, colour):
    """Page background as a slide background, so it cannot be clicked or moved by accident."""
    _, rid = slide.part.get_or_add_image_part(image)
    bg = etree.SubElement(slide._element.cSld, qn("p:bg"))
    slide._element.cSld.remove(bg); slide._element.cSld.insert(0, bg)
    pr = etree.SubElement(bg, qn("p:bgPr"))
    fill = etree.SubElement(pr, qn("a:blipFill"), {"dpi": "0", "rotWithShape": "1"})
    etree.SubElement(fill, qn("a:blip"), {qn("r:embed"): rid})
    etree.SubElement(etree.SubElement(fill, qn("a:stretch")), qn("a:fillRect"))
    etree.SubElement(pr, qn("a:effectLst"))


def add_box(slide, it, n):
    kind = {"ellipse": MSO_SHAPE.OVAL, "round": MSO_SHAPE.ROUNDED_RECTANGLE, "rect": MSO_SHAPE.RECTANGLE}[it["shape"]]
    shp = slide.shapes.add_shape(kind, emu(it["x"]), emu(it["y"]), emu(it["w"]), emu(it["h"]))
    shp.name = f"Box {n}"
    if it["shape"] == "round":
        shp.adjustments[0] = min(0.5, it["radius"] / min(it["w"], it["h"]))
    shp.shadow.inherit = False
    if it["fill"]:
        shp.fill.solid(); shp.fill.fore_color.rgb = RGBColor.from_string(it["fill"]["hex"])
        if it["fill"]["a"] < 1: set_alpha(shp.fill, it["fill"]["a"])
    else:
        shp.fill.background()
    if it["line"]:
        shp.line.color.rgb = RGBColor.from_string(it["line"]["hex"]); shp.line.width = Pt(it["line"]["w"] * 0.75)
    else:
        shp.line.fill.background()
    shp.text_frame.text = ""


def add_line(slide, it, n):
    ln = slide.shapes.add_connector(MSO_CONNECTOR.STRAIGHT, emu(it["x"]), emu(it["y"]), emu(it["x"] + it["w"]), emu(it["y"]))
    ln.name = f"Line {n}"
    ln.line.color.rgb = RGBColor.from_string(it["line"]["hex"]); ln.line.width = Pt(it["line"]["w"] * 0.75)


def add_picture(slide, it):
    pic = slide.shapes.add_picture(it["src"], emu(it["x"]), emu(it["y"]), emu(it["w"]), emu(it["h"]))
    pic.name = "Chart " + Path(it["src"]).stem
    pic._element.nvPicPr.cNvPr.set("descr", it.get("alt") or "")


def font_for(weight):
    """The ExtraBold and SemiBold files are separate font families; Bold is the regular family's bold."""
    if weight >= 800: return FONT + " ExtraBold", False
    if weight >= 600 and weight < 700: return FONT + " SemiBold", False
    return FONT, weight >= 700


def add_text(slide, it, n):
    one_line = round(it["h"] / (it["lineHeight"] / 0.75)) <= 1
    w = it["w"] * (1.08 if one_line else SLACK) if it["align"] == "left" else it["w"]   # one-line labels get more room
    x = it["x"]
    tb = slide.shapes.add_textbox(emu(x), emu(it["y"]), emu(w), emu(it["h"]))
    words = " ".join(r["text"] for r in it["runs"] if "text" in r).split()
    tb.name = f"Text {n}: " + " ".join(words[:5])
    tf = tb.text_frame; tf.word_wrap = True; tf.auto_size = MSO_AUTO_SIZE.NONE
    tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
    tf.vertical_anchor = MSO_ANCHOR.TOP
    p = tf.paragraphs[0]
    p.alignment = {"left": PP_ALIGN.LEFT, "center": PP_ALIGN.CENTER, "right": PP_ALIGN.RIGHT}[it["align"]]
    p.line_spacing = Pt(it["lineHeight"]); p.space_before = p.space_after = Pt(0)
    if it["bullet"]:
        pPr = p._p.get_or_add_pPr()
        pPr.set("marL", str(emu(it["indent"]))); pPr.set("indent", str(-emu(it["indent"])))
        pPr.append(pPr.makeelement(qn("a:buChar"), {"char": "•"}))
    for r in it["runs"]:
        if r.get("br"):
            p.add_line_break(); continue
        rr = p.add_run(); rr.text = r["text"]; f = rr.font
        name, bold = font_for(r["weight"])
        f.name = name; f.bold = bold; f.italic = r["italic"]; f.size = Pt(round(r["size"] * 2) / 2)
        f.color.rgb = RGBColor.from_string(r["colour"])
        if r.get("spacing"): rr._r.get_or_add_rPr().set("spc", str(int(r["spacing"] * 100)))


def build(out=OUT):
    lay = get_layout()
    prs = Presentation()
    prs.slide_width, prs.slide_height = emu(lay["page"]["w"]), emu(lay["page"]["h"])
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    if lay["background"]:
        set_background(slide, lay["background"], lay["pageColour"])
    for n, it in enumerate(lay["items"], 1):
        {"box": add_box, "line": add_line, "text": add_text}.get(it["t"], lambda s, i, n: add_picture(s, i))(slide, it, n)
    prs.save(out)
    print("written", out)


if __name__ == "__main__":
    build(Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else OUT)   # optional: another output path
