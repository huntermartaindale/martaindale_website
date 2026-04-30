# Recommendations: What This Means for Your Site

You said you are not married to the current `website/` draft. Read this as a "here is where the patterns from the field would push the design" memo, not a fix-list.

## What the current draft already does right

The existing scaffold lines up well with where field-leading Quarto sites have converged:

- **Quarto + cosmo + custom SCSS**: identical to Heiss, Canelon, Mahoney, Dimmery
- **Navy accent (#1a365d) on near-white background**: standard 2026 academic palette
- **Inter typeface**: same choice as half of the exemplars
- **YAML-backed publications + R rendering**: this is exactly Dimmery's "data separated from presentation" pattern, the single most important architectural decision for surviving maintenance
- **Topic-grouped publications page**: appropriate for your work since it clusters into 4 clear themes (active shooter, officer stress, decision making, public opinion)
- **GitHub Actions deploy + weekly Scholar refresh**: matches what Heiss and others run
- **CNAME at repo root + listed as resource in `_quarto.yml`**: avoids the most common Quarto + Pages footgun
- **Formspree-backed contact and consulting forms**: standard, free-tier-adequate
- **Scholar stats bar**: distinctive, automated, shows recency

If you want to keep iterating on what is already there, that is a defensible choice. The remaining gaps below are upgrades, not corrections.

## Gaps relative to the exemplars

### Big gaps

**1. No Blog or News.** Six of the seven exemplar sites have one. For an active researcher with a public-facing role at ALERRT, this is the most useful missing piece. Use cases:

- "New paper out" announcements (1 paragraph + DOI link)
- Conference recap notes
- Op-ed-length policy commentary on active shooter response
- Visualization explainers (great fit for Quarto code chunks)

A blog also fixes the homepage staleness problem: Scholar stats refresh weekly, but the homepage otherwise never changes. With a blog, the home page or a sidebar can show "latest post" and the site feels alive.

**Cost:** add `blog/` directory with an `index.qmd` listing page. Quarto handles the rest. Even 4 to 6 posts a year is enough to justify the page.

**2. No Talks page.** You give a lot of presentations at ALERRT, IACP, CNA-style events, etc. A talks page is one of the most-visited parts of academic sites because journalists, organizers, and prospective collaborators look for it. Pattern:

```
talks/
  index.qmd              # listing
  2026-iacp-keynote.qmd  # one file per talk: title, venue, date, slides, video
```

Each talk entry has: title, venue, date, abstract or one-line summary, link to slides (PDF or HTML), link to video if recorded.

**Cost:** small. Templates from `data/talks.yaml` follow exactly the same pattern you already use for media.

**3. CV is a placeholder.** The current `cv.qmd` says "Full CV available for download above" and the PDF link is to a file you have not yet built. Three options:

- **Option A (most polished):** maintain a Quarto CV in a separate project, render to PDF, and embed both an HTML preview and a download button on this page. The Hikmah extension or `pagedown::thesis_paged` are good starting points.
- **Option B (fastest):** point the download button at your existing Word or LaTeX CV PDF and stop maintaining a duplicate HTML version on the site.
- **Option C (hybrid):** bullet-point version directly in `cv.qmd` (current positions, education, recent grants, recent publications) plus a PDF download for the full version.

Option C is the lowest-effort, highest-signal choice. The full PDF satisfies the people who want to print or archive; the on-page version satisfies casual visitors.

### Medium gaps

**4. No selected work on the homepage.** Right now the homepage has bio + CTAs + Scholar stats. A "Selected Work" or "Recent Papers" section, listing 3 to 5 highlighted papers with one-sentence summaries, would help readers prioritize. Mike Mahoney does this with R packages; you would do it with papers.

**5. No per-paper landing pages.** All 7 exemplar sites at least support this for highlighted work. Worth doing for the 5 to 8 highest-cited or most-cited-in-press papers. Each landing page links to the PDF, replication code, abstract, press coverage, slide deck.

**6. No Open Graph / Twitter card metadata.** When someone shares a page on Bluesky / LinkedIn, the link card is generic. Two-line fix in `_quarto.yml`:

```yaml
website:
  open-graph: true
  twitter-card: true
```

### Small gaps and nice-to-haves

**7. Per-paper citation counts.** You already pull total Scholar stats. The same `scholar` R package can return per-paper counts. Embed those in the publications listing so a visitor can see which papers have been most influential. This is more useful to the visitor than the homepage stat bar.

**8. Newsletter / Substack peer link** (if you ever start one). Canelon and Cunningham both treat newsletters as a peer to social media.

**9. Now page** (Heiss-style). Low effort, high signal. Three short paragraphs: what I am writing, what I am reading, what I am traveling to. Update once a quarter.

**10. AI use statement.** Becoming common in 2026, especially for researchers whose work involves training officers (where AI training tools are an active topic). One paragraph: how you use AI in your research and writing. Demonstrates intellectual transparency.

**11. Accessibility statement.** Canelon does this. Small distinguishing addition.

**12. ImprovMX forwarding** for `hunter@huntermartaindale.com` instead of using `MartaindaleLLC@gmail.com` for consulting. Free. Looks more professional on the consulting page.

## Suggested navigation if you go all in

The current 5-tab nav (Research, CV, Media, Consulting, Contact) is conservative. If you implement the upgrades above, a 6 or 7 tab nav looks like:

**Option 1 (additive):** Research, Talks, CV, Blog, Media, Consulting, Contact (7 tabs, at the upper limit)

**Option 2 (consolidated):** Research, Talks, CV, Writing, Consulting (5 tabs; Media merges into Writing or moves to footer; contact via footer email)

Option 2 is cleaner. The convention "if it is a one-line piece of contact info, put it in the footer; do not give it a tab" is followed by Heiss, Mahoney, and Dimmery.

## Things in the current draft that I would not change

- Stack choice (Quarto)
- Color palette
- Typography
- Topic-grouped publications layout
- YAML data files
- Scholar stats bar
- Formspree on consulting form
- 4 GitHub Pages A records + apex domain plan

## Suggested order of work

If you want to keep iterating on the current draft rather than starting over, this is the path with the best effort-to-payoff ratio:

1. **Fill in real publication data in `data/publications.yaml`.** This is the page that pays for the site. Nothing else matters until this is real.
2. **Add the headshot at `img/headshot.jpg`.** The current homepage has a broken image reference.
3. **Build out CV (Option C above):** bullet-point CV directly in `cv.qmd` plus PDF download.
4. **Add Open Graph / Twitter card** (one-time, two lines).
5. **Add Talks page** (low effort, high payoff).
6. **Add Blog scaffold** even with one announcement post; you can grow it slowly.
7. **Add per-paper citation counts to the publications listing.**
8. **Set up domain forwarding** so `hunter@huntermartaindale.com` works.
9. **Decide on Now / AI / Accessibility statements** (any or all, low cost).
10. **Per-paper landing pages for the top 5 to 8 papers** (last because it is the highest effort).

## If you decide to start over

The two strongest alternatives to the current homegrown Quarto setup are:

- **Fork `andrewheiss/ath-quarto`** (or his `hikmah-academic-quarto` template). You get the full structure for free and the result will look polished out of the gate. Trade-off: his SCSS and EJS layouts are dense and you would inherit some of his idiosyncratic design choices.
- **Start from `qtwAcademic`** (Andrea Zhang's R package). More minimal, fewer custom layouts to fight, but less polished visually than Heiss's site.

I do not recommend switching to Hugo or al-folio. Both are fine but moving away from Quarto means giving up the seamless "code chunk in a page" capability that you already use for the Scholar stats bar (and that you would likely use for any future visualization-heavy posts).

## Bottom line

You have a defensible draft. The biggest single missing piece is **real content in `data/publications.yaml`** (and the headshot). Everything else (blog, talks, CV, Open Graph, per-paper landing pages, Now / AI pages) is incremental polish that you can add over time without ever rebuilding.

If your next 4 hours of work were spent on:

- Filling in publications data : 2 hours
- Adding talks page + 3 to 5 entries : 1 hour
- Bullet-point CV in `cv.qmd` + PDF link : 30 min
- Open Graph + ImprovMX setup : 30 min

you would have a finished website that is better than 90% of policing scholars' sites. The remaining items can wait.
