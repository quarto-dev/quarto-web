# Screenshot Setup Guide

Tooling for capturing and maintaining documentation screenshots in quarto-web.

## Prerequisites

- **Node.js 18+** — required for scripts and Playwright
- **Quarto** — required for rendering example projects (set `QUARTO_CMD` env var if your binary has a different name)

## Quick Start

Most screenshots already exist in the manifest. Install dependencies and run `capture.js`:

```bash
# One-time: install dependencies and browser
cd _tools/screenshots
npm install
npx playwright install chromium

# Capture all screenshots (light + dark variants):
npm run capture                          # all screenshots
npm run capture -- --name navbar-tools   # specific
npm run capture -- --name "about-*"      # glob pattern
npm run capture -- --dry-run             # preview what would be captured
npm run capture -- --list                # list manifest entries
npm run validate                         # validate manifest against schema

# Or from repo root:
node _tools/screenshots/capture.js
node _tools/screenshots/capture.js --name navbar-tools
```

## Interactive with Claude Code

Use `/screenshot` for creating new screenshots or iterating on existing ones:

```bash
# One-time: install playwright-cli skill
playwright-cli install --skills

# Use the /screenshot command
/screenshot
```

## Manual Exploration with playwright-cli

For debugging or figuring out what to capture interactively:

```bash
# 1. Render example project
quarto render _tools/screenshots/examples/about-pages

# 2. Serve the rendered site
node _tools/screenshots/scripts/serve.js _tools/screenshots/examples/about-pages/_site
# → prints http://localhost:<port>

# 3. In another terminal, capture
playwright-cli -s=screenshot open http://localhost:<port>/jolla.html
playwright-cli -s=screenshot resize 1200 900
playwright-cli -s=screenshot screenshot --filename=docs/websites/images/about-jolla.png
playwright-cli -s=screenshot close
```

## Optional: PNG Compression

```bash
# Windows
scoop install oxipng

# macOS
brew install oxipng

# Cargo
cargo install oxipng
```

A CI workflow compresses changed PNGs after merge to main. Local install is optional but keeps PR images smaller during review.

## File Structure

```
_tools/screenshots/
├── manifest.json          # screenshot definitions (single source of truth)
├── manifest-schema.json   # JSON Schema for manifest validation + IDE autocompletion
├── capture.js             # replay script (uses Playwright API directly)
├── package.json           # dependencies: playwright, open, ajv, sharp
├── CLAUDE.md              # visual rules for Claude
├── SETUP.md               # this file
├── scripts/
│   ├── help.js            # print available commands
│   ├── list.js            # read + format manifest
│   ├── validate.js        # manifest schema validation (CLI + importable)
│   ├── render.js          # quarto render wrapper
│   ├── serve.js           # static file server
│   ├── open.js            # open file with OS default app
│   └── compress.js        # oxipng wrapper
└── examples/
    ├── about-pages/       # about page templates (light + dark theme)
    └── navbar-tools/      # navbar with dropdown (light + dark theme)
```

## Manifest Format

Each screenshot in `manifest.json` specifies:
- `name` — unique identifier
- `output` — output PNG path (relative to repo root)
- `dark` — if `true`, also captures a `-dark` variant (e.g. `about-jolla-dark.png`)
- `source` — where to get the page (example project or URL)
- `capture` — viewport, zoom, interactions, clip selectors, element selector
- `doc` — which .qmd file references this image

Dark mode switches via `window.quartoToggleColorScheme()` (JS eval, not a CSS selector click). Example projects must have `theme: { light: cosmo, dark: darkly }` in `_quarto.yml`.

Optional `capture.zoom` (e.g., `1.15`) applies CSS zoom before capture, making content larger and reducing blank space from element padding. About pages use zoom 1.15.

Optional `capture.trim` (`true` or `{ threshold, padding }`) removes whitespace borders after capture using sharp. Samples the top-left pixel for background color, trims matching edges, adds uniform padding back (default 20px). Works for both light and dark screenshots.

Optional `capture.cropBottom` (pixels) removes a fixed number of pixels from the bottom edge. Optional `capture.maxHeight` (pixels) caps the image height — crops from bottom if exceeded. Use these when trim can't detect blank space (e.g., vertical rule lines extending to the edge).

See `manifest.json` for the full schema.
