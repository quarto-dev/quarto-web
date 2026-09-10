# Gallery data

How to add examples to the Quarto gallery.

The gallery has one landing page (`index.qmd`) and six category spoke pages (`reports-analytics.qmd`, `dashboards-monitoring.qmd`, `research-scholarship.qmd`, `teaching-learning.qmd`, `software-documentation.qmd`, `personal-community.qmd`).
Every card is driven by YAML under `data/` and rendered through the EJS templates in `assets/`.

## Data model

`data/<category>.yml` is the full list for one category, a flat sequence of cards.
The spoke page renders it through `assets/_card.ejs.md` with filtering, sorting, and category facets.
The first three cards in each list are the category's landing featured set.

`data/featured.yml` is the curated landing file, grouped by category.
Each category is an object with meta (`category`, `slug`, `anchor`, `page`, `icon`, `gap`, `tagline`, `capabilities`) and a `cards:` list.
`assets/_featured.ejs.md` renders up to three cards per category on the landing.

Both files use the same card shape.

| Field         | Required | Purpose                                                                                          |
| ------------- | -------- | ------------------------------------------------------------------------------------------------ |
| `name`        | yes      | Internal identifier, also the fallback title.                                                    |
| `slug`        | yes      | Category slug (`reports`, `dashboards`, `research`, `teaching`, `docs`, `personal`).             |
| `title`       | yes      | Headline shown on the card.                                                                      |
| `author`      | no       | Credit line.                                                                                     |
| `live`        | yes      | URL to the live example or PDF.                                                                  |
| `code`        | no       | URL to the source.                                                                               |
| `categories`  | yes      | Facet chips: format, project type, language; also the clickable filters.                         |
| `features`    | no       | Display-only capability chips, for example `Listings` or `brand.yml`.                            |
| `image`       | yes      | Thumbnail path, relative to `docs/gallery/`, for example `thumbnails/reports-analytics/whr.png`. |
| `alt`         | no       | Alt text for the thumbnail.                                                                      |
| `description` | yes      | One-line summary.                                                                                |
| `preview`     | no       | Featured only: hover-video base path with no extension.                                          |
| `preview-url` | no       | Featured only: page to record when `live` is not the best source.                                |

Thumbnails live under `thumbnails/<category>/<slug>.png`.
Featured hover clips live under `thumbnails/featured/<category>-<slug>.{webm,mp4}`.

## Add a normal entry

Append a card to the matching `data/<category>.yml` and set `slug` to that category's slug.

Add a thumbnail at `thumbnails/<category>/<slug>.png`, or generate one from `_tools/screenshots`.
Use `npm run capture:card-thumbs -- --name <slug>` for a normal web page.
Use `npm run capture:pdf-thumbs -- --name <slug>` when `live` points at a PDF.

The card appears on the spoke page automatically.
If it is one of the first three in the list it also becomes that category's landing featured card.

## Add a featured entry

Add or curate a card under the category's `cards:` in `data/featured.yml`; only the first three render on the landing.

For a hover video, set `preview:` to `thumbnails/featured/<category>-<slug>`, add `preview-url:` if the `live` link is not the richest page to record, then run `npm run capture:previews -- --name <slug>` from `_tools/screenshots`.
Leave `preview:` off to keep the still `image` as the poster with no motion.

The `capabilities` list on each category is the single source for the "Learn the Quarto features used" links, shown on the landing and pulled onto the spoke page.

Featured cards currently mirror the first entries of the matching `data/<category>.yml`, so keep the two in sync when curating.

## Related

`../../_tools/screenshots/README.md` is the capture tooling for thumbnails and previews.
`assets/` holds the EJS templates that render these YAML files.
`legacy/` holds the previous gallery implementation, kept for reference.
