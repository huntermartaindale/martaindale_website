# Canonical topic slug -> display label map. Sourced by index.qmd,
# research.qmd, and jsonld_helpers.R so the wording only lives in one place.
#
# Slugs come from data/publications.yaml, assigned either by the keyword
# rules in scripts/sync_publications.R or by a manual `topics:` override
# in cv_data.yaml (the CV repo).
#
# Adding a topic: add a row to both maps below. The research page builds
# its filter pills from the slugs actually present in the data, so a new
# slug gets a pill even if it is missing here (labelled from the slug
# itself) - adding it here is what controls the wording and the ordering.

TOPIC_LABELS <- c(
  "active-shooter"          = "Active Shooter Events",
  "policing-stress"         = "Officer Stress & Performance",
  "policing-decisions"      = "Decision Making & Use of Force",
  "policing-public-opinion" = "Public Opinion & Legitimacy",
  "drones"                  = "Drones",
  "other"                   = "Other"
)

# Plain-English phrasing for schema.org keywords: no ampersands, no
# site-specific shorthand.
TOPIC_KEYWORDS <- c(
  "active-shooter"          = "Active shooter events",
  "policing-stress"         = "Officer stress and performance",
  "policing-decisions"      = "Decision making and use of force",
  "policing-public-opinion" = "Public opinion of police",
  "drones"                  = "Drones and counter-UAS",
  "other"                   = "Criminology"
)

# Label for a single slug. Unknown slugs are title-cased from the slug so a
# newly tagged paper renders readably instead of showing raw kebab-case.
# Returns NA_character_ for an empty/missing slug; callers decide the
# fallback wording.
topic_label_for <- function(slug) {
  if (is.null(slug) || length(slug) == 0 || is.na(slug) || !nzchar(slug))
    return(NA_character_)
  if (slug %in% names(TOPIC_LABELS)) return(unname(TOPIC_LABELS[[slug]]))
  words <- strsplit(gsub("-", " ", slug), "\\s+")[[1]]
  paste(toupper(substring(words, 1, 1)), substring(words, 2), sep = "", collapse = " ")
}

# Every slug used by at least one publication, ordered for display:
# known topics in map order, then any slug not yet in the map, with
# "other" pinned last.
topics_in_use <- function(pubs) {
  present <- unique(unlist(lapply(pubs, function(p) {
    if (is.null(p$topics)) character(0) else unlist(p$topics)
  })))
  present <- present[nzchar(present)]
  known <- setdiff(names(TOPIC_LABELS), "other")
  c(
    intersect(known, present),
    setdiff(present, names(TOPIC_LABELS)),
    intersect("other", present)
  )
}
