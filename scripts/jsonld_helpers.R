# Helpers for generating ScholarlyArticle JSON-LD blocks from the
# publications.yaml records. Sourced from research.qmd and index.qmd.
#
# The output is one `<script type="application/ld+json">` per call to
# emit_publications_jsonld(), wrapping a schema.org @graph of
# ScholarlyArticle objects. Each author becomes a Person; Hunter is
# identified by url + ORCID so Google can link the article authorship
# back to the home page Person entity.

`%||%` <- function(a, b) if (!is.null(a)) a else b

.has_val <- function(x) {
  !is.null(x) && length(x) > 0 && !(is.atomic(x) && length(x) == 1 && is.na(x)) && nzchar(as.character(x))
}

# Split a CV-style author string into individual "First I. Last" names.
# Input examples:
#   "Tanksley, P. T., Barnes, J. C., Blair, J. P., & Martaindale, M. H."
#   "*Eleuterio-da-Rocha, J., Tanksley, P. T., Blair, J. P."
# Strategy: the only reliable shape across the dataset is
#   [optional *][Last name],[ ][initial(s)]
# so we regex-match author chunks rather than splitting on commas.
parse_authors <- function(authors_str) {
  if (!.has_val(authors_str)) return(character(0))
  s <- as.character(authors_str)
  pattern <- "\\*?[A-Z][A-Za-z'\\-]+,\\s+[A-Z]\\.(?:\\s*[A-Z]\\.)*"
  matches <- regmatches(s, gregexpr(pattern, s, perl = TRUE))[[1]]
  if (length(matches) == 0) return(character(0))
  vapply(matches, function(m) {
    m <- sub("^\\*", "", m)
    parts <- strsplit(m, ",\\s+", perl = TRUE)[[1]]
    if (length(parts) == 2) paste(trimws(parts[2]), trimws(parts[1])) else m
  }, character(1), USE.NAMES = FALSE)
}

# Convert author names to a list of Person objects. Hunter gets a url
# and ORCID sameAs so Google can connect the authorship to the Person
# entity declared on the home page.
build_author_objects <- function(authors_str) {
  names <- parse_authors(authors_str)
  if (length(names) == 0) return(NULL)
  lapply(names, function(n) {
    if (grepl("Martaindale", n, fixed = TRUE)) {
      list(
        `@type` = "Person",
        name    = "M. Hunter Martaindale",
        url     = "https://huntermartaindale.com",
        sameAs  = "https://orcid.org/0000-0002-8100-7698"
      )
    } else {
      list(`@type` = "Person", name = n)
    }
  })
}

# Map our internal topic slugs to plain-English keywords for schema.org
.topic_keywords <- c(
  "active-shooter"          = "Active shooter events",
  "policing-stress"         = "Officer stress and performance",
  "policing-decisions"      = "Decision making and use of force",
  "policing-public-opinion" = "Public opinion of police",
  "other"                   = "Criminology"
)

build_scholarly_article <- function(pub) {
  obj <- list(
    `@type`       = "ScholarlyArticle",
    headline      = pub$title,
    name          = pub$title,
    datePublished = as.character(pub$year),
    author        = build_author_objects(paste(unlist(pub$authors), collapse = ", "))
  )

  if (.has_val(pub$journal)) {
    obj$isPartOf <- list(`@type` = "Periodical", name = pub$journal)
  }
  if (.has_val(pub$volume)) obj$volumeNumber <- as.character(pub$volume)
  if (.has_val(pub$issue))  obj$issueNumber  <- as.character(pub$issue)
  if (.has_val(pub$pages))  obj$pagination   <- as.character(pub$pages)

  if (.has_val(pub$doi)) {
    obj$identifier <- list(
      `@type`    = "PropertyValue",
      propertyID = "doi",
      value      = pub$doi
    )
    obj$url    <- paste0("https://doi.org/", pub$doi)
    obj$sameAs <- paste0("https://doi.org/", pub$doi)
  }

  if (.has_val(pub$plain_summary)) {
    obj$abstract <- trimws(gsub("\\s+", " ", pub$plain_summary))
  }

  if (.has_val(pub$topics)) {
    slugs <- unlist(pub$topics)
    kws <- unname(.topic_keywords[slugs])
    kws <- kws[!is.na(kws)]
    if (length(kws) > 0) obj$keywords <- paste(kws, collapse = ", ")
  }

  obj
}

# Emit a complete <script type="application/ld+json"> block for a list of
# publication records. Call from inside an R chunk with `results: asis`.
emit_publications_jsonld <- function(pubs) {
  if (length(pubs) == 0) return(invisible())
  graph <- lapply(pubs, build_scholarly_article)
  doc <- list(`@context` = "https://schema.org", `@graph` = graph)
  json <- jsonlite::toJSON(doc, auto_unbox = TRUE, pretty = FALSE, null = "null", na = "null")
  cat('<script type="application/ld+json">\n')
  cat(as.character(json))
  cat('\n</script>\n')
}
