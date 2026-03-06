#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/render.js <project-dir>
// Renders a Quarto example project.
// Set QUARTO_CMD env var to override the quarto command (default: "quarto").

import { execSync } from 'node:child_process';
import { resolve } from 'node:path';

import { existsSync, statSync } from 'node:fs';

const projectDir = resolve(process.argv[2] || '');
if (!process.argv[2]) {
  console.error('Usage: node render.js <project-dir>');
  process.exit(1);
}
if (!existsSync(projectDir) || !statSync(projectDir).isDirectory()) {
  console.error(`Directory not found: ${projectDir}`);
  process.exit(1);
}

const profileIdx = process.argv.indexOf('--profile');
const profile = profileIdx !== -1 ? process.argv[profileIdx + 1] : null;
if (profileIdx !== -1 && (!profile || profile.startsWith('-'))) {
  console.error('--profile requires a value');
  process.exit(1);
}

const quartoCmd = process.env.QUARTO_CMD || 'quarto';
const args = [quartoCmd, 'render', `"${projectDir}"`];
if (profile) args.push('--profile', profile);

const profileLabel = profile ? ` (profile: ${profile})` : '';
console.log(`Rendering: ${projectDir}${profileLabel}`);
execSync(args.join(' '), { stdio: 'inherit' });
console.log(`Done. Output in: ${projectDir}/_site/`);
