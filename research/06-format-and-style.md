# Format and Style

Deeper notes on visual design: typography, layout, spacing, color, components, and imagery. Built from inspecting the exemplar sites and from your existing `styles.scss`.

## What "format" means in a Quarto site

Three different things get conflated under "style":

1. **Page format** : full-bleed vs centered, sidebar vs no sidebar, full vs default page layout (set in YAML frontmatter)
2. **Theme** : Bootstrap base (cosmo, litera, flatly, etc.) plus your SCSS overrides
3. **Content style** : how publication entries, talks, news posts, etc. are rendered (via templates and listings)

You set the first in each `.qmd` file's frontmatter, the second in `_quarto.yml` + `styles.scss`, and the third in your R rendering functions or Quarto listing configurations.

## Page format / layout choices

Quarto offers several `page-layout` options:

| Option | When to use |
|--------|-------------|
| `article` (default) | Body content, posts, papers. Centered, ~700px wide. |
| `full` | Homepage hero, dashboards, anything that needs the full viewport width. Your current `index.qmd` uses this. |
| `custom` | Full control; for landing pages or grid layouts. |

**Pattern across exemplars:**
- Heiss, Mahoney, Canelon: `full` on homepage, `article` everywhere else
- Cunningham: essentially `full` everywhere because the site is hand-rolled HTML
- Dimmery: `article` even on homepage (he treats the homepage as a blog post)

Your current draft uses `full` on the homepage with a 3-column / 9-column grid (`g-col-md-3` for the photo, `g-col-md-9` for the bio). This is the dominant 2026 pattern.

## Typography

### Font pairing strategies

The 7 exemplar sites cluster into three typographic camps:

**Camp 1: Single sans-serif throughout (your current draft)**

- One face, multiple weights
- Inter, Source Sans, IBM Plex Sans, Atkinson Hyperlegible
- Most common in 2026; clean, signals "data-oriented researcher"

Used by: Heiss, Canelon, Mahoney, your draft

**Camp 2: Serif body + sans-serif headings**

- Body: Source Serif Pro, Lora, Crimson, Charter
- Headings: same family bold, or paired sans-serif
- Signals "humanities-leaning" or "long-form writer"

Used by: many history / philosophy academics, less common in policing or quantitative fields

**Camp 3: Sans-serif body + display serif headings**

- Body: Inter, Plex Sans
- Headings: Playfair Display, Fraunces, Lora
- Signals "editorial" or "magazine-y"

Used by: Some Hugo Apero sites; rare in academic CS / quantitative

**Recommendation:** Stay in Camp 1 with Inter. It's what your draft already uses and it matches your peer group.

### Type scale

Your current SCSS doesn't explicitly set a scale; Bootstrap's defaults take over. The 2026 academic-site convention is:

| Element | Size | Notes |
|---------|------|-------|
| Body text | 17 to 19 px | Your draft inherits cosmo's ~16px; consider bumping to 17 |
| H1 | 2.0 to 2.5 rem | Page titles |
| H2 | 1.4 to 1.6 rem | Section headings; your draft sets `.topic-section h2` to 1.2rem which is on the small side |
| H3 | 1.1 to 1.2 rem | Subsection |
| Small text | 0.85 to 0.9 rem | Pub journal, captions |
| Tiny text | 0.7 to 0.78 rem | Citation counts, badges, footnotes |

### Line height and measure

- Body line-height: 1.6 to 1.75 (your draft uses 1.7, good)
- Measure (line length): 60 to 75 characters per line is the readability sweet spot. Quarto's default `article` layout (~700px) hits this. Resist making body content full-width.

### Weights

Your draft uses weights 300, 400, 500, 600, 700 from Inter. That's appropriate. Common patterns:

- Body: 400
- Bold inline: 600
- Headings: 600 to 700
- Captions / small caps: 500

Avoid 300 (light) for body text. It can look thin on Windows ClearType rendering.

## Color

### The current palette

Your `styles.scss` defines:

- Primary / link: `#1a365d` (deep navy)
- Body text: `#2d3748` (charcoal)
- Headings: `#1a2744` (deeper navy-charcoal)
- Borders / dividers: `#e2e8f0` (cool gray 200)
- Subtle backgrounds: `#f7fafc` (cool gray 50)
- Muted text: `#718096` (cool gray 500)

