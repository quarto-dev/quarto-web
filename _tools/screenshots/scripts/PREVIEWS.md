# Gallery featured video previews

`capture-previews.mjs` generates the short, muted, looping clips that featured
gallery cards play on hover or keyboard focus. The rendering,
interaction, and reduced-motion handling live in the gallery, not here:
`docs/gallery/assets/_featured.ejs.md` and `docs/gallery/assets/_gallery.scss`.

This script is separate from the still-screenshot manifest (`capture.js`): it
records motion rather than a single frame, and is driven by gallery data rather
than `manifest.json`.

## How it works

- Driven by `docs/gallery/data/featured.yml`: every card with both a `live` URL
  and a `preview` base path gets a clip. `preview:` is the output path without
  extension, e.g. `thumbnails/featured/software-documentation-gribouille`.
- Optional `preview-url:` overrides the page that is recorded when the card's
  `live` link is not the best source (e.g. a landing page vs a richer subpage). The
  card's `live` link is unchanged; only the capture source differs.
- Output: `<preview>.webm` (VP9) and `<preview>.mp4` (H.264) under
  `docs/gallery/thumbnails/featured/` (animated previews are a featured-only
  asset), beside the still PNG (`image:`), which stays the `<video>` poster.
- Capture mode comes from the card's `categories`:
  - **reveal.js** (`revealjs`/`presentation`) → step through a few slides with
    ArrowRight.
  - **everything else** → scroll the page top to bottom.
- The blank page-load lead-in is measured and trimmed from the encode, so clips
  open on real content and loop without a white flash.
- Each file is size-budgeted; the script warns above 500 KB.

Cards without a `preview:` field keep the static PNG. Leave it off for pages that
do not benefit: single-screen dashboards, PDF/blob `live` URLs, or sites that block
headless capture.

## Prerequisites

- **ffmpeg** on `PATH` (`brew install ffmpeg`). Playwright records VP8 webm only;
  ffmpeg re-encodes to a smaller VP9 webm and an H.264 mp4 for Safari/broad support.
- **A full Playwright Chromium** — the headless shell cannot record video. The
  script defaults to the installed `chromium-*/chrome-mac-arm64` build; set
  `PREVIEW_CHROME` to override the path (`npx playwright install chromium`).
- **This tool's dependencies installed** — `npm install` in `_tools/screenshots`
  (the script uses the tool's `playwright` and `js-yaml`).

## Usage

From `_tools/screenshots`:

```bash
npm run capture:previews                 # every preview card
npm run capture:previews -- --name whr   # match by name or preview path
npm run capture:previews -- --limit 2    # first N matches (staging)
```

After capturing, re-render the landing (`quarto render docs/gallery/index.qmd`) and
check the clips in the browser in both themes.

# PDF card thumbnails

`capture-pdf-thumbs.mjs` builds the still `image` for cards whose `live` URL is a
PDF, rendering the PDF's first two pages (or the first page alone when it has only
one) into a side-by-side spread that overwrites the card's existing thumbnail.

- Driven by `docs/gallery/data/*.yml`: every card with a `.pdf` `live` URL. GitHub
  `blob` URLs are rewritten to `raw.githubusercontent.com` before download.
- Output: overwrites the card's `image` PNG under `docs/gallery/thumbnails/`.
- Prerequisites: **poppler** (`pdfinfo`, `pdftoppm`) and **ImageMagick** (`magick`)
  on `PATH` (`brew install poppler imagemagick`).

```bash
npm run capture:pdf-thumbs                 # every PDF-linked card
npm run capture:pdf-thumbs -- --name whr   # match by name or image path
npm run capture:pdf-thumbs -- --limit 1    # first N matches (staging)
```

# Card thumbnails for image-less entries

`capture-card-thumbs.mjs` fills the `image` for cards that have none yet and whose
`live` URL is a normal web page (PDF-linked cards go through `capture-pdf-thumbs.mjs`).
It screenshots the page top to `docs/gallery/thumbnails/<category>/<slug>.png`,
dismissing a cookie/consent banner first, then prints the `image:` and a placeholder
`alt:` line to add to the card (it does not edit the YAML).

```bash
npm run capture:card-thumbs                 # every image-less web card
npm run capture:card-thumbs -- --name rap   # match by name
npm run capture:card-thumbs -- --limit 1    # first N matches (staging)
```
