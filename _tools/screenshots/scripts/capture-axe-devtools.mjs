// Capture docs/output-formats/images/axe-console.png: a real Chromium window
// with the DevTools console open on the axe `output: console` example.
//
// This can't go through capture.js/manifest.json — Playwright screenshots only
// the page, and the DevTools panel lives outside it. Instead this launches
// headed Chromium with DevTools auto-opened and uses macOS `screencapture -l`
// on the window ID, which composites only that window (other windows can't
// leak in even if they're in front). macOS only.
//
// Usage (from _tools/screenshots/):
//   node scripts/render.js examples/axe-violation
//   (cd examples/axe-violation/_site && python3 -m http.server 8931) &
//   node scripts/capture-axe-devtools.mjs
import { chromium } from "playwright";
import sharp from "sharp";
import { mkdirSync, writeFileSync, rmSync, mkdtempSync } from "fs";
import { execSync } from "child_process";
import { tmpdir } from "os";
import path from "path";
import { fileURLToPath } from "url";

const URL = "http://localhost:8931/console.html";
const W = 1100, H = 650;
const CHROME_PX = 174; // browser chrome height in device px (2x), cropped off
const BOTTOM_PX = 1150; // keep a little space below the console prompt
const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../..");
const OUT = path.join(repoRoot, "docs/output-formats/images/axe-console.png");

const profile = mkdtempSync(path.join(tmpdir(), "axe-devtools-"));
mkdirSync(path.join(profile, "Default"), { recursive: true });
// Preseed DevTools prefs: dock bottom, Console panel, light theme.
// Keys changed casing across Chrome versions — set both spellings.
writeFileSync(
  path.join(profile, "Default", "Preferences"),
  JSON.stringify({
    devtools: {
      preferences: {
        currentDockState: '"bottom"',
        "current-dock-state": '"bottom"',
        "panel-selectedTab": '"console"',
        "panel-selected-tab": '"console"',
        uiTheme: '"default"',
        "ui-theme": '"default"',
        "InspectorView.splitViewState": JSON.stringify({ horizontal: { size: 380 } }),
        "inspector-view.split-view-state": JSON.stringify({ horizontal: { size: 380 } }),
      },
    },
    // Zoom the DevTools UI so console text stays legible once the image is
    // scaled down into the docs page. Zoom level 2 = factor 1.2^2 ≈ 1.44.
    partition: { per_host_zoom_levels: { x: { devtools: 2.0 } } },
  })
);

const ctx = await chromium.launchPersistentContext(profile, {
  headless: false,
  viewport: null,
  args: ["--auto-open-devtools-for-tabs"],
});
const page = ctx.pages()[0] ?? (await ctx.newPage());

// Pin the OS window to exact bounds via CDP (--window-size is unreliable here).
const cdp = await ctx.newCDPSession(page);
const { windowId } = await cdp.send("Browser.getWindowForTarget");
await cdp.send("Browser.setWindowBounds", {
  windowId,
  bounds: { left: 20, top: 40, width: W, height: H, windowState: "normal" },
});

await page.goto(URL);
await page.waitForSelector("[data-quarto-axe-complete]", { timeout: 15000 });
// The page scrollbar renders as a dark strip at the window edge — hide it.
await page.addStyleTag({ content: "::-webkit-scrollbar{display:none !important}" });
await page.waitForTimeout(3000); // let DevTools finish painting

// Find the OS window ID (owner is "Chromium" or "Google Chrome for Testing").
const jxa = `
ObjC.import('CoreGraphics');
const list = ObjC.deepUnwrap(ObjC.castRefToObject(
  $.CGWindowListCopyWindowInfo($.kCGWindowListOptionOnScreenOnly, $.kCGNullWindowID)));
const win = list.find(w => /Chrom/.test(w.kCGWindowOwnerName)
  && w.kCGWindowBounds && Math.round(w.kCGWindowBounds.Width) === ${W});
win ? String(win.kCGWindowNumber) : 'NOTFOUND'`;
const winId = execSync(`osascript -l JavaScript -e '${jxa.replace(/'/g, "'\\''")}'`)
  .toString().trim();
if (winId === "NOTFOUND") throw new Error("Chromium window not found");

const raw = path.join(profile, "devtools-raw.png");
execSync(`screencapture -x -o -l ${winId} ${raw}`);
await ctx.close();

// Crop off the (dark) browser chrome and the empty console below the prompt;
// trim 8px sides where the window's rounded corners show the background.
const meta = await sharp(raw).metadata();
await sharp(raw)
  .extract({
    left: 8,
    top: CHROME_PX,
    width: meta.width - 16,
    height: Math.min(BOTTOM_PX, meta.height) - CHROME_PX,
  })
  .flatten({ background: "#ffffff" })
  .png()
  .toFile(OUT);
rmSync(profile, { recursive: true, force: true });
console.log("wrote", OUT);
