"""
communication/poster/pptx/compare_pptx.py

Lists what was changed by hand in an edited copy of the poster PowerPoint, compared with a
fresh build from poster.html: changed text, boxes or charts moved or resized, shapes added or
deleted. Use it to carry PowerPoint edits back into poster.html.

Run from the project folder:
    python communication/poster/pptx/compare_pptx.py path/to/edited.pptx
(builds a fresh copy from poster.html in a temporary folder and compares the two)
or  python communication/poster/pptx/compare_pptx.py edited.pptx original.pptx
"""
import sys, tempfile
from pathlib import Path
from pptx import Presentation

MM = 36000                                 # EMU per millimetre


def shapes(path):
    out = {}
    for sh in Presentation(path).slides[0].shapes:
        key = sh.name.split(":")[0]          # "Text 79", "Box 12", "Chart c04_rq1_drivers"
        text = sh.text_frame.text if sh.has_text_frame else ""
        runs = [(r.text, r.font.bold, r.font.italic, str(r.font.color.rgb) if r.font.color and r.font.color.type else None,
                 r.font.size.pt if r.font.size else None)
                for p in (sh.text_frame.paragraphs if sh.has_text_frame else []) for r in p.runs]
        out[key] = dict(name=sh.name, text=text, runs=runs, box=(sh.left, sh.top, sh.width, sh.height))
    return out


def main():
    edited = Path(sys.argv[1])
    if len(sys.argv) > 2:
        original = Path(sys.argv[2])
    else:
        sys.path.insert(0, str(Path(__file__).parent))
        from build_poster_pptx import build
        original = Path(tempfile.mkdtemp()) / "fresh.pptx"
        build(original)
    a, b = shapes(original), shapes(edited)
    changes = 0
    for k in a:
        if k not in b:
            print(f"DELETED  {a[k]['name']}"); changes += 1; continue
        if a[k]["text"] != b[k]["text"]:
            print(f"TEXT     {k}\n   was: {a[k]['text']!r}\n   now: {b[k]['text']!r}"); changes += 1
        elif a[k]["runs"] != b[k]["runs"]:
            print(f"STYLE    {k} (bold/italic/colour/size changed): {b[k]['text'][:60]!r}"); changes += 1
        moved = [round((y - x) / MM, 1) for x, y in zip(a[k]["box"], b[k]["box"])]
        if any(abs(m) >= 1 for m in moved):
            print(f"MOVED    {a[k]['name'][:50]}: x {moved[0]:+} mm, y {moved[1]:+} mm, "
                  f"width {moved[2]:+} mm, height {moved[3]:+} mm"); changes += 1
    for k in b:
        if k not in a:
            print(f"ADDED    {b[k]['name']}: {b[k]['text'][:80]!r}"); changes += 1
    print(f"{changes} change(s)")


if __name__ == "__main__":
    main()
