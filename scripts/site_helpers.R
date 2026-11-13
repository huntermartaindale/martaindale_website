# Shared rendering helpers for index.qmd, research.qmd and grants.qmd.
#
# Presentation only: everything here reads the auto-generated data files
# (data/publications.yaml, data/grants.yaml, data/scholar_stats.yaml) and
# turns them into HTML. Nothing here writes data, so the CV -> website sync
# pipeline is unaffected.
#
# Requires scripts/topic_labels.R to be sourced first.

`%||%` <- function(a, b) if (!is.null(a)) a else b

has_val <- function(x) {
  !is.null(x) && length(x) > 0 && !(is.atomic(x) && length(x) == 1 && is.na(x))
}

esc <- function(x) {
  if (is.null(x)) return("")
  x <- as.character(x)
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x
}

first_sentences <- function(text, n = 2) {
  if (!has_val(text)) return("")
  text <- gsub("\\s+", " ", trimws(text))
  matches <- regmatches(text, gregexpr("[^.!?]*[.!?]", text))[[1]]
  if (length(matches) == 0) return(text)
  paste(trimws(matches[seq_len(min(n, length(matches)))]), collapse = " ")
}

fmt_money <- function(x) {
  if (!has_val(x)) return("")
  paste0("$", formatC(as.numeric(x), format = "d", big.mark = ","))
}

# Compact dollars for headline figures: $1,985,780 -> "$2.0M".
fmt_money_short <- function(x) {
  x <- as.numeric(x)
  if (x >= 1e6) return(sprintf("$%.1fM", x / 1e6))
  if (x >= 1e3) return(sprintf("$%.0fK", x / 1e3))
  fmt_money(x)
}

# Stable anchor id for every publication, in the same order as `pubs`.
# Built from year + title so links from the home page chart land on the
# matching entry on the research page. Duplicate titles in the same year
# get a numeric suffix.
pub_ids <- function(pubs) {
  raw <- vapply(pubs, function(p) {
    slug <- tolower(iconv(p$title %||% "untitled", to = "ASCII//TRANSLIT", sub = ""))
    slug <- gsub("[^a-z0-9]+", "-", slug)
    slug <- gsub("^-+|-+$", "", slug)
    slug <- sub("-+$", "", substr(slug, 1, 48))
    paste0("pub-", p$year %||% "nd", "-", slug)
  }, character(1))
  make.unique(raw, sep = "-")
}

pub_topics <- function(pub) {
  if (has_val(pub$topics)) unlist(pub$topics) else character(0)
}

pub_primary_topic <- function(pub) {
  t <- pub_topics(pub)
  if (length(t) > 0) t[1] else "other"
}

pub_authors_str <- function(pub) paste(unlist(pub$authors), collapse = ", ")

# "Journal, 12(3), 45-67" with whichever parts exist.
pub_journal_str <- function(pub, pages = TRUE) {
  j <- pub$journal %||% ""
  if (has_val(pub$volume)) j <- paste0(j, ", ", pub$volume)
  if (has_val(pub$issue))  j <- paste0(j, "(", pub$issue, ")")
  if (pages && has_val(pub$pages)) j <- paste0(j, ", ", pub$pages)
  j
}

# Bold the site owner's name inside an author string, as the CV does.
highlight_author <- function(authors_str) {
  gsub("Martaindale, M. H.", "<strong>Martaindale, M. H.</strong>", authors_str, fixed = TRUE)
}

topic_tag_html <- function(slug) {
  label <- topic_label_for(slug)
  if (is.na(label)) label <- "Research"
  sprintf('<span class="topic-tag" data-topic="%s"><i aria-hidden="true"></i>%s</span>',
          esc(slug), esc(label))
}

