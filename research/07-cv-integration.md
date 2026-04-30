# CV Integration: Auto-Update from Your CV Project

You have a working personal CV at `1_claude/cv/` (Quarto project, renders to `cv.pdf` and `cv.html`, driven by `cv_data.yaml`, pulls Scholar citations). The website needs to display that CV without manual file copying. This file covers the architecture options.

## Current state

```
1_claude/                                  # parent monorepo (huntermartaindale/1_claude)
├── cv/                                    # Quarto project, NOT yet its own GitHub repo
│   ├── _quarto.yml
│   ├── cv.qmd                             # source
│   ├── cv_data.yaml                       # YAML data (positions, education, awards, etc.)
│   ├── cv.scss                            # styling
│   ├── cv.pdf                             # rendered PDF
│   ├── cv.html                            # rendered HTML
│   ├── output/cv_citations.rds            # cached Scholar pull
│   └── R/
│       ├── format_entries.R
│       └── fetch_citations.R
└── website/                               # Quarto project, will become its own GitHub repo
    ├── _quarto.yml
    ├── cv.qmd                             # currently a placeholder
    └── ...
```

Both `cv/` and `website/` currently live inside `huntermartaindale/1_claude` but neither is the live website. The website hasn't been pushed to its own repo yet (per your project_update.md).

## What "auto-update" actually means

Three different things this could mean:

1. **Edit `cv_data.yaml`, get an updated PDF and HTML on the website with no manual copying**
2. **Scholar citations refresh weekly without you touching anything**
3. **Add a new publication to your manuscripts and have it appear on both the CV and the website's Research page**

The architecture below handles 1 and 2. Item 3 is a separate problem (one shared `publications.bib` or `publications.yaml` that both projects read), addressed at the end.

## Architectural options

### Option A: Single combined repo (recommended)

Put both Quarto projects into one new GitHub repo, e.g., `huntermartaindale/website`. The CI workflow renders both, then the website's render embeds the CV's outputs.

```
huntermartaindale/website/
├── _quarto.yml                            # website config
├── index.qmd
├── research.qmd
├── cv.qmd                                 # this is the WEBSITE's cv page
├── cv-source/                             # the CV Quarto sub-project
│   ├── _quarto.yml
│   ├── cv.qmd                             # CV source
│   ├── cv_data.yaml
│   ├── cv.scss
│   └── R/
└── .github/workflows/deploy.yml
```

**Workflow:**

1. CI installs R + Quarto + dependencies
2. CI runs `quarto render cv-source/` → produces `cv-source/cv.html` and `cv-source/cv.pdf`
3. CI copies `cv-source/cv.html` → `cv/index.html` and `cv-source/cv.pdf` → `cv/martaindale_cv.pdf` in the website's render output
4. CI runs `quarto render` on the website itself
5. CI deploys the result to `gh-pages`

Live URLs:
- `huntermartaindale.com/cv/` : the HTML CV
- `huntermartaindale.com/cv/martaindale_cv.pdf` : the downloadable PDF

**Strengths:**
- Single repo, single deploy, single source of truth
- One commit can update CV and website together
- No PAT, no cross-repo auth, no secret management
- The `cv.qmd` page in the website can iframe or `{{< include >}}` the CV's content for native styling

**Weaknesses:**
- The CV repo is no longer reusable as a standalone artifact (e.g., if you ever want to share the source with someone else)
- Build time grows by ~30 seconds (the CV render)

This is what I recommend.

### Option B: Two repos, CI clones the CV at build time

`huntermartaindale/cv` is its own repo. `huntermartaindale/website` is its own repo. The website's CI workflow does:

```yaml
- name: Checkout CV repo
  uses: actions/checkout@v4
  with:
    repository: huntermartaindale/cv
    path: _cv-source

- name: Render CV
  run: |
    cd _cv-source
    quarto render

- name: Copy CV outputs into website
  run: |
    mkdir -p cv
    cp _cv-source/cv.html cv/index.html
    cp _cv-source/cv.pdf cv/martaindale_cv.pdf
```

**Strengths:**
- CV repo is a clean standalone artifact
- Can be shared, forked, version-released independently
- Website CI always pulls latest CV main branch

**Weaknesses:**
- Two repos to manage
- Updating CV requires a push to one repo and (if you want immediate website refresh) a trigger to the website's deploy workflow
- Slightly more CI complexity

The "trigger" issue: the website rebuilds on its own pushes, but a push to the CV repo doesn't automatically rebuild the website. Two ways to fix:

- **Repository dispatch:** CV repo's CI sends a `repository_dispatch` event to the website repo, which triggers a rebuild. Requires a PAT stored as a secret in the CV repo. Maybe 20 lines of YAML.
- **Scheduled rebuild:** Website CI runs on a daily cron in addition to push triggers. CV updates show up within 24 hours.

### Option C: Two repos, CV repo deploys independently to a subpath

