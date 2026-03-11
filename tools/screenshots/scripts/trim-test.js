#!/usr/bin/env node
// Standalone trim test — validates sharp trim on a PNG.
// Writes a -trimmed.png alongside for visual comparison.
//
// Usage: node scripts/trim-test.js <input.png> [threshold] [padding]

import sharp from 'sharp';
import { basename, dirname, extname, join } from 'node:path';

const [inputPath, thresholdArg, paddingArg] = process.argv.slice(2);

if (!inputPath) {
  console.error('Usage: node scripts/trim-test.js <input.png> [threshold] [padding]');
  process.exit(1);
}

const threshold = thresholdArg != null ? Number(thresholdArg) : 10;
const padding = paddingArg != null ? Number(paddingArg) : 20;

// Build output path: foo.png → foo-trimmed.png
const ext = extname(inputPath);
const base = basename(inputPath, ext);
const outputPath = join(dirname(inputPath), `${base}-trimmed${ext}`);

// Read original dimensions
const meta = await sharp(inputPath).metadata();
console.log(`Input:     ${meta.width}x${meta.height}  ${inputPath}`);

// Sample top-left pixel for background color
const { data } = await sharp(inputPath)
  .extract({ left: 0, top: 0, width: 1, height: 1 })
  .raw()
  .toBuffer({ resolveWithObject: true });
const bg = { r: data[0], g: data[1], b: data[2] };
console.log(`Background: rgb(${bg.r}, ${bg.g}, ${bg.b})`);

// Trim + extend
const trimmed = await sharp(inputPath)
  .trim({ threshold, lineArt: true })
  .extend({ top: padding, bottom: padding, left: padding, right: padding, background: bg })
  .toBuffer();

await sharp(trimmed).toFile(outputPath);

const outMeta = await sharp(outputPath).metadata();
console.log(`Output:    ${outMeta.width}x${outMeta.height}  ${outputPath}`);
console.log(`Threshold: ${threshold}, Padding: ${padding}`);
console.log(`Delta:     ${meta.width - outMeta.width}px width, ${meta.height - outMeta.height}px height`);
