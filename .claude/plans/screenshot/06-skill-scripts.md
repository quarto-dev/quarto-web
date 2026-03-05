# Sub-plan 06: /screenshot Skill + Helper Scripts

Parent: [00-index.md](00-index.md)

## Overview

The `/screenshot` command is the entry point for all screenshot work. It uses `!` command preprocessing to inject manifest data before Claude sees the prompt (zero AI turns for reading files). Helper scripts handle all deterministic work.

## /screenshot Command

**Location:** `.claude/commands/screenshot.md`

### Command Definition

```markdown
---
description: Capture or update documentation screenshots
allowed-tools: Bash(node:*), Bash(quarto:*), Agent
---

## Current Screenshots

!`node tools/screenshots/scripts/list.js`

## Visual Rules

!`cat tools/screenshots/CLAUDE.md`

## Instructions

You are the screenshot orchestrator. The manifest data above shows all registered screenshots.

### If the user wants to UPDATE existing screenshots:

1. Ask which screenshots to update (or "all")
2. For each screenshot group (by source project):
   a. Render: `node tools/screenshots/scripts/render.js <project-path>`
   b. Serve: `node tools/screenshots/scripts/serve.js <dir>` (prints URL)
   c. Launch capture agent for this group (pass URL + manifest entries)
   d. Compress: `node tools/screenshots/scripts/compress.js <output-file>`
3. Show results summary

### If the user wants to CREATE a new screenshot:

Ask these questions to determine the source:

1. **What are you screenshotting?**
   - A page on an external live site → source type `url`
   - A page from a PR preview deploy → source type `preview`
   - A local Quarto example project → source type `example`
   - A page from the quarto-web site itself → source type `local`

2. **For `url` source:** What's the URL?
3. **For `preview` source:** What's the path on the preview site? (e.g., `docs/websites/website-about.html`)
4. **For `example` source:**
   - Does an example project already exist in `tools/screenshots/examples/`?
   - If not, create one (minimal Quarto project, just enough to render the screenshot)
5. **What viewport size?** (suggest based on category: navbar=1440x400, sidebar=400x300, about=1200x900, full page=1440x900)
6. **Element or full page?** If element, what CSS selector?
7. **Any interactions needed?** (click dropdown, hover, etc.)
8. **Output path?** (suggest based on doc location)
9. **Which .qmd file references this image?** (for doc.file in manifest)

Then:
1. Add entry to manifest.json
2. Create example project if needed
3. Render + serve + capture + compress
4. Verify the screenshot looks correct

### Launching the capture agent:

Use the Agent tool with subagent_type="general-purpose" and model="sonnet":
- Pass the URL, viewport size, cleanup steps, interaction steps, element selector, and output path
- The agent has the playwright-cli skill and will handle all browser operations
- The agent validates visual correctness before saving
```

### `!` Preprocessing

The `!`backtick`` syntax runs the command at skill-load time, before Claude processes the prompt. This means:
- `!`node tools/screenshots/scripts/list.js`` outputs the formatted manifest → injected as text
- `!`cat tools/screenshots/CLAUDE.md`` outputs the visual rules → injected as text
- Zero AI turns spent reading these files

## Helper Scripts

All in `tools/screenshots/scripts/`. Zero npm dependencies — Node.js built-ins only.

### scripts/list.js (~30 lines)

Reads manifest.json, formats for Claude to read.

```javascript
#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/list.js [--name <pattern>]

import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const manifest = JSON.parse(readFileSync(join(__dirname, '..', 'manifest.json'), 'utf8'));

const namePattern = process.argv.includes('--name')
  ? process.argv[process.argv.indexOf('--name') + 1]
  : null;

const filtered = namePattern
  ? manifest.screenshots.filter(s => {
      if (namePattern.includes('*')) {
        const re = new RegExp('^' + namePattern.replace(/\*/g, '.*') + '$');
        return re.test(s.name);
      }
      return s.name === namePattern;
    })
  : manifest.screenshots;

console.log(`### ${filtered.length} screenshot(s) in manifest\n`);
for (const s of filtered) {
  const src = s.source.type === 'example' ? s.source.project
    : s.source.type === 'url' ? s.source.url
    : s.source.path || s.source.page;
  const vp = s.capture?.viewport || manifest.defaults.viewport;
  console.log(`- **${s.name}** → \`${s.output}\``);
  console.log(`  Source: ${s.source.type} (${src})`);
  console.log(`  Viewport: ${vp.width}x${vp.height}`);
  if (s.capture?.element) console.log(`  Element: \`${s.capture.element}\``);
  if (s.capture?.interaction?.length) console.log(`  Interactions: ${s.capture.interaction.length} step(s)`);
  console.log();
}
```

**Output example:**
```
### 8 screenshot(s) in manifest