`huntermartaindale/cv` deploys its own GitHub Pages output to `huntermartaindale.com/cv/` (or a subdomain like `cv.huntermartaindale.com`). The website's `cv.qmd` page is just an iframe or a redirect.

**Strengths:**
- CV is a fully independent deployment
- Website never has to render the CV

**Weaknesses:**
- iframe styling rarely matches the site (font hacks, scroll bar issues)
- A subdomain (`cv.huntermartaindale.com`) needs additional DNS config
- The CV page on the website is functionally a different site, breaks the navbar / footer continuity
- Two GitHub Pages deploys to manage

Not recommended unless you have a strong reason to keep CV deploys fully isolated.

### Option D: GitHub release artifact

CV repo creates a GitHub release on every push to main, attaching `cv.pdf` and `cv.html` as release artifacts. Website CI downloads the latest release on every build.

**Strengths:**
- Versioned CV history (release v1.0, v1.1, etc.)
- Clean separation; no need to render CV in website CI

**Weaknesses:**
- Manual release tagging or extra automation to auto-tag
- Release artifact API can be flaky
- More moving parts than necessary

Useful if you ever need archived versions of the CV (e.g., the version submitted with a specific grant). Otherwise overkill.

## Recommended path: Option A in detail

### Step 1: Move the CV project into the website repo

Create a new GitHub repo `huntermartaindale/website` if you haven't yet. Then:

```bash
# from the website/ directory
cp -r ../cv ./cv-source
# .gitignore the rendered outputs in cv-source so we don't commit them
echo "cv-source/cv.html" >> .gitignore
echo "cv-source/cv.pdf" >> .gitignore
echo "cv-source/_freeze/" >> .gitignore
echo "cv-source/output/cv_citations.rds" >> .gitignore   # or commit the cache, your call
```

### Step 2: Update the website's `cv.qmd`

Two approaches, pick one:

**Approach A1: Iframe the rendered CV**

```yaml
---
title: "Curriculum Vitae"
page-layout: full
---

[Download PDF](martaindale_cv.pdf){.btn .btn-primary style="margin-bottom: 1rem;"}

<iframe src="index-content.html" style="width: 100%; height: 1400px; border: none;"></iframe>
```

Pros: zero styling work, the CV renders exactly as it does standalone.
Cons: iframe is awkward; you don't get the website's navbar around it.

**Approach A2: Render the CV directly inside the website's `cv.qmd`**

This requires that the CV's rendering code (R chunks reading `cv_data.yaml`) work inside the website's project. Since both use Quarto + R + similar packages, this is feasible:

```yaml
---
title: "Curriculum Vitae"
toc: true
toc-location: right
---

[Download PDF](martaindale_cv.pdf){.btn .btn-primary style="margin-bottom: 1rem;"}

```{r}
#| label: load-cv
#| echo: false

source("cv-source/R/format_entries.R")
cv <- yaml::read_yaml("cv-source/cv_data.yaml")
# ... existing rendering code from cv-source/cv.qmd
```

(rest of the CV body, copied or `{{< include >}}`d from cv-source/cv.qmd)
```

Pros: native website styling, navbar and footer wrap the CV, single page.
Cons: requires either copying the CV's R code into the website's render, or using Quarto's `{{< include cv-source/cv-body.qmd >}}` shortcode to inline the CV content. Refactor the CV to put the body content in `cv-source/cv-body.qmd` and have both `cv-source/cv.qmd` (standalone) and `website/cv.qmd` include that body.

A2 is cleaner long-term. A1 ships faster.

### Step 3: Update the GitHub Actions workflow

```yaml
name: Deploy

on:
  push:
    branches: [main]
  schedule:
    - cron: "0 7 * * 1"   # Monday 7am UTC for Scholar refresh

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - uses: quarto-dev/quarto-actions/setup@v2

      - name: Install R packages
        run: |
          Rscript -e 'install.packages(c("yaml", "scholar", "htmltools", "dplyr", "purrr", "stringr", "knitr", "rmarkdown"))'

      - name: Refresh Scholar stats (website)
        run: Rscript data/update_scholar.R

      - name: Refresh Scholar citations (CV)
        run: |
          cd cv-source
          Rscript -e 'source("R/fetch_citations.R"); update_citation_data()'

      - name: Render CV (HTML + PDF)
        run: |
          cd cv-source
          quarto render

      - name: Copy CV outputs to website paths
        run: |
          mkdir -p cv
          cp cv-source/cv.html cv/cv-content.html
          cp cv-source/cv.pdf cv/martaindale_cv.pdf

      - name: Render website
        run: quarto render

      - name: Deploy to gh-pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_site
          cname: huntermartaindale.com
```

Key additions to your existing workflow:
- Render CV before website
- Copy CV outputs into the right place

The website's `cv.qmd` then references `martaindale_cv.pdf` (PDF download) and `cv-content.html` (if you go with the iframe approach).

