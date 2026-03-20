# Manifest Schema Reference

The manifest file (`tools/screenshots/manifest.json`) is the single source of truth
for all screenshot definitions. This document describes every field.

## Top-Level Structure

```json
{
  "defaults": { ... },
  "screenshots": [ ... ]
}
```

### `defaults`

Global settings applied to all screenshots unless overridden per-entry.

| Field | Type | Description |
|-------|------|-------------|
| `viewport` | `{ width, height }` | Default viewport size |
| `zoom` | number | Default CSS zoom factor (default: 1) |
| `compress` | boolean | Compress outputs with oxipng (default: true) |
| `trim` | boolean or object | Content-aware whitespace trimming (default: false) |
| `cleanup` | array | Cleanup steps run on every screenshot |
| `dark` | object | Dark mode configuration |

### `defaults.dark`

Controls automatic dark variant capture.

| Field | Type | Description |
|-------|------|-------------|
| `ready` | string | CSS selector to wait for after switching to dark (e.g., `body.quarto-dark`) |
| `readyLight` | string | CSS selector to wait for after switching back to light |
| `settle` | number | Milliseconds to wait after dark mode switch |

## Screenshot Entry

Each entry in the `screenshots` array defines one screenshot to capture.

```json
{
  "name": "about-jolla",
  "output": "docs/websites/images/about-jolla.png",
  "dark": true,
  "source": { ... },
  "capture": { ... },
  "doc": { ... }
}
```

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Unique identifier, used with `--name` flag |
| `output` | string | yes | Output path relative to repo root |
| `dark` | boolean | no | Produce a `-dark` variant (default: false) |
| `source` | object | yes | Where the page comes from |
| `capture` | object | no | How to capture (viewport, interactions, etc.) |
| `doc` | object | no | Which .qmd file references this image |

### `source`

Three source types:

**`example`** — a Quarto project that capture.js will **render then serve**:
```json
{
  "type": "example",
  "project": "examples/about-pages",
  "page": "about-jolla.html",
  "profile": "reader-mode"
}
```
- `project` — path relative to `tools/screenshots/`
- `page` — HTML page within the rendered site (optional, defaults to root)
- `profile` — Quarto profile name (optional, renders with `--profile <name>`)

**`url`** — a live URL (no rendering or serving):
```json
{ "type": "url", "url": "https://example.com/page.html" }
```

**`local`** — an **already-rendered** site directory that capture.js will **serve only** (no rendering):
```json
{ "type": "local", "path": "_site", "page": "docs/websites/index.html" }
```
- `path` — path to the rendered site directory (relative to repo root)
- `page` — HTML page within the site (optional, defaults to root)

Use `local` when you've already built the site (e.g., quarto-web's `_site/`) and just
need to screenshot pages from it. Use `example` when capture.js should handle
rendering the Quarto project.

### `capture`

All fields are optional. Missing fields inherit from `defaults` where applicable.

| Field | Type | Description |
|-------|------|-------------|
| `viewport` | `{ width, height }` | Viewport size (overrides default) |
| `zoom` | number | CSS zoom factor applied to body (default: 1.0) |
| `cleanup` | array | Per-screenshot cleanup steps (run after default cleanup) |
| `interaction` | array | Interaction steps before screenshot |
| `spotlight` | object | Highlight a specific element with dimmed overlay |
| `clip` | array of strings | CSS selectors — screenshot the union bounding box |
| `element` | string | CSS selector — screenshot this element only |
| `trim` | boolean or object | Content-aware whitespace trimming |
| `cropBottom` | number | Remove N pixels from bottom edge |
| `maxHeight` | number | Cap image height, crop from bottom |

### `capture.cleanup`

Array of cleanup steps. Each step runs JavaScript on the page.

```json
{ "action": "eval", "script": "document.querySelector('.banner').remove()" }
```

Only `"eval"` is supported as an action type. The `script` value is passed to
`page.evaluate()`.

Cleanup runs:
1. Default cleanup steps first
2. Per-screenshot cleanup steps second
3. Spotlight applied after all cleanup
4. Re-run after dark mode switch (CSS overrides may be clobbered by theme)

