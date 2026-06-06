# update_scholar.R
# Fetches citation stats from Google Scholar and writes them to scholar_stats.yaml.
# If the fetch fails (rate limit, network error, unexpected response), the
# existing scholar_stats.yaml is preserved and the script exits 0.
#
# Run manually from the website/ directory:
#   Rscript data/update_scholar.R
#
# Also runs automatically via GitHub Actions every Monday morning
# (see .github/workflows/deploy.yml).

suppressPackageStartupMessages({
  library(scholar)
  library(yaml)
})

SCHOLAR_ID <- "_7PlqKYAAAAJ"
OUT_PATH   <- "data/scholar_stats.yaml"

# Emit a GitHub Actions workflow annotation (warning/error) when running in CI.
# Locally these env vars are unset, so this is a no-op and the script stays quiet.
emit_ci <- function(level, msg) {
  if (Sys.getenv("GITHUB_ACTIONS") == "true") {
    cat(sprintf("::%s::%s\n", level, msg))
    summary_file <- Sys.getenv("GITHUB_STEP_SUMMARY")
    if (nzchar(summary_file)) {
      cat(sprintf("- **Scholar update %s:** %s\n", level, msg),
          file = summary_file, append = TRUE)
    }
  }
}

cat("Fetching Google Scholar profile for ID:", SCHOLAR_ID, "\n")

result <- tryCatch({
  profile <- get_profile(SCHOLAR_ID)

  # scholar::get_profile() is supposed to return a list. When Scholar
  # rate-limits or returns malformed HTML it can come back as an atomic
  # vector or with NULL fields, so guard explicitly.
  if (!is.list(profile)) {
    stop("Unexpected response type: ", class(profile)[1])
  }
  required <- c("total_cites", "h_index", "i10_index")
  missing <- setdiff(required, names(profile))
  if (length(missing) > 0) {
    stop("Profile missing fields: ", paste(missing, collapse = ", "))
  }

  list(
    total_citations = as.integer(profile$total_cites),
    h_index         = as.integer(profile$h_index),
    i10_index       = as.integer(profile$i10_index),
    last_updated    = format(Sys.Date(), "%Y-%m-%d")
  )
}, error = function(e) {
  message("Scholar fetch failed: ", conditionMessage(e))
  NULL
})

if (!is.null(result)) {
  yaml::write_yaml(result, OUT_PATH)
  cat(sprintf(
    "Done. Citations: %d | h-index: %d | i10-index: %d\n",
    result$total_citations, result$h_index, result$i10_index
  ))
} else {
  # Fetch failed (Google Scholar commonly blocks datacenter / CI IPs). The old
  # stats file is preserved so the build still succeeds, but the failure is now
  # visible as a CI warning. The workflow's staleness guard escalates to a hard
  # failure (red run + email) once the cached stats age past the threshold.
  cat("Update skipped. Existing", OUT_PATH, "preserved.\n")
  emit_ci("warning",
          "Google Scholar fetch failed; preserving cached stats. If this persists, Scholar is blocking the runner IP. Refresh locally with 'Rscript data/update_scholar.R' and commit.")
}
