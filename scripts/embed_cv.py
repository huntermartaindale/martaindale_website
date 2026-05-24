#!/usr/bin/env python3
"""Embed the rendered CV body into the website's cv.html.

The website's cv.qmd holds a <!-- CV_CONTENT --> placeholder inside a
<div class="cv-embed">. This script reads the CV repo's rendered cv.html
(produced by `quarto render` in the cv-source directory), extracts the
<main> content, strips the duplicate Quarto title block, and substitutes
it into the website's _site/cv.html at the placeholder.

Run AFTER the website renders and BEFORE deploy.
"""

from pathlib import Path
import re
import sys

CV_SOURCE = Path("cv-source/cv.html")
SITE_CV   = Path("_site/cv.html")
MARKER    = "<!-- CV_CONTENT -->"


def main() -> int:
    if not CV_SOURCE.exists():
        print(f"ERROR: {CV_SOURCE} not found", file=sys.stderr)
        return 1
    if not SITE_CV.exists():
        print(f"ERROR: {SITE_CV} not found", file=sys.stderr)
        return 1

    cv_html   = CV_SOURCE.read_text(encoding="utf-8")
    site_html = SITE_CV.read_text(encoding="utf-8")

    main_match = re.search(r"<main\b[^>]*>(.*?)</main>", cv_html, re.DOTALL)
    if not main_match:
        print("ERROR: could not find <main> in CV", file=sys.stderr)
        return 1
    cv_content = main_match.group(1)

    # Strip duplicate Quarto title block (ID collides with the host page's).
    cv_content = re.sub(
        r'<header\b[^>]*id="title-block-header"[^>]*>.*?</header>',
        '',
        cv_content,
        flags=re.DOTALL,
    )

    if MARKER not in site_html:
        print(f"ERROR: marker {MARKER!r} not found in {SITE_CV}", file=sys.stderr)
        return 1

    site_html = site_html.replace(MARKER, cv_content)
    SITE_CV.write_text(site_html, encoding="utf-8")
    print(f"Embedded {len(cv_content):,} chars of CV content into {SITE_CV}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
