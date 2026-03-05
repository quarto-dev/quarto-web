#!/usr/bin/env node
// Replay script: reads manifest.json and captures all screenshots using playwright-cli.
// No AI needed — purely mechanical execution.
//
// Usage:
//   node tools/screenshots/capture.js                     # all screenshots
//   node tools/screenshots/capture.js --name navbar-tools # specific entry
//   node tools/screenshots/capture.js --name "about-*"    # glob pattern
//   node tools/screenshots/capture.js --dry-run            # show plan only
//   node tools/screenshots/capture.js --no-compress        # skip oxipng
//   node tools/screenshots/capture.js --verify              # open each image for review
//   node tools/screenshots/capture.js --list               # list entries

import { readFileSync, existsSync, statSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { execSync, spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { openFile } from './scripts/open.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TOOLS_DIR = __dirname;
const REPO_ROOT = resolve(__dirname, '..', '..');

// Parse args
const args = process.argv.slice(2);
const namePattern = args.includes('--name') ? args[args.indexOf('--name') + 1] : null;
const dryRun = args.includes('--dry-run');
const noCompress = args.includes('--no-compress');
const verify = args.includes('--verify');
const listOnly = args.includes('--list');
const SESSION = 'screenshot';

// Read manifest
const manifest = JSON.parse(readFileSync(join(TOOLS_DIR, 'manifest.json'), 'utf8'));

// Filter screenshots
function matchName(name, pattern) {
  if (!pattern) return true;
  if (pattern.includes('*')) {
    const re = new RegExp('^' + pattern.replace(/\*/g, '.*') + '$');
    return re.test(name);
  }
  return name === pattern;
}

const screenshots = manifest.screenshots.filter(s => matchName(s.name, namePattern));

if (screenshots.length === 0) {
  console.error(`No screenshots match pattern: ${namePattern}`);
  process.exit(1);
}

// --list mode
if (listOnly) {
  for (const s of screenshots) {
    console.log(`${s.name} → ${s.output}`);
  }
  process.exit(0);
}

// Group by source project (avoid re-rendering the same project)
function groupBySource(shots) {
  const groups = new Map();
  for (const s of shots) {
    const key = s.source.type === 'example' ? s.source.project
      : s.source.type === 'url' ? `url:${s.source.url}`
      : `local:${s.source.page || 'site'}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(s);
  }
  return groups;
}

// Run a playwright-cli command in the screenshot session
function pcli(...args) {
  const cmd = `playwright-cli -s=${SESSION} ${args.join(' ')}`;
  if (dryRun) {
    console.log(`  [dry-run] ${cmd}`);
    return '';
  }
  try {
    return execSync(cmd, { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] });
  } catch (e) {
    console.error(`  playwright-cli error: ${e.stderr || e.message}`);
    throw e;
  }
}

// Start a Node.js file server, return { url, kill }
function startServer(dir) {
  const serveScript = join(TOOLS_DIR, 'scripts', 'serve.js');
  return new Promise((resolvePromise, reject) => {
    const proc = spawn('node', [serveScript, dir], {
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    let output = '';
    proc.stdout.on('data', chunk => {
      output += chunk.toString();
      const match = output.match(/http:\/\/localhost:\d+/);
      if (match) {
        resolvePromise({
          url: match[0],
          kill: () => proc.kill(),
        });
      }
    });
    proc.stderr.on('data', chunk => {
      console.error(`  serve.js: ${chunk}`);
    });
    proc.on('error', reject);
    setTimeout(() => reject(new Error('Server start timeout')), 10000);
  });
}

// Render a Quarto project
function renderProject(projectDir) {
  const renderScript = join(TOOLS_DIR, 'scripts', 'render.js');
  console.log(`  Rendering ${projectDir}...`);
  if (!dryRun) {
    execSync(`node "${renderScript}" "${projectDir}"`, { stdio: 'inherit' });
  }
}

// Run cleanup steps (defaults + per-screenshot)
function runCleanup(shot) {
  const steps = [...(manifest.defaults.cleanup || []), ...(shot.capture?.cleanup || [])];
  for (const step of steps) {
    if (step.action === 'eval') {
      pcli('eval', JSON.stringify(step.script));
    }
  }
}

// Run interaction steps
function runInteractions(shot) {
  const steps = shot.capture?.interaction || [];
  for (const step of steps) {
    switch (step.action) {
      case 'click':
        pcli('run-code', JSON.stringify(`async page => await page.click('${step.selector}')`));
        if (step.wait) {
          pcli('run-code', JSON.stringify(`async page => await page.waitForSelector('${step.wait}', { timeout: 5000 })`));
        }
        break;
      case 'hover':
        pcli('run-code', JSON.stringify(`async page => await page.hover('${step.selector}')`));
        break;
      case 'wait':
        pcli('run-code', JSON.stringify(`async page => await page.waitForSelector('${step.selector}', { timeout: ${step.timeout || 5000} })`));
        break;
      case 'eval':
        pcli('eval', JSON.stringify(step.script));
        break;
      case 'scroll':
        pcli('run-code', JSON.stringify(`async page => await page.locator('${step.selector}').scrollIntoViewIfNeeded()`));
        break;
    }
  }
}

// Take a screenshot
function takeScreenshot(shot) {
  const outputPath = resolve(REPO_ROOT, shot.output);
  if (shot.capture?.element) {
    // Element screenshot via run-code (bypasses ref system)
    const selector = shot.capture.element.replace(/'/g, "\\'");
    pcli('run-code', JSON.stringify(`async page => {
  await page.locator('${selector}').screenshot({ path: '${outputPath.replace(/\\/g, '/')}' });
}`));
  } else {
    pcli('screenshot', `--filename="${outputPath}"`);
  }
  return outputPath;
}

// Compress a PNG
function compressPng(filePath) {
  if (noCompress) return;
  const compressScript = join(TOOLS_DIR, 'scripts', 'compress.js');
  execSync(`node "${compressScript}" "${filePath}"`, { stdio: 'inherit' });
}

// Main
async function main() {
  const groups = groupBySource(screenshots);
  const results = [];
  let total = 0;

  console.log(`Capturing ${screenshots.length} screenshot(s)...\n`);

  for (const [sourceKey, shots] of groups) {
    let server = null;
    let baseUrl = '';

    try {
      // Prepare source
      if (shots[0].source.type === 'example') {
        const projectDir = resolve(TOOLS_DIR, shots[0].source.project);
        renderProject(projectDir);
        const siteDir = join(projectDir, '_site');
        if (!dryRun) {
          server = await startServer(siteDir);
          baseUrl = server.url;
          console.log(`  Serving ${siteDir} at ${baseUrl}`);
        }
      } else if (shots[0].source.type === 'url') {
        baseUrl = shots[0].source.url;
      }

      // Open browser session
      const firstPage = shots[0].source.page || '';
      const firstUrl = baseUrl + (firstPage ? `/${firstPage}` : '');
      pcli('open', firstUrl);

      for (const shot of shots) {
        total++;
        const label = `[${total}/${screenshots.length}] ${shot.name}`;
        console.log(`\n${label}`);

        try {
          // Navigate if not the first page in this group
          if (shot !== shots[0]) {
            const page = shot.source.page || 'index.html';
            pcli('goto', `${baseUrl}/${page}`);
          }

          // Resize viewport
          const vp = shot.capture?.viewport || manifest.defaults.viewport;
          pcli('resize', `${vp.width}`, `${vp.height}`);

          // Wait for load
          pcli('eval', '"document.readyState"');

          // Cleanup
          runCleanup(shot);

          // Interactions
          runInteractions(shot);

          // Screenshot
          const outputPath = takeScreenshot(shot);

          // Compress
          if (!dryRun) {
            compressPng(outputPath);
          }

          // Verify — open image for visual review
          if (verify && !dryRun) {
            console.log(`  Opening for review: ${outputPath}`);
            openFile(outputPath);
          }

          console.log(`  ${label} ... done`);
          results.push({ name: shot.name, status: 'ok' });
        } catch (e) {
          console.error(`  ${label} ... FAILED: ${e.message}`);
          results.push({ name: shot.name, status: 'failed', error: e.message });
        }
      }

      // Close browser session
      try { pcli('close'); } catch { /* ignore */ }

    } finally {
      if (server) server.kill();
    }
  }

  // Summary
  console.log('\n--- Results ---');
  const ok = results.filter(r => r.status === 'ok').length;
  const failed = results.filter(r => r.status === 'failed').length;
  for (const r of results) {
    const icon = r.status === 'ok' ? 'ok' : 'FAILED';
    console.log(`  ${icon}: ${r.name}${r.error ? ` (${r.error})` : ''}`);
  }
  console.log(`\nDone: ${ok}/${results.length} succeeded${failed ? `, ${failed} failed` : ''}`);
  process.exit(failed > 0 ? 1 : 0);
}

main().catch(e => {
  console.error(`Fatal: ${e.message}`);
  process.exit(1);
});
