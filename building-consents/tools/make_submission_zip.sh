#!/usr/bin/env bash
# =============================================================================
# tools/make_submission_zip.sh
# Builds the supplementary-materials zip for STAT462 Assessment 1 (end of week 9).
# Rules from the assessment brief: one zip, well structured, NO data (raw or
# processed), under 500 MB.
#
# Contents: the analysis notebooks (.Rmd + knitted .html), the R helpers, the
# figures and results tables they write, the data dictionary, the report as PDF,
# the .Rproj file and a submission README (tools/README_submission.md, renamed
# README.md inside the zip). Poster, slides, app and build scripts are left out.
#
# Usage (from the project folder):   bash tools/make_submission_zip.sh [output.zip]
# Default output: submission/Group8_whileTrue_learn_supplementary.zip
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"
OUT="${1:-submission/Group8_whileTrue_learn_supplementary.zip}"
mkdir -p "$(dirname "$OUT")"
OUT="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"
rm -f "$OUT"

STAGE="$(mktemp -d)"
DEST="$STAGE/Building-Consents-Project"
mkdir -p "$DEST"
trap 'rm -rf "$STAGE"' EXIT

copy() { mkdir -p "$DEST/$(dirname "$1")"; cp "$ROOT/$1" "$DEST/$1"; }

cp "$ROOT/tools/README_submission.md" "$DEST/README.md"
copy Building-Consents-Project.Rproj
for f in R/utils_data.R R/utils_models.R R/utils_cluster.R R/utils_classify.R; do copy "$f"; done
# notebooks and their knitted HTML only (no caches or *_files folders)
find analysis -type f \( -name "*.Rmd" -o -name "*.html" \) -not -path "*_cache/*" -not -path "*_files/*" |
  while read -r f; do copy "$f"; done
for d in rq1 rq2 rq3; do
  mkdir -p "$DEST/outputs/figures/$d" "$DEST/outputs/tables/$d"
  cp "$ROOT/outputs/figures/$d/"*.png "$DEST/outputs/figures/$d/"
  cp "$ROOT/outputs/tables/$d/"*.csv  "$DEST/outputs/tables/$d/"
done
copy docs/data_dictionary.md
copy report/group_report.pdf

(cd "$STAGE" && zip -r -q -X "$OUT" Building-Consents-Project -x "*.DS_Store")

echo "Written: $OUT ($(du -h "$OUT" | cut -f1), $(unzip -Z1 "$OUT" | grep -vc '/$') files)"
echo "Check that no data slipped in:"
if unzip -Z1 "$OUT" | grep -E "(^|/)data/|\.rds$|outputs/models" ; then
  echo "  WARNING: data files found above"; exit 1
else
  echo "  OK: no data/, .rds or saved models in the zip"
fi
