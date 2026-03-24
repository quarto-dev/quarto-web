#!/usr/bin/env node
// Usage: node tools/screenshots/scripts/serve.js <dir> [--port <port>]
// Starts a static file server. Prints the URL to stdout.
// Server runs in foreground (Ctrl+C to stop).

import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

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
  const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  let filePath = path.join(dir, pathname);
  const resolved = path.resolve(filePath);
  const dirPrefix = dir.endsWith(path.sep) ? dir : dir + path.sep;
  if (!resolved.startsWith(dirPrefix) && resolved !== dir) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }
  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, 'index.html');
  }
  if (!fs.existsSync(filePath)) {
    res.writeHead(404);
    res.end('Not found');
    return;
  }
  const ext = path.extname(filePath);
  res.setHeader('Content-Type', MIME[ext] || 'application/octet-stream');
  fs.createReadStream(filePath).pipe(res);
});

server.listen(portArg, () => {
  const { port } = server.address();
  console.log(`http://localhost:${port}`);
});
