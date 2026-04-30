# Deployment: GitHub Pages + huntermartaindale.com

The plan you have already (GitHub Pages + custom domain) is what almost every Quarto-based academic site uses. Documenting the specifics so the setup is unambiguous.

## Overview

```
Source repo (private or public)
   |
   | git push origin main
   v
GitHub Actions workflow (.github/workflows/deploy.yml)
   |
   | quarto render
   v
gh-pages branch (built artifacts only)
   |
   | GitHub Pages serves from gh-pages
   v
huntermartaindale.com
```

The current draft already has this scaffolded. The remaining work is one-time setup at GitHub + DNS.

## One-time GitHub setup

1. Create repository, e.g., `huntermartaindale/website` (or `huntermartaindale/huntermartaindale.github.io` for the user-site naming convention; either works with a custom domain).
2. Push the contents of `website/` to the `main` branch.
3. The first push triggers `.github/workflows/deploy.yml`, which:
   - Installs R + Quarto
   - Runs `Rscript data/update_scholar.R` to refresh Scholar stats
   - Runs `quarto render`
   - Deploys to the `gh-pages` branch
4. In repo Settings : Pages : set Source to "GitHub Actions" (or "Deploy from a branch" pointing at `gh-pages`, depending on what the workflow uses).
5. In repo Settings : Pages : add `huntermartaindale.com` as the custom domain. Check "Enforce HTTPS" once it is available (usually within an hour after DNS propagates).

## CNAME file (Quarto-specific gotcha)

GitHub's UI for setting a custom domain creates a `CNAME` file in the **deployed branch**. Quarto will overwrite that branch on every render and the file disappears. The fix that the Quarto community has settled on:

1. Put a `CNAME` file at the root of your **source** project (alongside `_quarto.yml`) containing `huntermartaindale.com`.
2. List it as a resource in `_quarto.yml`:

```yaml
project:
  type: website
  output-dir: _site
  resources:
    - CNAME
```

Your current draft already does both of these. Good.

If the custom domain ever drops off (you visit huntermartaindale.com and get a 404 or a "not configured" page), the cause is almost always: the `CNAME` file got dropped from the rendered site. Re-render and re-deploy.

## DNS setup at your registrar

You mentioned the domain is registered through a personal account (the project_update.md mentions Google Domains; that service was sold to Squarespace and migrated automatically, so check if you are at Squarespace Domains or moved the registration elsewhere).

For the **apex domain** (`huntermartaindale.com`), set 4 A records pointing at GitHub Pages:

| Type | Name | Value |
|------|------|-------|
| A | @ | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |

For the **www subdomain** (`www.huntermartaindale.com`), set a CNAME record:

| Type | Name | Value |
|------|------|-------|
| CNAME | www | huntermartaindale.github.io. |

The trailing dot on `huntermartaindale.github.io.` is intentional in DNS notation; some UIs add it automatically.

GitHub will accept either the apex or `www` as your custom domain in the Pages settings. The convention is to set the apex (`huntermartaindale.com`), and GitHub will automatically redirect `www.huntermartaindale.com` to it once DNS resolves.

## Propagation and verification

DNS changes typically propagate within 1 hour, but can take up to 48. Tools to verify:

```bash
# from PowerShell or bash
nslookup huntermartaindale.com
```

Should return one of the four GitHub Pages IPs above.

In repo Settings : Pages, GitHub will show a green checkmark next to the custom domain once DNS is correctly configured. After that, click "Enforce HTTPS"; the certificate provisioning takes a few minutes more.

## HTTPS

GitHub Pages issues Let's Encrypt certs automatically once DNS is set. You should never have to touch this. If "Enforce HTTPS" is grayed out for more than a few hours after DNS propagation, the most common fix is to remove and re-add the custom domain in repo Settings : Pages.

## Workflow file (`.github/workflows/deploy.yml`)

The current draft has this. The standard pattern:

```yaml
name: Deploy

on:
  push:
    branches: [main]
  schedule:
    - cron: "0 7 * * 1"   # Monday 7am UTC, refresh Scholar stats

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - uses: quarto-dev/quarto-actions/setup@v2
      - name: Install R packages
        run: Rscript -e 'install.packages(c("yaml", "scholar", "htmltools"))'
      - name: Refresh Scholar stats
        run: Rscript data/update_scholar.R
      - name: Render
        run: quarto render
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_site
          cname: huntermartaindale.com
```

A few things worth noting:

- The `cname` argument to `peaceiris/actions-gh-pages` writes the CNAME file into the published branch automatically. If you set this, you can drop the resource trick in `_quarto.yml`. Belt-and-suspenders is fine; do both.
- The cron schedule for Scholar stats refresh is a good cadence. Weekly is enough; daily is overkill and may get rate-limited.
- If you ever want to commit the Scholar stats refresh back to `main` (so the cache survives between runs), the workflow needs `permissions: contents: write` and a `git commit && git push` step at the end. Your current setup just deploys the freshly-fetched stats, which is simpler and fine.

## Forms (Formspree)

Your draft uses Formspree for the consulting and contact forms (endpoint `https://formspree.io/f/mykbwyyn`). Free tier is 50 submissions/month per form. For a personal academic site that is plenty. If submissions spike (you go viral on something), upgrade or move to a different provider.

Alternative: a `mailto:` link instead of a form. Pros: zero infrastructure, no third party. Cons: requires the visitor to have a mail client configured, harder to add fields like "topic" or "preferred date." Your current Formspree setup is the better default.

## Email at the domain

If you want `hunter@huntermartaindale.com` instead of `MartaindaleLLC@gmail.com`:

- Cheapest: a forwarding service (ImprovMX is free for one domain, forwards to any inbox)
- More serious: Google Workspace ($7/mo) or Fastmail ($5/mo) for a real mailbox
- DIY: not worth it; SPF / DKIM / DMARC headaches

ImprovMX is the right choice for "I want to hand out a domain email but read it in Gmail."

## Observability and analytics

A few choices, in increasing complexity:

1. **Nothing** : you do not actually need to know how many people visit
2. **Plausible.io** ($9/mo) : privacy-respecting, GDPR-friendly, lightweight script
3. **GoatCounter** (free for personal use) : minimal, open-source
4. **Google Analytics** : free, but heavy and tracking-heavy

For an academic site, GoatCounter or nothing is the principled choice. Plausible is reasonable if you want a paid product with a nicer dashboard. Avoid GA unless you need cross-property reporting with another GA property.

## Deployment checklist (one-time)

- [ ] Create GitHub repo
- [ ] Push `website/` to `main`
- [ ] Confirm GitHub Action runs successfully (green check)
- [ ] In Pages settings, set custom domain to `huntermartaindale.com`
- [ ] Confirm `CNAME` file exists in repo root
- [ ] Add 4 A records at registrar pointing to GitHub Pages IPs
- [ ] Add CNAME record for `www`
- [ ] Wait for DNS to propagate (`nslookup` returns GitHub IPs)
- [ ] Confirm "Enforce HTTPS" is checked in Pages settings
- [ ] Visit `https://huntermartaindale.com` and confirm site loads
- [ ] Visit `https://www.huntermartaindale.com` and confirm it redirects to apex
- [ ] (Optional) Set up ImprovMX forwarding for `hunter@huntermartaindale.com`
- [ ] (Optional) Add Plausible or GoatCounter snippet to `_quarto.yml`

## Ongoing deployment

After the one-time setup, the workflow is just:

```bash
# edit a .qmd file or update data/publications.yaml
git add .
git commit -m "add new paper to publications"
git push
# GitHub Action runs, site rebuilds, ~3 minutes later live
```

That is the entire ops story.
