// Aggregate per-cell axe dumps (from scan.mjs) into a grouped, persisted findings.json.
//
// Usage: node aggregate.mjs [--dir _results] [--out _results/findings.json]
//
// This is the middle stage: scan -> AGGREGATE -> render. All grouping/labelling
// decisions live here, so you can re-group without re-scanning, and any renderer
// (table, markdown, html) or a baseline diff reads the same findings.json.
//
// Grouping is by ROOT-CAUSE signature, not exact DOM target, so the same defect
// repeated by shared/generated code collapses into one finding with a multiplicity
// count. Hybrid signature:
//   - color-contrast : the failing colour pair (fg on bg) — all `.at`/`.ot` tokens
//     sharing a colour collapse to one finding regardless of which code block.
//   - everything else: a NORMALIZED selector — strip volatile bits (:nth-child,
//     instance ids like #cb12-1/#fn3, attribute *values*) so repeated template
//     output (90 gallery cards, the navbar toggler on every page) collapses.
//
// "Duplicated vs unique" is reported as evidence (instances / pages / cells), not a
// guess at ownership: a defect from a repeated source has many instances (across
// pages OR within one page); a one-off has a single instance.

import { readFileSync, readdirSync, writeFileSync } from "fs";

const argv = process.argv.slice(2);
const opt = (n, d) => (argv.indexOf(`--${n}`) >= 0 && argv[argv.indexOf(`--${n}`) + 1]) || d;
const dir = opt("dir", "_results");
const outFile = opt("out", `${dir}/findings.json`);
// instances-or-pages threshold above which a finding is "systemic" (repeated source)
const SYSTEMIC_MIN = Number(opt("systemic-min", "3"));

const cells = readdirSync(dir)
  .filter((f) => f.endsWith(".json") && f !== "_index.json" && f !== "findings.json")
  .map((f) => JSON.parse(readFileSync(`${dir}/${f}`, "utf8")));
const ok = cells.filter((c) => c.status === "ok");
const notOk = cells.filter((c) => c.status !== "ok");

// Conformance label from axe tags (mirrors Quarto's axeConformanceLevel).
const conformance = (tags) => {
  if (tags.includes("best-practice")) return "best-practice";
  const v = tags.find((t) => /^wcag\d+a+$/.test(t));
  if (!v) return "";
  const m = v.match(/^wcag(\d)(\d?)(a+)$/);
  const sc = tags.filter((t) => /^wcag\d{3,}$/.test(t)).map((t) => {
    const d = t.slice(4);
    return `${d[0]}.${d[1]}.${d.slice(2)}`;
  });
  return `WCAG ${m[1]}.${m[2] || "0"}${m[3].toUpperCase()}${sc.length ? " " + sc.join("/") : ""}`;
};

// The standard itself (version + level), for grouping/sorting — separate from the
// per-finding success criteria. Ordered WCAG by version then level (A<AA<AAA),
// best-practice last. label e.g. "WCAG 2.1 AA".
const standardInfo = (tags) => {
  if (tags.includes("best-practice")) return { label: "best-practice", rank: 9000 };
  const v = tags.find((t) => /^wcag\d+a+$/.test(t));
  if (!v) return { label: "—", rank: 9999 };
  const m = v.match(/^wcag(\d)(\d?)(a+)$/);
  const version = Number(`${m[1]}.${m[2] || "0"}`); // 2.0, 2.1, 2.2
  const level = m[3].length; // A=1, AA=2, AAA=3
  return { label: `WCAG ${m[1]}.${m[2] || "0"} ${m[3].toUpperCase()}`, rank: version * 100 + level };
};

