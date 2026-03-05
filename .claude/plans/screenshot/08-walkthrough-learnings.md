# Phase 0.5 Walkthrough Learnings

Date: 2026-03-04

## What Worked

1. **playwright-cli screenshot** — viewport and element screenshots both work perfectly
2. **Element screenshot by ref** — `playwright-cli -s=screenshot screenshot e3 --filename=out.png` crops to just the element
3. **Snapshot refs** — AI can read the YAML snapshot and pick the right ref for element/interaction
4. **oxipng compression** — 137KB → 122KB (11% savings) on a typical about page screenshot
5. **Bluesky icon** — Bootstrap Icons render correctly in headless Chrome
6. **Quarto render** — example project renders into `_site/` successfully
7. **Local file server** — serving `_site/` works for localhost screenshot capture

## Learnings (must update plans)

### L1: About pages need website project type
Standalone render (`quarto render jolla.qmd`) strips the about template features — no circular image, no link buttons. **Must use `project: type: website`** in `_quarto.yml`.

→ Sub-plan 03 already says website type. Confirmed correct.

### L2: Example projects need explicit render list (or navigation)
Quarto website projects discover input files through navigation config (navbar/sidebar contents). Our example projects have no navigation (we don't want it in screenshots), so auto-discovery finds 0 files. Fix: add explicit `render:` list in `_quarto.yml`:
```yaml
project:
  type: website
  render:
    - index.qmd
    - jolla.qmd
```
Alternative: add navigation entries, but that adds unwanted UI to the screenshots.

→ Sub-plan 03 needs `render:` lists added to all example `_quarto.yml` configs.

### L3: Use named sessions (`-s=screenshot`)
Without `-s`, playwright-cli uses the `default` session which can collide with other sessions. **Always use `-s=screenshot`** for all commands.

→ Sub-plans 01, 05, 07 must specify `-s=screenshot` in all playwright-cli commands.

### L4: Quarto prerelease required
quarto-web requires the latest Quarto prerelease to render correctly (same as CI). Contributors are expected to have the right version on PATH.

→ SETUP.md should mention this prerequisite.

### L5: File server port management
Background servers don't always clean up ports. `serve.js` should:
- Use random ports (port 0) and parse the output to return the URL
- Or kill existing servers before starting new ones

→ Sub-plan 06 serve.js design needs this consideration.

### L6: `--filename` flag for screenshots
playwright-cli uses `--filename=path` (not positional arg) for screenshot output path. Resolved relative to cwd.

→ Sub-plan 01 capture script needs correct flag syntax.

### L7: Website title appended to page title
With website project type, page title becomes "Finley Malloc – About Pages". Doesn't affect screenshots, just visible in snapshot metadata.

### L8: Console error for favicon.ico is harmless
Every page load produces a 404 for favicon.ico. Expected, can be ignored.

### L9: PR deploy preview shows quarto.org site, not examples
`https://deploy-preview-1815.quarto.org/` shows the full quarto.org website with its own navbar/sidebar. All 8 screenshots need minimal example projects because they show custom/simplified configs, not the full site. The deploy preview is useful for verifying content changes but not for taking example screenshots.

### L10: Dropdown menus overflow element bounds — use `run-code` with clip
Element screenshots (`screenshot e3`) clip dropdown menus because they overflow the `<nav>` element's bounding box. Solution: use `run-code` with Playwright's clip option:
```bash
playwright-cli -s=screenshot run-code "async page => {
  await page.screenshot({ path: 'out.png', clip: { x: 1100, y: 0, width: 340, height: 130 } });
}"
```
This captures a specific region of the viewport including any overflowing content.

### L11: Clip coordinates need AI judgment
The clip region depends on viewport width, element positions, and dropdown size. The capture agent must:
1. Click to open dropdown
2. Use `eval` to get bounding boxes of elements
3. Calculate the clip region dynamically
4. Use `run-code` with the computed clip

This is a key reason the capture agent needs AI (Sonnet) — computing the right crop region from dynamic layout.

### L12: `run-code` path resolution
`run-code` paths resolve relative to cwd (where playwright-cli was invoked), not relative to `.playwright-cli/`. Unix-style paths (`/tmp/...`) don't work on Windows from run-code — use relative paths.

### L13: Click toggles dropdown
Clicking the GitHub dropdown icon toggles it (open → close → open). The capture agent needs to verify the dropdown is open after clicking (check for `[expanded]` in snapshot) and click again if it closed.

## Validated Workflow

```bash
# 1. Render
quarto render tools/screenshots/examples/about-pages

# 2. Serve _site/ directory (via serve.js or any local file server)
node tools/screenshots/scripts/serve.js tools/screenshots/examples/about-pages/_site
# → prints http://localhost:<port>

# 3. Open browser with named session
playwright-cli -s=screenshot open http://localhost:<port>/jolla.html

# 4. Resize viewport
playwright-cli -s=screenshot resize 1200 900

# 5. Snapshot to check load state and get refs
playwright-cli -s=screenshot snapshot

# 6. Screenshot (full viewport)
playwright-cli -s=screenshot screenshot --filename=docs/websites/images/about-jolla.png

# 7. Screenshot (element by ref, for navbar/sidebar crops)
playwright-cli -s=screenshot screenshot e3 --filename=out.png

# 8. Compress
oxipng -o 4 -i 0 --strip safe docs/websites/images/about-jolla.png

# 9. Close
playwright-cli -s=screenshot close
```

## Open Design Question: Agent-first, Script-replay Workflow

Desired workflow:
1. **Agent creates** — builds example project, finds the right playwright-cli commands interactively (viewport, clicks, clip coordinates)
2. **Manifest records** — the exact commands/coordinates/selectors get saved to manifest.json
3. **Script replays** — for small doc updates, `capture.js` re-runs the same commands without AI

Key question: Should clip coordinates be **hardcoded** in manifest (fragile — break if layout changes) or **computed dynamically** by the replay script from bounding boxes (more robust but adds complexity)? Possible hybrid: store CSS selectors + padding rules in manifest, compute coordinates at runtime.

## Still to Validate

- [x] Click interaction (navbar dropdown) — ✅ works with named session + click ref + run-code clip
- [ ] `run-code` for CSS selector-based capture in replay script
- [ ] Multiple pages in one session (goto between pages without reopening)
- [ ] Cleanup evals (removing prerelease callouts)
