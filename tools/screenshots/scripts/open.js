#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/open.js <file>
// Opens a file with the OS default application.
// Designed for image verification after screenshot capture.

import { spawn } from 'node:child_process';

export function openFile(filePath) {
  const [cmd, args, opts] = process.platform === 'win32'
    ? ['cmd', ['/c', 'start', '""', filePath], {}]
    : process.platform === 'darwin'
    ? ['open', [filePath], {}]
    : ['xdg-open', [filePath], { detached: true }];

  try {
    spawn(cmd, args, { stdio: 'ignore', ...opts }).unref();
  } catch {
    console.log(`Could not open automatically. Open manually: ${filePath}`);
  }
}

// CLI usage
if (process.argv[1] && process.argv[1].endsWith('open.js') && process.argv[2]) {
  openFile(process.argv[2]);
}
