# Exemplar Academic Sites

Notes from reading specific personal academic sites. Each entry covers structure, what they do well, and what is borrowable.

## Andrew Heiss : andrewheiss.com

**Field:** Public policy, NGOs, R / data viz teaching
**Stack:** Quarto (`andrewheiss/ath-quarto` is open source)
**Domain:** Personal apex domain
**Why it matters:** This is the de facto reference Quarto academic site. Multiple newer Quarto sites copied parts of his SCSS or `_variables.yml`.

**Navigation (8 items):** About, CV, Blog, Research, Teaching, Talks, Now, Uses, AI

**Homepage layout**
- Profile photo + brief intro paragraph
- Bio block: title, institution, PhD year and source
- Research focus statement
- Teaching areas listed as keywords / tags
- Credentials line (RStudio certified, Posit Academy)
- Social icons in footer (Bluesky, Mastodon, GitHub, YouTube, LinkedIn)
- ORCID + PGP key in footer

**Source structure (from GitHub)**
- `blog/`, `research/`, `teaching/`, `talks/`, `cv/`, `ai/`, `uses/`, `now/` : one folder per major content type, each with a Quarto listing
- `_extensions/` : custom Quarto extensions
- `_variables.yml` : centralized theme variables
- `atom.qmd`, `rss.qmd` : feeds
- `.htaccess` : redirects (suggests he hosts on a non-Pages provider)
- `deploy.sh` : custom deployment script

**Borrowable**
- The "Now" page (what I am working on this month) is high-trust, low-effort
- Listings as the entire architecture: every section is just a directory + an `index.qmd` listing
- The Uses page is fun and unique (your tools, hardware, software)
- AI page : a public statement on AI use is becoming common in 2026

## Drew Dimmery : ddimmery.com

**Field:** Economics / causal inference (ex-Facebook, NYU)
**Stack:** Quarto + Jupyter, deployed via GitHub Actions to Netlify
**Why it matters:** Clean exposition of the "data separated from presentation" pattern.

**Navigation:** Home, About, Research, Software, Blog

**Design philosophy quoted on his blog post:**
> "By separating out the data entry from the formatting, this simplifies matters substantially."

**Pattern**
- `papers.yaml` : single source of truth with title, authors, year, venue, URLs
- `research.qmd` : Jupyter-backed, transforms YAML into HTML, distinguishes published vs preprint, sorts chronologically
- Bootstrap-styled buttons : preprint, code, published version
- Self-author bolding (his name automatically bolded in author lists)
- Quarto freeze prevents re-rendering unchanged posts

**Borrowable**
- The YAML pattern is exactly what `data/publications.yaml` already does in your draft
- Auto-bolding the site owner's name in author lists
- Distinct buttons for DOI / PDF / preprint / code / replication

## Silvia Canelon : silviacanelon.com

**Field:** Health equity, R education
**Stack:** Quarto (migrated from Hugo Apero in 2023)
**Why it matters:** A model of clean, accessible, branded Quarto.

**Navigation:** About, Projects, Talks, Blog, Publications

**Homepage**
- Brief intro paragraph
- Three focus areas described concisely
- Social links: Bluesky, LinkedIn, GitHub, ORCID, Google Scholar, Newsletter
- CTA to learn more
- Visual brand: abstract circular Philadelphia skyline (a graphic identity, not just a photo)

**Notable**
- Dedicated **accessibility commitment** page linked from header and footer
- Footer links to license + contact
- Newsletter as a top-level link

**Borrowable**
- Accessibility statement is a small, distinguishing addition that signals professionalism
- Newsletter / Substack as a peer to social links

## Mike Mahoney : mm218.dev

**Field:** Forest carbon, geospatial, R packages (USGS)
**Stack:** Quarto
**Why it matters:** A more compact site than Heiss's. Good template for someone who wants to be brief.

**Navigation (4 items):** Home, Papers, Presentations, Blog (+ RSS)

