// Capture short, muted, looping preview clips for the gallery featured cards.
//
// Data-driven from docs/gallery/data/featured.yml: every featured card with both
// a `live` URL and a `preview` base path gets a short recording of its live page,
// encoded to <preview>.webm (VP9) and <preview>.mp4 (H.264) under docs/gallery/.
// The `preview` path points at thumbnails/featured/ (animated previews are a
// featured-only asset); the still PNG (`image`) stays the poster, untouched.
//
// Capture mode is chosen from the card's `categories`: reveal.js decks step through
// a few slides; everything else scrolls the page top to bottom. The blank page-load
// lead-in is measured and trimmed from the encode so clips open on real content (no
// white flash, including on loop).
//
// Usage (from _tools/screenshots):
//   npm run capture:previews                 # every preview card
//   npm run capture:previews -- --name whr   # match by name or preview path
//   npm run capture:previews -- --limit 2    # first N matches (staging)
//
// Prerequisites and details: see scripts/PREVIEWS.md.

import { readFileSync, existsSync, mkdtempSync, mkdirSync, readdirSync, rmSync, statSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { tmpdir } from "node:os";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";
import { load as yamlLoad } from "js-yaml";

const HERE = dirname(fileURLToPath(import.meta.url));
const TOOLS_DIR = resolve(HERE, "..");
const REPO_ROOT = resolve(TOOLS_DIR, "..", "..");
const GALLERY_DIR = join(REPO_ROOT, "docs", "gallery");
const FEATURED_YML = join(GALLERY_DIR, "data", "featured.yml");

// A full browser build is required for recordVideo; the headless shell cannot
// screencast. Point at the installed chrome-for-testing (override per platform).
const CHROME =
  process.env.PREVIEW_CHROME ||
  join(
    process.env.HOME,
    "Library/Caches/ms-playwright/chromium-1234/chrome-mac-arm64",
    "Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing",
  );

const RECORD = { width: 1280, height: 720 };
const SCROLL_MS = 9000;
const SLIDE_STEPS = 5; // reveal.js: number of ArrowRight presses
const SLIDE_HOLD_MS = 1500; // dwell on each slide
const SIZE_BUDGET = 500 * 1024; // warn above 500 KB per file

function parseArgs(argv) {
  const args = { name: null, limit: Infinity };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--name") args.name = argv[++i];
    else if (argv[i] === "--limit") args.limit = Number(argv[++i]);
  }
  return args;
}

function modeFor(card) {
  const cats = (card.categories || []).map((c) => String(c).toLowerCase());
  if (cats.includes("revealjs") || cats.includes("presentation")) return "slides";
  return "scroll";
}

function featuredCards() {
  const doc = yamlLoad(readFileSync(FEATURED_YML, "utf8"));
  const cards = [];
  for (const cat of doc || []) {
    for (const card of cat.cards || []) {
      if (card.live && card.preview) {
        cards.push({
          name: card.name || card.title,
          // `preview-url` overrides the capture source when the card's `live`
          // link is not the best page to record (e.g. a landing vs a rich subpage).
          captureUrl: card["preview-url"] || card.live,
          preview: card.preview,
          mode: modeFor(card),
        });
      }
    }
  }
  return cards;
}

function ffmpeg(args) {
  execFileSync("ffmpeg", ["-y", "-hide_banner", "-loglevel", "error", ...args], { stdio: "inherit" });
}

function kb(bytes) {
  return `${(bytes / 1024).toFixed(0)} KB`;
}

function scrollMax(page) {
  // The real scroll distance, read from the scrolling root. Works whether the
  // document itself scrolls or a smooth-scroll library drives a taller body.
  return page.evaluate(() => {
    const root = document.scrollingElement || document.documentElement;
    return Math.max(0, root.scrollHeight - window.innerHeight);
  });
}

async function scrollThrough(page) {
  // Drive the scroll with trusted wheel events rather than `window.scrollTo`:
  // some sites hijack scrolling with a smooth-scroll library (Lenis/Locomotive)
  // that ignores programmatic scroll and only reacts to real wheel input.
  const max = await scrollMax(page);
  if (max === 0) {
    await page.waitForTimeout(1500);
    return;
  }
  await page.mouse.move(RECORD.width / 2, RECORD.height / 2);
  const FRAMES = 60;
  const dt = SCROLL_MS / FRAMES;
  let prev = 0;
  for (let i = 1; i <= FRAMES; i++) {
    const t = i / FRAMES;
    const eased = t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
    const target = max * eased;
    await page.mouse.wheel(0, target - prev);
    prev = target;
    await page.waitForTimeout(dt);
  }
  await page.mouse.wheel(0, 600); // nudge past any smooth-scroll easing shortfall
  await page.waitForTimeout(400);
}