- **navbar-tools** → `docs/websites/images/navbar-tools.png`
  Source: example (examples/navbar-tools)
  Viewport: 1440x400
  Element: `.navbar`
  Interactions: 1 step(s)

- **about-jolla** → `docs/websites/images/about-jolla.png`
  Source: example (examples/about-pages)
  Viewport: 1200x900
```

### scripts/render.js (~15 lines)

Runs `quarto render` on an example project.

```javascript
#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/render.js <project-dir>
// Example: node tools/screenshots/scripts/render.js tools/screenshots/examples/navbar-tools

import { execSync } from 'node:child_process';
import { resolve } from 'node:path';

const projectDir = resolve(process.argv[2]);
if (!process.argv[2]) {
  console.error('Usage: node render.js <project-dir>');
  process.exit(1);
}

console.log(`Rendering: ${projectDir}`);
execSync(`quarto render "${projectDir}"`, { stdio: 'inherit' });
console.log(`Done. Output in: ${projectDir}/_site/`);
```

### scripts/serve.js (~35 lines)

Starts a static file server. Detects `simple-http-server.exe` (Chris's preferred tool) or falls back to Node.js built-in.

```javascript
#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/serve.js <dir> [--port <port>]
// Prints the URL to stdout. Server runs in foreground (Ctrl+C to stop).
// When called from capture.js, spawned as background process.

import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';

const dir = path.resolve(process.argv[2] || '.');
const portArg = process.argv.includes('--port')
  ? parseInt(process.argv[process.argv.indexOf('--port') + 1])
  : 0;

const MIME = {
  '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml',
  '.json': 'application/json', '.woff2': 'font/woff2', '.woff': 'font/woff',
  '.ttf': 'font/ttf', '.ico': 'image/x-icon',
};

const server = http.createServer((req, res) => {
  let filePath = path.join(dir, decodeURIComponent(new URL(req.url, 'http://localhost').pathname));
  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, 'index.html');
  }
  const ext = path.extname(filePath);
  const stream = fs.createReadStream(filePath);
  res.setHeader('Content-Type', MIME[ext] || 'application/octet-stream');
  stream.pipe(res);
  stream.on('error', () => { res.writeHead(404); res.end('Not found'); });
});

server.listen(portArg, () => {
  const { port } = server.address();
  console.log(`http://localhost:${port}`);
});
```

### scripts/compress.js (~20 lines)

Runs oxipng if available, silently skips otherwise.

```javascript
#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/compress.js <file.png> [<file2.png> ...]

import { execSync } from 'node:child_process';

// Check if oxipng is available
let hasOxipng = false;
try {
  execSync('oxipng --version', { stdio: 'pipe' });
  hasOxipng = true;
} catch { /* not installed — skip */ }

const files = process.argv.slice(2);
if (files.length === 0) {
  console.error('Usage: node compress.js <file.png> [...]');
  process.exit(1);
}

if (!hasOxipng) {
  console.log('oxipng not found — skipping compression (CI will handle it)');
  process.exit(0);
}

for (const file of files) {
  console.log(`Compressing: ${file}`);
  execSync(`oxipng -o 4 -i 0 --strip safe "${file}"`, { stdio: 'inherit' });
}
```

## Script Design Principles

1. **Zero npm dependencies** — all built-in Node.js modules
2. **One responsibility per script** — render, serve, list, compress
3. **Deterministic** — no AI judgment, same input → same output
4. **Composable** — can be called from capture.js, from /screenshot command, or standalone
5. **Clear stdout** — scripts print exactly what the orchestrator needs (URLs, paths, status)
