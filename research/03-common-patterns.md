# Common Patterns

What shows up again and again across well-built academic personal sites.

## Site information architecture

A small, stable set of pages covers ~95% of what academics do online. Adding more pages costs maintenance time without adding visitors.

### The core 5 (every site has these)

1. **Home / About** : bio, photo, what you study, what to read first
2. **Research / Publications** : the actual scholarly output
3. **CV** : either a page or a downloadable PDF
4. **Teaching** (if you teach)
5. **Contact** (or email in footer)

### The common 3 (most have these)

6. **Blog / News** : low-stakes writing, conference updates, paper announcements
7. **Talks / Presentations** : slides + recordings if available
8. **Projects / Software / Data** : non-paper outputs (R packages, datasets, replication code)

### The distinctive ones (pick 0 to 2)

- **Now page** (what you are working on this month, in plain prose)
- **Uses page** (your hardware / software / tools)
- **AI page** (your stance on AI use in scholarship and teaching)
- **Workshops / Consulting** (if you actually do this and want clients)
- **Media / Press** (if you do public-facing commentary)
- **Accessibility commitment**
- **Newsletter signup**

The current `website/` draft has Research, CV, Media, Consulting, Contact. That maps cleanly onto core + 1 distinctive (Consulting) + 1 field-specific (Media, which is appropriate given ALERRT's public profile). Reasonable starting point.

## Homepage patterns

Three homepage archetypes show up.

### Archetype A: "Above-the-fold bio + CTAs" (your current draft, Mahoney, Canelon)

- Photo on the left or top
- Name + title + institution
- 2 to 4 sentence bio
- 2 to 4 buttons : Research, CV, Contact, Talks
- Social icons
- Optional: a stat bar (citations, h-index)

This is the most common pattern in 2026. Works at all career stages. Renders well on phones.

### Archetype B: "Full-text intro" (Heiss, Cunningham)

- Photo + name at top
- A multi-paragraph essay : who I am, what I study, why
- Selected projects or papers below
- No buttons; visitor reads or leaves

Works if you have strong prose voice. Riskier for early-career or busy readers.

### Archetype C: "Latest content stream" (some Hugo Apero sites, blog-forward academics)

- Bio in a sidebar
- Main column: latest blog posts, news, papers
- Visitor lands on the most recent thing first

Works if you publish frequently to the blog. If your blog has 3 posts from 2024, this archetype hurts you.

**Recommendation:** Stick with Archetype A. The current draft already does this and it is the safest pattern.

## Publications page patterns

This is the page that pays for the website. Three patterns dominate.

### Pattern 1: Topic-grouped listing (your current draft)

```
## Topic 1
- paper, paper, paper

## Topic 2
- paper, paper, paper
```

Each paper has: title, authors, journal, year, plain-language summary, DOI / PDF / preprint links, and optionally citation count.

**Strengths**: signals what you study; helps a reader who searched "active shooter response" find the right cluster fast.
**Weaknesses**: papers that span topics need to be duplicated or assigned arbitrarily.

### Pattern 2: Year-sorted listing (Dimmery, most al-folio sites)

```
## 2026
- paper, paper, paper

## 2025
- paper, paper, paper
```

**Strengths**: simplest, most common in CV-style listings; aligns with how journals ask you to format.
**Weaknesses**: visitor cannot quickly scan by topic.

### Pattern 3: Selected + full (Cunningham, Heiss)

- Homepage or research page shows 5 to 8 "selected" papers
- A separate page or a click-to-expand reveals the full list
- Often paired with a CV PDF download

**Strengths**: makes the site feel curated; visitor sees your best work first.
**Weaknesses**: "selected" requires you to actually decide what is selected and update it.

**Recommendation:** Pattern 1 (topic-grouped) is appropriate for your draft because your work has a natural cluster structure (active shooter response, officer stress, decision making, public opinion). Add a "Selected work" feature on the homepage as a 3 to 5 paper highlight reel.

## Per-paper data structure

Sites that survive maintenance store paper metadata in one of two formats.

### YAML (Quarto, Hugo)

```yaml
- title: "..."
  authors: ["Martaindale, H.", "Blair, J.P."]
  year: 2024
  journal: "Police Quarterly"
  volume: 27
  issue: 3
  pages: "245-262"
  doi: "10.1177/..."
  pdf: "/pubs/martaindale_2024_pq.pdf"
  preprint: "https://osf.io/..."
  topics: [active-shooter, training]
  plain_summary: "..."
  citations: 12
```

This is exactly what your current draft uses. It is the right call.

### BibTeX (al-folio, academic-CV, some Hugo themes)

```bibtex
@article{martaindale2024,
  title={...},
  author={Martaindale, H. and Blair, J.P.},
  journal={Police Quarterly},
  year={2024},
  ...
  abstract={...}
}
```

**Strengths over YAML**
- Same file you already use to cite papers in manuscripts
- Updating a paper updates everywhere

**Weaknesses**
- Plain-language summaries are awkward in BibTeX (have to use `note` or custom fields)
- Not as rich for non-paper outputs (datasets, software)

**Recommendation:** YAML is fine. If you want the BibTeX advantage, you could write a small R script that reads `docs/refs.bib` from your projects, joins per-paper plain-language summaries from a separate YAML, and writes `data/publications.yaml`. Best of both worlds.

## Per-paper landing pages

Some sites give every paper a dedicated URL, e.g., `/research/2024-active-shooter-response/`. This page typically includes:

- Full abstract
- All authors with links
- Replication code, data, materials
- Press coverage
- Slide deck
- Suggested citation in BibTeX
- Errata, post-publication updates

**When this is worth doing**
- The paper has unusual replication materials (your simulation studies might qualify)
- The paper has gotten media attention worth aggregating
- You expect the paper to be assigned in courses

**When to skip**
- You publish 4+ papers a year and would have to maintain 20 pages
- The paper is one of many; the listing entry is enough

**Recommendation:** Worth doing for the 5 to 8 highest-impact papers. Skip for everything else. Your existing `pubs/` directory in the draft suggests you were already heading this way.

## Navigation design

**Top nav: 4 to 7 items max.** More than 7 forces a hamburger menu on tablets.

**Order convention** (most common):
1. Research / Publications
2. CV
3. Teaching
4. Talks
5. Blog
6. (something distinctive : Now, Consulting, Media)
7. Contact

**What goes in the right side of the nav**
- GitHub icon
- LinkedIn / Bluesky / Mastodon icon
- Optional: ORCID, Google Scholar, Substack

**What goes in the footer**
- ORCID + Scholar (often duplicated from right nav)
- Email
- Copyright + license
- Optional: PGP key, accessibility statement

The current draft already does this correctly.

## Dark mode

Increasingly expected in 2026. al-folio has a built-in toggle. Quarto supports it with `theme: [cosmo, styles.scss]` plus a dark variant. Your current `_quarto.yml` does not have a dark variant; adding one is a 30-line SCSS change.

Optional. The default cosmo light theme is fine.

## Typography

**Body text**: a clean sans-serif at 17 to 19 px is standard. Inter, Source Sans, IBM Plex Sans are common in 2026. Your draft uses Inter, which is the right choice.

**Headings**: same family or one-step up in weight. Avoid pairing display serif with sans body unless you want a deliberately editorial feel.

**Code blocks**: a monospace with ligatures (Fira Code, JetBrains Mono) reads well; Quarto's defaults are fine.

## Color

The 2026 academic site palette is conservative:

- Background: white or near-white
- Body text: charcoal (#222 to #333)
- Accent: one color for links + buttons (navy, deep blue, deep red, or your institution's color)
- Use color sparingly; the page should be readable in greyscale

Your draft's "navy accent" follows this pattern. Good.

## Citation stats

Pulling Google Scholar citation counts is a niche but appreciated feature. Your draft already does this via `data/update_scholar.R`. Three things to be aware of:

1. Scholar can rate-limit or block scrapers; the GitHub Actions weekly schedule is appropriately conservative
2. Per-paper citation counts in the listing are higher impact than the homepage stat bar (they help readers prioritize what to read)
3. Scholar IDs can break (rare but possible); cache the last successful pull and degrade gracefully

## Accessibility

The bar is rising. Minimum:

- Sufficient color contrast (use a checker like contrast-ratio.com)
- Alt text on every image (especially headshot and figure images)
- Logical heading hierarchy (one `#` per page, then `##`, then `###`)
- Keyboard-navigable nav

Stretch:

- Skip-to-content link
- Accessibility statement page (Canelon does this)
- Reduced-motion media query for any animations

## Maintenance discipline

The single biggest predictor of whether a site stays alive is how easy it is to update. The pattern that works:

1. **Data files separated from layout** : you already do this with `data/publications.yaml`
2. **One command to deploy** : `git push` or `quarto publish gh-pages`
3. **Automated rebuilds on data refresh** : your GitHub Actions workflow already does this for Scholar stats

What kills sites:

- Custom layouts that break on theme upgrades
- Hand-edited HTML for individual papers
- Multiple sources of truth for the same content
- A blog with 2 posts from 2 years ago at the top of the homepage

## RSS / Atom feed

If you have a blog, give it an RSS feed. Quarto generates this for free with a `listing` page. Heiss has both `atom.qmd` and `rss.qmd`. The audience for academic RSS is small but loyal.

## Open Graph / social cards

When someone shares your paper page on Bluesky / LinkedIn / X, what shows up? By default: nothing useful. Setting Open Graph metadata (title, description, image) is a one-time configuration. Quarto supports it via `_quarto.yml`:

```yaml
website:
  open-graph: true
  twitter-card: true
```

Worth doing.
