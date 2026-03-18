# Sub-plan 12: Navigation Page Screenshots

Parent: [00-index.md](00-index.md)
Doc page: `docs/websites/website-navigation.qmd`

## Screenshot Inventory

| # | Image file | Line | Section | Status | Source | Viewport |
|---|-----------|------|---------|--------|--------|----------|
| 1 | `nav-bar.png` | 37 | Top Navigation | **DONE + PR** | navbar-basic | 1000x400 |
| 2 | `navbar-tools.png` | 112 | Navbar Tools | DONE (plan 09) | navbar-tools | 1440x400 |
| 3 | `nav-side-anchored.png` | 158 | Side Navigation | **DONE + PR** | quarto-demo (default) | 1200x800 |
| 4 | `nav-side-floating.png` | 158 | Side Navigation | **DONE + PR** | quarto-demo (floating) | 1200x800 |
| 5 | `tools.png` | 276 | Sidebar Tools | DONE (plan 09) | quarto-demo URL | 992x600 |
| 6 | `nav-bar-hybrid.png` | 285 | Hybrid Navigation | **DONE + PR** | hybrid-nav (default) | 1050x400 element |
| 7 | `nav-bar-hybrid-sidebar.png` | 289 | Hybrid Navigation | **DONE + PR** | hybrid-nav (default) | 1200x350 zoom 1.25 maxH 280 |
| 8 | `nav-bar-hybrid-dropdown.png` | 345 | Hybrid Navigation | **DONE + PR** | hybrid-nav (dropdown) | 1200x400 element |
| 9 | `nav-breadcrumbs.png` | 404 | Breadcrumbs | **DONE + PR** | examples/breadcrumbs | 1200x400 clip+trim |
| 10 | `reader-mode.png` | 476 | Reader Mode | **DONE + PR** | navbar-basic (reader-mode) | 1200x600 clip |
| 11 | `repo-actions.png` | 514 | GitHub Links | **DONE** | quarto-demo (repo-actions) | 900x600 + spotlight |

11/11 DONE. All cherry-picked to PR #1815.
Cherry-picked to PR #1815: all 11 screenshots (9 from tool branch + 2 from plan 09).

## Source Projects

### quarto-demo (git subtree) — screenshots 3, 4, 11

**Path**: `tools/screenshots/examples/quarto-demo/`
**Repo**: https://github.com/quarto-dev/quarto-demo
**Setup**: `git subtree add --prefix=tools/screenshots/examples/quarto-demo https://github.com/quarto-dev/quarto-demo main --squash`

Already has: docked sidebar, 6 sections (Basics, Layout, Crossrefs, HTML, Websites, Books), dark mode (`theme: {light: cosmo, dark: darkly}`), sidebar tools (Bluesky + GitHub dropdown), `repo-url`, search. 15+ pages.

**Profile YAMLs** (added locally inside subtree):
- `_quarto-floating.yml` — `sidebar.style: "floating"` → `nav-side-floating.png`
- `_quarto-repo-actions.yml` — `repo-actions: [edit, source, issue]` → `repo-actions.png`
- (default config) — docked sidebar as-is → `nav-side-anchored.png`

**Environment setup**: None needed. Upstream uses `freeze: true` — all computation results are in `_freeze/` directory. No Python or R required.

**Rendering**: Use `npm run render -- examples/quarto-demo [--profile X]`. Fast with freeze.

**Output dir**: Default `_site`. Profile overrides use `docs-floating`, `docs-repo-actions`.

### breadcrumbs (NEW, dedicated) — screenshot 9

**Path**: `tools/screenshots/examples/breadcrumbs/`
Minimal project matching the qmd's sidebar YAML example (Tutorials > Tutorial Landing).
Uses `dark: [darkly, theme-dark.scss]` with `$breadcrumb-bg: transparent` to eliminate
the breadcrumb bar background in dark mode (darkly sets `$breadcrumb-bg: body-mix(85%)`).

### navbar-basic (NEW) — screenshots 1, 10

**Path**: `tools/screenshots/examples/navbar-basic/`
3 pages (index.qmd, talks.qmd, about.qmd). Theme: `{light: cosmo, dark: darkly}`.

**Profiles**:
- (default) — navbar with Home/Talks/About → `nav-bar.png`
- `reader-mode` — adds `reader-mode: true` → `reader-mode.png`

### hybrid-nav (NEW) — screenshots 6, 7, 8

