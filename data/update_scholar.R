# update_scholar.R
# Fetches citation stats from Google Scholar and writes them to scholar_stats.yaml.
#
# Run manually from the website/ directory:
#   Rscript data/update_scholar.R
#
# Also runs automatically via GitHub Actions every Monday morning
# (see .github/workflows/deploy.yml).

library(scholar)
library(yaml)

SCHOLAR_ID <- "_7PlqKYAAAAJ"

cat("Fetching Google Scholar profile for ID:", SCHOLAR_ID, "\n")

profile <- tryCatch(
  get_profile(SCHOLAR_ID),
  error = function(e) {
    message("Error fetching profile: ", conditionMessage(e))
    NULL
  }
)

if (!is.null(profile)) {
  stats <- list(
    total_citations = profile$total_cites,
    h_index         = profile$h_index,
    i10_index       = profile$i10_index,
    last_updated    = format(Sys.Date(), "%Y-%m-%d")
  )

  yaml::write_yaml(stats, "data/scholar_stats.yaml")

  cat(sprintf(
    "Done. Citations: %d | h-index: %d | i10-index: %d\n",
    stats$total_citations,
    stats$h_index,
    stats$i10_index
  ))
} else {
  cat("Update skipped due to fetch error. Existing stats file preserved.\n")
}
