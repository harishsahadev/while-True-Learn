# Poster: PowerPoint version

`communication/poster/poster.pptx` is an editable A2 PowerPoint copy of `poster.html`. Every heading, sentence and
bullet is an ordinary text box. Every chart is a picture, and every card is a shape. The page background is
set as the slide background, so it can't be moved by accident.

`poster.html` is the master copy. The PowerPoint file and both PDFs are made from it.

## Fonts
Install the five font files in `communication/assets/fonts` (double-click each one, then Install). Without
them, PowerPoint or Keynote swaps in another font and the text no longer fits its boxes.

## Files
| File | What it does |
|---|---|
| `build_poster_pptx.py` | Opens `poster.html` in headless Chrome and redraws it as `poster.pptx` |
| `extract_layout.R`, `extract_layout.js` | Used by the builder: read the position and style of everything on the page |
| `compare_pptx.py` | Lists hand edits in a PowerPoint copy (changed text, moved or resized boxes, added or deleted shapes) |

Run from the project folder (needs `pip install python-pptx` and the R package `chromote`):

    python communication/poster/pptx/build_poster_pptx.py                      # -> communication/poster/poster.pptx
    python communication/poster/pptx/compare_pptx.py path/to/edited.pptx       # what changed by hand

## PDF from the PowerPoint
- **PowerPoint:** File > Export > PDF.
- **Keynote:** open the .pptx, then File > Export To > PDF.
- **Google Slides:** File > Download > PDF. It doesn't have the poster's font.

The PDF made from the HTML (`Rscript communication/render_pdf.R poster`) is still the reference print copy.

## Workflow for PowerPoint edits
1. Edit `poster.pptx` and save it. Don't rename shapes: the compare script matches shapes by name.
2. The changes are carried into `poster.html` (`compare_pptx.py` lists them).
3. `poster.pdf` and `poster.pptx` are rebuilt from the HTML. The hand-edited pptx is kept in
   `communication/earlier_versions/` first.