**Path**: `tools/screenshots/examples/hybrid-nav/`
7 pages (index, tutorials, tutorial1, tutorial2, howto, fundamentals, reference). Theme: `{light: cosmo, dark: darkly}`.

**Profiles**:
- (default) — flat hybrid navbar + sidebar → `nav-bar-hybrid.png`, `nav-bar-hybrid-sidebar.png`
- `dropdown` — navbar items reference sidebar IDs → `nav-bar-hybrid-dropdown.png`

## Execution Order

### Phase 1: Prerequisite (output-dir fix) — DONE
- capture.js `getOutputDir()` with profile support — committed
- render.js `cwd: projectDir` fix — committed
- `.gitignore` for `quarto-demo/docs*/` — committed

### Phase 2: quarto-demo + breadcrumbs captures — DONE

**Completed and cherry-picked to PR #1815 (`twitter-to-bluesky` branch):**
- nav-side-anchored (light + dark) — committed on tool branch, cherry-picked `08ac2bf46`
- nav-side-floating (light + dark) — committed on tool branch, cherry-picked `08ac2bf46`
- nav-breadcrumbs (light + dark) — committed on tool branch, cherry-picked `7f8f47aa7`

`.include-dark` added on PR branch for all three (anchored + floating in `08ac2bf46`, breadcrumbs in `7f8f47aa7`).

**Completed on tool branch (not yet cherry-picked to PR):**
- repo-actions (light + dark) — spotlight effect, committed `dfefda1a4`
  - Fixed: dark mode toggle uses `quartoToggleColorScheme()` JS instead of click (navbar hidden at 900px viewport)
  - Fix committed separately: `049ee2b1c`

**Tooling improvements made during Phase 2:**
- capture.js: spotlight feature with elevate/dim/overlay (plan 13)
- capture.js: dark mode refactored to reload-based flow (no more hidden-toggle issues)
- capture.js: cleanup now re-runs after dark switch (CSS overrides survive theme changes)
- capture.js: scrollbar auto-hidden when spotlight active
- CLAUDE.md: added Cleanup section documenting re-run behavior
- /screenshot skill: updated to enforce one-at-a-time confirmation workflow
- capture-agent.md: eval vs run-code guidance, Chrome DevTools MCP debugging tip

### Phase 3: navbar-basic + 2 captures — DONE

**Completed and cherry-picked to PR #1815:**
- navbar-basic example project created (3 pages, reader-mode profile) — `77e37d535`
- nav-bar (light + dark) — element capture of `.navbar` at 1000px — `a8c72b836`, cherry-picked `341e0b52d`
- reader-mode (light + dark) — clip capture of icons + "On this page" dropdown at 1200x600 — `cf3defaf1`, cherry-picked `0fc132879`
- `.include-dark` added on PR branch for nav-bar (`341e0b52d`) and reader-mode (`36566c5ee`)

**Tooling improvements made during Phase 3:**
- skill.md: Clarified serve.js takes directory path, not `--profile`; documented `docs-<profile>/` output convention
- manifest-schema.md: Added stateful toggle warning (localStorage persistence breaks dark variant when using plain click)
- capture-agent.md: Cross-referenced stateful toggle warning
- manifest-schema.md: Created as new doc (`77e37d535`) — complete field reference for manifest.json

### Phase 4: hybrid-nav + 3 captures — DONE

**Completed and cherry-picked to PR #1815:**
- hybrid-nav example project created (7 pages, default + dropdown profiles) — `40469d215`
- Used profile-based config split: base `_quarto.yml` has shared settings, `_quarto-default.yml` has plain navbar+sidebar, `_quarto-dropdown.yml` has sidebar:id navbar items. Avoids Quarto array merging issue.
- nav-bar-hybrid (light + dark) — element capture of `.navbar` at 1050px — `aa5a66072`, cherry-picked `90a0c1cdf`
- nav-bar-hybrid-sidebar (light + dark) — viewport capture at 1200x350 with zoom 1.25 + maxHeight 280 — `aa5a66072`, cherry-picked `90a0c1cdf`
- nav-bar-hybrid-dropdown (light + dark) — element capture of `.navbar` at 1200px — `aa5a66072`, cherry-picked `90a0c1cdf`
- `.include-dark` added on PR branch for all three (`241c9b3b8`)

### Phase 5: .qmd updates + cleanup — TODO
10. Add `.include-dark` to all image references
11. Delete `examples/sidebar-tools/` (superseded)
12. Commit

## .qmd Changes Needed

