# Screenshot Tooling for quarto-web

## How It Works

**manifest.json** defines every screenshot: what to capture, where to save it, viewport
size, interactions, and cleanup steps. **capture.js** reads the manifest and produces
the screenshots. Everything flows through the manifest.

## Updating Screenshots

If the screenshot already exists in the manifest and examples are ready:

    npm run capture                          # all
    npm run capture -- --name navbar-tools   # specific
    npm run capture -- --name "about-*"      # glob

Verify the output visually. If it looks right, you're done.

If it needs tweaking (wrong viewport, missing interaction, layout issue), use
`/screenshot` for AI-assisted iteration on the manifest entry and example project,
then re-run `npm run capture`.

## Creating New Screenshots

Use `/screenshot` to walk through the process:

1. Create or identify the source (example project in `examples/`, live URL, or local site)
2. Explore interactively with playwright-cli to determine viewport, element,
   interactions, and cleanup steps
3. Encode the findings into a manifest.json entry
4. Run `npm run capture` to produce the final image
5. Verify output — iterate on manifest/example if needed

## Tools

| Tool | Role |
|------|------|
| `manifest.json` | Source of truth — defines all screenshots |
| `npm run capture` | Execution — reads manifest, produces images |
| `/screenshot` + capture agent | Design — AI helps create/refine manifest entries and examples |
| `playwright-cli` | Exploration — interactive browser for figuring out what to capture |
| `npm run render` | Render example Quarto projects |
| `npm run serve` | Serve rendered sites locally |
| `npm run compress` | Compress PNGs with oxipng |
| `npm run help` | Show available commands |

## Manifest

Single source of truth: `tools/screenshots/manifest.json`

Path conventions:
- `output` — relative to repo root (e.g., `docs/websites/images/about-jolla.png`)
- `source.project` — relative to `tools/screenshots/` (e.g., `examples/about-pages`)
- `doc.file` — relative to repo root

## Dark Mode

Screenshots with `"dark": true` get a `-dark` variant automatically.
Use `.include-dark` class on images in .qmd files so the include-dark.lua filter
generates both light/dark `<img>` tags.

Dark mode switching uses `window.quartoToggleColorScheme()` via `page.evaluate()`.
This is the same function the toggle button calls — it switches stylesheets, toggles
`quarto-dark`/`quarto-light` body classes, and persists to localStorage. Using JS
instead of clicking avoids issues at narrow viewports where the navbar collapses and
the toggle is hidden.

Cleanup and interactions are re-run after switching to dark mode so that CSS
overrides are reapplied (dark theme CSS can clobber inline style changes).

**Stateful toggle caution:** Interactions that click a stateful toggle (reader mode,
sidebar collapse) will break on the dark pass if the toggle state persists in
localStorage — the reload inherits the active state, so clicking again deactivates it.
Use an `eval` guard instead of `click`. See `manifest-schema.md` for the pattern.

## Visual Rules

- Light color scheme first (dark captured automatically)
- Wait for full page load (fonts and icons must render)
- Remove prerelease callouts (automated in manifest defaults)
- Verify Bootstrap Icons loaded (not blank boxes)
- Consistent fictional data: "Finley Malloc", "myblog", "ProjectX"
- When replacing an existing screenshot, always `npm run open` both the existing
  image and the new capture for side-by-side comparison before asking for approval

## Zoom

`capture.zoom` (optional, default 1.0) — CSS zoom factor applied to the page body
before capture. Makes content larger relative to the viewport, reducing blank space
from element internal padding.

Applied after viewport resize, before cleanup/interactions/screenshot.
Can be set per-screenshot in `capture.zoom` or globally in `defaults.zoom`.

Example: `"zoom": 1.15` makes content 15% larger. About pages use 1.15.

## Cleanup

`capture.cleanup` (optional) — array of actions to run after page load, before
screenshot. Each action has an `action` type and relevant parameters.

Supported actions:
- `{ "action": "eval", "script": "..." }` — run JavaScript on the page

Cleanup runs in both light and dark modes. After switching to dark mode, cleanup
is re-run so that CSS property overrides (which may be clobbered by the dark theme)
are reapplied. DOM mutations like `display: none` persist across theme switches,
but re-running cleanup is harmless for idempotent operations.

## Spotlight

