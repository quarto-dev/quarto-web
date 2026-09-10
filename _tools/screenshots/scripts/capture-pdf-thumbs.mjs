// Build gallery card thumbnails for PDF-linked examples from the PDF itself.
//
// Data-driven from docs/gallery/data/*.yml: every card whose `live` URL is a PDF
// gets its `image` regenerated as a spread of the first two pages (or the first
// page alone when the PDF has a single page). The output overwrites the card's
// existing `image` PNG under docs/gallery/thumbnails/, so nothing else changes.
//
// Pipeline per card: resolve the raw PDF URL (GitHub blob -> raw.githubusercontent),
// download it, read the page count with pdfinfo, render the first one or two pages
// with pdftoppm, then composite them side by side with ImageMagick.
//
// Usage (from _tools/screenshots):
//   npm run capture:pdf-thumbs                 # every PDF-linked card
//   npm run capture:pdf-thumbs -- --name whr   # match by name or image path
//   npm run capture:pdf-thumbs -- --limit 1    # first N matches (staging)
//
// Prerequisites: poppler (`pdfinfo`, `pdftoppm`) and ImageMagick (`magick`) on PATH
// (`brew install poppler imagemagick`). See scripts/PREVIEWS.md.

import { readFileSync, existsSync, mkdtempSync, rmSync, statSync, writeFileSync, readdirSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { tmpdir } from "node:os";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { load as yamlLoad } from "js-yaml";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(HERE, "..", "..", "..");
const GALLERY_DIR = join(REPO_ROOT, "docs", "gallery");
const DATA_DIR = join(GALLERY_DIR, "data");

const RENDER_DPI = 150; // pdftoppm render resolution before downscaling
const OUT_WIDTH = 1000; // final composite width (keeps PNG small)
const GUTTER = 12; // px gap between the two page images
const SIZE_BUDGET = 500 * 1024;

function parseArgs(argv) {
  const args = { name: null, limit: Infinity };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--name") args.name = argv[++i];
    else if (argv[i] === "--limit") args.limit = Number(argv[++i]);
  }
  return args;
}

function isPdf(url) {
  return typeof url === "string" && /\.pdf(\?|#|$)/i.test(url);
}

// GitHub "blob" viewer URLs are HTML; rewrite to the raw file host.
function rawUrl(url) {
  const m = url.match(/^https?:\/\/github\.com\/([^/]+)\/([^/]+)\/blob\/(.+)$/i);
  if (m) return `https://raw.githubusercontent.com/${m[1]}/${m[2]}/${m[3]}`;
  return url;
}

function pdfCards() {
  const out = new Map(); // dedupe by output image path (shared across featured + list)
  for (const file of ["featured.yml", "reports-analytics.yml", "dashboards-monitoring.yml", "research-scholarship.yml", "teaching-learning.yml", "software-documentation.yml", "personal-community.yml"]) {
    const path = join(DATA_DIR, file);
    if (!existsSync(path)) continue;
    const doc = yamlLoad(readFileSync(path, "utf8"));
    const cards = [];
    for (const node of doc || []) {
      if (node && Array.isArray(node.cards)) cards.push(...node.cards);
      else cards.push(node);
    }
    for (const card of cards) {
      if (!card || !isPdf(card.live) || !card.image) continue;
      if (!out.has(card.image)) out.set(card.image, { name: card.name || card.title, url: card.live, image: card.image });
    }
  }
  return [...out.values()];
}

async function download(url, dest) {
  const res = await fetch(url, { redirect: "follow" });
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  const buf = Buffer.from(await res.arrayBuffer());
  writeFileSync(dest, buf);
}

function pageCount(pdf) {
  const out = execFileSync("pdfinfo", [pdf], { encoding: "utf8" });
  const m = out.match(/^Pages:\s*(\d+)/m);
  return m ? Number(m[1]) : 1;
}

function renderPages(pdf, count, dir) {
  // pdftoppm zero-pads the page suffix to the document's page-count width
  // (page-1.png for short PDFs, page-01.png for longer ones), so glob whatever
  // it actually wrote and take the first two in order.
  const prefix = join(dir, "page");
  execFileSync("pdftoppm", ["-png", "-r", String(RENDER_DPI), "-f", "1", "-l", String(Math.min(2, count)), pdf, prefix]);
  return readdirSync(dir)
    .filter((f) => /^page-\d+\.png$/.test(f))
    .sort()
    .slice(0, 2)
    .map((f) => join(dir, f));
}

function composite(pages, out) {
  if (pages.length === 1) {
    execFileSync("magick", [pages[0], "-resize", `${OUT_WIDTH}x`, "-strip", out]);
  } else {
    // Side-by-side spread with a thin white gutter, then downscale the whole thing.
    execFileSync("magick", [pages[0], pages[1], "-background", "white", "+smush", String(GUTTER), "-resize", `${OUT_WIDTH}x`, "-strip", out]);
  }
}

function kb(bytes) {
  return `${(bytes / 1024).toFixed(0)} KB`;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  for (const bin of ["pdfinfo", "pdftoppm", "magick"]) {
    try {
      execFileSync(bin, ["-h"], { stdio: "ignore" }); // usage exits non-zero; only ENOENT means missing
    } catch (e) {
      if (e && e.code === "ENOENT") {
        console.error(`Missing '${bin}'. Install poppler + imagemagick. See scripts/PREVIEWS.md.`);
        process.exit(1);
      }
    }
  }

  let cards = pdfCards();
  if (args.name) {
    const q = args.name.toLowerCase();
    cards = cards.filter((c) => (c.name || "").toLowerCase().includes(q) || c.image.toLowerCase().includes(q));
  }
  cards = cards.slice(0, args.limit);
  if (cards.length === 0) {
    console.log("No matching PDF-linked cards.");
    return;
  }
  console.log(`Building ${cards.length} PDF thumbnail(s).`);

  const report = [];
  for (const card of cards) {
    process.stdout.write(`- ${card.name} … `);
    const dir = mkdtempSync(join(tmpdir(), "gal-pdf-"));
    try {
      const pdf = join(dir, "in.pdf");
      await download(rawUrl(card.url), pdf);
      const count = pageCount(pdf);
      const pages = renderPages(pdf, count, dir);
      const out = join(GALLERY_DIR, card.image);
      composite(pages, out);
      const size = statSync(out).size;
      report.push({ name: card.name, size });
      const warn = size > SIZE_BUDGET ? "  ⚠ over budget" : "";
      console.log(`${pages.length} page(s), ${kb(size)}${warn}`);
    } catch (err) {
      console.log(`FAILED: ${err.message}`);
      report.push({ name: card.name, error: err.message });
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  }
  const ok = report.filter((r) => !r.error);
  console.log(`\nDone: ${ok.length}/${report.length} built.`);
  if (report.some((r) => r.error)) process.exitCode = 1;
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
