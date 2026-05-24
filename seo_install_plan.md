# SEO Install Plan: SearchFit SEO on martaindale_website

**Status:** DRAFT (not yet executed)
**Created:** 2026-05-23
**Repo:** huntermartaindale/martaindale_website (this one)
**Goal:** Install the SearchFit SEO Claude Code plugin and run a first audit on the live site (huntermartaindale.com) and the local Quarto build.
**Source:** https://claude.com/plugins/searchfit-seo

## Why SearchFit (vs alternatives)

- In Anthropic's official plugin directory (vetted source).
- No API keys, no paid connectors.
- 11 skills + 3 sub-agents covering technical audit, on-page review, JSON-LD schema, and content planning. Right-sized for a single academic Quarto site.
- Two larger community kits exist (AgriciDaniel/claude-seo, aaron-he-zhu/seo-geo-claude-skills). Defer those until after a first pass with SearchFit; revisit if the bigger toolkit is needed for the ALERRT site or future web projects.

## What SearchFit gives you (once installed)

Slash commands:
- `/seo-check` - scored SEO evaluation of an HTML page (live URL or local file)
- `/generate-schema` - JSON-LD structured data ready to paste into a page
- `/keyword-cluster` - groups a comma-separated keyword list by intent
- `/create-topic`, `/create-content` - research + article drafting
- `/translate-content` - multilingual localization (not needed here)

Auto-activating agents:
- SEO Auditor
- Content Strategist
- Competitor Analyzer

## Step 1: Install the plugin

In a Claude Code session opened in this repo:

1. Run `/plugin` to open the plugin browser, OR try `/plugin install searchfit-seo` directly.
2. If the direct command does not resolve, browse the plugin marketplace and search "SearchFit SEO" - the source page is https://claude.com/plugins/searchfit-seo.
3. Confirm the install. SearchFit installs at the user level by default, so it will be available in all your projects (including the ALERRT site later), not just this repo.

Verify install:
- `/plugin list` should show searchfit-seo as installed.
- `/seo-check` should appear in the slash-command list when you type `/`.

## Step 2: Build the site locally

SEO checks should run against rendered HTML, not `.qmd` source. Build first:

```
quarto render
```

The output lands in `_site/`. Sanity-check that `_site/index.html`, `_site/research/index.html`, and `_site/cv.html` all exist.

## Step 3: First audit (live URL)

Run the SEO check against the deployed site so the audit sees what Google and LLM crawlers actually fetch:

```
/seo-check https://huntermartaindale.com
```

Repeat for the main subpages:
- `/seo-check https://huntermartaindale.com/research.html`
- `/seo-check https://huntermartaindale.com/cv.html`
- `/seo-check https://huntermartaindale.com/consulting.html`
- `/seo-check https://huntermartaindale.com/contact.html`

If the custom domain is not live yet (DNS A records are still on the TODO list per `project_update.md`), point the audit at the GitHub Pages URL instead.

## Step 4: First audit (local build)

Run the same checks against `_site/` so you can iterate on fixes before redeploying:

```
/seo-check _site/index.html
/seo-check _site/research.html
```

Expected first-audit findings (predicted, based on a vanilla Quarto cosmo site):
- Missing or generic `<meta name="description">` on most pages
- Missing Open Graph + Twitter Card tags
- No JSON-LD schema (Person schema on index, ScholarlyArticle on publication pages, ProfessionalService on consulting)
- Heading hierarchy may skip levels in places
- `<title>` tags may be the page slug rather than a real SEO title
- No `sitemap.xml` or `robots.txt` (Quarto can generate sitemap; robots needs to be added)

## Step 5: Generate schema markup

Academic sites benefit disproportionately from structured data because it helps LLMs answer "who studies X" with you in the answer.

Priority schemas:
- `Person` schema on `index.qmd` (name, affiliation = ALERRT Center / Texas State, sameAs links to Scholar/ORCID/LinkedIn, jobTitle = Director of Research)
- `ScholarlyArticle` schema on each publication entry (or aggregated on `research.qmd`)
- `ProfessionalService` schema on `consulting.qmd`
- `ContactPoint` schema on `contact.qmd`

Run, e.g.:
```
/generate-schema Person for Hunter Martaindale, Director of Research, ALERRT Center, Texas State University. Scholar ID _7PlqKYAAAAJ. GitHub huntermartaindale. Research areas: active shooter response, policing stress, police decision-making.
```

Paste the returned JSON-LD into the relevant `.qmd` file inside a raw HTML block:

````
```{=html}
<script type="application/ld+json">
{ ...generated JSON... }
</script>
```
````

## Step 6: Keyword + topic planning (optional, do later)

Once the technical fixes are in:
- `/keyword-cluster active shooter response, ALERRT, police training, active threat, civilian response, run hide fight` to see how the SEO tool groups your research vocabulary by search intent.
- `/create-topic` for ideas on short explainer posts that could live under `research/` and pull search traffic to the topic pages.

This is the part most likely to feel like marketing rather than academic work. Defer until the technical pass is done and you have a sense of whether you want the site to attract general traffic or stay reference-only.

## Step 7: Decide on rollout to ALERRT and future sites

After this first pass, evaluate:
- Did SearchFit produce useful findings, or was it shallow?
- Did the schema generation save real time?
- Are there gaps SearchFit does not cover that would matter at ALERRT scale (deeper technical SEO, GEO/AEO, semantic clustering)?

If yes to the last one, install AgriciDaniel/claude-seo for the ALERRT site as the heavier toolkit. If SearchFit was sufficient, stay with it.

## Out of scope for this plan

- Buying any paid SEO tools (Ahrefs, Semrush, DataForSEO). None needed for SearchFit.
- Backlink campaigns. Academic backlinks come from publication citations, not outreach.
- Migrating off Quarto. The site stack is fine; SEO work is content + meta + schema, not platform.

## Done criteria

- [ ] SearchFit installed and `/seo-check` available
- [ ] Baseline audit run on all five live pages, results saved to `docs/seo_baseline_YYYY-MM-DD.md` (create `docs/` if needed)
- [ ] Person schema on `index.qmd`
- [ ] Meta description + OG tags on all five pages
- [ ] Site re-rendered, re-audited, baseline-vs-after delta noted in the same file