This is a Tailwind-flavored "slate" palette. It's tasteful and conservative. Stay with it.

### When to add a second accent

If you ever want to draw attention to one specific thing (a featured paper, a current project, a CTA on the consulting page), a single second accent helps. Options that pair with `#1a365d`:

- Burnt orange `#c05621` (warm, complementary)
- Forest green `#2f855a` (signals "data viz")
- Gold `#b7791f` (Texas-flavored if you want institutional reference)

**Use sparingly:** badge backgrounds, "Highlighted" markers on featured publications, buttons that need to stand out from the primary navy. If you find yourself using the second accent on more than ~5% of the site, it stops working.

### Color contrast minimums

WCAG AA requires 4.5:1 for body text. Your `#2d3748` on `#ffffff` is 13.5:1. Comfortable.

Where contrast often fails:
- `.media-meta` and `.pub-citations` use `#718096` on white = 4.4:1, just under WCAG AA. Bump to `#5a6678` or darker to be safe.
- Light gray on light gray (subtle dividers) is fine; that's not body text.

### Dark mode (optional)

If you want dark mode, the cosmo theme has a sibling dark variant. Two-line change in `_quarto.yml`:

```yaml
format:
  html:
    theme:
      light: [cosmo, styles.scss]
      dark: [darkly, styles-dark.scss]
```

Then write a small `styles-dark.scss` that flips background and text colors. Not required, but increasingly expected by readers in 2026.

## Spacing and density

The single biggest visual decision in academic site design is **how much whitespace you give each element.** Two camps:

**Dense (Cunningham, Dimmery):** packed lists of papers, minimal padding, scrolling is the navigation. Looks "serious" / utilitarian.

**Airy (Heiss, Mahoney, Canelon, your draft):** generous padding, larger font sizes, lots of vertical space between elements. Feels modern and 2024-era.

Your draft is firmly airy:

- `.pub-entry` has 1.25rem vertical padding (about 20px above and below each paper)
- `.scholar-stats` has 1.25rem 1.5rem padding
- `.topic-section` has 3rem bottom margin between sections

That's a good calibration. Don't tighten it.

### Vertical rhythm

For the body content, pick a base unit (e.g., 1rem = 16px) and use multiples of it for all spacing: 0.5rem, 1rem, 1.5rem, 2rem, 3rem. Avoid arbitrary values like `0.875rem` for spacing (you do use `0.875rem` for type sizes, which is fine). Your current SCSS is mostly disciplined here; a quick audit could tighten a couple of inconsistencies.

## Component patterns

These are the recurring building blocks of academic sites. Establish a visual treatment for each, then reuse it.

### Publication entry (you have this)

Current treatment: title (bold, primary color), authors, journal (italic), summary, link buttons, citation count.

**Possible upgrades:**
- Add a "Featured" badge on top-cited papers (replaces or supplements citation count)
- Show a thumbnail of the first figure or paper preview on hover (al-folio style)
- Per-topic color accents on the left border of each entry

### Talk entry (not yet built)

Recommended treatment, mirroring the pub-entry pattern:

```
[Talk title]
Venue, Date
[2-line abstract or summary]
[Slides] [Video] [Code]
```

### News / blog post entry (not yet built)

Recommended treatment:

```
[Date in muted small caps]
[Title in semibold]
[1-line summary]
[Read more]
```

### Stat block (you have this)

Your `.scholar-stats` block is already a clean component. Same pattern can be reused for:

- Project stats on a paper landing page (citations, alt-metric, downloads)
- ALERRT impact stats if you ever want them on the consulting page (training hours delivered, agencies served)

### Callout / quote block

Quarto has `:::{.callout-note}` etc. built in. Useful for:

- Methodological notes on paper landing pages
- "This work is in progress" markers
- Quotes from press coverage on a Media page

### Cards (grid layouts)

Quarto's listings can render as cards:

```yaml
listing:
  type: grid
  grid-columns: 3
  fields: [image, title, subtitle, date]
```

Useful for talks, projects, courses. Each card is a tile with a thumbnail. Visually heavier than text listings, so use selectively.

## Imagery

### Headshot

Three patterns on the homepage:

