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
import { writeFile } from 'node:fs/promises';
import { join, dirname, resolve } from 'node:path';
import { execSync, spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';
import open from 'open';
import sharp from 'sharp';
import { validateManifest } from './scripts/validate.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TOOLS_DIR = __dirname;
const REPO_ROOT = resolve(__dirname, '..', '..');

// Parse args
const args = process.argv.slice(2);

if (args.includes('--help') || args.includes('-h')) {
  console.log(`Usage: npm run capture [-- options]

Options:
  --name <pattern>   Capture specific entry (supports glob patterns)
  --list             List manifest entries
  --dry-run          Show plan without capturing
  --no-compress      Skip oxipng compression
  --verify           Open each image for visual review
  --help, -h         Show this help

Examples:
  npm run capture                          # all screenshots
  npm run capture -- --name navbar-tools   # specific entry
  npm run capture -- --name "about-*"      # glob pattern
  npm run capture -- --dry-run             # preview plan`);
  process.exit(0);
}

const namePattern = args.includes('--name') ? args[args.indexOf('--name') + 1] : null;
if (args.includes('--name') && (!namePattern || namePattern.startsWith('-'))) {
  console.error('--name requires a value');
  process.exit(1);
}
const dryRun = args.includes('--dry-run');
const noCompress = args.includes('--no-compress');
const verify = args.includes('--verify');
const listOnly = args.includes('--list');

// Read manifest
const manifest = JSON.parse(readFileSync(join(TOOLS_DIR, 'manifest.json'), 'utf8'));

// Validate manifest against schema
const validation = validateManifest(manifest);
if (!validation.valid) {
  console.error('manifest.json validation failed:');
  validation.errors.forEach(e => console.error(`  ${e}`));
  process.exit(1);
}

// Compression: respect both manifest defaults and CLI flag
const shouldCompress = (manifest.defaults?.compress ?? true) && !noCompress;

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
    const key = s.source.type === 'example'
      ? s.source.project + (s.source.profile ? `:${s.source.profile}` : '')
      : s.source.type === 'url' ? `url:${s.source.url}`
      : `local:${s.source.path}`;
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
    const timer = setTimeout(() => { try { proc.kill(); } catch {} reject(new Error('Server start timeout')); }, 10000);
    proc.stdout.on('data', chunk => {
      output += chunk.toString();
      const match = output.match(/http:\/\/localhost:\d+/);
      if (match) {
        clearTimeout(timer);
        resolvePromise({
          url: match[0],
          kill: () => proc.kill(),
        });
      }
    });
    proc.stderr.on('data', chunk => {
      console.error(`  serve.js: ${chunk}`);
    });
    proc.on('error', (err) => { clearTimeout(timer); reject(err); });
    proc.on('close', (code) => {
      if (code !== 0) { clearTimeout(timer); reject(new Error(`serve.js exited with code ${code}`)); }
    });
  });
}

// Render a Quarto project
// Read project.output-dir from _quarto.yml, checking profile override first (default: '_site')
function getOutputDir(projectDir, profile) {
  const parseOutputDir = (filePath) => {
    if (!existsSync(filePath)) return null;
    const content = readFileSync(filePath, 'utf8');
    const match = content.match(/^\s*output-dir:\s*(.+)$/m);
    return match ? match[1].trim().replace(/^["']|["']$/g, '') : null;
  };
  if (profile) {
    const profileDir = parseOutputDir(join(projectDir, `_quarto-${profile}.yml`));
    if (profileDir) return profileDir;
  }
  return parseOutputDir(join(projectDir, '_quarto.yml')) || '_site';
}

function renderProject(projectDir, profile) {
  const renderScript = join(TOOLS_DIR, 'scripts', 'render.js');
  const profileLabel = profile ? ` (profile: ${profile})` : '';
  console.log(`  Rendering ${projectDir}${profileLabel}...`);
  if (!dryRun) {
    const args = [renderScript, projectDir];
    if (profile) args.push('--profile', profile);
    execSync(`node ${args.map(a => `"${a}"`).join(' ')}`, { stdio: 'inherit' });
  }
}

// Run cleanup steps (defaults + per-screenshot), then apply spotlight if configured
async function runCleanup(page, shot) {
  const steps = [...(manifest.defaults.cleanup || []), ...(shot.capture?.cleanup || [])];
  for (const step of steps) {
    if (step.action === 'eval') {
      await page.evaluate(step.script);
    }
  }
  if (shot.capture?.spotlight) {
    await applySpotlight(page, shot.capture.spotlight);
  }
}

// Spotlight effect: dim page with overlay, highlight target element
async function applySpotlight(page, config) {
  const { selector, elevate, dim, overlay = 0.5, radius = '6px', padding = '8px' } = config;
  const dimSelectors = Array.isArray(dim) ? dim : dim ? [dim] : [];

  await page.evaluate(({ selector, elevate, dimSelectors, overlay, radius, padding }) => {
    // Idempotent: remove previous spotlight
    document.getElementById('__spotlight-overlay')?.remove();
    document.getElementById('__spotlight-style')?.remove();

    const bg = getComputedStyle(document.body).backgroundColor;

    // Hide scrollbar — the overlay div can trigger one
    document.documentElement.style.overflow = 'hidden';

    let css = `
      #__spotlight-overlay {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, ${overlay});
        z-index: 9998;
        pointer-events: none;
      }
      ${selector} {
        background: ${bg} !important;
        border-radius: ${radius} !important;
        padding: ${padding} !important;
      }
    `;

    if (elevate) {
      // Lift ancestor above overlay (stacking context fix)
      css += `${elevate} { z-index: 9999 !important; }\n`;
    } else {
      // Simple case: target itself above overlay
      css += `${selector} { position: relative !important; z-index: 9999 !important; }\n`;
    }

    for (const dimSel of dimSelectors) {
      css += `${dimSel} { opacity: 0.3 !important; }\n`;
    }

    const style = document.createElement('style');
    style.id = '__spotlight-style';
    style.textContent = css;
    document.head.appendChild(style);

    const overlay_el = document.createElement('div');
    overlay_el.id = '__spotlight-overlay';
    document.body.appendChild(overlay_el);
  }, { selector, elevate, dimSelectors, overlay, radius, padding });
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
      default:
        console.warn(`  Warning: unknown interaction action "${step.action}", skipping`);
    }
  }
}

