# Sub-plan 12: Navigation Page Screenshots

Parent: [00-index.md](00-index.md)
Doc page: `docs/websites/website-navigation.qmd`

## Screenshot Inventory

| # | Image file | Line | Section | Status | Source | Viewport |
|---|-----------|------|---------|--------|--------|----------|
| 1 | `nav-bar.png` | 37 | Top Navigation | **TODO** | navbar-basic | 1440x400 |
| 2 | `navbar-tools.png` | 112 | Navbar Tools | DONE | navbar-tools | 1440x400 |
| 3 | `nav-side-anchored.png` | 158 | Side Navigation | **CAPTURED** — needs review | quarto-demo (default) | 1200x800 |
| 4 | `nav-side-floating.png` | 158 | Side Navigation | **CAPTURED** — needs review | quarto-demo (floating) | 1200x800 |
| 5 | `tools.png` | 276 | Sidebar Tools | DONE | quarto-demo URL | 992x600 |
| 6 | `nav-bar-hybrid.png` | 285 | Hybrid Navigation | **TODO** | hybrid-nav | 1440x400 |
| 7 | `nav-bar-hybrid-sidebar.png` | 289 | Hybrid Navigation | **TODO** | hybrid-nav | 1200x800 |
| 8 | `nav-bar-hybrid-dropdown.png` | 345 | Hybrid Navigation | **TODO** | hybrid-nav (dropdown) | 1440x400 |
| 9 | `nav-breadcrumbs.png` | 404 | Breadcrumbs | **CAPTURED** — needs review | quarto-demo (breadcrumbs) | 1200x400 |
| 10 | `reader-mode.png` | 476 | Reader Mode | **TODO** | navbar-basic (reader-mode) | 1440x400 |
| 11 | `repo-actions.png` | 514 | GitHub Links | **TODO** | quarto-demo (repo-actions) | 1200x800 |

6 TODO, 3 CAPTURED (need visual review/adjustment). Each uses `/screenshot` skill for interactive design and capture.

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

**Environment setup**: None needed. Upstream uses `freeze: true` — all computation results are in `_freeze/` directory. No Python or R required.

**Rendering**: Use `npm run render -- examples/quarto-demo [--profile X]` (not quartoPreRelease directly). Fast with freeze.

**Output dir**: Default `_site` (no `output-dir` in `_quarto.yml`). Profile overrides use `docs-floating`, `docs-breadcrumbs`, `docs-repo-actions`. capture.js `getOutputDir()` handles this.

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

## Prerequisite: Fix output-dir in capture.js — DONE

capture.js `getOutputDir()` reads `_quarto.yml` → `project.output-dir`, with profile override support. render.js sets `cwd: projectDir` so relative paths in `_environment` resolve correctly.

**Commits**: Already on `worktree-screenshot-tool` branch.

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

### Phase 1: Prerequisite (output-dir fix) — DONE
- capture.js `getOutputDir()` with profile support — committed
- render.js `cwd: projectDir` fix — committed
- `.gitignore` for `quarto-demo/docs*/` — committed

### Phase 2: quarto-demo subtree + 4 captures — IN PROGRESS
1. `git subtree add` quarto-demo — DONE
2. Add 3 profile YAMLs — DONE
3. Subtree updated 3x (pulled `_environment`, `renv/settings.json`, freeze + drop output-dir) — DONE
4. Upstream now uses `freeze: true`, output to `_site` (no Python/R needed) — DONE
5. 4 manifest entries added — DONE (committed in WIP)
6. First-pass captures from old `docs/` renders — need re-capture from `_site`
7. Re-render all profiles, re-capture all 4, visual review — **TODO**
8. Commit final screenshots — **TODO**

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
| `tools/screenshots/capture.js` | Add `getOutputDir()` with profile support — DONE |
| `tools/screenshots/scripts/render.js` | Add `cwd: projectDir` to execSync — DONE |
| `.gitignore` | Ignore `quarto-demo/docs*/` rendered output — DONE |
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

## Session Notes (2026-03-12)

### Learnings
- **render.js cwd fix**: `execSync` needed `cwd: projectDir` so quarto resolves relative paths in `_environment` correctly.
- **Use `npm run render`**: Not `quartoPreRelease` directly. The render.js script handles profile flag passthrough.
- **Use playwright-cli for exploration**: The `/screenshot` skill expects playwright-cli, not chrome devtools MCP.
- **`--no-render` flag**: `npm run capture -- --name X --no-render` skips rendering but capture.js still renders anyway (it renders per-group). Rendering is fast with freeze.
- **Dark variants**: All 4 quarto-demo screenshots set to `dark: true` — breadcrumbs and repo-actions need dark variants for `.include-dark` in the qmd.
- **freeze: true**: Upstream quarto-demo now uses freeze — no Python/R needed, `_freeze/` dir has all computation results. Deleted `.venv` and `renv/library`.
- **output-dir change**: Upstream removed `output-dir: docs`, now defaults to `_site`. Profile YAMLs still use `docs-*` custom names.
- **git subtree can't exclude paths**: `.github/` comes along with the subtree, kept as-is.

### Uncommitted state
- `tools/screenshots/manifest.json` — 4 new entries added
- `docs/websites/images/nav-side-anchored.png` + `-dark.png` — captured
- `docs/websites/images/nav-side-floating.png` + `-dark.png` — captured
- `docs/websites/images/nav-breadcrumbs.png` — captured

### Next session TODO
1. Re-render all 4 profiles (output dir changed from `docs` to `_site`)
2. Re-capture all 3 screenshots (they were captured from old `docs/` renders)
3. Visually review and adjust viewport/clip/interactions as needed
4. Capture repo-actions screenshot
5. Commit manifest + PNGs
6. Continue with Phase 3 (navbar-basic) and Phase 4 (hybrid-nav)