- Round headshot (Mahoney, Canelon) : friendly, modern
- Square headshot (Heiss) : more formal
- Headshot + secondary visual (Canelon's Philadelphia skyline graphic) : adds visual identity

**Recommendation:** Round headshot, ~200px on desktop (your draft has `max-width: 200px`, that's right). Always include alt text.

### Paper / talk thumbnails

Optional but powerful. Each paper or talk can have a 1200x630 social card image (also doubles as Open Graph card). Two ways to generate:

- Manually in Figma / Canva
- Auto-generate from the paper title using a tool like `og-image` or a Quarto pre-render hook

For your site, manually generating cards for the 5 to 8 highlighted papers is plenty; the rest can use a default site card.

### Hero / banner image

Not required. Few of the exemplar sites use one. Adds visual interest but also visual weight. Only use if you have a specific image that signals what you study (e.g., a tactical scenario photo, an ALERRT training shot).

## Mobile responsiveness

Things that commonly break on mobile in academic Quarto sites:

- Wide tables (publication tables) : add `style="overflow-x: auto"` to table wrappers
- Side-by-side `g-col-md-*` blocks that stack badly on phones : verify the `g-col-12` fallback is set
- Long DOI strings : let them wrap (`word-break: break-word`)
- Navbar that becomes a hamburger menu : check that the hamburger is keyboard-accessible

Your draft already uses `g-col-12 .g-col-md-3` style fallbacks, which is correct.

Test on a phone-sized window before deploying. Quarto preview at ~400px width is a quick proxy.

## Quarto-specific format levers

Worth knowing about:

### `page-layout`

Set per-file in YAML frontmatter:

```yaml
---
title: "Research"
page-layout: article    # or full, custom
---
```

### `toc`

Table of contents on the right side. Useful for long pages (like CV or a detailed research page). Your `_quarto.yml` has `toc: false` globally, which suppresses it. To enable per-page:

```yaml
---
title: "CV"
toc: true
toc-location: right
---
```

### `listing`

The most powerful Quarto feature for academic sites. Auto-generates a list of all `.qmd` files in a directory. Used for blogs, talks, projects, papers. Example:

```yaml
---
title: "Talks"
listing:
  contents: talks
  type: default
  fields: [date, title, venue]
  sort: "date desc"
---
```

Each item in `talks/` gets a row with date, title, venue. No manual list-building.

### Includes

Reusable content fragments via `{{< include _fragment.qmd >}}`. Useful for:

- Footer disclaimers
- Author bio that appears on the homepage and in blog posts
- Standard "How to cite this work" boilerplate on paper landing pages

### Conditional content

```
::: {.content-visible when-format="html"}
This only shows on the website
:::

::: {.content-visible when-format="pdf"}
This only shows in the PDF
:::
```

Useful for the CV, where you might want different versions for HTML and PDF rendering.

## Style guide proposal for huntermartaindale.com

If you want a one-page style spec to refer back to:

| Element | Spec |
|---------|------|
| Background | `#ffffff` |
| Body text | `#2d3748` at 17px, 1.7 line-height |
| Heading family | Inter (same as body), 600 weight |
| Heading color | `#1a2744` |
| Primary accent | `#1a365d` (links, buttons, primary nav, paper titles) |
| Subtle background | `#f7fafc` (stat blocks, callouts) |
| Borders / dividers | `#e2e8f0` (1px) |
| Muted text | `#5a6678` (slightly darker than current `#718096` for contrast) |
| Body max width | ~700px (Quarto article default) |
| Section spacing | 3rem between major sections |
| Component spacing | 1.25rem between items in a list |
| Round photos at 200px max | Headshot only |
| Buttons | 1px border, 0.5rem horizontal padding, primary navy background or outline |
| Code | JetBrains Mono or Fira Code (Quarto default is fine) |
| Links | Underline on hover, no underline by default, primary navy color |

This is a refinement of what you already have, not a rewrite.

## Density vs polish: the one decision to make

The deepest format question is whether you want the site to feel:

- **Dense and content-first** (Cunningham, Dimmery) : visitors who arrive know who you are, they want the papers fast
- **Polished and curated** (Heiss, Canelon) : visitors include funders, journalists, students; the site signals "I take this seriously"

Your role at ALERRT and the Consulting page suggest you want the second. The current draft is correctly calibrated for that. Resist any future temptation to densify the publications page or shrink the typography to "fit more."
