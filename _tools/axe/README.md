# axe accessibility audit (`_tools/axe/`)

Audits the built site with Quarto's own axe-core reporter (`format: html: axe:`)
across a **page × viewport × theme** matrix, then deduplicates findings by
root-cause and renders a drill-down report.

It **scans a pre-built `_site/`** — it does not render. Rendering stays Quarto's
job (its freeze cache, its execution env); the audit just reads the output-dir.
Background and design rationale: the audit notes in the separate `accessibility`
repo (`notes/site-audit-pathways.md`, `notes/axe-test-coverage.md`).

## Prerequisites

- **Node** (bundled with Quarto is fine) and **Python 3** (for the static server).
- **A Chrome/Chromium binary** — driven headless over the DevTools Protocol for
  viewport + `prefers-color-scheme` control. `run.sh` locates one the same way
  Quarto does, in order: `$CHROME` → `$QUARTO_CHROMIUM` → Quarto's installed
  `chrome-headless-shell` → system Chrome/Chromium/Edge/Brave. If none is found it
  tells you to run `quarto install chrome-headless-shell` (the lightweight
  headless build Quarto already uses for mermaid/typst).
- **Network access** — Quarto's `axe-check.js` fetches axe-core from a CDN at scan
  time (it is *not* bundled). Offline, the scan fails *closed* (recorded as `error`,
  never a silent pass).
- Render from a checkout that is **not nested inside another quarto-web working
  tree** — nesting breaks Quarto's project detection (see the audit notes).

## Run it

```bash
# 1. Render the whole site WITH axe enabled (freeze-backed; ~minutes).
#    --metadata-file avoids editing _quarto.yml.
quarto render --metadata-file _tools/axe/axe-meta.yml     # -> _site/

# 2. Serve, drive Chrome across the matrix, aggregate, report.
_tools/axe/run.sh                                          # -> _axe-checks/

# 3. Open the drill-down report.
open _axe-checks/report.html
```

Output lands in `_axe-checks/` (git-ignored — regenerable):

- `report.html` — the drill-down report (open this)
- `findings.json` — grouped, deduplicated findings with occurrences (the stable,
  re-groupable intermediate; also the seam for a future baseline/diff)
- `json/<page>__<viewport>__<theme>.json` — raw axe result per cell

## The three stages

| Stage | Script | In → out |
|-------|--------|----------|
| scan | `scan.mjs` | served `_site` → per-cell raw axe JSON |
| aggregate | `aggregate.mjs` | per-cell JSON → `findings.json` (grouping lives here) |
| render | `report.mjs` | `findings.json` → `table` \| `markdown` \| `html` |

`run.sh` chains all three. Run stages individually to re-group or re-render without
re-scanning, e.g. `node _tools/axe/report.mjs --file _axe-checks/findings.json --format markdown`.

## How findings are grouped

By **root-cause signature**, not exact DOM target, so one defect repeated by
shared/generated code collapses into a single finding with a multiplicity count
(hybrid: colour pair for `color-contrast`, a normalized selector otherwise). Each
finding is labelled:

- **systemic** — repeats across pages *or* many times within one page → likely a
  shared source; fix once, fixes many.
- **localized** — a single instance; that page's specific content.

This reports *evidence* (occurrences / pages), not a guess at ownership — on a site
that demos Quarto, "in the document body" is not the same as "authored here", so the
report deliberately leaves ownership to the reader.

## Coverage & options

Defaults: `pages.txt` (a layout-distinct sample — chrome recurs, so cover layouts,
not all pages) × viewports `1440x900,390x844` × themes `light,dark`.

```bash
# scan a different sample / matrix
node _tools/axe/scan.mjs --base http://localhost:8788 \
  --pages _tools/axe/pages.txt --out _axe-checks/json \
  --viewports 1440x900,390x844 --themes light,dark
```

Env overrides for `run.sh`: `SITE PAGES OUT PORT CDP CHROME QUARTO_CHROMIUM REPORT_BASE`.
`REPORT_BASE` sets the report's page links (default `https://quarto.org`, so links
persist after the local server stops).

## Known limits

- **Resting DOM only** — no hover / open-menu / focus states (a large share of real
  issues). See `axe-test-coverage.md` in the audit repo.
- **axe version is Quarto's** (fetched online), so results can shift on a Quarto
  upgrade independent of content.
