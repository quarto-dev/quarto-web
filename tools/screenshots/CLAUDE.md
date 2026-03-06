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

## Manifest Path Conventions

- `output` paths are relative to the **repo root** (e.g., `docs/websites/images/about-jolla.png`)
- `source.project` paths are relative to **tools/screenshots/** (e.g., `examples/about-pages`)
- `doc.file` paths are relative to the **repo root**

## Adding New Screenshots

1. Add entry to `tools/screenshots/manifest.json`
2. If needed, create example project in `tools/screenshots/examples/`
3. Set `"dark": true` if the screenshot needs a dark mode variant
4. Ensure example `_quarto.yml` has `theme: { light: cosmo, dark: darkly }` for dark support
5. Run `/screenshot` or `capture.js`

## Dark Mode

Screenshots with `"dark": true` in the manifest automatically get a `-dark` variant:
- `about-jolla.png` → also generates `about-jolla-dark.png`
- The dark variant is captured by clicking the Quarto color scheme toggle
- Use `.include-dark` class on images in .qmd files so the filter generates both light/dark `<img>` tags

## Visual Rules

- Default to light color scheme (dark captured automatically when `dark: true`)
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
2. `capture.js` — automated batch replay from manifest (no AI, uses Playwright API directly)
3. `playwright-cli` — direct browser control for interactive/debugging use

## Environment

- `QUARTO_CMD` env var to override quarto command (default: `quarto`)
- `capture.js` uses Playwright as a Node.js library (npm dependency, no global install needed)
- `playwright-cli` uses `-s=screenshot` session flag (for interactive/agent use)
- oxipng compression is optional locally (CI handles it as safety net)
