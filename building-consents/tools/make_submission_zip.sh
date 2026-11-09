#!/usr/bin/env bash
# =============================================================================
# tools/make_submission_zip.sh
# Builds the supplementary-materials zip for STAT462 Assessment 1 (end of week 9).
# Rules from the assessment brief: one zip, well structured, NO data (raw or
# processed), under 500 MB.
#
# Usage (from the project folder):   bash tools/make_submission_zip.sh [output.zip]
# Default output: submission/Group8_whileTrue_learn_supplementary.zip
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-submission/Group8_whileTrue_learn_supplementary.zip}"
mkdir -p "$(dirname "$OUT")"
rm -f "$OUT"

# what goes in
INCLUDE=(
  README.md
  Building-Consents-Project.Rproj
  R
  analysis
  app
  report
  communication
  docs
  tools
  outputs/figures
  outputs/tables
)

# what never goes in: data, saved models (they contain processed data rows),
# knitr caches, personal notes, pitch material, OS/IDE clutter
EXCLUDE=(
  "data/*" "outputs/models/*"
  "*_cache/*" "*_files/*"
  "my_notes/*" "extra/*" "submission/*"
  "*.DS_Store" ".Rproj.user/*" ".Rhistory" "*/.Rhistory"
  "communication/slides/slides.html" "communication/earlier_versions/*"
)

zip -r -q "$OUT" "${INCLUDE[@]}" -x "${EXCLUDE[@]}"

echo "Written: $OUT ($(du -h "$OUT" | cut -f1))"
echo "Check that no data slipped in:"
if unzip -l "$OUT" | grep -E "(^|/)data/|\.rds$|outputs/models" ; then
  echo "  WARNING: data files found above"; exit 1
else
  echo "  OK: no data/, .rds or saved models in the zip"
fi