// Compute dark output path: about-jolla.png → about-jolla-dark.png
function darkOutputPath(outputPath) {
  const ext = outputPath.lastIndexOf('.');
  return outputPath.slice(0, ext) + '-dark' + outputPath.slice(ext);
}

// Switch to dark mode via JS (avoids toggle visibility issues at narrow viewports)
async function switchToDark(page) {
  const darkConfig = manifest.defaults.dark;
  await page.evaluate(() => {
    if (typeof window.quartoToggleColorScheme !== 'function') {
      throw new Error('quartoToggleColorScheme not found — page may not support dark mode');
    }
    window.quartoToggleColorScheme();
  });
  await page.locator(darkConfig.ready).waitFor({ timeout: 5000 });
  if (darkConfig.settle) {
    await page.waitForTimeout(darkConfig.settle);
  }
}

// Switch back to light mode
async function switchToLight(page) {
  const darkConfig = manifest.defaults.dark;
  await page.evaluate(() => {
    if (typeof window.quartoToggleColorScheme !== 'function') {
      throw new Error('quartoToggleColorScheme not found — page may not support dark mode');
    }
    window.quartoToggleColorScheme();
  });
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
  const pad = 20;
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
  if (!shouldCompress) return;
  const compressScript = join(TOOLS_DIR, 'scripts', 'compress.js');
  execSync(`node "${compressScript}" "${filePath}"`, { stdio: 'inherit' });
}

// Content-aware trim: remove blank edges, add uniform padding
async function trimPng(filePath, trimConfig) {
  const threshold = trimConfig.threshold ?? 10;
  const padding = trimConfig.padding ?? 20;

  // Determine background color: explicit config or sample top-left pixel (sharp's default)
  let bg = trimConfig.background;
  if (!bg) {
    const { data } = await sharp(filePath)
      .extract({ left: 0, top: 0, width: 1, height: 1 })
      .raw()
      .toBuffer({ resolveWithObject: true });
    bg = { r: data[0], g: data[1], b: data[2] };
  }

  const trimmed = await sharp(filePath)
    .trim({ background: bg, threshold, lineArt: true })
    .extend({ top: padding, bottom: padding, left: padding, right: padding, background: bg })
    .toBuffer();

  await writeFile(filePath, trimmed);
}

// Crop image: remove pixels from bottom and/or enforce max height
async function cropPng(filePath, { cropBottom = 0, maxHeight = 0 }) {
  const meta = await sharp(filePath).metadata();
  let targetHeight = meta.height;

  if (cropBottom > 0) {
    targetHeight = Math.max(1, targetHeight - cropBottom);
  }
  if (maxHeight > 0 && targetHeight > maxHeight) {
    targetHeight = maxHeight;
  }
  if (targetHeight === meta.height) return;

  const cropped = await sharp(filePath)
    .extract({ left: 0, top: 0, width: meta.width, height: targetHeight })
    .toBuffer();

  await writeFile(filePath, cropped);
}

