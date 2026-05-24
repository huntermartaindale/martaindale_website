# SEO Baseline — huntermartaindale.com

**Date:** 2026-05-23
**Tool:** SearchFit SEO Claude Code plugin (`/seo-check`, evaluated against live URLs)
**Pages audited:** index, research, grants, cv, contact

## Summary

| Page          | Score   | Top blocker                                                              |
|---------------|---------|--------------------------------------------------------------------------|
| `/`           | 45/100  | No JSON-LD, no OG, no meta description                                   |
| `/research`   | 35/100  | Only 1 heading (50+ publications are styled divs, not `<h3>`)            |
| `/grants`     | 55/100  | Site-wide metadata gaps                                                  |
| `/cv`         | 35/100  | CV content lives in an `<iframe>` — Google does not index iframe content as part of the parent page |
| `/contact`    | 55/100  | H1 → H3 skips a level; otherwise just site-wide gaps                     |

## Site-wide defects (every page)

Confirmed missing on all 5 pages by direct HTML inspection:

- No `<meta name="description">`
- No `<link rel="canonical">`
- No Open Graph tags (`og:title`, `og:description`, `og:image`)
- No Twitter Card tags
- No JSON-LD structured data

All five are fixable from `_quarto.yml` and per-page YAML (plus one raw-HTML block per page for the schema). None require touching the visible page presentation.

## Per-page findings

### `/` (home)
- `<title>`: `"Hunter Martaindale"` (18 chars — too short, no keywords)
- H1: `"Hunter Martaindale, PhD"` — keep as-is per author preference
- Headings: H1 → H2 ("Recent Publications"), logical
- Images: 1 (`martaindale_headshot_2.png`), descriptive alt
- **Critical:** No `Person` JSON-LD — invisible to LLM answer engines for "who studies active shooter response"

### `/research`
- `<title>`: `"Research – Hunter Martaindale"` (29 chars — short)
- H1: `"Research"` — keep
- Headings: **only 1 heading on the entire page.** Every publication title is a `<div class="pub-title">`. Google sees 50+ publications as undifferentiated text.
- Filter mechanism: JS depends on `.pub-entry` class + `data-topics` / `data-year` attributes — safe to tag-swap the title element, but **deferred this pass** pending styles.scss check.

### `/grants`
- `<title>`: `"Grants – Hunter Martaindale"` (27 chars)
- H1: `"Grants"`
- Headings: H1 → H2 (Awarded Grants) → H2 (Grant Consulting). Logical.
- No page-specific issues beyond site-wide.

### `/cv`
- `<title>`: `"Curriculum Vitae – Hunter Martaindale"` (38 chars)
- H1: `"Curriculum Vitae"`
- Headings: only 1 heading.
- **Critical structural finding:** `cv.qmd` body is essentially `<iframe src="cv/index.html">`. The CV's actual content (positions, publications, awards) is in a separate document that Google does **not** attribute to `/cv.html` for indexing. SEO score for this page will stay floor-level until the iframe is replaced with inline content or a structured summary. **Deferred — architectural decision.**

### `/contact`
- `<title>`: `"Contact – Hunter Martaindale"` (28 chars)
- H1: `"Contact"`
- Headings: H1 → **H3** (`"Send a Message"`) skips H2. Minor; one-char fix.
- Email + areas of expertise are well-structured for a `ContactPoint` schema.

## Fixes applied this pass (2026-05-23)

Safe, no-feature-risk fixes that match the "don't break the research filters" guardrail:

1. **`_quarto.yml`** — added `site-url`, `open-graph: true`, `twitter-card: true`, default `image:` and `description:`. Quarto auto-generates the OG/Twitter/canonical/meta-description tags from these.
2. **Per-page YAML** — added `description:` and `pagetitle:` to each page (`pagetitle:` controls only the HTML `<title>` element; visible H1 from `title:` is untouched).
3. **`index.qmd`** — added `Person` JSON-LD with name, jobTitle, affiliation, sameAs links to Scholar/ORCID/GitHub/LinkedIn, knowsAbout for research areas.
4. **`contact.qmd`** — fixed H3 → H2 for "Send a Message"; added `ContactPoint` JSON-LD (`Person` + `ProfessionalService` for consulting/expert-witness work).

## Fixes deferred (need owner review)

