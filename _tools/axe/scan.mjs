// Site-wide axe scan driver.
//
// Scans an ALREADY-BUILT site (output-dir served over HTTP) across a matrix of
// page x viewport x theme, using Quarto's built-in `axe: output: json` reporter.
// It does NOT render — render the site first with axe enabled, e.g.
//   quarto render --metadata-file axe-meta.yml
// then serve the output-dir and point this script at it.
//
// Usage:
//   node scan.mjs --base http://localhost:8799 --pages pages.txt --out _results
// Options:
//   --viewports 1440x900,390x844   (default)
//   --themes light,dark            (default)
//
// Requires a headless Chrome listening on CDP :9222, e.g.
//   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
//     --headless=new --disable-gpu --remote-debugging-port=9222 \
//     --user-data-dir=/tmp/chrome-a11y about:blank
//
// Fails CLOSED: Quarto's axe-check.js fetches axe-core from a CDN at runtime and,
// if that fetch fails, still marks the page "complete" with no violations — a
// network failure looks identical to a clean pass. We treat "complete but no
// violations payload" as status:"error", never a pass.

import { writeFileSync, mkdirSync, readFileSync } from "fs";

const argv = process.argv.slice(2);
const opt = (name, def) => {
  const i = argv.indexOf(`--${name}`);
  return i >= 0 && argv[i + 1] ? argv[i + 1] : def;
};
const base = opt("base", "http://localhost:8799").replace(/\/$/, "");
const pagesFile = opt("pages", "pages.txt");
const outDir = opt("out", "_results");
const viewports = opt("viewports", "1440x900,390x844")
  .split(",")
  .map((v) => {
    const [w, h] = v.split("x").map(Number);
    return { label: v, width: w, height: h };
  });
const themes = opt("themes", "light,dark").split(",");

const pages = readFileSync(pagesFile, "utf8")
  .split("\n")
  .map((l) => l.trim())
  .filter((l) => l && !l.startsWith("#"));

mkdirSync(outDir, { recursive: true });

const CDP = 9222;
async function getWsUrl() {
  for (let i = 0; i < 100; i++) {
    try {
      const list = await (await fetch(`http://localhost:${CDP}/json`)).json();
      const pg = list.find((t) => t.type === "page");
      if (pg?.webSocketDebuggerUrl) return pg.webSocketDebuggerUrl;
    } catch {}
    await new Promise((r) => setTimeout(r, 200));
  }
  throw new Error("no CDP page target — is headless Chrome running on :9222?");
}

const ws = new WebSocket(await getWsUrl());
await new Promise((res) => ws.addEventListener("open", res));

let idc = 0;
const pending = new Map();
function cmd(method, params = {}) {
  const id = ++idc;
  ws.send(JSON.stringify({ id, method, params }));
  return new Promise((resolve) => pending.set(id, resolve));
}

// axe-check.js logs the full JSON to the console once per scan (output: json), then
// sets data-quarto-axe-complete. We treat that console event as the completion
// signal — no DOM polling. `onDone` is the per-cell resolver, fired the instant the
// payload (or the error) arrives. We also watch the error path so a failed CDN fetch
// is caught rather than counted clean.
let axePayload = null;
let axeError = false;
let onDone = null;
ws.addEventListener("message", (ev) => {
  const msg = JSON.parse(ev.data);
  if (msg.id && pending.has(msg.id)) {
    pending.get(msg.id)(msg.result);
    pending.delete(msg.id);
    return;
  }
  if (msg.method === "Runtime.consoleAPICalled") {
    const a = msg.params.args?.[0];
    if (a?.type === "string" && a.value.includes('"violations"')) {
      axePayload = a.value;
      onDone?.();
    } else if (msg.params.type === "error" || (a?.value || "").includes("Axe accessibility check failed")) {
      axeError = true;
      onDone?.();
    }
  }
});

await cmd("Runtime.enable");
await cmd("Page.enable");

const slug = (p) => p.replace(/\.html$/, "").replace(/[\/]/g, "_") || "index";
const summary = [];

for (const page of pages) {
  for (const vp of viewports) {
    for (const theme of themes) {
      await cmd("Emulation.setDeviceMetricsOverride", {
        width: vp.width, height: vp.height, deviceScaleFactor: 1, mobile: false,
      });
      await cmd("Emulation.setEmulatedMedia", {
        features: [{ name: "prefers-color-scheme", value: theme }],
      });
      axePayload = null;
      axeError = false;
      const url = `${base}/${page}`;
      // Resolve on the axe console event; fall back to a timeout so a stuck page
      // (or a page with no axe injected) can't hang the whole run.
      const completed = new Promise((resolve) => (onDone = resolve));
      await cmd("Page.navigate", { url });
      const done = await Promise.race([
        completed.then(() => true),
        new Promise((resolve) => setTimeout(() => resolve(false), 30000)),
      ]);
      onDone = null;

      const cell = { page, viewport: vp.label, theme, url };
      if (!done) {
        cell.status = "timeout";
      } else if (!axePayload) {
        cell.status = axeError ? "error" : "no-payload"; // fail closed
      } else {
        cell.status = "ok";
        cell.result = JSON.parse(axePayload);
      }
      const vcount = cell.result ? cell.result.violations.length : "-";
      const ids = cell.result
        ? cell.result.violations.map((v) => v.id).join(",") || "(none)"
        : cell.status.toUpperCase();
      const name = `${slug(page)}__${vp.label}__${theme}`;
      writeFileSync(`${outDir}/${name}.json`, JSON.stringify(cell, null, 2));
      const line = `${name.padEnd(48)} ${String(vcount).padStart(3)}  ${ids}`;
      console.log(line);
      summary.push({ name, status: cell.status, violations: vcount, ids });
    }
  }
}

writeFileSync(`${outDir}/_index.json`, JSON.stringify(summary, null, 2));
ws.close();
process.exit(0);
