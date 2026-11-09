# =============================================================================
# communication/render_pdf.R
# Prints the poster and the slide deck HTML to PDF with headless Chrome.
# Needs Google Chrome and the 'chromote' package: install.packages("chromote")
# Usage (from the project folder):
#   Rscript communication/render_pdf.R poster   # -> communication/poster/poster.pdf
#   Rscript communication/render_pdf.R slides   # -> communication/slides/slides.pdf
# Alternative without R: open the .html in Chrome, Print, Save as PDF,
# "Margins: none", tick "Background graphics".
# =============================================================================
library(chromote)
args <- commandArgs(trailingOnly = TRUE)
what <- if (length(args)) args[1] else "poster"
html <- normalizePath(file.path("communication", what, paste0(what, ".html")))
pdf  <- file.path("communication", what, paste0(what, ".pdf"))

b <- ChromoteSession$new()
b$Page$navigate(paste0("file://", html, "?v=", as.integer(Sys.time())))
Sys.sleep(3)                                     # let images load
res <- b$Page$printToPDF(printBackground = TRUE, preferCSSPageSize = TRUE,
                         marginTop = 0, marginBottom = 0, marginLeft = 0, marginRight = 0)
writeBin(jsonlite::base64_dec(res$data), pdf)
b$close()
cat("written", pdf, "\n")
