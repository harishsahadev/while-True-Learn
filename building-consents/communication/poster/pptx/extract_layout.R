# Opens poster.html in headless Chrome and writes the position and style of every box, image and
# block of text to a JSON file. build_poster_pptx.py turns that file into poster.pptx.
# Usage (from the project folder): Rscript communication/poster/pptx/extract_layout.R out.json
library(chromote)
out <- commandArgs(trailingOnly = TRUE)[1]
html <- normalizePath("communication/poster/poster.html")
js <- paste(readLines("communication/poster/pptx/extract_layout.js", warn = FALSE), collapse = "\n")

b <- ChromoteSession$new(width = 1588, height = 2245)
invisible(b$Page$navigate(paste0("file://", html, "?v=", as.integer(Sys.time()))))
Sys.sleep(3)                                     # let fonts and images load
res <- b$Runtime$evaluate(js)
invisible(b$close())
writeLines(res$result$value, out)
cat("layout written to", out, "\n")