| Line | Image | Change | Status |
|------|-------|--------|--------|
| 37 | `nav-bar.png` | Add `.include-dark` | DONE on PR (`341e0b52d`) |
| 158 | `nav-side-anchored.png` | Add `.include-dark` | DONE on PR (`08ac2bf46`) |
| 158 | `nav-side-floating.png` | Add `.include-dark` | DONE on PR (`08ac2bf46`) |
| 285 | `nav-bar-hybrid.png` | Add `.include-dark` | DONE on PR (`241c9b3b8`) |
| 289 | `nav-bar-hybrid-sidebar.png` | Add `.include-dark` | DONE on PR (`241c9b3b8`) |
| 345 | `nav-bar-hybrid-dropdown.png` | Add `.include-dark` | DONE on PR (`241c9b3b8`) |
| 404 | `nav-breadcrumbs.png` | Add `.include-dark` | DONE on PR (`7f8f47aa7`) |
| 476 | `reader-mode.png` | Add `.include-dark` + fix fig-alt | DONE on PR (`36566c5ee`) |
| 514 | `repo-actions.png` | Add `.include-dark` | DONE on PR (`5018185fe`) |

## Key Learnings

- **Breadcrumb bar in darkly theme**: `$breadcrumb-bg: body-mix(85%)` creates a visible lighter bar. Fix: custom SCSS with `$breadcrumb-bg: transparent`. quarto.org uses cosmo for both light+dark with custom SCSS overlays.
- **Cleanup re-run needed after dark switch**: CSS property overrides get clobbered by dark theme. Added `runCleanup` after `switchToDark` in both code paths.
- **One-at-a-time screenshot workflow**: Must pause for Chris's visual review after each screenshot. Never batch-capture without confirmation.
- **Use dedicated example projects**: breadcrumbs needed its own project to match the qmd's YAML example exactly (Tutorials > Tutorial Landing). Don't force quarto-demo to serve all use cases.
- **quarto.org theme**: cosmo for both light/dark + custom `theme.scss`/`theme-dark.scss`. No breadcrumb-specific SCSS — the clean dark breadcrumb comes from cosmo not setting `$breadcrumb-bg`.
- **freeze: true**: Upstream quarto-demo needs no Python/R. `_freeze/` has computation results.
- **Dark mode reload-based flow**: Refactored capture.js to reload the page fresh for dark variant, switching before cleanup runs. Eliminates hidden-toggle click failures when cleanup hides the navbar.
- **Spotlight stacking contexts**: CSS z-index on target alone doesn't work when ancestors create stacking contexts (e.g., `#quarto-margin-sidebar` is `position: sticky; z-index: 1`). Need `elevate` to lift ancestor + `dim` to fade siblings.
- **eval vs run-code in playwright-cli**: Use `run-code` for complex JS (template literals, getComputedStyle, multi-line). `eval` shell escaping breaks easily.
- **Commit separately**: tooling changes and image outputs in different commits.
- **Dark mode toggle at narrow viewports**: At <992px, Quarto's navbar collapses and `.quarto-color-scheme-toggle` is hidden. Fix: use `page.evaluate(() => window.quartoToggleColorScheme())` instead of clicking. The JS function is identical to the click handler (confirmed via deepwiki). It toggles classes, stylesheets, persists to localStorage, and dispatches resize. Fresh browser context per capture group prevents localStorage bleed.
- **npm in Git Bash**: With nvm/scoop, `npm` resolves to an extensionless shell script that breaks on `npm run`. Use `npm.cmd` instead. Added to global Windows rules.
- **Stateful toggles break dark variant**: Reader mode persists in localStorage. Light pass activates it → dark reload inherits active state → click deactivates it → timeout. Fix: use `eval` with guard condition (`if (!el.classList.contains('active')) el.click()`) instead of plain `click`. Documented in manifest-schema.md and capture-agent.md.
- **serve.js doesn't understand --profile**: It only takes a directory path. For profiled renders, serve the output directory directly (e.g., `docs-reader-mode/`). Documented in skill.md.
- **clip selectors work for tight crops**: Using `clip: [".quarto-navbar-tools", "#quarto-search", "#quarto-toc-toggle"]` with the 20px padding produces tight element-focused crops without needing cropLeft/cropTop/cropRight.
- **Quarto profile array merging**: When a profile YAML defines the same array as the base `_quarto.yml` (e.g., `website.navbar.left`), Quarto concatenates them instead of replacing. Fix: move conflicting arrays out of base config into dedicated profile files (`_quarto-default.yml` + `_quarto-dropdown.yml`), keeping only shared scalar settings in `_quarto.yml`.
