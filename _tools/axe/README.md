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
  re-groupable intermediate); each finding carries a `baselined` flag (see
  [Baseline](#baseline-focus-on-new-findings))
- `README.md` — an orientation doc for an AI/agent: what the results are, the
  `findings.json` schema, and how to fix issues in a Quarto site
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

## Baseline (focus on new findings)

`baseline.json` (next to the scripts) is a ledger of findings **accepted at a point
in time** — shared-chrome defects, issues tracked upstream, deferred best-practice
items. Any finding whose signature is in the baseline is marked `baselined: true`,
dropped from the "new" list, and tucked into a collapsed *Known / baselined* section
of the report. So you act only on genuinely new findings.

The key property: the baseline is keyed by each finding's **page-independent
signature** (the same key used for grouping — a colour pair for `color-contrast`, a
normalized selector otherwise). Suppression is therefore **by signature, never by page
or count**. A known navbar/footer/sidebar defect stays suppressed when it recurs on a
newly-added page — its signature is identical regardless of which page it's on — so
**expanding `pages.txt` surfaces only genuinely new root causes.** (A finding sitting in
a page-type-specific selector, e.g. a homepage-only `#quarto-content > …`, is naturally
page-scoped and won't auto-suppress on a different layout — correct, since it isn't the
same recurring instance.)

Workflow:

```bash
# Capture / re-capture the baseline from the current findings.
UPDATE_BASELINE=1 _tools/axe/run.sh
# …or without re-scanning, straight from existing per-cell dumps:
node _tools/axe/aggregate.mjs --dir _axe-checks/json --out _axe-checks/findings.json --update-baseline
```

`--update-baseline` **merges and adds, never drops**: newly-seen signatures are
appended; existing entries — and any hand-written `note` you add per entry (e.g.
`"tracked upstream quarto-cli#14378"`) — are preserved, even for signatures not seen in
this run (a partial scan must not discard entries for pages it didn't visit). Baseline
entries not present in the current scan are reported as **stale**; if it was a full-page
scan they're resolved and safe to prune by hand — if a subset scan, they may just live
on unscanned pages. `baseline.json` is committed (unlike the git-ignored `_axe-checks/`),
so the accepted set is shared and reviewable.

## Getting AI help to fix findings

The HTML report is built for handing findings to an AI, two ways:

- **Chat mode** (paste into any assistant) — the **copy** button on each report row
  puts a self-contained markdown briefing on the clipboard: the rule, WCAG criterion,
  severity, scope ("fix once → N occurrences" for systemic), the failing elements,
  axe's help URL, and a preamble that steers the fix toward the Quarto *source*
  (`.qmd`, `_quarto.yml`, `brand.yml`, theme SCSS) rather than the generated HTML.
- **Agent mode** (the AI has the repo, e.g. Claude Code) — point it at
  `_axe-checks/README.md`, which orients it (what the results are, the `findings.json`
  schema, how to fix issues in a Quarto site) and hands off to `findings.json`. Each
  finding has a stable **id** (e.g. `link-name-7b818f`, click to copy in the report),
  so "fix `link-name-7b818f` from `_axe-checks/findings.json`" resolves to the full,
  lossless record (every occurrence + selector).

## Coverage & options

Defaults: `pages.txt` (a layout-distinct sample — chrome recurs, so cover layouts,
not all pages) × viewports `1440x900,390x844` × themes `light,dark`.

```bash
# scan a different sample / matrix
node _tools/axe/scan.mjs --base http://localhost:8788 \
  --pages _tools/axe/pages.txt --out _axe-checks/json \
  --viewports 1440x900,390x844 --themes light,dark
```

Env overrides for `run.sh`: `SITE PAGES OUT PORT CDP CHROME QUARTO_CHROMIUM REPORT_BASE`
and `UPDATE_BASELINE` (set to re-capture the baseline — see above). `REPORT_BASE` sets
the report's page links (default `https://quarto.org`, so links persist after the local
server stops).

## Known limits

- **Resting DOM only** — no hover / open-menu / focus states (a large share of real
  issues). See `axe-test-coverage.md` in the audit repo.
- **Client-side-rendered content races the scan** — axe runs when Quarto's
  `axe-check.js` reports complete, which does **not** wait for content that renders
  after load: Mermaid, OJS, Plotly, htmlwidgets, leaflet, etc. So a scan may sample a
  transient pre-render state, giving **flaky false positives** that don't reproduce
  every run. Observed example: a Mermaid diagram's source `<pre class="mermaid">` is
  briefly styled black-on-dark before it becomes an SVG, so it intermittently trips
  `color-contrast` (`#000000 on #151515 = 1.14`) in dark mode only. Treat findings
  whose element is a JS-rendered widget (`.mermaid`, `.ojs-*`, `.plotly`, …) as
  "verify manually," not hard failures. (The real fix is upstream: have axe wait for
  network-idle / render-settle before running.)
- **axe version is Quarto's** (fetched online), so results can shift on a Quarto
  upgrade independent of content.
