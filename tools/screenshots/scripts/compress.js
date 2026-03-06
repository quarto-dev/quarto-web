#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/compress.js [<file.png> ...]
// No args: compress all manifest outputs that exist on disk.
// With args: compress the specified files.
// Runs oxipng if available, silently skips otherwise.

import { execSync, execFileSync } from 'node:child_process';
import { statSync, existsSync, readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, '..', '..', '..');

let hasOxipng = false;
try {
  execSync('oxipng --version', { stdio: 'pipe' });
  hasOxipng = true;
} catch { /* not installed */ }

let files = process.argv.slice(2);

if (files.length === 0) {
  // No args: collect all manifest output paths
  const manifestPath = resolve(__dirname, '..', 'manifest.json');
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  for (const entry of manifest.screenshots) {
    const light = resolve(repoRoot, entry.output);
    if (existsSync(light)) files.push(light);
    if (entry.dark) {
      const dark = light.replace(/\.png$/, '-dark.png');
      if (existsSync(dark)) files.push(dark);
    }
  }
  if (files.length === 0) {
    console.log('No manifest output files found on disk — nothing to compress.');
    process.exit(0);
  }
  console.log(`Found ${files.length} manifest outputs to compress.`);
}

if (!hasOxipng) {
  console.log('oxipng not found — skipping compression (CI will handle it)');
  process.exit(0);
}

for (const file of files) {
  const before = statSync(file).size;
  execFileSync('oxipng', ['-o', '4', '-i', '0', '--strip', 'safe', file], { stdio: 'pipe' });
  const after = statSync(file).size;
  const saved = before > 0 ? Math.round((1 - after / before) * 100) : 0;
  console.log(`Compressed: ${file} (${formatSize(before)} → ${formatSize(after)}, ${saved}% saved)`);
}

function formatSize(bytes) {
  return bytes < 1024 ? `${bytes}B` : `${Math.round(bytes / 1024)}KB`;
}
