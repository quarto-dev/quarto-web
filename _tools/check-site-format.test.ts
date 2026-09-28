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

let notebookMessage = "";
try {
  findViolations(["docs/broken.ipynb"], () => "{ not json");
} catch (e) {
  notebookMessage = (e as Error).message;
}

// Runs the script itself, as the hook and CI do, in a scratch git repository.
const script = new URL("./check-site-format.ts", import.meta.url).pathname;
const repo = Deno.makeTempDirSync();
const git = (...args: string[]) => new Deno.Command("git", { args, cwd: repo }).outputSync();
const write = (path: string, text: string) => {
  Deno.mkdirSync(`${repo}/${path.split("/").slice(0, -1).join("/") || "."}`, { recursive: true });
  Deno.writeTextFileSync(`${repo}/${path}`, text);
};
const cli = (cwd: string, ...args: string[]) => {
  const out = new Deno.Command("quarto", { args: ["run", script, ...args], cwd, stderr: "piped" }).outputSync();
  return { code: out.code, stderr: new TextDecoder().decode(out.stderr) };
};
git("init", "-q");
write("docs/page.qmd", "---\ntitle: A\n---\n");
write("about.qmd", "---\nformat: html\n---\n");
git("add", "-A");
const fromSubdir = cli(`${repo}/docs`);
write("docs/page.qmd", "---\nformat: html\n---\n");
const unstagedEdit = cli(repo, "--staged");
git("add", "docs/page.qmd");
write("docs/page.qmd", "---\ntitle: A\n---\n");
const stagedEdit = cli(repo, "--staged");
write("docs/bad.qmd", "---\nformat: [html\n---\n");
git("add", "docs/bad.qmd");
const parseFailure = cli(repo);
Deno.removeSync(repo, { recursive: true });

const checks: [string, boolean][] = [
  ["a malformed notebook names the file", notebookMessage.startsWith("docs/broken.ipynb:")],
  ["run from a subdirectory, the whole repository is checked", fromSubdir.code === 1 && fromSubdir.stderr.includes("about.qmd")],
  ["--staged ignores an unstaged edit", unstagedEdit.code === 1 && !unstagedEdit.stderr.includes("docs/page.qmd")],
  ["--staged reports the staged content", stagedEdit.code === 1 && stagedEdit.stderr.includes("docs/page.qmd")],
  [
    "a parse error exits 2 with a plain message",
    parseFailure.code === 2 && parseFailure.stderr.includes("docs/bad.qmd:") && !parseFailure.stderr.includes("    at "),
  ],
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
