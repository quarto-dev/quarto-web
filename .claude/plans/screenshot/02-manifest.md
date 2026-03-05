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
    "waitUntil": "networkidle",
    "cleanup": [
      { "action": "eval", "script": "document.querySelectorAll('.callout-note').forEach(el => { if (el.textContent.includes('Pre-release')) el.remove() })" },
      { "action": "eval", "script": "document.querySelectorAll('[class*=prerelease],[class*=preview]').forEach(el => el.remove())" }
    ]
  },
  "screenshots": [ ... ]
}
```

## Screenshot Entry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | yes | Unique identifier (used with `--name` filter) |
| `output` | yes | Output PNG path relative to repo root |
| `source.type` | yes | `example`, `url`, `preview`, or `local` |
| `source.project` | if example | Path to example Quarto project (relative to `tools/screenshots/`) |
| `source.page` | if example/local | HTML page within rendered project |
| `source.url` | if url | Direct URL to screenshot |
| `source.path` | if preview | Path appended to preview URL template |
| `capture.viewport` | no | Override default viewport `{ width, height }` |
| `capture.element` | no | CSS selector for element-level screenshot |
| `capture.fullPage` | no | `true` for full scrollable page capture |
| `capture.interaction` | no | Array of interaction steps before capture |
| `capture.cleanup` | no | Array of cleanup steps (merged with defaults) |
| `doc.file` | no | Documentation .qmd file that references this screenshot |
| `doc.line` | no | Line number of the image reference |
| `doc.alt` | no | Alt text for the image (kept in sync with .qmd) |

## Source Types

**`example`** — render local Quarto project, serve, screenshot:
```json
"source": { "type": "example", "project": "examples/navbar-tools", "page": "index.html" }
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
  "source": { "type": "example", "project": "examples/navbar-tools", "page": "index.html" },
  "capture": {
    "viewport": { "width": 1440, "height": 400 },
    "interaction": [
      { "action": "click", "selector": ".bi-github", "wait": ".dropdown-menu.show" }
    ],
    "element": ".navbar"
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "line": 112,
    "alt": "The right section of a Quarto navbar containing a Bluesky and Github logo. The Github logo is selected and a menu is underneath it with two items: 'Source Code' and 'Report a Bug'"
  }
}
```

### 2. sidebar-tools
```json
{
  "name": "sidebar-tools",
  "output": "docs/websites/images/tools.png",
  "source": { "type": "example", "project": "examples/sidebar-tools", "page": "index.html" },
  "capture": {
    "viewport": { "width": 400, "height": 300 },
    "interaction": [
      { "action": "click", "selector": ".bi-github", "wait": ".dropdown-menu.show" }
    ],
    "element": ".sidebar-tools-main"
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "line": 276,
    "alt": "The top section of a Quarto sidebar containing a Bluesky and Github logo. The Github logo is selected and a menu is underneath it with two items: 'Source Code' and 'Report a Bug'"
  }
}
```

### 3-7. about-* (5 templates)
All share source project `examples/about-pages`, differ by page and template name:

| Name | Page | Viewport | Doc line |
|------|------|----------|----------|
| about-jolla | jolla.html | 1200x900 | 69 |
| about-trestles | trestles.html | 1200x900 | 73 |
| about-solana | solana.html | 1200x900 | 77 |
| about-marquee | marquee.html | 1200x900 | 81 |
| about-broadside | broadside.html | 1200x900 | 85 |

All reference `docs/websites/website-about.qmd`. Alt text updated to replace "twitter" with "Bluesky"/"bluesky".

### 8. myblog
```json
{
  "name": "myblog",
  "output": "docs/websites/images/myblog.png",
  "source": { "type": "example", "project": "examples/myblog", "page": "index.html" },
  "capture": {
    "viewport": { "width": 1440, "height": 900 }
  },
  "doc": {
    "file": "docs/websites/website-blog.qmd",
    "line": 111,
    "alt": "Screenshot of a blog page. There is a navigation bar at the top with the blog title ('myblog') on the left, and on the right: 'About', a GitHub icon, a Bluesky icon, and a Search icon. The body has two posts listed with titles, tags, description and preview ordered by date. On the right of the body are categories with counts of posts next to them."
  }
}
```
