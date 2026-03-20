#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/list.js [--name <pattern>]
// Reads manifest.json and formats screenshot entries for Claude to read.

import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const manifest = JSON.parse(readFileSync(join(__dirname, '..', 'manifest.json'), 'utf8'));

const namePattern = process.argv.includes('--name')
  ? process.argv[process.argv.indexOf('--name') + 1]
  : null;
if (process.argv.includes('--name') && (!namePattern || namePattern.startsWith('-'))) {
  console.error('--name requires a value');
  process.exit(1);
}

const filtered = namePattern
  ? manifest.screenshots.filter(s => {
      if (namePattern.includes('*')) {
        const escaped = namePattern.replace(/[.+?^${}()|[\]\\]/g, '\\$&');
        const re = new RegExp('^' + escaped.replace(/\*/g, '.*') + '$');
        return re.test(s.name);
      }
      return s.name === namePattern;
    })
  : manifest.screenshots;

console.log(`### ${filtered.length} screenshot(s) in manifest\n`);
for (const s of filtered) {
  const src = s.source.type === 'example' ? s.source.project
    : s.source.url;
  const vp = s.capture?.viewport || manifest.defaults.viewport;
  console.log(`- **${s.name}** → \`${s.output}\``);
  console.log(`  Source: ${s.source.type} (${src})`);
  console.log(`  Viewport: ${vp.width}x${vp.height}`);
  if (s.capture?.element) console.log(`  Element: \`${s.capture.element}\``);
  if (s.capture?.interaction?.length) console.log(`  Interactions: ${s.capture.interaction.length} step(s)`);
  console.log();
}
