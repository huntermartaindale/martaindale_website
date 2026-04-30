#!/usr/bin/env Rscript
# scripts/import_pdfs.R
#
# Match PDFs in the user's published_articles directory to publications in
# cv_data.yaml using greedy bipartite assignment on title-token Jaccard
# similarity. Copies matched PDFs to website/pubs/ with stable slugs and
# emits a CSV match report.
#
# Usage: Rscript scripts/import_pdfs.R
# Run from website/.

suppressPackageStartupMessages({
  library(yaml)
})

cv_path  <- "../cv/cv_data.yaml"
pdf_dir  <- "C:/Users/hunte/OneDrive - Texas State University/Research/published_articles"
out_dir  <- "pubs"
report   <- "scripts/_pdf_match_report.csv"

stopifnot(file.exists(cv_path), dir.exists(pdf_dir))
dir.create(out_dir, showWarnings = FALSE)

cv <- yaml::read_yaml(cv_path)
pubs <- cv$publications

# --- helpers ---------------------------------------------------------------

slugify <- function(s, max_len = 60) {
  s <- tolower(s)
  s <- gsub("[\u2018\u2019\u201C\u201D'\"]", "", s, perl = TRUE)
  s <- gsub("[^a-z0-9]+", "-", s, perl = TRUE)
  s <- gsub("^-+|-+$", "", s)
  if (nchar(s) > max_len) s <- substr(s, 1, max_len)
  gsub("-+$", "", s)
}

first_author_lastname <- function(authors_str) {
  if (is.null(authors_str) || is.na(authors_str)) return("unknown")
  s <- gsub("^\\*", "", authors_str)
  s <- strsplit(s, ",", fixed = TRUE)[[1]][1]
  s <- gsub("[^A-Za-z\\-]", "", s)
  if (nchar(s) == 0) "unknown" else tolower(s)
}

clean_pdf_name <- function(fn) {
  s <- sub("\\.pdf$", "", fn, ignore.case = TRUE)
  s <- sub("^\\d{4}\\s*[-_]\\s*", "", s)
  tolower(s)
}

tokens <- function(s) {
  s <- tolower(s)
  s <- gsub("[^a-z0-9 ]", " ", s)
  toks <- strsplit(s, "\\s+", perl = TRUE)[[1]]
  toks <- toks[nchar(toks) >= 4]
  stop <- c("with", "from", "this", "that", "their", "they", "them", "what",
            "when", "which", "while", "would", "could", "should", "based",
            "study", "into", "than", "between", "among", "during", "after",
            "before", "about", "have", "been", "were", "into")
  setdiff(unique(toks), stop)
}

jaccard <- function(a, b) {
  if (length(a) == 0 || length(b) == 0) return(0)
  length(intersect(a, b)) / length(union(a, b))
}

# --- collect PDFs ----------------------------------------------------------

pdf_files <- list.files(pdf_dir, pattern = "\\.pdf$", ignore.case = TRUE,
                        full.names = FALSE)
cat(sprintf("Found %d PDFs in %s\n", length(pdf_files), pdf_dir))

pdf_meta <- lapply(pdf_files, function(fn) {
  yr <- sub("^(\\d{4}).*", "\\1", fn)
  list(
    file   = fn,
    year   = if (grepl("^\\d{4}$", yr)) as.integer(yr) else NA_integer_,
    tokens = tokens(clean_pdf_name(fn))
  )
})

# --- pub metadata ---------------------------------------------------------

pub_meta <- lapply(seq_along(pubs), function(i) {
  p <- pubs[[i]]
  list(
    idx    = i,
    year   = as.integer(p$year),
    title  = p$title,
    slug   = sprintf("%d_%s_%s",
                     as.integer(p$year),
                     first_author_lastname(p$authors),
                     slugify(p$title, 50)),
    tokens = tokens(p$title)
  )
})

# --- pairwise similarity (year proximity boost, no hard year filter) ------

n_pdfs <- length(pdf_meta)
n_pubs <- length(pub_meta)

score_mat <- matrix(0, nrow = n_pubs, ncol = n_pdfs)
for (i in seq_len(n_pubs)) {
  for (j in seq_len(n_pdfs)) {
    s <- jaccard(pub_meta[[i]]$tokens, pdf_meta[[j]]$tokens)
    # year penalty: same year = 1, +/-1 = 0.85, +/-2 = 0.6, beyond = 0.3
    yd <- if (is.na(pdf_meta[[j]]$year) || is.na(pub_meta[[i]]$year)) 999
          else abs(pdf_meta[[j]]$year - pub_meta[[i]]$year)
    yw <- if (yd == 0) 1 else if (yd == 1) 0.85 else if (yd == 2) 0.6 else 0.3
    score_mat[i, j] <- s * yw
  }
}

# --- greedy bipartite assignment ------------------------------------------

THRESH <- 0.25
assigned_pdf <- rep(NA_integer_, n_pubs)
assigned_score <- rep(0, n_pubs)
used_pdf <- rep(FALSE, n_pdfs)

repeat {
  # mask used pubs/pdfs
  m <- score_mat
  m[!is.na(assigned_pdf), ] <- -1
  m[, used_pdf] <- -1
  best <- which(m == max(m), arr.ind = TRUE)[1, , drop = FALSE]
  best_score <- m[best[1], best[2]]
  if (best_score < THRESH) break
  assigned_pdf[best[1]] <- best[2]
  assigned_score[best[1]] <- best_score
  used_pdf[best[2]] <- TRUE
}

# --- build results --------------------------------------------------------

results <- lapply(seq_len(n_pubs), function(i) {
  pm <- pub_meta[[i]]
  pdf_j <- assigned_pdf[i]
  if (!is.na(pdf_j)) {
    list(idx = i, year = pm$year, title = pm$title, slug = pm$slug,
         pdf_file = pdf_meta[[pdf_j]]$file,
         score = round(assigned_score[i], 3),
         status = "matched")
  } else {
    # report best (unassigned) candidate score for visibility
    best_j <- which.max(score_mat[i, ])
    list(idx = i, year = pm$year, title = pm$title, slug = pm$slug,
         pdf_file = "",
         score = round(score_mat[i, best_j], 3),
         status = "no-pdf")
  }
})

# --- write report ---------------------------------------------------------

df <- do.call(rbind, lapply(results, function(r) data.frame(
  idx = r$idx, year = r$year, status = r$status, score = r$score,
  slug = r$slug, pdf_file = r$pdf_file, title = r$title,
  stringsAsFactors = FALSE
)))
write.csv(df, report, row.names = FALSE)

cat(sprintf("\nMatch report: %s\n", report))
cat("Status counts:\n"); print(table(df$status))

# --- copy matched PDFs ----------------------------------------------------

n_copied <- 0
for (r in results) {
  if (r$status == "matched" && nzchar(r$pdf_file)) {
    src <- file.path(pdf_dir, r$pdf_file)
    dst <- file.path(out_dir, paste0(r$slug, ".pdf"))
    if (file.exists(src)) {
      file.copy(src, dst, overwrite = TRUE)
      n_copied <- n_copied + 1
    }
  }
}
cat(sprintf("\nCopied %d PDFs to %s/\n", n_copied, out_dir))

# --- unassigned PDFs ------------------------------------------------------

assigned_files <- sapply(results, function(r) if (r$status == "matched") r$pdf_file else "")
unassigned <- setdiff(pdf_files, assigned_files)
if (length(unassigned) > 0) {
  cat("\nPDFs in folder NOT assigned to any publication:\n")
  for (f in unassigned) cat("  ", f, "\n")
}
