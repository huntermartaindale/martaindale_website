#!/usr/bin/env Rscript
# scripts/annotate_cv.R
#
# Reads scripts/_pdf_match_report.csv and data/_summaries_raw.txt, then
# surgically inserts `pdf:` and `plain_summary:` fields into the matched
# publication entries in ../cv/cv_data.yaml. Text-based insertion preserves
# the existing YAML formatting and quoting style.
#
# Usage: Rscript scripts/annotate_cv.R
# Run from website/.

suppressPackageStartupMessages({
  library(yaml)
})

cv_path       <- "../cv/cv_data.yaml"
match_report  <- "scripts/_pdf_match_report.csv"
summaries_txt <- "data/_summaries_raw.txt"
backup_path   <- paste0(cv_path, ".bak")

stopifnot(file.exists(cv_path), file.exists(match_report), file.exists(summaries_txt))

# --- helpers ---------------------------------------------------------------

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

# --- load match report ----------------------------------------------------

mr <- read.csv(match_report, stringsAsFactors = FALSE)
pdf_by_idx <- setNames(mr$slug, mr$idx)
pdf_status <- setNames(mr$status, mr$idx)

# --- parse summaries doc into title/body pairs ---------------------------

raw <- readLines(summaries_txt, warn = FALSE)
# split into blocks separated by blank lines
is_blank <- !nzchar(trimws(raw))
block_id <- cumsum(is_blank)
blocks <- split(raw[!is_blank], block_id[!is_blank])
blocks <- lapply(blocks, function(b) paste(trimws(b), collapse = " "))
blocks <- unname(blocks)

# Pattern: [year]? [title] [summary] [title] [summary] [year] [title] ...
# Year line is a bare 4-digit number. Title is a single block. Summary is a
# single block that follows a title.
summaries <- list()
i <- 1
last_was_title <- FALSE
last_title <- NULL
while (i <= length(blocks)) {
  b <- blocks[[i]]
  if (grepl("^\\d{4}$", b)) {
    last_was_title <- FALSE
  } else if (!last_was_title) {
    last_title <- b
    last_was_title <- TRUE
  } else {
    summaries[[length(summaries) + 1]] <- list(title = last_title, body = b)
    last_was_title <- FALSE
  }
  i <- i + 1
}
cat(sprintf("Parsed %d summaries from %s\n", length(summaries), summaries_txt))

# --- load cv_data.yaml to get publication titles in order ----------------

cv <- yaml::read_yaml(cv_path)
pub_titles <- sapply(cv$publications, function(p) p$title)

# --- match each summary to best pub idx ----------------------------------

summary_by_idx <- list()  # idx -> body
for (s in summaries) {
  st <- tokens(s$title)
  scores <- sapply(pub_titles, function(t) jaccard(st, tokens(t)))
  best <- which.max(scores)
  if (scores[best] >= 0.40) {
    summary_by_idx[[as.character(best)]] <- list(
      body = s$body,
      score = round(scores[best], 3),
      summary_title = s$title,
      yaml_title = pub_titles[best]
    )
  } else {
    cat(sprintf("  [skip] '%s' best score %.2f against '%s'\n",
                substr(s$title, 1, 60), scores[best], substr(pub_titles[best], 1, 60)))
  }
}
cat(sprintf("Matched %d summaries to publications\n", length(summary_by_idx)))

# --- surgical text insertion into cv_data.yaml ---------------------------

lines <- readLines(cv_path, warn = FALSE)

# locate publications block
pub_start <- which(lines == "publications:")[1]
stopifnot(!is.na(pub_start))

# find next top-level key after publications (or end of file)
top_level_re <- "^[a-zA-Z_][a-zA-Z0-9_]*:"
post_pub_idx <- which(grepl(top_level_re, lines))
post_pub_idx <- post_pub_idx[post_pub_idx > pub_start]
pub_end <- if (length(post_pub_idx) > 0) post_pub_idx[1] - 1 else length(lines)

# find each pub entry boundary inside [pub_start+1, pub_end]
entry_start_lines <- which(grepl("^- title:", lines))
entry_start_lines <- entry_start_lines[entry_start_lines > pub_start &
                                       entry_start_lines <= pub_end]
stopifnot(length(entry_start_lines) == length(cv$publications))

# end of each entry = line before next entry start (or pub_end)
entry_end_lines <- c(entry_start_lines[-1] - 1, pub_end)

# build insertions per idx
insertions <- list()  # list of (after_line, lines_to_insert)
for (i in seq_along(cv$publications)) {
  ek <- as.character(i)
  add <- character(0)
  if (!is.na(pdf_by_idx[ek]) && pdf_status[ek] == "matched") {
    add <- c(add, sprintf("  pdf: pubs/%s.pdf", pdf_by_idx[ek]))
  }
  if (!is.null(summary_by_idx[[ek]])) {
    body <- summary_by_idx[[ek]]$body
    # YAML literal block scalar; one line of body. Wrap softly.
    add <- c(add, "  plain_summary: |", paste0("    ", body))
  }
  if (length(add) > 0) {
    insertions[[length(insertions) + 1]] <- list(
      after = entry_end_lines[i],
      lines = add
    )
  }
}

# apply insertions in reverse so line numbers stay valid
insertions <- insertions[order(sapply(insertions, function(x) x$after), decreasing = TRUE)]
new_lines <- lines
for (ins in insertions) {
  new_lines <- append(new_lines, ins$lines, after = ins$after)
}

# backup + write
file.copy(cv_path, backup_path, overwrite = TRUE)
writeLines(new_lines, cv_path)

# --- summary --------------------------------------------------------------

n_pdf <- sum(pdf_status == "matched", na.rm = TRUE)
n_sum <- length(summary_by_idx)
both  <- sum(sapply(seq_along(cv$publications), function(i) {
  k <- as.character(i)
  isTRUE(pdf_status[k] == "matched") && !is.null(summary_by_idx[[k]])
}))
cat(sprintf("\nAnnotated cv_data.yaml:\n"))
cat(sprintf("  PDFs added:      %d\n", n_pdf))
cat(sprintf("  Summaries added: %d\n", n_sum))
cat(sprintf("  Both pdf+sum:    %d\n", both))
cat(sprintf("Backup at: %s\n", backup_path))