// Post-process a screenshot: trim, crop, compress (in order)
async function postProcess(filePath, shot) {
  const trimConfig = shot.capture?.trim ?? manifest.defaults.trim ?? false;
  if (trimConfig) {
    await trimPng(filePath, trimConfig === true ? {} : trimConfig);
  }

  const cropBottom = shot.capture?.cropBottom ?? 0;
  const maxHeight = shot.capture?.maxHeight ?? 0;
  if (cropBottom || maxHeight) {
    await cropPng(filePath, { cropBottom, maxHeight });
  }

  compressPng(filePath);
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
        renderProject(projectDir, shots[0].source.profile);
        const siteDir = join(projectDir, getOutputDir(projectDir, shots[0].source.profile));
        if (!dryRun) {
          server = await startServer(siteDir);
          baseUrl = server.url;
          console.log(`  Serving ${siteDir} at ${baseUrl}`);
        }
      } else if (shots[0].source.type === 'url') {
        baseUrl = shots[0].source.url;
      } else if (shots[0].source.type === 'local') {
        const siteDir = resolve(REPO_ROOT, shots[0].source.path);
        if (!dryRun) {
          server = await startServer(siteDir);
          baseUrl = server.url;
          console.log(`  Serving ${siteDir} at ${baseUrl}`);
        }
      }

      // Launch browser
      if (!dryRun) {
        browser = await chromium.launch({ headless: true });
      }
      const context = !dryRun ? await browser.newContext() : null;
      const page = !dryRun ? await context.newPage() : null;

      // Build navigation URL for a shot
      function shotUrl(shot) {
        if (shot.source.type === 'url') return shot.source.url;
        const pagePath = shot.source.page || '';
        return baseUrl + (pagePath ? `/${pagePath}` : '');
      }

      // Navigate to first page
      const firstUrl = shotUrl(shots[0]);
      if (!dryRun) {
        await page.goto(firstUrl, { waitUntil: 'domcontentloaded' });
      } else {
        const profileLabel = shots[0].source.profile ? ` [profile: ${shots[0].source.profile}]` : '';
        console.log(`  [dry-run] goto ${firstUrl}${profileLabel}`);
      }

      for (const shot of shots) {
        total++;
        const label = `[${total}/${screenshots.length}] ${shot.name}`;
        console.log(`\n${label}`);

        try {
          // Navigate if not the first page in this group
          if (shot !== shots[0]) {
            const targetUrl = shotUrl(shot);
            if (!dryRun) {
              await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });
            } else {
              console.log(`  [dry-run] goto ${targetUrl}`);
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
            // Prepare page: zoom, cleanup (+ spotlight), interactions
            async function prepareShot() {
              const zoom = shot.capture?.zoom || manifest.defaults.zoom || 1;
              if (zoom !== 1) {
                await page.evaluate(z => document.body.style.zoom = z, String(zoom));
                await page.waitForTimeout(200);
              }
              await runCleanup(page, shot);
              await runInteractions(page, shot);
            }

            // --- Light screenshot ---
            await prepareShot();

            let sharedClip = null;
            if (shot.dark && shot.capture?.clip) {
              // Compute light clip for union calculation
              sharedClip = await computeClip(page, shot.capture.clip);
            }

            const outputPath = await takeScreenshot(page, shot, null, sharedClip);
            await postProcess(outputPath, shot);

            // --- Dark variant ---
            if (shot.dark) {
              console.log(`  ${shot.name} (dark)...`);
              // Reload fresh page, switch to dark before cleanup
              const url = shotUrl(shot);
              await page.goto(url, { waitUntil: 'domcontentloaded' });
              await page.setViewportSize({ width: vp.width, height: vp.height });
              await switchToDark(page);
              await prepareShot();

              const darkPath = darkOutputPath(resolve(REPO_ROOT, shot.output));

              if (shot.capture?.clip) {
                // Compute dark clip and union with light clip
                const darkClip = await computeClip(page, shot.capture.clip);
                const x = Math.min(sharedClip.x, darkClip.x);
                const y = Math.min(sharedClip.y, darkClip.y);
                const right = Math.max(sharedClip.x + sharedClip.width, darkClip.x + darkClip.width);
                const bottom = Math.max(sharedClip.y + sharedClip.height, darkClip.y + darkClip.height);
                const unionClip = { x, y, width: right - x, height: bottom - y };
                await takeScreenshot(page, shot, darkPath, unionClip);
              } else {
                await takeScreenshot(page, shot, darkPath);
              }
              await postProcess(darkPath, shot);

              // Reset dark mode state so subsequent shots in this group start light
              await page.evaluate(() => localStorage.removeItem('quarto-color-scheme'));
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

    } finally {
      try { if (browser) await browser.close(); } catch (e) { console.error('  browser.close failed:', e); }
      if (server) try { server.kill(); } catch (e) { if (e.code !== 'ESRCH') throw e; }
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