async function warmUp(page) {
  // Wheel through once to trigger lazy-loaded images, wait for them to decode,
  // then hard-reset to the top. Runs before the recorded scroll (and before the
  // lead offset) so images are painted and we open at the top when it begins.
  // Uses trusted wheel events for the same reason scrollThrough does.
  const max = await scrollMax(page);
  if (max === 0) {
    await page.waitForTimeout(500);
    return;
  }
  await page.mouse.move(RECORD.width / 2, RECORD.height / 2);
  const step = Math.round(RECORD.height * 0.8) || 1;
  const steps = Math.min(40, Math.ceil(max / step));
  for (let i = 0; i < steps; i++) {
    await page.mouse.wheel(0, step);
    await page.waitForTimeout(150);
  }
  await page.waitForTimeout(400);
  await page.evaluate(async () => {
    const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
    const untilLoaded = Promise.all(
      Array.from(document.images).map((img) =>
        img.complete
          ? Promise.resolve()
          : new Promise((r) => {
              img.addEventListener("load", r, { once: true });
              img.addEventListener("error", r, { once: true });
            }),
      ),
    );
    await Promise.race([untilLoaded, sleep(4000)]); // don't hang on a stuck image
  });
  // Overshoot upward so a smooth-scroll library settles hard at the very top.
  await page.mouse.wheel(0, -(max + steps * step + 2000));
  await page.waitForTimeout(700);
}

async function advanceSlides(page) {
  // Reveal.js: step through a few slides with ArrowRight (slide-level, not fragments).
  for (let i = 0; i < SLIDE_STEPS; i++) {
    await page.waitForTimeout(SLIDE_HOLD_MS);
    await page.keyboard.press("ArrowRight");
  }
  await page.waitForTimeout(SLIDE_HOLD_MS);
}

async function record(browser, url, mode) {
  const dir = mkdtempSync(join(tmpdir(), "gal-preview-"));
  const context = await browser.newContext({
    viewport: { width: RECORD.width, height: RECORD.height },
    recordVideo: { dir, size: RECORD },
  });
  const recordStart = Date.now();
  const page = await context.newPage();
  await page.goto(url, { waitUntil: "domcontentloaded", timeout: 60000 });
  // Best-effort settle; heavy sites may never reach full load, so don't block on it.
  await page.waitForLoadState("networkidle", { timeout: 8000 }).catch(() => {});
  await page.waitForTimeout(800); // let fonts/images paint on the first frame

  // Pre-load lazy images with a warm-up scroll (scroll cards only), then reset to top.
  if (mode !== "slides") await warmUp(page).catch(() => {});

  // Everything before this point is the blank/white page load and warm-up; record the
  // offset so the encode trims it and opens on real content (no white flash, incl. on loop).
  const lead = Math.max(0, (Date.now() - recordStart) / 1000 - 0.2);

  if (mode === "slides") await advanceSlides(page);
  else await scrollThrough(page);

  await page.close();
  await context.close(); // flushes the .webm

  const raw = readdirSync(dir)
    .filter((f) => f.endsWith(".webm"))
    .map((f) => join(dir, f))[0];
  return { raw, dir, lead };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!existsSync(CHROME)) {
    console.error(`Full Chromium not found at:\n  ${CHROME}\nInstall it or set PREVIEW_CHROME. See scripts/PREVIEWS.md.`);
    process.exit(1);
  }

  let cards = featuredCards();
  if (args.name) {
    const q = args.name.toLowerCase();
    cards = cards.filter((c) => c.name.toLowerCase().includes(q) || c.preview.toLowerCase().includes(q));
  }
  cards = cards.slice(0, args.limit);

  if (cards.length === 0) {
    console.log("No matching featured cards with both `live` and `preview`.");
    return;
  }
  console.log(`Capturing ${cards.length} preview(s).`);

  const browser = await chromium.launch({ executablePath: CHROME });
  const report = [];
  for (const card of cards) {
    const webmOut = join(GALLERY_DIR, `${card.preview}.webm`);
    const mp4Out = join(GALLERY_DIR, `${card.preview}.mp4`);
    mkdirSync(dirname(webmOut), { recursive: true }); // e.g. thumbnails/featured/

    process.stdout.write(`- ${card.name} … `);
    let tmp;
    try {
      const rec = await record(browser, card.captureUrl, card.mode);
      tmp = rec.dir;
      if (!rec.raw) throw new Error("no video produced");
      // Re-encode from the raw capture, trimming the blank page-load lead-in so the
      // clip opens on real content (fast `-ss` before `-i`).
      const ss = ["-ss", rec.lead.toFixed(2)];
      ffmpeg([...ss, "-i", rec.raw, "-an", "-vf", "scale=640:-2", "-c:v", "libvpx-vp9", "-crf", "40", "-b:v", "0", webmOut]);
      ffmpeg([...ss, "-i", rec.raw, "-an", "-vf", "scale=640:-2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "30", "-movflags", "+faststart", mp4Out]);
      const wb = statSync(webmOut).size;
      const mb = statSync(mp4Out).size;
      report.push({ name: card.name, webm: wb, mp4: mb });
      const warn = wb > SIZE_BUDGET || mb > SIZE_BUDGET ? "  ⚠ over budget" : "";
      console.log(`webm ${kb(wb)}, mp4 ${kb(mb)}${warn}`);
    } catch (err) {
      console.log(`FAILED: ${err.message}`);
      report.push({ name: card.name, error: err.message });
    } finally {
      if (tmp) rmSync(tmp, { recursive: true, force: true });
    }
  }
  await browser.close();

  const ok = report.filter((r) => !r.error);
  const total = ok.reduce((s, r) => s + r.webm + r.mp4, 0);
  console.log(`\nDone: ${ok.length}/${report.length} captured, total ${kb(total)} added.`);
  if (report.some((r) => r.error)) process.exitCode = 1;
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
