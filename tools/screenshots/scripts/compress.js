#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/compress.js <file.png> [<file2.png> ...]
// Runs oxipng if available, silently skips otherwise.

import { execSync, execFileSync } from 'node:child_process';
import { statSync } from 'node:fs';

let hasOxipng = false;
try {
  execSync('oxipng --version', { stdio: 'pipe' });
  hasOxipng = true;
} catch { /* not installed */ }

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
  const before = statSync(file).size;
  execFileSync('oxipng', ['-o', '4', '-i', '0', '--strip', 'safe', file], { stdio: 'pipe' });
  const after = statSync(file).size;
  const saved = before > 0 ? Math.round((1 - after / before) * 100) : 0;
  console.log(`Compressed: ${file} (${formatSize(before)} → ${formatSize(after)}, ${saved}% saved)`);
}

function formatSize(bytes) {
  return bytes < 1024 ? `${bytes}B` : `${Math.round(bytes / 1024)}KB`;
}
