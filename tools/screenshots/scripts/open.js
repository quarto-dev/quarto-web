#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/open.js <file>
// Opens a file with the OS default application.

import open from 'open';

const file = process.argv[2];
if (!file) {
  console.error('Usage: node open.js <file>');
  process.exit(1);
}
await open(file);
