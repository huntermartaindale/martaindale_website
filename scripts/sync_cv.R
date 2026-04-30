#!/usr/bin/env Rscript
# scripts/sync_cv.R
#
# Renders the CV from the canonical source (huntermartaindale/cv at ../cv)
# and copies the HTML and PDF outputs into website/cv/ for local preview.
#
# In CI, .github/workflows/deploy.yml does this same work using a deploy
# key against the private cv repo. This script exists so local previews
# match production without manual file copying.
#
# Usage (from website/):
#   Rscript scripts/sync_cv.R [path/to/cv/repo]
#
# Default cv-source path: ../cv

args <- commandArgs(trailingOnly = TRUE)
cv_repo <- if (length(args) >= 1) args[1] else "../cv"

if (!dir.exists(cv_repo)) stop("CV repo not found at: ", cv_repo)

quarto <- Sys.getenv(
  "QUARTO_PATH",
  "C:/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe"
)
if (!file.exists(quarto)) {
  # fall back to PATH lookup
  found <- Sys.which("quarto")
  if (nzchar(found)) quarto <- unname(found)
  else stop("quarto executable not found. Set QUARTO_PATH env var.")
}

cat("Rendering CV at", cv_repo, "...\n")
old_wd <- getwd()
setwd(cv_repo)
on.exit(setwd(old_wd), add = TRUE)
rc <- system2(quarto, args = c("render", "cv.qmd", "--to", "all"))
setwd(old_wd)
if (rc != 0) stop("quarto render failed (exit ", rc, ")")

src_html <- file.path(cv_repo, "cv.html")
src_pdf  <- file.path(cv_repo, "cv.pdf")
if (!file.exists(src_html)) stop("Expected output not found: ", src_html)
if (!file.exists(src_pdf))  stop("Expected output not found: ", src_pdf)

dir.create("cv", showWarnings = FALSE)
file.copy(src_html, "cv/index.html",        overwrite = TRUE)
file.copy(src_pdf,  "cv/martaindale_cv.pdf", overwrite = TRUE)

cat("Synced:\n")
cat("  cv/index.html         (", file.info("cv/index.html")$size, "bytes)\n")
cat("  cv/martaindale_cv.pdf (", file.info("cv/martaindale_cv.pdf")$size, "bytes)\n")
