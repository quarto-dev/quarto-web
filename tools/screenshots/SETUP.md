# Screenshot Setup Guide

Tooling for capturing and maintaining documentation screenshots in quarto-web.

## Prerequisites

- **Node.js 18+** — required for scripts and Playwright
- **Quarto** — required for rendering example projects (set `QUARTO_CMD` env var if your binary has a different name)

## Option A: Automated Replay (no AI)

```bash
# One-time: install dependencies and browser
cd tools/screenshots
npm install
npx playwright install chromium

# Capture all screenshots (light + dark variants):
npm run capture                          # all screenshots
npm run capture -- --name navbar-tools   # specific
npm run capture -- --name "about-*"      # glob pattern
npm run capture -- --dry-run             # preview what would be captured
npm run capture -- --list                # list manifest entries

# Or from repo root:
node tools/screenshots/capture.js
node tools/screenshots/capture.js --name navbar-tools
```

## Option B: Interactive with Claude Code

```bash
# One-time: install playwright-cli skill
playwright-cli install --skills

# Use the /screenshot command
/screenshot
```

## Option C: Manual with playwright-cli

```bash
# 1. Render example project
quarto render tools/screenshots/examples/about-pages

# 2. Serve the rendered site
node tools/screenshots/scripts/serve.js tools/screenshots/examples/about-pages/_site
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
tools/screenshots/
├── manifest.json          # screenshot definitions (single source of truth)
├── capture.js             # replay script (uses Playwright API directly)
├── package.json           # dependencies: playwright, open
├── CLAUDE.md              # visual rules for Claude
├── SETUP.md               # this file
├── scripts/
│   ├── list.js            # read + format manifest
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
- `source` — where to get the page (example project, URL, or local)
- `capture` — viewport, interactions, clip selectors, element selector
- `doc` — which .qmd file references this image

Dark mode works by clicking the Quarto color scheme toggle (`.quarto-color-scheme-toggle`). Example projects must have `theme: { light: cosmo, dark: darkly }` in `_quarto.yml`.

See `manifest.json` for the full schema.
