import { findViolations, isRendered } from "./check-site-format.ts";

const files: Record<string, string> = {
  "docs/scalar.qmd": "---\ntitle: A\nformat: html\n---\nBody\n",
  "docs/list.qmd": "---\nformat: [html, pdf]\n---\n",
  "docs/mapping.qmd": "---\nformat:\n  html:\n    toc: false\n---\n",
  "docs/site.qmd": "---\nformat:\n  quartoorg-html:\n    toc: false\n---\n",
  "docs/site-scalar.qmd": "---\nformat: quartoorg-html\n---\n",
  "docs/slides.qmd": "---\nformat: revealjs\n---\n",
  "docs/fenced.qmd": "---\ntitle: B\n---\n\n```yaml\nformat:\n  html:\n    toc: true\n```\n",
  "docs/plain.md": "No front matter.\n",
  "docs/sub/_metadata.yml": "format:\n  html:\n    citeproc: false\n",
  "docs/ok/_metadata.yml": "format:\n  quartoorg-html:\n    citeproc: false\n",
  "docs/_examples/demo.qmd": "---\nformat: html\n---\n",
  "docs/_partial.qmd": "---\nformat: html\n---\n",
  ".github/x.md": "---\nformat: html\n---\n",
  "docs/nb.ipynb": JSON.stringify({ cells: [{ cell_type: "raw", source: ["---\n", "format: html\n", "---"] }] }),
  "docs/nb-ok.ipynb": JSON.stringify({ cells: [{ cell_type: "raw", source: ["---\n", "title: C\n", "---"] }] }),
};

const expected = ["docs/list.qmd", "docs/mapping.qmd", "docs/nb.ipynb", "docs/scalar.qmd", "docs/sub/_metadata.yml"];
const actual = findViolations(Object.keys(files), (p) => files[p]).sort();

const deletedRead = (p: string) => {
  if (p === "docs/gone.qmd") throw new Deno.errors.NotFound(`readfile '${p}'`);
  return files[p];
};
const skipsDeleted = findViolations(["docs/gone.qmd", "docs/scalar.qmd"], deletedRead);

let parseMessage = "";
try {
  findViolations(["docs/broken.qmd"], () => "---\nformat: [html\n---\n");
} catch (e) {
  parseMessage = (e as Error).message;
}

const checks: [string, boolean][] = [
  ["violations match", JSON.stringify(actual) === JSON.stringify(expected)],
  ["a deleted but unstaged file is skipped", JSON.stringify(skipsDeleted) === JSON.stringify(["docs/scalar.qmd"])],
  ["a YAML error names the file", parseMessage.startsWith("docs/broken.qmd:")],
  ["_metadata.yml in a rendered directory is checked", isRendered("docs/sub/_metadata.yml")],
  [
    "a project config with format: html is reported",
    JSON.stringify(findViolations(["_quarto.yml", "_quarto-rc.yml"], () => "format:\n  html:\n    toc: true\n")) ===
      JSON.stringify(["_quarto.yml", "_quarto-rc.yml"]),
  ],
  [
    "a project config with quartoorg-html is clean",
    findViolations(["_quarto-prerelease-docs.yml"], () => "format:\n  quartoorg-html:\n    toc: true\n").length === 0,
  ],
  ["a nested _quarto.yml is not a project config", !isRendered("docs/example/_quarto.yml")],
  ["underscore directory is skipped", !isRendered("docs/_examples/demo.qmd")],
  ["underscore file is skipped", !isRendered("docs/_partial.qmd")],
  ["dot directory is skipped", !isRendered(".github/x.md")],
];

let failed = 0;
for (const [name, ok] of checks) {
  console.log(`${ok ? "ok" : "FAIL"} - ${name}`);
  if (!ok) failed++;
}
if (failed > 0) {
  console.log(`actual: ${JSON.stringify(actual)}`);
  Deno.exit(1);
}