### `capture.interaction`

Array of interaction steps run after cleanup, before screenshot.

| Action | Fields | Description |
|--------|--------|-------------|
| `click` | `selector`, `wait` (optional) | Click element, optionally wait for selector |
| `hover` | `selector` | Hover over element |
| `wait` | `selector`, `timeout` (optional) | Wait for element to appear |
| `eval` | `script` | Run JavaScript |
| `scroll` | `selector` | Scroll element into view |

Examples:
```json
{ "action": "click", "selector": ".bi-github", "wait": ".dropdown-menu.show" }
{ "action": "hover", "selector": ".nav-link" }
{ "action": "wait", "selector": ".loaded", "timeout": 5000 }
{ "action": "eval", "script": "document.querySelector('.tab').click()" }
{ "action": "scroll", "selector": "#section-3" }
```

**Stateful toggle warning:** When `dark: true`, capture.js runs interactions twice — once
for light, once for dark (after reloading the page). If an interaction clicks a **stateful
toggle** (reader mode, sidebar collapse, etc.) whose state persists in localStorage, the
second click will **deactivate** the feature instead of activating it. Use `eval` with a
guard condition instead of `click`:

```json
{ "action": "eval", "script": "if (!document.querySelector('.toggle.active')) document.querySelector('.toggle').click()" }
{ "action": "wait", "selector": ".expected-element" }
```

This does not affect stateless interactions (dropdowns, hover menus, tab clicks) which
reset on page reload.

### `capture.spotlight`

Highlights a target element by dimming the rest of the page with a semi-transparent
overlay.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `selector` | string | required | CSS selector for the highlighted element |
| `elevate` | string | — | CSS selector for an ancestor to lift above the overlay (stacking context fix) |
| `dim` | string or array | — | CSS selector(s) for siblings to fade (opacity: 0.3) |
| `overlay` | number | 0.5 | Overlay opacity (0-1) |
| `radius` | string | `"6px"` | Border radius on the highlighted element |
| `padding` | string | `"8px"` | Padding added to the highlighted element |

When `elevate` is set, the ancestor gets `z-index: 9999` to lift the entire
subtree above the overlay. Without it, the target itself gets `position: relative;
z-index: 9999`.

### `capture.clip`

Array of CSS selectors. The screenshot captures the union bounding box of all
matched elements, with 20px padding. Used when content spans multiple elements
(e.g., a navbar tools area plus its dropdown menu).

### `capture.trim`

Content-aware whitespace removal using sharp. Set `true` for defaults, or an object:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `threshold` | number | 10 | Color distance threshold for edge detection |
| `padding` | number | 20 | Uniform padding added after trimming |
| `background` | `{ r, g, b }` | auto | Background color (auto-detected from top-left pixel) |

### `doc`

Links the screenshot to its documentation file.

| Field | Type | Description |
|-------|------|-------------|
| `file` | string | Path to the .qmd file (relative to repo root) |
| `alt` | string | Alt text for the image |

## Processing Order

capture.js processes each screenshot in this order:

1. Navigate to page
2. Set viewport size
3. Apply zoom (CSS `document.body.style.zoom`)
4. Run cleanup steps (defaults + per-screenshot) + apply spotlight
5. Run interaction steps
6. Take screenshot (clip/element/viewport)
7. **Post-processing (on saved file):**
   - Trim (content-aware whitespace removal)
   - Crop (`cropBottom` then `maxHeight`)
   - Compress (oxipng)
8. Dark variant: reload page → switch to dark → repeat steps 3-7

## Validation

Run `npm run validate` to check manifest.json against the schema. Catches typos in
field names, wrong types, and missing required fields. Also runs automatically at
`capture.js` startup.

## Path Conventions

- `output` — relative to repo root (e.g., `docs/websites/images/about-jolla.png`)
- `source.project` — relative to `tools/screenshots/` (e.g., `examples/about-pages`)
- `doc.file` — relative to repo root
