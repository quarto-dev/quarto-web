# Sub-plan 05: CLAUDE.md, SETUP.md, and Visual Guidelines

Parent: [00-index.md](00-index.md)

## CLAUDE.md (for Claude sessions)

Located at `tools/screenshots/CLAUDE.md`. Instructions Claude reads when working on screenshots (injected via `!` preprocessing in /screenshot command).

### Contents

**Quick workflow (automated):**
```bash
node tools/screenshots/capture.js --name <pattern>
```

**Interactive workflow (playwright-cli):**
```bash
playwright-cli open http://localhost:8080/jolla.html
playwright-cli resize 1200 900
playwright-cli eval "..."   # cleanup
playwright-cli snapshot      # check load state
playwright-cli screenshot --filename=docs/websites/images/about-jolla.png
playwright-cli close
```

**Adding new screenshots:**
1. Create entry in manifest.json
2. If no live source exists, create example project in `examples/`
3. Use `/screenshot` command (orchestrates everything) or run capture.js
4. Compress with oxipng if available

**Edge cases and rules:**
- Remove prerelease callouts before capture (script does this automatically)
- Remove preview/prerelease banners
- Always use light color scheme unless documenting dark mode
- Wait for full page load — fonts and icons must be rendered
- Verify Bootstrap Icons loaded (not blank boxes)
- Use consistent fictional data ("Finley Malloc", "myblog", "ProjectX")

**Available tools (preference order):**
1. `/screenshot` command — primary entry point (orchestrates render, serve, capture, compress)
2. `capture.js` — automated batch replay from manifest (no AI needed)
3. `playwright-cli` — direct browser control for interactive/debugging use
4. Chrome DevTools MCP — fallback for element inspection when needed

## SETUP.md (Colleague Setup Guide)

Located at `tools/screenshots/SETUP.md`.

### Contents

**Prerequisites:**
```bash
# Node.js 18+ required
node --version

# Quarto required (for rendering example projects)
quarto --version
```

**Option A: Automated replay (no AI)**
```bash
# One-time: install playwright-cli and browser
npm install -g @playwright/cli@latest
playwright-cli install-browser

# Run all screenshots
node tools/screenshots/capture.js

# Run specific screenshot(s)
node tools/screenshots/capture.js --name navbar-tools
node tools/screenshots/capture.js --name "about-*"
```

**Option B: Interactive with Claude Code**
```bash
# One-time: install playwright-cli skill into project
playwright-cli install --skills

# Use the /screenshot command
/screenshot
```

**Option C: Manual with playwright-cli**
```bash
# Render example project
quarto render tools/screenshots/examples/about-pages

# Serve it
node tools/screenshots/scripts/serve.js tools/screenshots/examples/about-pages/_site

# In another terminal, use playwright-cli
playwright-cli open http://localhost:<port>/jolla.html
playwright-cli resize 1200 900
playwright-cli screenshot --filename=docs/websites/images/about-jolla.png
playwright-cli close
```

**Optional: PNG compression**
```bash
# Windows:  scoop install oxipng
# macOS:    brew install oxipng
# Cargo:    cargo install oxipng
# CI handles this automatically — local install is optional.
```

## Visual Consistency Rules

Documented in CLAUDE.md, enforced by manifest defaults:

1. **Viewport sizes by category:**
   - Navbar screenshots: 1440 x 400
   - Sidebar screenshots: 400 x 300
   - About pages: 1200 x 900
   - Blog/full pages: 1440 x 900
   - Gallery thumbnails: 1440 x 900
2. **Always light color scheme**
3. **Always wait for full load** (fonts, icons, content)
4. **Always clean up dynamic content** (prerelease callouts, banners)
5. **Compress all PNGs** with oxipng (locally if available, CI as safety net)
6. **Consistent example data** ("Finley Malloc", "myblog", "ProjectX")
