# Sub-plan 01: capture.js — Replay Script

Parent: [00-index.md](00-index.md)

## Purpose

A thin Node.js script that reads `manifest.json` and replays screenshot captures using `playwright-cli` commands. No AI needed — purely mechanical execution. Anyone with Node.js + playwright-cli installed can run it to reproduce all screenshots.

## Why playwright-cli (not Playwright API)

- Same commands the capture agent used — replay is 1:1
- Token-efficient CLI designed for agents (refs, snapshots)
- Element screenshots via refs: `playwright-cli screenshot e5`
- Interactions: `click`, `hover`, `eval`, `resize`
- Session management: daemon persists between commands
- `npx playwright-cli` works without global install

## Dependencies

- Node.js 18+ (already needed for playwright-cli)
- playwright-cli: `npm install -g @playwright/cli@latest` or `npx playwright-cli`
- Optional: `oxipng` (use if in PATH, skip silently if not)
- Zero npm dependencies — Node.js built-ins only

## CLI Interface

```bash
node tools/screenshots/capture.js                          # all screenshots
node tools/screenshots/capture.js --name navbar-tools      # specific
node tools/screenshots/capture.js --name "about-*"         # glob pattern
node tools/screenshots/capture.js --dry-run                # show plan without executing
node tools/screenshots/capture.js --no-compress            # skip oxipng
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
5. Open playwright-cli session:
   - playwright-cli open <url>
6. For each screenshot in group:
   a. playwright-cli goto <page-url>
   b. playwright-cli resize <width> <height>
   c. Wait for load (eval document.readyState or setTimeout)
   d. Run cleanup steps:
      - For each cleanup entry: playwright-cli eval "<script>"
   e. Run interaction steps:
      - click: playwright-cli snapshot → find ref → playwright-cli click <ref>
      - hover: playwright-cli snapshot → find ref → playwright-cli hover <ref>
      - wait: playwright-cli eval "document.querySelector('<selector>')" in loop
      - eval: playwright-cli eval "<script>"
   f. Take screenshot:
      - If capture.element: playwright-cli snapshot → find ref → playwright-cli screenshot <ref> --filename=<output>
      - Else: playwright-cli screenshot --filename=<output>
   g. If compress enabled: run oxipng on output file
7. playwright-cli close
8. Stop HTTP server
9. Report results (success/fail per screenshot)
```

## Ref Resolution Challenge

playwright-cli uses refs (e3, e15) not CSS selectors for click/screenshot. The replay script needs to:

1. Take a snapshot: `playwright-cli snapshot --filename=temp.yaml`
2. Parse the YAML to find the ref matching a CSS selector
3. Use that ref for click/screenshot

This is the trickiest part. The manifest stores CSS selectors (`.bi-github`, `.navbar`), but playwright-cli needs refs.

### Approach: eval-based selector resolution

For interactions (click, hover), use `playwright-cli eval` to find elements, then use `playwright-cli run-code` for precise targeting:

```bash
# Instead of trying to map CSS selector → ref, use run-code for clicks:
playwright-cli run-code "async page => await page.click('.bi-github')"

# For element screenshots, use run-code too:
playwright-cli run-code "async page => {
  const el = await page.locator('.navbar');
  await el.screenshot({ path: 'output.png' });
}"
```

This bypasses the ref system entirely for the replay script, while the capture agent (which IS an AI) can use refs naturally from snapshots.

## Static File Server

Zero-dependency Node.js server (same as before, works):

```javascript
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

const MIME = {
  '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml',
  '.json': 'application/json', '.woff2': 'font/woff2',
};

function serve(dir, port = 0) {
  const server = http.createServer((req, res) => {
    let filePath = path.join(dir, decodeURIComponent(new URL(req.url, 'http://localhost').pathname));
    if (filePath.endsWith('/') || filePath.endsWith(path.sep)) filePath = path.join(filePath, 'index.html');
    const ext = path.extname(filePath);
    const stream = fs.createReadStream(filePath);
    res.setHeader('Content-Type', MIME[ext] || 'application/octet-stream');
    stream.pipe(res);
    stream.on('error', () => { res.writeHead(404); res.end('Not found'); });
  });
  return new Promise(resolve => server.listen(port, () => resolve(server)));
}
```

## Interaction Mapping: Manifest → playwright-cli

| Manifest action | Replay command |
|----------------|----------------|
| `{ "action": "click", "selector": ".bi-github" }` | `playwright-cli run-code "async page => await page.click('.bi-github')"` |
| `{ "action": "hover", "selector": ".nav-link" }` | `playwright-cli run-code "async page => await page.hover('.nav-link')"` |
| `{ "action": "wait", "selector": ".dropdown-menu.show" }` | `playwright-cli run-code "async page => await page.waitForSelector('.dropdown-menu.show')"` |
| `{ "action": "eval", "script": "..." }` | `playwright-cli eval "..."` |
| `{ "action": "scroll", "selector": "#section" }` | `playwright-cli run-code "async page => await page.locator('#section').scrollIntoViewIfNeeded()"` |

## Element Screenshot via run-code

```bash
playwright-cli run-code "async page => {
  await page.locator('.navbar').screenshot({ path: 'docs/websites/images/navbar-tools.png' });
}"
```

## Error Handling

- Continue on failure per screenshot (don't abort batch)
- Collect errors, report summary at end
- Exit code 1 if any failures
- Clear error messages: `"Failed: navbar-tools — element .navbar not found"`

## Output

```
$ node tools/screenshots/capture.js
[1/8] navbar-tools ... ✓ (compressed: 45KB → 32KB)
[2/8] sidebar-tools ... ✓ (compressed: 28KB → 20KB)
[3/8] about-jolla ... ✓ (oxipng not found, skipping compression)
...
Done: 8/8 succeeded
```
