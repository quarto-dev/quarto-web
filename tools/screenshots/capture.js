#!/usr/bin/env node
// Replay script: reads manifest.json and captures all screenshots using Playwright API.
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

import { readFileSync, existsSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { execSync, spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';
import open from 'open';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TOOLS_DIR = __dirname;
const REPO_ROOT = resolve(__dirname, '..', '..');

// Parse args
const args = process.argv.slice(2);
const namePattern = args.includes('--name') ? args[args.indexOf('--name') + 1] : null;
if (args.includes('--name') && !namePattern) {
  console.error('--name requires a value');
  process.exit(1);
}
const dryRun = args.includes('--dry-run');
const noCompress = args.includes('--no-compress');
const verify = args.includes('--verify');
const listOnly = args.includes('--list');

// Read manifest
const manifest = JSON.parse(readFileSync(join(TOOLS_DIR, 'manifest.json'), 'utf8'));

// Filter screenshots
function matchName(name, pattern) {
  if (!pattern) return true;
  if (pattern.includes('*')) {
    const escaped = pattern.replace(/[.+?^${}()|[\]\\]/g, '\\$&');
    const re = new RegExp('^' + escaped.replace(/\*/g, '.*') + '$');
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
    if (s.dark) {
      const ext = s.output.lastIndexOf('.');
      console.log(`${s.name} (dark) → ${s.output.slice(0, ext)}-dark${s.output.slice(ext)}`);
    }
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
    proc.on('close', (code) => {
      if (code !== 0) reject(new Error(`serve.js exited with code ${code}`));
    });
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
async function runCleanup(page, shot) {
  const steps = [...(manifest.defaults.cleanup || []), ...(shot.capture?.cleanup || [])];
  for (const step of steps) {
    if (step.action === 'eval') {
      await page.evaluate(step.script);
    }
  }
}

// Run interaction steps
async function runInteractions(page, shot) {
  const steps = shot.capture?.interaction || [];
  for (const step of steps) {
    switch (step.action) {
      case 'click':
        await page.locator(step.selector).click();
        if (step.wait) {
          await page.locator(step.wait).waitFor({ timeout: 5000 });
        }
        break;
      case 'hover':
        await page.locator(step.selector).hover();
        break;
      case 'wait':
        await page.locator(step.selector).waitFor({ timeout: step.timeout || 5000 });
        break;
      case 'eval':
        await page.evaluate(step.script);
        break;
      case 'scroll':
        await page.locator(step.selector).scrollIntoViewIfNeeded();
        break;
    }
  }
}

// Compute dark output path: about-jolla.png → about-jolla-dark.png
function darkOutputPath(outputPath) {
  const ext = outputPath.lastIndexOf('.');
  return outputPath.slice(0, ext) + '-dark' + outputPath.slice(ext);
}

// Switch to dark mode by clicking the toggle
async function switchToDark(page) {
  const darkConfig = manifest.defaults.dark;
  await page.locator(darkConfig.toggle).click();
  await page.locator(darkConfig.ready).waitFor({ timeout: 5000 });
  if (darkConfig.settle) {
    await page.waitForTimeout(darkConfig.settle);
  }
}

// Switch back to light mode
async function switchToLight(page) {
  const darkConfig = manifest.defaults.dark;
  await page.locator(darkConfig.toggle).click();
  await page.locator(darkConfig.readyLight || 'body:not(.quarto-dark)').waitFor({ timeout: 5000 });
  if (darkConfig.settle) {
    await page.waitForTimeout(darkConfig.settle);
  }
}

// Compute clip region from selectors
async function computeClip(page, selectors) {
  const boxes = [];
  for (const sel of selectors) {
    const loc = page.locator(sel);
    if (await loc.count() > 0) {
      const box = await loc.first().boundingBox();
      if (box) boxes.push(box);
    }
  }
  if (boxes.length === 0) throw new Error('No clip selectors matched');
  if (boxes.length < selectors.length) {
    console.warn(`  Warning: only ${boxes.length}/${selectors.length} clip selectors matched`);
  }
  const vp = page.viewportSize();
  const pad = 10;
  const x = Math.max(0, Math.min(...boxes.map(b => b.x)) - pad);
  const y = Math.max(0, Math.min(...boxes.map(b => b.y)) - pad);
  const right = Math.min(Math.max(...boxes.map(b => b.x + b.width)) + pad, vp.width);
  const bottom = Math.min(Math.max(...boxes.map(b => b.y + b.height)) + pad, vp.height);
  return { x, y, width: right - x, height: bottom - y };
}

// Take a screenshot (optionally override output path and/or clip)
async function takeScreenshot(page, shot, overridePath, overrideClip) {
  const outputPath = overridePath || resolve(REPO_ROOT, shot.output);

  if (shot.capture?.clip) {
    const clip = overrideClip || await computeClip(page, shot.capture.clip);
    await page.screenshot({ path: outputPath, clip });
  } else if (shot.capture?.element) {
    await page.locator(shot.capture.element).screenshot({ path: outputPath });
  } else {
    await page.screenshot({ path: outputPath });
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
    let browser = null;

    try {
      let baseUrl = '';

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

      // Launch browser
      if (!dryRun) {
        browser = await chromium.launch({ headless: true });
      }
      const context = !dryRun ? await browser.newContext() : null;
      const page = !dryRun ? await context.newPage() : null;

      // Navigate to first page
      const firstPage = shots[0].source.page || '';
      const firstUrl = baseUrl + (firstPage ? `/${firstPage}` : '');
      if (!dryRun) {
        await page.goto(firstUrl, { waitUntil: 'domcontentloaded' });
      } else {
        console.log(`  [dry-run] goto ${firstUrl}`);
      }

      for (const shot of shots) {
        total++;
        const label = `[${total}/${screenshots.length}] ${shot.name}`;
        console.log(`\n${label}`);

        try {
          // Navigate if not the first page in this group
          if (shot !== shots[0]) {
            const pagePath = shot.source.page || 'index.html';
            if (!dryRun) {
              await page.goto(`${baseUrl}/${pagePath}`, { waitUntil: 'domcontentloaded' });
            } else {
              console.log(`  [dry-run] goto ${baseUrl}/${pagePath}`);
            }
          }

          // Resize viewport
          const vp = shot.capture?.viewport || manifest.defaults.viewport;
          if (!dryRun) {
            await page.setViewportSize({ width: vp.width, height: vp.height });
          } else {
            console.log(`  [dry-run] resize ${vp.width}x${vp.height}`);
          }

          if (!dryRun) {
            // Cleanup
            await runCleanup(page, shot);

            // Interactions
            await runInteractions(page, shot);

            // For dark variants with clip: compute union clip across both modes
            // so light and dark screenshots have identical dimensions
            let sharedClip = null;
            if (shot.dark && shot.capture?.clip) {
              const lightClip = await computeClip(page, shot.capture.clip);
              await switchToDark(page);
              await runInteractions(page, shot);
              const darkClip = await computeClip(page, shot.capture.clip);
              // Union of both clip regions
              const x = Math.min(lightClip.x, darkClip.x);
              const y = Math.min(lightClip.y, darkClip.y);
              const right = Math.max(lightClip.x + lightClip.width, darkClip.x + darkClip.width);
              const bottom = Math.max(lightClip.y + lightClip.height, darkClip.y + darkClip.height);
              sharedClip = { x, y, width: right - x, height: bottom - y };
              // Take dark screenshot while we're here
              const darkPath = darkOutputPath(resolve(REPO_ROOT, shot.output));
              console.log(`  ${shot.name} (dark)...`);
              await takeScreenshot(page, shot, darkPath, sharedClip);
              compressPng(darkPath);
              // Switch back to light for the light screenshot
              await switchToLight(page);
              await runInteractions(page, shot);
            }

            // Light screenshot
            const outputPath = await takeScreenshot(page, shot, null, sharedClip);
            compressPng(outputPath);

            // Dark variant (non-clip mode: element or viewport)
            if (shot.dark && !shot.capture?.clip) {
              console.log(`  ${shot.name} (dark)...`);
              await switchToDark(page);
              const darkPath = darkOutputPath(outputPath);
              await runInteractions(page, shot);
              await takeScreenshot(page, shot, darkPath);
              compressPng(darkPath);
              await switchToLight(page);
            }

            // Verify — open image for visual review
            if (verify) {
              console.log(`  Opening for review: ${outputPath}`);
              await open(outputPath, { wait: true });
              if (shot.dark) {
                const darkPath = darkOutputPath(outputPath);
                console.log(`  Opening dark for review: ${darkPath}`);
                await open(darkPath, { wait: true });
              }
            }
          }

          console.log(`  ${label} ... done`);
          results.push({ name: shot.name, status: 'ok' });
        } catch (e) {
          console.error(`  ${label} ... FAILED: ${e.message}`);
          results.push({ name: shot.name, status: 'failed', error: e.message });
        }
      }

      // Close browser
      if (browser) {
        await browser.close();
      }

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