`capture.spotlight` (optional) — dims the page with a semi-transparent overlay while
highlighting a specific element. Useful for drawing attention to a UI feature in
documentation screenshots (e.g., repo-actions links, sidebar tools).

```json
"spotlight": {
  "selector": ".toc-actions",
  "elevate": "#quarto-margin-sidebar",
  "dim": "#TOC.toc-active > ul:first-of-type",
  "overlay": 0.5,
  "radius": "6px",
  "padding": "8px"
}
```

| Field | Type | Default | Description |
|---|---|---|---|
| `selector` | string | required | CSS selector for element to highlight |
| `elevate` | string | null | Ancestor to lift above overlay (stacking context fix) |
| `dim` | string or string[] | null | Sibling elements to fade within the elevated container |
| `overlay` | number | 0.5 | Overlay opacity (0.0–1.0) |
| `radius` | string | `"6px"` | Border-radius on spotlit element |
| `padding` | string | `"8px"` | Padding around spotlit element |

### Stacking contexts and `elevate`

CSS stacking contexts trap child z-indexes. Quarto layouts commonly have ancestors
with `position: sticky` + `z-index` (e.g., `#quarto-margin-sidebar`), so setting
z-index on the target alone has no visible effect.

**When `elevate` is needed:** If the target's ancestor creates a stacking context,
set `elevate` to that ancestor's selector. This lifts the entire container above the
overlay, then use `dim` to fade other elements inside it.

**When `elevate` is NOT needed:** If the target has no stacking context ancestors
(direct child of body, all ancestors are `static`), the simple spotlight works — the
target gets `position: relative; z-index: 9999` automatically.

**How to diagnose:** Walk up the DOM from the target checking `getComputedStyle` for
`position` (not static) + `z-index` (not auto). Use Chrome DevTools MCP
(`evaluate_script`) for faster iteration than playwright-cli.

### Constraints

- **Incompatible with `trim: true`** — the overlay changes the background color that
  trim uses for edge detection.
- **Only useful with viewport or clip capture** — element capture (`capture.element`)
  clips to the element bounds, cutting out the overlay entirely.

## Trim

`capture.trim` (optional, default false) — content-aware whitespace removal via sharp.
Samples the top-left pixel for background color, removes matching edges, then adds
uniform padding back (default 20px).

Set `"trim": true` for defaults, or `"trim": { "threshold": 10, "padding": 20 }` to
customize. Handles both light and dark screenshots automatically (detects background
from each image independently).

### When to use trim vs crop

**Crop is more faithful** — it preserves real page margins (top, left, right) as
rendered in the browser. Only the bottom is affected. Use when the screenshot should
match what a user actually sees on screen.

**Trim produces a clean, uniform result** — it replaces real margins with synthetic
uniform padding (default 20px on all sides). Use for isolated element captures where
a consistent presentation matters more than fidelity to the page layout.

**Use `cropBottom`/`maxHeight`** when:
- You want to preserve real page margins (more faithful to what the user sees)
- Layout has vertical rule lines extending to the image edge (e.g., trestles template)
- Multi-colored backgrounds (e.g., colored sidebars alongside main content)
- Top-left pixel isn't representative of the background (trim samples pixel at 0,0)

`trim` and `cropBottom`/`maxHeight` can be combined — trim runs first, then crop.

## Crop

`capture.cropBottom` (optional) — removes N pixels from the bottom edge after
capture/trim. For layouts where trim can't detect blank space (e.g., trestles
template has a vertical rule extending the full height).

`capture.maxHeight` (optional) — caps the image height. If the image exceeds this
after capture/trim, crops from the bottom.

Both can be combined. `cropBottom` is applied first, then `maxHeight`.

## Viewport Sizes

| Category | Width | Height |
|----------|-------|--------|
| Navbar | 1440 | 400 |
| Sidebar | 992 | 600 |
| About pages | 1200 | 900 |
| Blog/full pages | 1440 | 900 |

## Compression

- `npm run compress` — compresses all manifest outputs (runs oxipng if available)
- `npm run compress -- file.png` — compress specific files
- CI compresses all changed PNGs after merge (safety net)
- `npm run capture` compresses by default (`--no-compress` to skip)

## Environment

- `package.json` lives in `tools/screenshots/` — run `npm` commands from that directory
- `QUARTO_CMD` env var to override quarto command (default: `quarto`)
- Playwright is an npm dependency (no global install needed)
- `playwright-cli -s=screenshot` for interactive exploration
