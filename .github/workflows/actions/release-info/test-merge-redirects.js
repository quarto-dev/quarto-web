const assert = require("assert");
const { mergeRedirects } = require("./merge-redirects");

const downloadLines = [
  "/download/latest/quarto-win.msi https://example/v1/quarto-win.msi",
  "/download/prerelease/quarto-win.msi https://example/v2/quarto-win.msi",
];
const managedPrefixes = ["/download/latest/", "/download/prerelease/"];

// Fixture: stale download lines + a manual blog block (comment + rules).
const existing = [
  "/download/latest/quarto-win.msi https://example/OLD/quarto-win.msi",
  "/download/prerelease/quarto-win.msi https://example/OLD2/quarto-win.msi",
  "",
  "# Quarto blog migrated",
  "/docs/blog/posts/2022-02-13-feature-callouts/*  https://opensource.posit.co/blog/2022-02-13_feature-callouts/  301!",
  "/docs/blog/  https://opensource.posit.co/blog/q/quarto/  301!",
].join("\n");

const out = mergeRedirects(existing, downloadLines, managedPrefixes);

// 1. Manual content preserved.
assert(out.includes("# Quarto blog migrated"), "comment preserved");
assert(
  out.includes("/docs/blog/posts/2022-02-13-feature-callouts/*"),
  "per-post blog rule preserved"
);
assert(
  out.includes("/docs/blog/  https://opensource.posit.co/blog/q/quarto/  301!"),
  "blog index rule preserved"
);

// 2. Download lines regenerated; stale ones gone.
assert(out.includes("https://example/v1/quarto-win.msi"), "new latest url present");
assert(out.includes("https://example/v2/quarto-win.msi"), "new prerelease url present");
assert(!out.includes("OLD"), "stale download urls removed");

// 3. Download block on top, manual block below.
assert(
  out.indexOf("/download/latest/") < out.indexOf("# Quarto blog"),
  "download block precedes manual block"
);

// 4. Idempotent: merging the output again yields identical content.
const out2 = mergeRedirects(out, downloadLines, managedPrefixes);
assert.strictEqual(out2, out, "mergeRedirects is idempotent");

// 5. Empty existing content -> download block only.
assert.strictEqual(
  mergeRedirects("", downloadLines, managedPrefixes),
  downloadLines.join("\n"),
  "empty existing -> download block only"
);

// 6. No trailing newline (matches committed _redirects format).
assert(!out.endsWith("\n"), "no trailing newline");

// 7. Prefix derivation used by index.js: template text before the first $$.
assert.strictEqual(
  "/download/latest/$$prefix$$-$$suffix$$.$$extension$$".split("$$")[0],
  "/download/latest/",
  "latest prefix derived from template"
);
assert.strictEqual(
  "/download/prerelease/$$prefix$$-$$suffix$$.$$extension$$".split("$$")[0],
  "/download/prerelease/",
  "prerelease prefix derived from template"
);

console.log("All mergeRedirects tests passed");
