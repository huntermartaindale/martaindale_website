# Academic Website Research

Research notes on how independent academics structure their personal websites (the kind hosted on a personal domain, not the institutional faculty page).

## Files

1. `01-landscape.md` : the platform landscape (Quarto, Hugo, Jekyll, plain HTML, builders)
2. `02-exemplar-sites.md` : real academic websites with structural notes
3. `03-common-patterns.md` : site IA, homepage patterns, publications pages, navigation
4. `04-deployment.md` : GitHub Pages + custom domain (specific to huntermartaindale.com)
5. `05-recommendations.md` : what this means for the current rough draft in `website/`
6. `06-format-and-style.md` : typography, color, spacing, components, Quarto layout levers
7. `07-cv-integration.md` : architecture for auto-updating the website from `1_claude/cv/`

## TL;DR

- The dominant platforms for self-hosted academic sites are **Quarto**, **Hugo (Apero / Wowchemy / minimalist PaperMod-based)**, and **Jekyll (al-folio, academicpages)**. Quarto has been winning the last two years among data-centric academics; al-folio remains dominant in CS/ML; minimalist Hugo is popular in economics.
- Most successful sites share a small set of pages: **Home, Research/Publications, CV, Teaching, Talks, Blog, Contact**. The rest is taste.
- The strongest design pattern is **separating data from presentation**: publications stored in YAML or BibTeX, then rendered by the site template. This makes maintenance survivable.
- For a personal domain on GitHub Pages: **`CNAME` file at repo root + 4 A records + a www CNAME** is the entire setup.
- The current `website/` draft is already on the right track. Main upgrades to consider: a blog/news feed, a Now or Talks page, BibTeX import, and per-paper landing pages for the highest-cited work.

## Method

- 8 web searches on platform comparison, exemplar sites, structure, deployment
- Direct reads of 6 exemplar sites (Andrew Heiss, Drew Dimmery, Silvia Canelon, Mike Mahoney, Scott Cunningham, Pascal Michaillat)
- Reads of 2 template repos (al-folio, ath-quarto, qtwAcademic)
- Synthesis dated 2026-04-29
