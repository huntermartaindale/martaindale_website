# pubs/ - paper PDFs

This directory is the **single source of truth** for the full-text PDFs of
publications listed in `cv_data.yaml`. The website
(`huntermartaindale/martaindale_website`) copies these files in during its
deploy (it checks this repo out as `cv-source/` and copies `cv-source/pubs/`
into the site), so the PDFs only need to live here.

## Adding a PDF for a new publication

1. Name the file: `{year}_{first-author-lastname}_{slugified-title}.pdf`
   - lowercase; the title portion is truncated to 50 characters
   - example: `2026_schildkraut_introducing-sharing-information-to-stop-mass-shoot.pdf`
2. Reference it from the matching entry in `cv_data.yaml`:
   ```yaml
   pdf: pubs/2026_schildkraut_introducing-sharing-information-to-stop-mass-shoot.pdf
   ```
3. Commit both the PDF and the `cv_data.yaml` edit, then push. The website
   rebuilds automatically (via the `cv-updated` repository_dispatch) and
   publishes the PDF and the updated publication list.

Not every publication needs a PDF; entries without a `pdf:` field simply render
without a download link.
