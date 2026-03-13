# Sub-plan 12: Navigation Page Screenshots

Parent: [00-index.md](00-index.md)
Doc page: `docs/websites/website-navigation.qmd`

## Screenshot Inventory

| # | Image file | Line | Section | Status | Source | Viewport |
|---|-----------|------|---------|--------|--------|----------|
| 1 | `nav-bar.png` | 37 | Top Navigation | **TODO** | navbar-basic | 1440x400 |
| 2 | `navbar-tools.png` | 112 | Navbar Tools | DONE | navbar-tools | 1440x400 |
| 3 | `nav-side-anchored.png` | 158 | Side Navigation | **DONE** | quarto-demo (default) | 1200x800 |
| 4 | `nav-side-floating.png` | 158 | Side Navigation | **DONE** | quarto-demo (floating) | 1200x800 |
| 5 | `tools.png` | 276 | Sidebar Tools | DONE | quarto-demo URL | 992x600 |
| 6 | `nav-bar-hybrid.png` | 285 | Hybrid Navigation | **TODO** | hybrid-nav | 1440x400 |
| 7 | `nav-bar-hybrid-sidebar.png` | 289 | Hybrid Navigation | **TODO** | hybrid-nav | 1200x800 |
| 8 | `nav-bar-hybrid-dropdown.png` | 345 | Hybrid Navigation | **TODO** | hybrid-nav (dropdown) | 1440x400 |
| 9 | `nav-breadcrumbs.png` | 404 | Breadcrumbs | **DONE** | examples/breadcrumbs | 1200x400 clip+trim |
| 10 | `reader-mode.png` | 476 | Reader Mode | **TODO** | navbar-basic (reader-mode) | 1440x400 |
| 11 | `repo-actions.png` | 514 | GitHub Links | **IN PROGRESS** | quarto-demo (repo-actions) | 900x600 + spotlight |

3 DONE, 1 IN PROGRESS, 7 TODO.

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

### Phase 2: quarto-demo + breadcrumbs captures — DONE (3/4)

**Completed:**
- nav-side-anchored (light + dark) — committed
- nav-side-floating (light + dark) — committed
- nav-breadcrumbs (light + dark) — committed, uses dedicated `examples/breadcrumbs/` project

**In progress:**
- repo-actions — needs spotlight effect (see plan 13). Current state:
  - Manifest: source=quarto-demo/repo-actions, viewport 1200x800, zoom 1.25
  - Cleanup evals: hide navbar + sidebar (content + TOC only)
  - Blocked on: spotlight feature implementation (plan 13)
  - Explored interactively: 900x600 at 1.25x zoom looks good but needs spotlight
    to highlight the "Edit this page / View source / Report an issue" links

**Tooling improvements made during Phase 2:**
- capture.js: cleanup now re-runs after `switchToDark` (CSS overrides survive theme changes)
- CLAUDE.md: added Cleanup section documenting re-run behavior
- /screenshot skill: updated to enforce one-at-a-time confirmation workflow

### Phase 3: navbar-basic + 2 captures — TODO
1. Create `examples/navbar-basic/` project
2. `/screenshot` for `nav-bar.png`
3. `/screenshot` for `reader-mode.png`
4. Commit

### Phase 4: hybrid-nav + 3 captures — TODO
5. Create `examples/hybrid-nav/` project
6. `/screenshot` for `nav-bar-hybrid.png`
7. `/screenshot` for `nav-bar-hybrid-sidebar.png`
8. `/screenshot` for `nav-bar-hybrid-dropdown.png`
9. Commit

### Phase 5: .qmd updates + cleanup — TODO
10. Add `.include-dark` to all image references
11. Delete `examples/sidebar-tools/` (superseded)
12. Commit

## .qmd Changes Needed

| Line | Image | Change |
|------|-------|--------|
| 37 | `nav-bar.png` | Add `.include-dark` |
| 158 | `nav-side-anchored.png` | Add `.include-dark` |
| 158 | `nav-side-floating.png` | Add `.include-dark` |
| 285 | `nav-bar-hybrid.png` | Add `.include-dark` |
| 289 | `nav-bar-hybrid-sidebar.png` | Add `.include-dark` |
| 345 | `nav-bar-hybrid-dropdown.png` | Add `.include-dark` |
| 404 | `nav-breadcrumbs.png` | Add `.include-dark` |
| 476 | `reader-mode.png` | Add `.include-dark` |
| 514 | `repo-actions.png` | Add `.include-dark` |

## Key Learnings

- **Breadcrumb bar in darkly theme**: `$breadcrumb-bg: body-mix(85%)` creates a visible lighter bar. Fix: custom SCSS with `$breadcrumb-bg: transparent`. quarto.org uses cosmo for both light+dark with custom SCSS overlays.
- **Cleanup re-run needed after dark switch**: CSS property overrides get clobbered by dark theme. Added `runCleanup` after `switchToDark` in both code paths.
- **One-at-a-time screenshot workflow**: Must pause for Chris's visual review after each screenshot. Never batch-capture without confirmation.
- **Use dedicated example projects**: breadcrumbs needed its own project to match the qmd's YAML example exactly (Tutorials > Tutorial Landing). Don't force quarto-demo to serve all use cases.
- **quarto.org theme**: cosmo for both light/dark + custom `theme.scss`/`theme-dark.scss`. No breadcrumb-specific SCSS — the clean dark breadcrumb comes from cosmo not setting `$breadcrumb-bg`.
- **freeze: true**: Upstream quarto-demo needs no Python/R. `_freeze/` has computation results.
- **Commit separately**: tooling changes and image outputs in different commits.
