# Screenshot and preview tooling

Scripts to capture and update quarto-web's documentation images and gallery media.

There are two families.
Doc screenshots come from `manifest.json` through `capture.js`.
Gallery assets come from `docs/gallery/data/*.yml` through the `scripts/capture-*.mjs` scripts.

Run every command from `_tools/screenshots/`.

## Which tool makes what

| Asset                                     | Command                       | Script                             | Output                                          |
| ----------------------------------------- | ----------------------------- | ---------------------------------- | ----------------------------------------------- |
| Doc screenshots (PNG, light and dark)     | `npm run capture`             | `capture.js` (manifest)            | `docs/**/images/*.png`                          |
| Gallery hover previews (webm and mp4)     | `npm run capture:previews`    | `scripts/capture-previews.mjs`     | `docs/gallery/thumbnails/featured/*.{webm,mp4}` |
| Gallery PDF card thumbnails (PNG)         | `npm run capture:pdf-thumbs`  | `scripts/capture-pdf-thumbs.mjs`   | `docs/gallery/thumbnails/**/*.png`              |
| Gallery card thumbnails, image-less (PNG) | `npm run capture:card-thumbs` | `scripts/capture-card-thumbs.mjs`  | `docs/gallery/thumbnails/<category>/<slug>.png` |
| axe DevTools console (PNG, manual, macOS) | see script header             | `scripts/capture-axe-devtools.mjs` | `docs/output-formats/images/axe-console.png`    |

Only `npm run capture:previews` makes the mp4 and webm hover clips.

Each `capture:*` gallery command takes `-- --name <pattern>` to match a subset.
Each also takes `-- --limit <n>` to stage the first `n` matches.

## Prerequisites at a glance

All commands need Node.js 18+ and this tool's dependencies (`npm install`, then `npx playwright install chromium`).

`capture:previews` also needs ffmpeg on `PATH` and a full Playwright Chromium; set `PREVIEW_CHROME` to point at it because the headless shell cannot record video.

`capture:pdf-thumbs` also needs poppler (`pdfinfo`, `pdftoppm`) and ImageMagick (`magick`).

Full setup steps are in `SETUP.md`.
The gallery prerequisites are detailed in `scripts/PREVIEWS.md`.

## Where to read next

`SETUP.md` covers install steps and the still-screenshot workflow.
`scripts/PREVIEWS.md` covers gallery video previews plus PDF and card thumbnails in detail.
`docs/gallery/README.md` covers how to add the gallery entries these thumbnails serve.
`CLAUDE.md` covers the AI-assisted workflow and the `manifest.json` field reference.
`DECISIONS.md` covers why the tooling is built the way it is.
`npm run help` prints the full command list.
