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

## Visual Rules

- Light color scheme first (dark captured automatically)
- Wait for full page load (fonts and icons must render)
- Remove prerelease callouts (automated in manifest defaults)
- Verify Bootstrap Icons loaded (not blank boxes)
- Consistent fictional data: "Finley Malloc", "myblog", "ProjectX"

## Viewport Sizes

| Category | Width | Height |
|----------|-------|--------|
| Navbar | 1440 | 400 |
| Sidebar | 400 | 300 |
| About pages | 1200 | 900 |
| Blog/full pages | 1440 | 900 |

## Compression

- `npm run compress` — compresses all manifest outputs (runs oxipng if available)
- `npm run compress -- file.png` — compress specific files
- CI compresses all changed PNGs after merge (safety net)
- `npm run capture` compresses by default (`--no-compress` to skip)

## Environment

- `QUARTO_CMD` env var to override quarto command (default: `quarto`)
- Playwright is an npm dependency (no global install needed)
- `playwright-cli -s=screenshot` for interactive exploration
