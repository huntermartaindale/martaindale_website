# The Platform Landscape

Self-hosted academic websites cluster around four families. Each has a different audience, a different barrier to entry, and a different feature ceiling.

## Family 1: Quarto (R/Posit ecosystem)

The current generation of statistical and data-intensive academics has largely moved to Quarto in the last 2 to 3 years. It is the natural choice if you already write papers in R Markdown / Quarto and want one toolchain for papers, slides, and the website.

**Strengths**
- Native R, Python, Julia, Observable JS code execution in pages
- Cross references for figures, tables, equations out of the box
- Listings: powerful auto-generated pages from YAML or directory structure
- Bibliography / `.bib` support is first class (citeproc + biblatex)
- Freezing prevents re-rendering unchanged pages
- The default `cosmo` and `litera` themes look clean; `styles.scss` lets you tune them
- Same toolchain you already use for manuscripts

**Weaknesses**
- Less mature ecosystem of plug-and-play themes than Jekyll/Hugo
- Visual customization beyond SCSS often requires Liquid-style templates or EJS
- Smaller community of academic-specific examples than al-folio
- Listings require a bit of YAML wrangling to get right

**Notable templates**
- `andrewheiss/hikmah-academic-quarto` (Andrew Heiss, GSU)
- `drganghe/quarto-academic-website-template` (Gang He, Stony Brook)
- `andreaczhang/qtwAcademic` (Andrea Zhang, R package with 3 templates)
- `kazuyanagimoto/quarto-academic-typst` (Quarto + Typst manuscript style)

**Real sites**
- andrewheiss.com (GSU, public policy) : the de facto reference Quarto academic site
- silviacanelon.com (data science / health equity)
- mm218.dev (Mike Mahoney, USGS)
- ddimmery.com (Drew Dimmery, NYU)

## Family 2: Hugo (general-purpose static site generator)

Hugo dominates among economists, ML researchers who want speed, and anyone who wants the deepest theme catalog. It is faster to build than Jekyll and has more themes than Quarto, but it is not Markdown plus code execution: you cannot run R inside a Hugo page.

**Strengths**
- Single binary, no dependency tracking, very fast builds
- Largest theme catalog of any SSG
- Several mature academic themes
- Clean URL structure and content collection model

**Weaknesses**
- No native code execution: figures and tables must be rendered before being placed in the site
- Themes vary wildly in quality; choosing one is its own project
- Wowchemy (formerly Academic) had a period of license / governance churn; some academics moved off it

**Notable templates**
- **Hugo Apero** (Alison Hill / Apreshill): the most "designerly" academic theme, custom layouts, sidebar option, Formspree built in. Lots of R community sites used it before the Quarto migration.
- **Wowchemy / HugoBlox Academic CV**: AI-generated pages, BibTeX auto-import, the most batteries-included option. Has had governance noise.
- **Pascal Michaillat's Hugo template** (`pmichaillat/hugo-website`): minimalist, PaperMod-based, gray scale + slate-blue links, popular among economists.
- **academia-hugo** (gethugothemes): traditional resume + publications layout.

## Family 3: Jekyll (GitHub-native)

Jekyll is the original GitHub Pages SSG. It has the deepest "academic-flavored" theme in al-folio, which has become the default in CS/ML.

**Strengths**
- Tightest GitHub Pages integration (Pages can build it without an Action)
- al-folio is genuinely full-featured: publications from BibTeX, news, projects, books, teaching, repositories, photos, dark mode
- Huge install base in CS / ML (Stanford / MIT / CMU faculty)

**Weaknesses**
- Ruby toolchain; slow builds on large sites
- Customizing al-folio means learning Liquid + Jekyll collections
- Less natural for non-CS academics; the aesthetic is calibrated for ML papers

**Notable templates**
- `alshedivat/al-folio` (Maruan Al-Shedivat, formerly CMU): the gold standard. Publications from BibTeX, RenderCV PDF generation, MathJax, Mermaid, TikZ, GDPR cookie banner, Open Graph cards.
- `academicpages/academicpages.github.io`: Minimal Mistakes fork, lighter than al-folio, easier to start with.

## Family 4: Plain HTML or hand-rolled

A meaningful fraction of senior academics still run hand-coded HTML or a CMS like WordPress. The most-cited example is Scott Cunningham (scunning.com), whose site is essentially semantic HTML with minimal styling. Loads instantly, easy to edit, but no automation.

This is a viable choice if:
- The site is small (less than ~30 pages)
- You update it rarely
- You do not want to learn a build system

It is a bad choice if you publish frequently or want a publications page that auto-updates from BibTeX.

## Family 5: Hosted builders (Owlstown, Squarespace, Wix, Faculty.bio)

Owlstown is the academic-specific hosted builder. Squarespace and Wix are general. These trade away control and portability for zero technical setup. Most academics with a CS / quantitative background skip this tier; humanists more often use it.

**When this might make sense**
- You will not maintain a build pipeline
- You want a contact form, drag-and-drop editing, no Git
- You are okay with a recurring subscription cost (~$15 to $30 / month)

## What this means for ALERRT / criminal justice context

Criminal justice and policing scholars are a quieter web presence than economists or ML researchers. Searches did not surface a dominant template specific to the field. Most field-specific personal sites lean toward:

- Light WordPress with a CV plus media coverage page
- Plain HTML on the institutional domain
- A Google Sites or institutional CMS page

A self-hosted Quarto site at huntermartaindale.com would already be a more polished presence than 90% of criminologists. The current `website/` draft uses Quarto, which is the right call given:
- You already use R and Quarto for papers
- You will want code-driven figures (citation stats, ASR trends, etc.) embedded in the site
- Quarto listings make the publications page maintainable as you add to `data/publications.yaml`
