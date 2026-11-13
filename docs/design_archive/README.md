# Design archive

Snapshots of how the site looked before each redesign, so a previous look can
be compared against or restored.

## 2026-11-13_pre-redesign

The navy and gold design that was live until the November 2026 redesign.

- Screenshots of the live site are in `2026-11-13_pre-redesign/` (home,
  research, grants, CV, contact at desktop width, plus the home page at phone
  width).
- The exact source is preserved in git as the annotated tag
  `pre-redesign-2026-11-13`.

### Restoring the old design

Only presentation files changed in the redesign. To bring the old look back
while keeping current publication and grant data:

```bash
git checkout pre-redesign-2026-11-13 -- \
  styles.scss _brand.yml _quarto.yml \
  index.qmd research.qmd grants.qmd cv.qmd contact.qmd
```

Then commit and push. `scripts/site_helpers.R`, `img/favicon.svg` and
`img/martaindale_headshot_800.jpg` were added by the redesign and can be
deleted afterwards (the old pages do not use them).

To browse the old source without changing anything:

```bash
git show pre-redesign-2026-11-13:styles.scss
```
