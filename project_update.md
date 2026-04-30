# Website Project Status
Last updated: 2026-03-29

## What is built

Quarto website scaffolded in this directory. All core pages and automation are in place.

**Pages**
- `index.qmd` - Homepage with bio, Scholar stats bar, CTA buttons
- `research.qmd` - Publications grouped by topic, rendered from `data/publications.yaml`
- `cv.qmd` - Placeholder with PDF download button (pending Quarto CV project)
- `media.qmd` - Media appearances rendered from `data/media.yaml`
- `consulting.qmd` - Services description and inquiry form
- `contact.qmd` - Contact info and general form

**Automation**
- `data/update_scholar.R` - Fetches citation stats from Google Scholar (Scholar ID: `_7PlqKYAAAAJ`)
- `data/scholar_stats.yaml` - Cached stats (720 citations, h-index 15, i10-index 23 as of 2026-03-29)
- `.github/workflows/deploy.yml` - Builds site and deploys to GitHub Pages every push to main, plus runs Scholar refresh every Monday at 7am UTC

**Config**
- Theme: cosmo + custom `styles.scss` (Inter font, navy accent)
- `CNAME` set to `huntermartaindale.com`
- Formspree endpoint: `https://formspree.io/f/mykbwyyn` (used in both forms)

## What still needs to be done

**Content (high priority)**
- Replace sample entries in `data/publications.yaml` with real publications
- Add real entries to `data/media.yaml`
- Add headshot at `img/headshot.jpg`

**CV page**
- Build Quarto CV (separate project, in progress)
- Once built, integrate into this site - see the three options commented in `cv.qmd`

**Deployment (one-time setup)**
1. Create a new GitHub repo (e.g., `huntermartaindale/website`)
2. Push the contents of this directory to the repo's `main` branch
3. In repo Settings > Pages, set Source to "GitHub Actions"
4. Add `huntermartaindale.com` as the custom domain in Settings > Pages
5. In Google Domains, add these DNS A records pointing to GitHub Pages:
   - `185.199.108.153`
   - `185.199.109.153`
   - `185.199.110.153`
   - `185.199.111.153`
   - Also add a CNAME record: `www` pointing to `huntermartaindale.github.io.`

**Nice-to-have later**
- Update consulting email from `MartaindaleLLC@gmail.com` to domain email once set up
- Per-paper citation counts (currently only showing overall Scholar totals)
- ORCID pull to auto-import new publications to `data/publications.yaml`

## How to preview locally

1. Open `website.Rproj` in RStudio
2. In the terminal: `quarto preview`

## Key file locations

| Purpose | File |
|---|---|
| Site config and nav | `_quarto.yml` |
| Styling | `styles.scss` |
| Add a publication | `data/publications.yaml` |
| Add a media appearance | `data/media.yaml` |
| Refresh Scholar stats manually | `Rscript data/update_scholar.R` |
| Deploy workflow | `.github/workflows/deploy.yml` |