# One publication as an editorial row.
#   id          anchor id (research page) or NULL
#   href        if set, the title links there (home page -> research page)
#   sentences   NULL for the full plain-language summary, or a sentence count
#   citations   show the Google Scholar citation count
render_pub_row <- function(pub, id = NULL, href = NULL, sentences = NULL, citations = TRUE) {
  links <- character(0)
  if (has_val(pub$doi))
    links <- c(links, sprintf('<a href="https://doi.org/%s">DOI</a>', pub$doi))
  if (has_val(pub$pdf))
    links <- c(links, sprintf('<a href="%s">PDF</a>', pub$pdf))
  if (has_val(pub$preprint))
    links <- c(links, sprintf('<a href="%s">Preprint</a>', pub$preprint))

  authors_str <- pub_authors_str(pub)
  journal_str <- pub_journal_str(pub)
  slugs <- pub_topics(pub)

  tags_html <- ""
  if (length(slugs) > 0)
    tags_html <- sprintf('<div class="pub-topics">%s</div>',
                         paste(vapply(slugs, topic_tag_html, character(1)), collapse = ""))

  summary_html <- ""
  if (has_val(pub$plain_summary)) {
    txt <- if (is.null(sentences)) trimws(pub$plain_summary) else first_sentences(pub$plain_summary, sentences)
    summary_html <- sprintf('<div class="pub-summary"><p>%s</p></div>', txt)
  }

  cite_html <- ""
  if (citations && has_val(pub$citations) && as.integer(pub$citations) > 0)
    cite_html <- sprintf('<span class="pub-citations">Cited %d times (Google Scholar)</span>',
                         as.integer(pub$citations))

  links_html <- ""
  if (length(links) > 0)
    links_html <- sprintf('<div class="pub-links">%s</div>', paste(links, collapse = ""))

  title_html <- pub$title
  if (!is.null(href)) title_html <- sprintf('<a href="%s">%s</a>', esc(href), pub$title)

  search_text <- tolower(paste(pub$title, authors_str, journal_str, pub$year, sep = " "))

  htmltools::HTML(sprintf(
    '<article class="pub-row"%s data-topic="%s" data-topics="%s" data-year="%s" data-search="%s">
  <div class="pub-year" aria-hidden="true">%s</div>
  <div class="pub-body">
    <h3 class="pub-title">%s</h3>
    <p class="pub-meta"><span class="pub-authors">%s</span> <span class="pub-journal"><em>%s</em> (%s)</span></p>
    %s
  </div>
  <div class="pub-side">
    %s
    %s
    %s
  </div>
</article>',
    if (!is.null(id)) sprintf(' id="%s"', esc(id)) else "",
    esc(pub_primary_topic(pub)),
    esc(paste(slugs, collapse = " ")),
    esc(pub$year),
    esc(search_text),
    esc(pub$year),
    title_html,
    highlight_author(authors_str),
    journal_str,
    pub$year,
    summary_html,
    tags_html,
    links_html,
    cite_html
  ))
}

# Funding totals split by role. Reads grants.yaml (everything except the
# recurring COPS Office PASS awards) and grants_summary.yaml (the PASS
# totals), both written by the CV sync, so the figures follow the CV.
#   pi      grants where the role is PI
#   copi    everything else: PASS awards plus any non-PI grant in grants.yaml
grant_funding <- function(grants, summary_stats) {
  amt   <- vapply(grants, function(g) as.numeric(g$amount %||% 0), numeric(1))
  is_pi <- vapply(grants, function(g) identical(g$role %||% "", "PI"), logical(1))
  pass_total <- as.numeric(summary_stats$pass_total %||% 0)
  pass_count <- as.integer(summary_stats$pass_count %||% 0)
  list(
    pi_total     = sum(amt[is_pi]),
    pi_count     = sum(is_pi),
    copi_total   = sum(amt[!is_pi]) + pass_total,
    copi_count   = sum(!is_pi) + pass_count,
    other_copi   = sum(!is_pi),
    pass_total   = pass_total,
    pass_count   = pass_count,
    total        = sum(amt) + pass_total
  )
}

# Row of headline figures. `items` is a list of list(value, label, href,
# note); `note` is an optional second line under the label.
render_stat_band <- function(items, caption = NULL) {
  cells <- vapply(items, function(it) {
    inner <- sprintf('<span class="stat-value">%s</span><span class="stat-label">%s</span>',
                     it$value, esc(it$label))
    if (!is.null(it$note))
      inner <- paste0(inner, sprintf('<span class="stat-note">%s</span>', esc(it$note)))
    if (!is.null(it$href))
      sprintf('<a class="stat" href="%s">%s</a>', esc(it$href), inner)
    else
      sprintf('<div class="stat">%s</div>', inner)
  }, character(1))
  cap <- if (!is.null(caption)) sprintf('<p class="stat-caption">%s</p>', caption) else ""
  htmltools::HTML(sprintf('<div class="stat-band stat-band-%d" style="--n:%d">%s</div>%s',
                          length(items), length(items), paste(cells, collapse = ""), cap))
}
