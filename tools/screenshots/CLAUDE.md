# Screenshot Tooling for quarto-web

## Quick Workflow

**Automated replay (no AI):**
```bash
node tools/screenshots/capture.js                     # all screenshots
node tools/screenshots/capture.js --name navbar-tools  # specific
node tools/screenshots/capture.js --name "about-*"     # glob pattern
```

**Interactive with Claude Code:**
```
/screenshot
```

## Adding New Screenshots

1. Add entry to `tools/screenshots/manifest.json`
2. If needed, create example project in `tools/screenshots/examples/`
3. Run `/screenshot` or `capture.js`

## Visual Rules

- Always use light color scheme
- Wait for full page load (fonts and icons must render)
- Remove prerelease callouts before capture (automated in defaults)
- Remove preview/prerelease banners
- Verify Bootstrap Icons loaded (not blank boxes)
- Consistent fictional data: "Finley Malloc", "myblog", "ProjectX"

## Viewport Sizes by Category

| Category | Width | Height |
|----------|-------|--------|
| Navbar | 1440 | 400 |
| Sidebar | 400 | 300 |
| About pages | 1200 | 900 |
| Blog/full pages | 1440 | 900 |

## Tools (preference order)

1. `/screenshot` command — orchestrates render, serve, capture, compress
2. `capture.js` — automated batch replay from manifest (no AI)
3. `playwright-cli` — direct browser control for interactive/debugging use

## Environment

- `QUARTO_CMD` env var to override quarto command (default: `quarto`)
- playwright-cli must use `-s=screenshot` session flag
- oxipng compression is optional locally (CI handles it as safety net)
