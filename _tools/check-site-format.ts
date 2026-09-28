// Fails when a rendered page, a _metadata.yml, or a project config file sets a
// plain `html` format.
// Plain `html` replaces the site's `quartoorg-html` format, so the page loses
// the site theme without any error.
import { parse } from "stdlib/yaml";

const kSourceExtensions = [".qmd", ".md", ".ipynb"];
const kProjectConfig = /^_quarto(-[^/]+)?\.ya?ml$/;

const isYamlConfig = (path: string) => path.endsWith("_metadata.yml") || kProjectConfig.test(path);

export function isRendered(path: string): boolean {
  const segments = path.split("/");
  const name = segments.pop()!;
  if (segments.some((s) => s.startsWith("_") || s.startsWith("."))) return false;
  if (name === "_metadata.yml") return true;
  if (segments.length === 0 && kProjectConfig.test(name)) return true;
  return !name.startsWith("_") && !name.startsWith(".") && kSourceExtensions.some((ext) => name.endsWith(ext));
}

function frontMatter(path: string, text: string): string | undefined {
  if (isYamlConfig(path)) return text;
  if (path.endsWith(".ipynb")) {
    const first = JSON.parse(text).cells?.[0];
    if (first?.cell_type !== "raw") return undefined;
    text = Array.isArray(first.source) ? first.source.join("") : first.source;
  }
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---(\r?\n|$)/);
  return match?.[1];
}

function usesPlainHtml(meta: unknown): boolean {
  if (meta === null || typeof meta !== "object") return false;
  const format = (meta as Record<string, unknown>).format;
  if (format === "html") return true;
  if (Array.isArray(format)) return format.includes("html");
  return format !== null && typeof format === "object" && Object.hasOwn(format, "html");
}

export function findViolations(files: string[], read: (path: string) => string): string[] {
  return files.filter(isRendered).filter((path) => {
    let text: string;
    try {
      text = read(path);
    } catch (e) {
      // `git ls-files` still lists a file deleted from the working tree but not staged.
      if (e instanceof Deno.errors.NotFound) return false;
      throw e;
    }
    const yaml = frontMatter(path, text);
    if (yaml === undefined) return false;
    try {
      return usesPlainHtml(parse(yaml));
    } catch (e) {
      throw new Error(`${path}: cannot parse the front matter: ${(e as Error).message}`);
    }
  });
}

if (import.meta.main) {
  // `--staged` checks only the staged content of the files staged for commit,
  // for the pre-commit hook.
  const staged = Deno.args.includes("--staged");
  const gitArgs = staged
    ? ["diff", "--cached", "--name-only", "--diff-filter=ACMR", "-z"]
    : ["ls-files", "-z"];
  const readStaged = (path: string) => {
    const show = new Deno.Command("git", { args: ["show", `:${path}`], stdout: "piped" }).outputSync();
    if (!show.success) throw new Error(`${path}: cannot read the staged content`);
    return new TextDecoder().decode(show.stdout);
  };
  const listing = new Deno.Command("git", { args: gitArgs, stdout: "piped" }).outputSync();
  if (!listing.success) {
    console.error(`check-site-format: \`git ${gitArgs[0]}\` failed; run this from inside the repository.`);
    Deno.exit(2);
  }
  const files = new TextDecoder().decode(listing.stdout).split("\0").filter(Boolean);
  const violations = findViolations(files, staged ? readStaged : (p) => Deno.readTextFileSync(p));
  for (const path of violations) {
    console.error(`${path}: \`format: html\` drops the site theme. Remove the \`format\` key, or use \`quartoorg-html\`.`);
  }
  Deno.exit(violations.length > 0 ? 1 : 0);
}