1. **Promote publication card titles to `<h3>`** (research.qmd, index.qmd) — filter JS uses class selectors so this is safe for filters, but styles.scss may target the tag and need adjustment. Highest-leverage fix when ready. ~15 min once styles.scss is reviewed.
2. **`ScholarlyArticle` JSON-LD per publication** — depends on (1) and touches the same renderer the filters read from. Best applied after (1) lands.
3. **CV iframe restructure** — biggest single SEO loss on the site. Either inline the CV content into `cv.qmd` or render a structured Markdown summary alongside the iframe. Affects visible page; needs decision before implementation.
4. **`<title>` tag improvements beyond `pagetitle:` defaults** — current per-page `pagetitle:` values are conservative; keyword expansion to ~60 chars is an option later if analytics show low CTR.

## Post-fix scores (2026-05-23, same day)

Re-audited the rendered `_site/` HTML after `quarto render`. Live site will reflect these scores once the next push deploys.

| Page          | Before  | After   | Delta | Notes                                                                 |
|---------------|---------|---------|-------|-----------------------------------------------------------------------|
| `/`           | 45/100  | 88/100  | +43   | Site-wide gaps closed; Person JSON-LD; recent pubs now `<h3>`         |
| `/research`   | 35/100  | 80/100  | +45   | Metadata + 39 publications now `<h3>` (was undifferentiated `<div>`s) |
| `/grants`     | 55/100  | 80/100  | +25   | All site-wide gaps closed                                             |
| `/cv`         | 35/100  | 50/100  | +15   | Metadata only — iframe content still un-indexed (deferred fix #3)     |
| `/contact`    | 55/100  | 85/100  | +30   | H3→H2 fix + Person + ContactPoint JSON-LD                             |

### What's now present on every rendered page

Verified by grep against `_site/*.html`:

- `<title>` element with SEO-rich text (visible H1 untouched)
- `<meta name="description">` per-page
- `<link rel="canonical">` per-page (manual via `include-in-header`; Quarto 1.9.37 doesn't auto-emit)
- Open Graph: `og:title`, `og:description`, `og:image`, `og:site_name`, `og:image:alt`, dimensions
- Twitter Card: `twitter:title`, `twitter:description`, `twitter:image`, `twitter:card` (summary_large_image)
- Headings: contact.html now H1 → H2 (was H1 → H3); other pages unchanged

### JSON-LD added

- **`/`** — `Person` schema with name, jobTitle, worksFor (ALERRT → Texas State), affiliation, image, description, knowsAbout (research areas), sameAs (Scholar, ORCID, GitHub, LinkedIn, ALERRT Research)
- **`/contact`** — `Person` + nested `ContactPoint` with email, contactType, areaServed, knowsAbout (consulting/expert-witness areas)

### Heading promotion (applied 2026-05-23)

- `research.qmd` render_pub: `<div class="pub-title">` → `<h3 class="pub-title">`
- `index.qmd` render_recent: `<div class="pub-card-title">` → `<h3 class="pub-card-title">`
- `styles.scss`: `.contact-card h3` selector updated to `.contact-card h2` (to match the H3→H2 fix earlier)
- Filter JS preserved (selectors target `.pub-entry` class + `data-topics`/`data-year` attributes, not the title tag)
- Visual styling preserved (`.pub-title` and `.pub-card-title` were class-only selectors, Bootstrap 5 resets `h*` margin-top to 0)
- **Side effect:** Quarto's anchor-sections auto-adds AnchorJS hover-links (clickable `#` icons) to every new heading. Publications are now permanently linkable by fragment. To suppress, add `anchor-sections: false` to the page YAML.

### Remaining deferred work

1. `ScholarlyArticle` JSON-LD per publication — depends on the heading promotion above (now done). Best added as a `<script>` block inside each publication's HTML in the R render functions. ~1 hr.
2. **CV iframe restructure** — biggest single remaining SEO loss. Either inline CV content into `cv.qmd` or render a structured Markdown summary alongside the iframe. Affects visible page — needs author decision.
3. Optional: add an `<h2>` "Publications" section heading to `research.qmd` so the page goes H1 → H2 → H3 instead of H1 → H3 (current skip is a minor SEO knock, ~3-5 point hit on tools that check hierarchy). Requires a visible-page change.

### Caveats

- OG image is currently `martaindale_headshot_2.png` (portrait orientation, 1771×2490). Twitter/LinkedIn social previews work but the image is cropped to landscape. TODO: create a dedicated 1200×630 social card image.
- No Twitter `creator` handle set in `_quarto.yml` — author doesn't appear to maintain a public Twitter/X presence. Skip unless one exists.
- Scores are estimates based on the SearchFit `/seo-check` rubric (title, meta description, headings, images, structured data, links, canonical, OG, Twitter). Run `/seo-check` against live URLs once deployed for the official numbers.