### Step 4: Decide what to commit vs render in CI

Two options:

**Commit rendered outputs (simpler).** Run `quarto render` on the CV locally, commit `cv.pdf` and `cv.html` along with the source. CI just copies the committed files into place. Faster builds but you have to remember to render before committing.

**Render in CI (cleaner).** CI renders the CV from scratch every time. Slower builds but always reflects the latest source. Recommended.

The PDF render in CI requires LaTeX, which means your workflow needs to install TinyTeX:

```yaml
- name: Install LaTeX
  run: |
    quarto install tinytex --update-path
```

Or use `r-lib/actions/setup-tinytex@v2`. Either works.

### Step 5: Repo layout after migration

```
huntermartaindale/website/
├── _quarto.yml
├── index.qmd
├── research.qmd
├── cv.qmd                        # website CV page (iframe or include)
├── media.qmd
├── consulting.qmd
├── contact.qmd
├── styles.scss
├── CNAME
├── data/
│   ├── publications.yaml
│   ├── media.yaml
│   ├── scholar_stats.yaml
│   └── update_scholar.R
├── img/
│   └── headshot.jpg
├── pubs/                         # paper PDFs
├── cv-source/                    # the CV Quarto sub-project
│   ├── _quarto.yml
│   ├── cv.qmd                    # CV body
│   ├── cv-body.qmd               # extractable shared body (if using include)
│   ├── cv_data.yaml
│   ├── cv.scss
│   ├── R/
│   │   ├── format_entries.R
│   │   └── fetch_citations.R
│   └── output/                   # gitignored, rebuilt in CI
└── .github/workflows/deploy.yml
```

## Handling shared publications data (the deeper problem)

Right now, you'd have two YAML files:
- `cv-source/cv_data.yaml` (full CV data)
- `data/publications.yaml` (website publications)

These describe overlapping content (publications appear in both). Three ways to keep them in sync:

### Approach 1: Single canonical source

Maintain only `cv-source/cv_data.yaml`. Write an R script that extracts the publications block and produces `data/publications.yaml`. Run it in CI before the website render.

```r
# scripts/sync_publications.R
cv <- yaml::read_yaml("cv-source/cv_data.yaml")
pubs <- cv$peer_reviewed_publications  # whatever the key is

# Transform to website format
website_pubs <- lapply(pubs, function(p) {
  list(
    title = p$title,
    authors = p$authors,
    year = p$year,
    journal = p$venue,
    doi = p$doi,
    plain_summary = p$plain_summary,
    topics = p$topics
  )
})

yaml::write_yaml(website_pubs, "data/publications.yaml")
```

Pros: single source of truth, no drift.
Cons: requires defining the schema once and maintaining the transform script. Plain-language summaries and topic tags need to live in `cv_data.yaml` even though the CV doesn't display them. (You can hide them from CV rendering with simple filtering.)

### Approach 2: Two sources, lockstep updates

Update both files when adding a paper. Discipline-based, error-prone.

### Approach 3: BibTeX as canonical

Maintain a single `publications.bib` file. Both projects read from it. The website adds plain-language summaries and topics in a separate sidecar YAML keyed by BibTeX key. The CV reads BibTeX directly via the `RefManageR` or `bibtex` R packages.

**Recommendation:** Approach 1 (single canonical source in `cv_data.yaml`). It's the lowest-friction path that prevents drift. Approach 3 is more elegant but requires more upfront engineering.

## Scholar citation cache

Both the website (`data/scholar_stats.yaml` for the homepage stat bar) and the CV (`cv-source/output/cv_citations.rds` for per-paper counts) hit Google Scholar. To avoid double rate-limiting:

- Have one of them refresh and write to a shared cache file
- Have the other read from that cache

In CI:

```yaml
- name: Refresh Scholar (one shared pull)
  run: Rscript scripts/refresh_scholar.R
```

The script writes both `data/scholar_stats.yaml` and `cv-source/output/cv_citations.rds` from a single Scholar fetch. Reduces rate limit risk and keeps the two views consistent.

## Summary

- **Recommended:** Option A (single combined repo). Your CV project moves to `cv-source/` inside the website repo. CI renders the CV first, copies outputs into a `cv/` subdirectory, then renders the website around it.
- **Single source of truth for publications** via `cv_data.yaml`, with an R sync script producing `data/publications.yaml`.
- **One Scholar pull** in CI shared between CV and website.
- **Build time** roughly 2 to 4 minutes including LaTeX install.
- **Live URLs:** CV at `huntermartaindale.com/cv/`, PDF download at `huntermartaindale.com/cv/martaindale_cv.pdf`.
- **Update flow:** edit `cv-source/cv_data.yaml` (or `cv-source/cv.qmd`), commit, push. Site rebuilds. CV and Research page both reflect the change within ~3 minutes.

If you want, the next step is to scaffold the `cv-source/` move and the updated `deploy.yml` so you can push everything once the CV is finished.
