# Sub-plan 01: capture.js — Replay Script

Parent: [00-index.md](00-index.md)

## Purpose

A thin Node.js script that reads `manifest.json` and replays screenshot captures using the Playwright API directly. No AI needed — purely mechanical execution. Anyone with Node.js installed can run it to reproduce all screenshots.

## Why Playwright API (not playwright-cli)

- Direct API calls — no shell, no quoting, no string marshaling
- Works identically on all platforms (no cmd.exe / bash differences)
- CSS selectors work directly — no ref resolution needed
- `page.evaluate(script)` accepts strings directly — no escaping
- Bounding box computation is in-process — no shell round-trips

Originally used playwright-cli subprocess calls, but Windows `execSync` goes through `cmd.exe` which corrupts complex JS strings with quotes and newlines. The direct API eliminates this entire class of bugs.

## Dependencies

- Node.js 18+
- `playwright` npm package (Chromium browser auto-installed via `npx playwright install chromium`)
- `open` npm package (cross-platform file opener for --verify)
- `sharp` npm package (image processing — content-aware trim)
- Optional: `oxipng` (use if in PATH, skip silently if not)

## CLI Interface

```bash
node tools/screenshots/capture.js                          # all screenshots
node tools/screenshots/capture.js --name navbar-tools      # specific
node tools/screenshots/capture.js --name "about-*"         # glob pattern
node tools/screenshots/capture.js --dry-run                # show plan without executing
node tools/screenshots/capture.js --no-compress            # skip oxipng
node tools/screenshots/capture.js --verify                 # open each image for review
node tools/screenshots/capture.js --list                   # list all screenshots in manifest
```

## Script Flow

```
1. Read manifest.json (resolve paths relative to tools/screenshots/)
2. Filter by --name pattern (if given), or run all
3. Group screenshots by source project (avoid re-rendering same project)
4. For each source group:
   a. If type=example:
      - quarto render <project-dir>
      - Start Node HTTP server on <project-dir>/_site/ (random port)
   b. If type=url: use URL directly
   c. If type=local: start Node HTTP server on repo _site/
5. Launch Playwright browser:
   - const browser = await chromium.launch({ headless: true })
   - const page = await browser.newContext().then(c => c.newPage())
   - await page.goto(url, { waitUntil: 'domcontentloaded' })
6. For each screenshot in group:
   a. await page.goto(pageUrl, { waitUntil: 'domcontentloaded' })
   b. await page.setViewportSize({ width, height })
   b2. Apply zoom (if capture.zoom or defaults.zoom != 1):
       await page.evaluate(z => document.body.style.zoom = z, String(zoom))
       await page.waitForTimeout(200)
   c. Run cleanup steps:
      - await page.evaluate(script)  // script is a string from manifest
   d. Run interaction steps:
      - click: await page.click(selector)
      - hover: await page.hover(selector)
      - wait: await page.waitForSelector(selector, { timeout })
      - eval: await page.evaluate(script)
      - scroll: await page.locator(selector).scrollIntoViewIfNeeded()
   e. Take screenshot:
      - clip mode: compute union bounding box via locator.boundingBox(), page.screenshot({ clip })
      - element mode: page.locator(selector).screenshot({ path })
      - viewport mode: page.screenshot({ path })
   f. If trim enabled: sharp trim (sample bg from top-left pixel, trim matching edges, extend with uniform padding)
   g. If cropBottom or maxHeight set: sharp crop (remove bottom pixels or enforce max height)
   h. If compress enabled: run oxipng on output file
7. await browser.close()
8. Stop HTTP server
9. Report results (success/fail per screenshot)
```

## Interaction Mapping: Manifest → Playwright API

| Manifest action | API call |
|----------------|----------|
| `{ "action": "click", "selector": ".bi-github" }` | `await page.locator('.bi-github').click()` |
| `{ "action": "hover", "selector": ".nav-link" }` | `await page.locator('.nav-link').hover()` |
| `{ "action": "wait", "selector": ".dropdown-menu.show" }` | `await page.locator('.dropdown-menu.show').waitFor({ timeout })` |
| `{ "action": "eval", "script": "..." }` | `await page.evaluate(script)` |
| `{ "action": "scroll", "selector": "#section" }` | `await page.locator('#section').scrollIntoViewIfNeeded()` |

## Clip Screenshot (union of selectors)

```javascript
const boxes = [];
for (const sel of shot.capture.clip) {
  const loc = page.locator(sel);
  if (await loc.count() > 0) {
    const box = await loc.first().boundingBox();
    if (box) boxes.push(box);
  }
}
const vp = page.viewportSize();
const pad = 20;
const x = Math.max(0, Math.min(...boxes.map(b => b.x)) - pad);
const y = Math.max(0, Math.min(...boxes.map(b => b.y)) - pad);
const right = Math.min(Math.max(...boxes.map(b => b.x + b.width)) + pad, vp.width);
const bottom = Math.min(Math.max(...boxes.map(b => b.y + b.height)) + pad, vp.height);
await page.screenshot({ path, clip: { x, y, width: right - x, height: bottom - y } });
```

## Error Handling

- Continue on failure per screenshot (don't abort batch)
- Collect errors, report summary at end
- Exit code 1 if any failures
- Clear error messages: `"Failed: navbar-tools — element .navbar not found"`

## Output

```
$ node tools/screenshots/capture.js
[1/8] navbar-tools ... done
[2/8] about-jolla ... done
...
Done: 8/8 succeeded
```
