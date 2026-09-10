// Capture still card thumbnails for gallery entries that have no `image` yet.
//
// Data-driven from docs/gallery/data/*.yml: every card that is missing an `image`
// and whose `live` URL is a normal web page (not a PDF) gets a screenshot of that
// page, written to docs/gallery/thumbnails/<category>/<slug>.png. The script prints
// the `image:` (and a placeholder `alt:`) line to add to the card; it does not edit
// the YAML itself.
//
// PDF-linked cards are handled by capture-pdf-thumbs.mjs instead.
//
// Usage (from _tools/screenshots):
//   npm run capture:card-thumbs                 # every image-less web card
//   npm run capture:card-thumbs -- --name rap   # match by name
//   npm run capture:card-thumbs -- --limit 1    # first N matches (staging)
//
// Prerequisites: this tool's dependencies (`npm install`); Playwright's chromium.

import { readFileSync, existsSync, mkdirSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";
import { load as yamlLoad } from "js-yaml";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(HERE, "..", "..", "..");
const GALLERY_DIR = join(REPO_ROOT, "docs", "gallery");
const DATA_DIR = join(GALLERY_DIR, "data");

const VIEWPORT = { width: 1200, height: 760 };

// Reuse the installed full chrome-for-testing build (same as capture-previews);
// override with PREVIEW_CHROME. Falls back to Playwright's default resolution.
const CHROME =
  process.env.PREVIEW_CHROME ||
  join(process.env.HOME || "", "Library/Caches/ms-playwright/chromium-1234/chrome-mac-arm64", "Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing");

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

function slugify(s) {
  return String(s)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function missingCards() {
  const out = [];
  const files = ["dashboards-monitoring.yml", "reports-analytics.yml", "research-scholarship.yml", "teaching-learning.yml", "software-documentation.yml", "personal-community.yml"];
  for (const file of files) {
    const path = join(DATA_DIR, file);
    if (!existsSync(path)) continue;
    const category = file.replace(/\.yml$/, "");
    const doc = yamlLoad(readFileSync(path, "utf8"));
    for (const card of doc || []) {
      if (!card || card.image || !card.live || isPdf(card.live)) continue;
      out.push({ name: card.name || card.title, url: card.live, category, image: `thumbnails/${category}/${slugify(card.name || card.title)}.png` });
    }
  }
  return out;
}

// Dismiss a cookie/consent banner if one is covering the page, so it does not
// end up in the thumbnail. Clicks the first visible consent button (buttons only,
// never links, to avoid navigating away).
async function dismissConsent(page) {
  const clicked = await page
    .evaluate(() => {
      const re = /^(i agree|agree|accept all|accept|got it|allow all|allow|i decline|decline|reject all|reject)\b/i;
      const els = [...document.querySelectorAll('button, [role="button"], input[type="button"], input[type="submit"]')];
      const hit = els.find((e) => e.offsetParent !== null && re.test((e.textContent || e.value || "").trim()));
      if (hit) {
        hit.click();
        return true;
      }
      return false;
    })
    .catch(() => false);
  if (clicked) await page.waitForTimeout(600);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  let cards = missingCards();
  if (args.name) {
    const q = args.name.toLowerCase();
    cards = cards.filter((c) => (c.name || "").toLowerCase().includes(q));
  }
  cards = cards.slice(0, args.limit);
  if (cards.length === 0) {
    console.log("No image-less web cards found.");
    return;
  }
  console.log(`Capturing ${cards.length} card thumbnail(s).`);

  const browser = await chromium.launch(existsSync(CHROME) ? { executablePath: CHROME } : {});
  const toAdd = [];
  for (const card of cards) {
    process.stdout.write(`- ${card.name} … `);
    const ctx = await browser.newContext({ viewport: VIEWPORT, deviceScaleFactor: 2 });
    const page = await ctx.newPage();
    try {
      await page.goto(card.url, { waitUntil: "domcontentloaded", timeout: 60000 });
      await page.waitForLoadState("networkidle", { timeout: 8000 }).catch(() => {});
      await page.waitForTimeout(1200);
      await dismissConsent(page);
      const out = join(GALLERY_DIR, card.image);
      mkdirSync(dirname(out), { recursive: true });
      await page.screenshot({ path: out }); // viewport only (top of the page)
      console.log(card.image);
      toAdd.push(card);
    } catch (err) {
      console.log(`FAILED: ${err.message}`);
    } finally {
      await ctx.close();
    }
  }
  await browser.close();

  if (toAdd.length) {
    console.log("\nAdd to each card's YAML (fill in a real alt):");
    for (const c of toAdd) {
      console.log(`  # ${c.name} (${c.category})`);
      console.log(`  image: ${c.image}`);
      console.log(`  alt: TODO describe the ${c.name} page.`);
    }
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
