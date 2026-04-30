#!/usr/bin/env Rscript
# scripts/sync_publications.R
#
# Generates data/publications.yaml from the canonical source of truth
# (cv_data.yaml in the huntermartaindale/cv repo). Edit cv_data.yaml,
# not data/publications.yaml.
#
# Usage:
#   Rscript scripts/sync_publications.R [path/to/cv_data.yaml]
#
# Defaults:
#   - In CI, cv repo is checked out to cv-source/, so default input is
#     cv-source/cv_data.yaml.
#   - Locally from website/, run: Rscript scripts/sync_publications.R ../cv/cv_data.yaml

suppressPackageStartupMessages({
  library(yaml)
})

# --- helpers --------------------------------------------------------------

`%||%` <- function(a, b) if (!is.null(a)) a else b

# Drop fields that are NULL or NA so yaml output is clean (no `~` placeholders)
drop_empty <- function(lst) {
  keep <- sapply(lst, function(x) {
    !is.null(x) && !(length(x) == 1 && is.atomic(x) && is.na(x))
  })
  lst[keep]
}

# --- args -----------------------------------------------------------------

args        <- commandArgs(trailingOnly = TRUE)
input_path  <- if (length(args) >= 1) args[1] else "cv-source/cv_data.yaml"
output_path <- "data/publications.yaml"

if (!file.exists(input_path)) {
  stop("CV data file not found: ", input_path)
}

cat("Reading", input_path, "\n")
cv <- yaml::read_yaml(input_path)

if (is.null(cv$publications) || length(cv$publications) == 0) {
  stop("No publications found in ", input_path)
}

# --- topic tagging --------------------------------------------------------
# Priority order: policing-public-opinion > active-shooter > policing-stress
#                 > policing-decisions > other
# Public-opinion is checked first so papers explicitly studying public
# attitudes don't get swallowed by active-shooter just because they study
# attitudes about an active-shooter scenario.
# Override per-paper by adding a `topics:` field directly in cv_data.yaml.

topic_keywords <- list(
  `policing-public-opinion` = c(
    "public opinion", "public perception", "legitimacy",
    "community trust", "perception of police", "perceptions of police",
    "civilians' perception", "civilians perception",
    "attitudes toward", "attitudes about", "officers' attitudes",
    "officer attitudes", "view their role",
    "comparing public", "public and officer"
  ),
  `active-shooter` = c(
    "active shooter", "active attack", "active killer", "active shooting",
    "school shooter", "school shoot", "mass shooter", "mass shoot",
    "lockdown", "barricade", "rapid response",
    "rifle", "ballistic", "tactical training",
    "room entry", "room clearing", "entry technique", "entry system",
    "school safety", "k-12", "junior college", "campus safety",
    "armed teacher", "arm the educators", "armed civilian",
    "definitional confusion", "false flag", "robb elementary",
    "chain of survival", "active shooter response"
  ),
  `policing-stress` = c(
    "stress", "cortisol", "physiolog", "biomarker",
    "fitness", "cardiovascular", "heart rate",
    "sleep", "fatigue", "wellness", "firefighter",
    "anxiety", "mortality", "psychophysiolog",
    "blood pressure", "metabolic", "inflammation",
    "cardiometabolic", "cardiorespiratory", "salivary"
  ),
  `policing-decisions` = c(
    "use of force", "decision-making", "decision making",
    "shoot/no-shoot", "shoot no shoot",
    "split-second", "judgment", "lethal", "deadly force",
    "21-foot", "21 foot", "low light",
    "firearm identification", "officer accuracy", "suspect accuracy",
    "swear", "throw a chair", "chair could save",
    "interrogation", "interview"
  )
)

assign_topic <- function(title, venue) {
  text <- tolower(paste(title %||% "", venue %||% ""))
  for (topic in names(topic_keywords)) {
    pats <- topic_keywords[[topic]]
    if (any(sapply(pats, function(k) grepl(k, text, fixed = TRUE)))) {
      return(topic)
    }
  }
  "other"
}

# --- transform ------------------------------------------------------------
# Only peer-reviewed journal articles appear on the website. Book chapters,
# reports, conference proceedings, etc. are tracked in the CV but excluded
# here.

pubs_pr <- Filter(function(p) identical(p$type, "journal_article"), cv$publications)

out <- lapply(pubs_pr, function(p) {
  # Respect a manual topic override if cv_data.yaml provides one
  topic <- if (!is.null(p$topics)) p$topics[[1]] else assign_topic(p$title, p$venue)

  entry <- list(
    title         = p$title,
    authors       = list(p$authors),     # site renderer paste()s a list
    year          = as.integer(p$year),
    journal       = p$venue,
    volume        = p$volume,
    issue         = p$issue,
    pages         = p$pages,
    doi           = p$doi,
    pdf           = p$pdf,                # NULL unless explicitly set in CV
    preprint      = p$preprint,
    plain_summary = p$plain_summary,      # NULL until summaries are added
    topics        = list(topic),
    citations     = p$citations
  )
  drop_empty(entry)
})

# --- write ----------------------------------------------------------------

header <- c(
  "# publications.yaml",
  "# AUTO-GENERATED from cv_data.yaml by scripts/sync_publications.R",
  "# Edit cv_data.yaml in huntermartaindale/cv, not this file.",
  "#",
  paste0("# Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  paste0("# Source:    ", input_path),
  paste0("# Total:     ", length(out), " publications"),
  ""
)

yaml_str <- yaml::as.yaml(out, indent = 2)
writeLines(c(header, yaml_str), output_path)

# --- summary --------------------------------------------------------------

topic_counts <- table(sapply(out, function(p) p$topics[[1]]))
cat(sprintf("\nWrote %d publications to %s\n", length(out), output_path))
cat("Topic distribution:\n")
for (t in names(topic_counts)) {
  cat(sprintf("  %-25s %d\n", t, topic_counts[[t]]))
}
