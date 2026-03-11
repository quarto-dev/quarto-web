# Sub-plan: manifest.json Specification

Parent: `glistening-beaming-thunder.md` | Task #2

## Overview

A JSON file that maps every documentation screenshot to its source, capture config, and output path. The single source of truth for what each screenshot shows and how to recreate it.

## Format

```json
{
  "defaults": {
    "viewport": { "width": 1440, "height": 900 },
    "compress": true,
    "cleanup": [
      { "action": "eval", "script": "..." }
    ],
    "zoom": 1.0,
    "dark": {
      "toggle": ".quarto-color-scheme-toggle",
      "ready": "body.quarto-dark",
      "readyLight": "body.quarto-light",
      "settle": 500
    }
  },
  "screenshots": [ ... ]
}
```

## Screenshot Entry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | yes | Unique identifier (used with `--name` filter) |
| `output` | yes | Output PNG path relative to repo root |
| `dark` | no | `true` to auto-capture a `-dark` variant |
| `source.type` | yes | `example`, `url`, `preview`, or `local` |
| `source.project` | if example | Path to example Quarto project (relative to `tools/screenshots/`) |
| `source.profile` | no | Quarto profile name; maps to `quarto render --profile <value>` |
| `source.page` | if example/local | HTML page within rendered project |
| `source.url` | if url | Direct URL to screenshot |
| `source.path` | if preview | Path appended to preview URL template |
| `capture.viewport` | no | Override default viewport `{ width, height }` |
| `capture.zoom` | no | CSS zoom factor (default 1.0). Makes content larger, reducing blank space from element padding. Applied via `document.body.style.zoom` |
| `capture.clip` | no | Array of CSS selectors — union bounding box used as clip region |
| `capture.element` | no | CSS selector for element-level screenshot |
| `capture.interaction` | no | Array of interaction steps before capture |
| `capture.trim` | no | `true` or `{ threshold, padding }` — content-aware trim via sharp after capture. Samples top-left pixel for background, removes matching edges, extends with uniform padding. Default threshold: 10, default padding: 20. |
| `capture.cropBottom` | no | Number of pixels to remove from the bottom edge after capture/trim. For layouts where trim can't detect blank space (e.g., vertical rule lines extending full height). |
| `capture.maxHeight` | no | Maximum image height in pixels. If image exceeds this after capture/trim, crops from the bottom. |
| `capture.cleanup` | no | Array of cleanup steps (merged with defaults) |
| `doc.file` | no | Documentation .qmd file that references this screenshot |
| `doc.alt` | no | Alt text for the image (kept in sync with .qmd) |

## Source Types

**`example`** — render local Quarto project, serve, screenshot:
```json
"source": { "type": "example", "project": "examples/navbar-tools", "page": "index.html" }
```

With profile (each profile gets its own render cycle):
```json
"source": { "type": "example", "project": "examples/about-pages", "profile": "trestles", "page": "about.html" }
```

**`url`** — screenshot any URL directly:
```json
"source": { "type": "url", "url": "https://mine.quarto.pub/dashing-through-snow-py/" }
```

**`preview`** — PR preview site (URL template):
```json
"source": { "type": "preview", "path": "docs/websites/website-about.html" }
```
Script constructs: `https://deploy-preview-{PR}.quarto.org/{path}` (PR number passed via CLI flag)

**`local`** — serve from repo's `_site/` directory:
```json
"source": { "type": "local", "page": "docs/websites/website-about.html" }
```

## Dark Mode

Screenshots with `"dark": true` automatically get a `-dark` variant (e.g., `about-jolla.png` + `about-jolla-dark.png`). The `defaults.dark` config controls:
- `toggle` — CSS selector for the color scheme toggle button
- `ready` — selector to wait for after switching to dark
- `readyLight` — selector to wait for after switching back to light
- `settle` — ms to wait for CSS transitions after toggle

For screenshots with `clip`, light and dark clips are computed separately and merged into a union region so both variants have identical dimensions.

