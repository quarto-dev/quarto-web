# Sub-plan 12: Navigation Page Screenshots

Parent: [00-index.md](00-index.md)
Doc page: `docs/websites/website-navigation.qmd`

## Screenshot Inventory

| # | Image file | Line | Section | Status | Source | Viewport |
|---|-----------|------|---------|--------|--------|----------|
| 1 | `nav-bar.png` | 37 | Top Navigation | **TODO** | navbar-basic | 1440x400 |
| 2 | `navbar-tools.png` | 112 | Navbar Tools | DONE | navbar-tools | 1440x400 |
| 3 | `nav-side-anchored.png` | 158 | Side Navigation | **TODO** | quarto-demo (default) | 1200x800 |
| 4 | `nav-side-floating.png` | 158 | Side Navigation | **TODO** | quarto-demo (floating) | 1200x800 |
| 5 | `tools.png` | 276 | Sidebar Tools | DONE | quarto-demo URL | 992x600 |
| 6 | `nav-bar-hybrid.png` | 285 | Hybrid Navigation | **TODO** | hybrid-nav | 1440x400 |
| 7 | `nav-bar-hybrid-sidebar.png` | 289 | Hybrid Navigation | **TODO** | hybrid-nav | 1200x800 |
| 8 | `nav-bar-hybrid-dropdown.png` | 345 | Hybrid Navigation | **TODO** | hybrid-nav (dropdown) | 1440x400 |
| 9 | `nav-breadcrumbs.png` | 404 | Breadcrumbs | **TODO** | quarto-demo (breadcrumbs) | 1200x400 |
| 10 | `reader-mode.png` | 476 | Reader Mode | **TODO** | navbar-basic (reader-mode) | 1440x400 |
| 11 | `repo-actions.png` | 514 | GitHub Links | **TODO** | quarto-demo (repo-actions) | 1200x800 |

9 TODO. Each uses `/screenshot` skill for interactive design and capture.

## Source Projects

### quarto-demo (git subtree) — screenshots 3, 4, 9, 11

**Path**: `tools/screenshots/examples/quarto-demo/`
**Repo**: https://github.com/quarto-dev/quarto-demo
**Setup**: `git subtree add --prefix=tools/screenshots/examples/quarto-demo https://github.com/quarto-dev/quarto-demo main --squash`

Already has: docked sidebar, 6 sections (Basics, Layout, Crossrefs, HTML, Websites, Books), dark mode (`theme: {light: cosmo, dark: darkly}`), sidebar tools (Bluesky + GitHub dropdown), `repo-url`, search. 15+ pages.

**Profile YAMLs** (added locally inside subtree):
- `_quarto-floating.yml` — `sidebar.style: "floating"` → `nav-side-floating.png`
- `_quarto-breadcrumbs.yml` — navigates nested page for breadcrumbs → `nav-breadcrumbs.png`
- `_quarto-repo-actions.yml` — `repo-actions: [edit, source, issue]` → `repo-actions.png`
- (default config) — docked sidebar as-is → `nav-side-anchored.png`

**Note**: `output-dir: docs` (not `_site`). Requires capture.js fix (see prerequisite).

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

## Prerequisite: Fix output-dir in capture.js

capture.js line 337 hardcodes `_site`. quarto-demo uses `output-dir: docs`.

**Fix**: Add `getOutputDir(projectDir)` that reads `_quarto.yml` → `project.output-dir` (default `_site`). Replace hardcoded `_site` with the detected value.

**Files**: `tools/screenshots/capture.js` (line 337), `tools/screenshots/scripts/render.js` (line 35, cosmetic log)

## Cleanup

Delete `examples/sidebar-tools/` — superseded by URL source to quarto-demo live site.

## Per-Screenshot Workflow

Each screenshot follows this cycle. Use `/screenshot` skill for steps C-E.

| Step | Action | Tool |
|------|--------|------|
| A | Create/setup example project | Manual (files + git subtree) |
| B | Render: `node tools/screenshots/scripts/render.js <project> [--profile X]` | Shell |
| C | Interactive design: viewport, clip, interactions, cleanup | `/screenshot` skill |
| D | Add manifest entry | `/screenshot` skill |
| E | Automated capture: `npm run capture -- --name <name>` | `/screenshot` skill |
| F | .qmd update: add `.include-dark`, update alt text | Edit |
| G | Commit (split: tooling \| images \| .qmd) | Git |

## Execution Order

### Phase 1: Prerequisite (output-dir fix)
- Fix capture.js `getOutputDir()` + render.js log
- Commit

### Phase 2: quarto-demo subtree + 4 captures
1. `git subtree add` quarto-demo
2. Add 3 profile YAMLs
3. `/screenshot` for `nav-side-anchored.png` (default profile)
4. `/screenshot` for `nav-side-floating.png` (floating profile)
5. `/screenshot` for `nav-breadcrumbs.png` (breadcrumbs profile)
6. `/screenshot` for `repo-actions.png` (repo-actions profile + highlight eval)
7. Commit

### Phase 3: navbar-basic + 2 captures
8. Create `examples/navbar-basic/` project
9. `/screenshot` for `nav-bar.png`
10. `/screenshot` for `reader-mode.png`
11. Commit

### Phase 4: hybrid-nav + 3 captures
12. Create `examples/hybrid-nav/` project
13. `/screenshot` for `nav-bar-hybrid.png`
14. `/screenshot` for `nav-bar-hybrid-sidebar.png`
15. `/screenshot` for `nav-bar-hybrid-dropdown.png`
16. Commit

### Phase 5: .qmd updates + cleanup
17. Add `.include-dark` to all 9 image references
18. Delete `examples/sidebar-tools/`
19. Commit

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

## Files Modified

| File | Change |
|------|--------|
| `tools/screenshots/capture.js` | Add `getOutputDir()`, fix hardcoded `_site` |
| `tools/screenshots/scripts/render.js` | Fix hardcoded `_site` in log |
| `tools/screenshots/examples/quarto-demo/` | git subtree + 3 profile YAMLs |
| `tools/screenshots/examples/navbar-basic/` | New: 3 pages, 2 profile YAMLs |
| `tools/screenshots/examples/hybrid-nav/` | New: 7 pages, 2 profile YAMLs |
| `tools/screenshots/examples/sidebar-tools/` | Delete |
| `tools/screenshots/manifest.json` | 9 new entries |
| `docs/websites/website-navigation.qmd` | `.include-dark` on 9 images |
| `docs/websites/images/` | 9 new PNGs + 9 dark variants |

## Verification

- `npm run capture -- --name "nav-*"` — all nav-prefixed screenshots capture
- `npm run capture -- --name reader-mode` + `--name repo-actions` — remaining 2
- All 18 images on disk (9 light + 9 dark)
- All .qmd image references have `.include-dark` class