// Normalize a selector so repeated instances collapse but structure survives.
// Volatile navigational/index attributes (href, data-index, ...) are dropped
// entirely — they make otherwise-identical template output look distinct (the 90
// gallery cards). Semantic attributes (type, data-bs-target, ...) keep their NAME
// but lose their value, so e.g. sidebar-section-1/2/3 collapse to one.
const VOLATILE_ATTR = /\[(?:href|data-original-href|data-index|id|name|style)(?:[~^$*|]?=(?:"[^"]*"|'[^']*'|[^\]]*))?\]/g;
const normalizeSelector = (target) => {
  const raw = Array.isArray(target) ? target.join(" > ") : String(target);
  return raw
    .replace(/:nth-(child|of-type|last-child)\(\d+\)/g, "") // positional
    .replace(VOLATILE_ATTR, "") // drop volatile attrs entirely
    .replace(/\[([-\w]+)(?:[~^$*|]?=(?:"[^"]*"|'[^']*'|[^\]]*))?\]/g, "[$1]") // strip values on the rest
    .replace(/#([A-Za-z][\w-]*?)-?\d+(-\d+)*(?=[\s>~+.:#\[]|$)/g, "#$1") // instance ids: #cb12-1 -> #cb, #fn3 -> #fn
    .replace(/\s+/g, " ")
    .trim();
};

// Hybrid signature.
const signatureOf = (rule, node) => {
  if (rule === "color-contrast") {
    const cc = (node.any || []).find((a) => a.id === "color-contrast");
    if (cc?.data) return `color-contrast :: ${cc.data.fgColor} on ${cc.data.bgColor}`;
  }
  return `${rule} :: ${normalizeSelector(node.target)}`;
};

// Per-node human detail: the contrast numbers, or the first real line of axe's
// failureSummary (skipping its "Fix any/all of the following:" preamble).
const nodeDetail = (rule, n) => {
  if (rule === "color-contrast") {
    const cc = (n.any || []).find((a) => a.id === "color-contrast");
    if (cc?.data) return `${cc.data.fgColor} on ${cc.data.bgColor} = ${cc.data.contrastRatio} (needs ${cc.data.expectedContrastRatio})`;
  }
  return (n.failureSummary || "")
    .split("\n").map((x) => x.trim()).filter(Boolean)
    .find((l) => !/^fix (any|all)/i.test(l)) || "";
};

const IMPACT_RANK = { critical: 4, serious: 3, moderate: 2, minor: 1, null: 0 };
const groups = new Map();

for (const c of ok) {
  for (const v of c.result.violations) {
    for (const n of v.nodes) {
      const sig = signatureOf(v.id, n);
      if (!groups.has(sig)) {
        groups.set(sig, {
          signature: sig, rule: v.id, impact: v.impact || "minor",
          conformance: conformance(v.tags), standard: standardInfo(v.tags),
          bestPractice: v.tags.includes("best-practice"),
          help: v.help,
          _instances: new Set(), // distinct DOM elements = (page + raw target)
          pages: new Set(), cells: new Set(),
          viewports: new Set(), themes: new Set(),
          examples: new Set(), detail: null,
          _occ: new Map(), // drill-down: distinct (page + target) -> element + matrix cells
        });
      }
      const g = groups.get(sig);
      if ((IMPACT_RANK[g.impact] || 0) < (IMPACT_RANK[v.impact] || 0)) g.impact = v.impact;
      const rawTarget = Array.isArray(n.target) ? n.target.join(" > ") : String(n.target);
      g._instances.add(`${c.page}##${rawTarget}`);
      g.pages.add(c.page);
      g.cells.add(`${c.page}|${c.viewport}|${c.theme}`);
      g.viewports.add(c.viewport);
      g.themes.add(c.theme);
      if (g.examples.size < 4) g.examples.add(rawTarget);
      const occKey = `${c.page}##${rawTarget}`;
      if (!g._occ.has(occKey))
        g._occ.set(occKey, {
          page: c.page, target: rawTarget,
          html: (n.html || "").trim().slice(0, 400),
          detail: nodeDetail(v.id, n), cells: new Set(),
        });
      g._occ.get(occKey).cells.add(`${c.viewport}·${c.theme}`);
      if (v.id === "color-contrast" && !g.detail) {
        const cc = (n.any || []).find((a) => a.id === "color-contrast");
        if (cc?.data)
          g.detail = `${cc.data.fgColor} on ${cc.data.bgColor} = ${cc.data.contrastRatio} (needs ${cc.data.expectedContrastRatio})`;
      }
    }
  }
}

const findings = [...groups.values()]
  .map((g) => {
    const instances = g._instances.size;
    const pages = g.pages.size;
    return {
      signature: g.signature, rule: g.rule, impact: g.impact,
      conformance: g.conformance, standard: g.standard.label, standardRank: g.standard.rank,
      severityRank: IMPACT_RANK[g.impact] || 0,
      bestPractice: g.bestPractice, help: g.help,
      detail: g.detail,
      instances, pages, cells: g.cells.size,
      // systemic = repeated source: many DOM elements OR many pages
      label: instances >= SYSTEMIC_MIN || pages >= 2 ? "systemic" : "localized",
      viewports: [...g.viewports].sort(),
      themes: [...g.themes].sort(),
      examples: [...g.examples],
      occurrences: [...g._occ.values()]
        .map((o) => ({ ...o, cells: [...o.cells].sort() }))
        .sort((a, b) => a.page.localeCompare(b.page) || a.target.localeCompare(b.target)),
    };
  })
  // default order: by standard (WCAG version/level, best-practice last), then
  // severity, then reach. (The HTML report lets you re-sort any column.)
  .sort(
    (a, b) =>
      a.standardRank - b.standardRank ||
      b.severityRank - a.severityRank ||
      b.instances - a.instances ||
      b.pages - a.pages
  );

const report = {
  generated: new Date().toISOString(),
  cells: { total: cells.length, ok: ok.length, notOk: notOk.length },
  notOkCells: notOk.map((c) => ({ page: c.page, viewport: c.viewport, theme: c.theme, status: c.status })),
  pagesScanned: new Set(ok.map((c) => c.page)).size,
  findings,
};
writeFileSync(outFile, JSON.stringify(report, null, 2));
console.log(`wrote ${outFile}: ${findings.length} findings from ${cells.length} cells (${ok.length} ok, ${notOk.length} not-ok)`);