## Clip vs Element Screenshots

**`capture.zoom`** — optional CSS zoom factor (default 1.0). Applied via `document.body.style.zoom` after viewport resize, before cleanup/capture. Zoom affects element bounding boxes proportionally — a 1.15 zoom makes the element's bounding box ~15% larger in viewport pixels, naturally reducing relative blank space. About pages use 1.15.

**`capture.clip`** — array of CSS selectors. capture.js computes each element's bounding box, takes the union (with 20px padding), and uses Playwright's `page.screenshot({ clip })`. Handles overflow (e.g., dropdown menus that extend beyond parent elements). Note: clip is clamped to viewport bounds — if the element extends beyond the viewport, increase viewport height to accommodate.

**`capture.element`** — single CSS selector. Uses Playwright's `locator.screenshot()`. Clips to the element's own bounds, which can cut off overflowing content like dropdowns.

Prefer `clip` for anything involving dropdowns or overflow.

## Profile-Aware Grouping

`capture.js` groups screenshots by source to avoid redundant renders. When `source.profile` is set, the group key includes the profile (`examples/about-pages:trestles`), so each profile gets its own render → serve → capture cycle.

## Interaction & Cleanup Step Types

```json
{ "action": "click", "selector": ".bi-github", "wait": ".dropdown-menu.show" }
{ "action": "hover", "selector": ".nav-link" }
{ "action": "wait", "selector": ".loaded", "timeout": 5000 }
{ "action": "scroll", "selector": "#section" }
{ "action": "eval", "script": "document.querySelector('.banner')?.remove()" }
```

## PR #1815 Screenshots (8 entries)

### 1. navbar-tools
```json
{
  "name": "navbar-tools",
  "output": "docs/websites/images/navbar-tools.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/navbar-tools", "page": "index.html" },
  "capture": {
    "viewport": { "width": 1440, "height": 400 },
    "interaction": [
      { "action": "click", "selector": ".bi-github", "wait": ".dropdown-menu.show" }
    ],
    "clip": [".quarto-navbar-tools", ".dropdown-menu.show"]
  }
}
```

### 2. sidebar-tools
```json
{
  "name": "sidebar-tools",
  "output": "docs/websites/images/tools.png",
  "dark": true,
  "source": { "type": "url", "url": "https://quarto-dev.github.io/quarto-demo/html-themes.html" },
  "capture": {
    "viewport": { "width": 992, "height": 600 },
    "interaction": [
      { "action": "click", "selector": "#quarto-navigation-tool-dropdown-0", "wait": ".dropdown-menu.show" }
    ],
    "clip": ["#quarto-sidebar", ".dropdown-menu.show"],
    "maxHeight": 320
  }
}
```
Note: Uses `#quarto-navigation-tool-dropdown-0` instead of `.bi-github` because quarto-demo pages have multiple GitHub icons (sidebar tools, "Edit this page", TOC actions). Source is the live quarto-demo site (has dark mode: cosmo light / darkly dark).

### 3-7. about-* (5 templates via profiles)
All share source project `examples/about-pages` and page `about.html`. Each uses a different Quarto profile to select the template:

| Name | Profile | Clip selector | Viewport |
|------|---------|---------------|----------|
| about-jolla | jolla | `.quarto-about-jolla` | 1200x900 |
| about-trestles | trestles | `.quarto-about-trestles` | 1200x900 |
| about-solana | solana | `.quarto-about-solana` | 1200x900 |
| about-marquee | marquee | `.quarto-about-marquee` | 1200x900 |
| about-broadside | broadside | `.quarto-about-broadside` | 1200x900 |

All reference `docs/websites/website-about.qmd`.

### 8. myblog
```json
{
  "name": "myblog",
  "output": "docs/websites/images/myblog.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/myblog", "page": "index.html" },
  "capture": { "viewport": { "width": 1440, "height": 900 } }
}
```