**Homepage**
- Circular avatar
- Social links (LinkedIn, Bluesky, Mastodon, GitHub)
- Email + CV download right at the top
- Short bio
- "Selected Projects" section : five R packages with year + brief description

**Borrowable**
- 4-page navigation is cleaner than 7. Resist the urge to add tabs
- "Selected Projects" with year-stamped highlights on the homepage
- CV download as a button at the top, not buried on a CV page

## Scott Cunningham : scunning.com

**Field:** Economics, causal inference
**Stack:** Plain HTML (no SSG)
**Why it matters:** Proof that minimal static HTML still works for senior academics.

**Navigation (8 items):** Home, Publications, Working Papers, Teaching, Workshops, CV, Mixtape (book), Orley genealogy

**Homepage**
- Bio block
- Photo
- Cover image of his book "Causal Inference: The Mixtape" with purchase links
- Newsletter (Substack), podcast, workshop side-projects all linked

**Notable**
- Splits "Publications" and "Working Papers" : useful because economists have a long pipeline of unpublished work
- Each side-project (Mixtape book, Mixtape Sessions workshops, podcast, Substack) gets nav-level promotion
- Aesthetic is functionally indifferent : hand-rolled HTML, no theming

**Borrowable**
- Splitting Publications / Working Papers is a useful pattern if you accumulate non-peer-reviewed reports (NIJ briefs, ALERRT white papers, etc.)
- Promoting the book or the consulting practice to top-level navigation if it is a real second activity (your draft already does this with Consulting)

## Pascal Michaillat : pascalmichaillat.org

**Field:** Macroeconomics, UC Santa Cruz
**Stack:** Hugo (his own template, `pmichaillat/hugo-website`, based on PaperMod)
**Why it matters:** The minimalist economist style. His template is widely forked.

**Navigation:** Papers, Courses, Data, Books

**Homepage**
- Profile picture
- Name + subtitle
- Social icons : CV, email, Google Scholar, GitHub
- Buttons to main sections

**Design**
- Grayscale with slate-blue links
- Markdown-based : dropping a new file in `content/papers/` automatically lists it
- Mobile-responsive, very fast

**Borrowable**
- The "drop a file in a folder, it shows up" pattern (Quarto listings give you the same thing)
- Restraint: 4 main pages, gray + one accent color, sans-serif everywhere

## al-folio sites (e.g., Maruan Al-Shedivat, many ML faculty)

**Stack:** Jekyll, `alshedivat/al-folio`
**Why it matters:** Default for CS / ML. If you are recruiting CS-trained postdocs, they will recognize this template instantly.

**Default pages**
- About (homepage)
- Publications (auto-generated from `_bibliography/papers.bib`)
- Projects
- News (timestamped announcements)
- Books, Teaching, People, Repositories, Blog

**Features**
- Light/dark mode toggle
- BibTeX import for publications
- RenderCV or JSONResume for the CV
- MathJax, Mermaid, TikZ, Chart.js
- Open Graph social previews
- Atom/RSS feed
- GDPR cookie banner

**When to consider**
- You want a complete, batteries-included academic theme without writing layouts
- You publish heavily and want BibTeX as the source of truth for the publications page

**When to skip**
- You already have a Quarto-based workflow (al-folio means learning Jekyll + Liquid)
- You do not want a Ruby toolchain on Windows

## Cross-cutting observations

**Most common navigation items (in descending frequency across the 7 sites):**
1. Research / Publications (7/7)
2. CV (6/7)
3. Blog / News (6/7)
4. Teaching (5/7)
5. Talks / Presentations (4/7)
6. About / Bio (varies : sometimes the homepage, sometimes a separate page) (7/7)
7. Contact (3/7 explicit; others put email + socials in footer)
8. Projects / Software (3/7, mostly Quarto + R community)

**Least common but distinctive:**
- Now page (Heiss)
- Uses page (Heiss)
- AI use statement (Heiss, becoming common in 2026)
- Accessibility statement (Canelon)
- Newsletter as a peer to socials (Canelon, Cunningham)
- Workshops / Consulting as top-level nav (Cunningham, your current draft)
