// publish-date.ts — Set a blog post's date to today and rename its directory.
// Usage: quarto run _tools/publish-date.ts <post-directory>
//
// Example:
//   quarto run _tools/publish-date.ts docs/blog/posts/2026-04-13-chrome-headless-shell
//
// What it does:
//   1. Updates `date:` in index.qmd frontmatter to today (YYYY-MM-DD)
//   2. Renames the directory if it has a YYYY-MM-DD prefix
//   3. Prints a reminder to stage the changes with git

import * as path from "stdlib/path";

const postDir = Deno.args[0];
if (!postDir) {
  console.error("Usage: quarto run _tools/publish-date.ts <post-directory>");
  Deno.exit(1);
}

const resolvedDir = path.resolve(postDir);

// Verify directory exists
try {
  const stat = Deno.statSync(resolvedDir);
  if (!stat.isDirectory) {
    console.error(`Not a directory: ${postDir}`);
    Deno.exit(1);
  }
} catch {
  console.error(`Directory not found: ${postDir}`);
  Deno.exit(1);
}

// Get today's date
const today = new Date();
const dateStr = [
  today.getFullYear(),
  String(today.getMonth() + 1).padStart(2, "0"),
  String(today.getDate()).padStart(2, "0"),
].join("-");

// Read index.qmd
const indexPath = path.join(resolvedDir, "index.qmd");
let content: string;
try {
  content = Deno.readTextFileSync(indexPath);
} catch {
  console.error(`Cannot read ${indexPath}`);
  Deno.exit(1);
}

// Update date in frontmatter
const datePattern = /^(date:\s*)"?\d{4}-\d{2}-\d{2}"?\s*$/m;
const match = content.match(datePattern);
if (!match) {
  console.error("No date: field with YYYY-MM-DD format found in frontmatter.");
  Deno.exit(1);
}

const oldDateMatch = match[0].match(/\d{4}-\d{2}-\d{2}/);
const oldDate = oldDateMatch ? oldDateMatch[0] : "unknown";

if (oldDate === dateStr) {
  console.log(`Date is already ${dateStr}, nothing to do.`);
  Deno.exit(0);
}

const newContent = content.replace(datePattern, `$1"${dateStr}"`);
Deno.writeTextFileSync(indexPath, newContent);
console.log(`Updated date: ${oldDate} → ${dateStr}`);

// Rename directory if it has a date prefix
const dirName = path.basename(resolvedDir);
const dirDatePrefix = dirName.match(/^\d{4}-\d{2}-\d{2}/);

if (dirDatePrefix && dirDatePrefix[0] !== dateStr) {
  const newDirName = dirName.replace(/^\d{4}-\d{2}-\d{2}/, dateStr);
  const parentDir = path.dirname(resolvedDir);
  const newResolvedDir = path.join(parentDir, newDirName);

  Deno.renameSync(resolvedDir, newResolvedDir);
  console.log(`Renamed: ${dirName} → ${newDirName}`);
  console.log(`\nDone. Stage with:`);
  console.log(`  git add -A ${path.relative(Deno.cwd(), newResolvedDir)} ${path.relative(Deno.cwd(), resolvedDir)}`);
} else if (!dirDatePrefix) {
  console.log("Directory has no date prefix — skipped rename.");
  console.log(`\nDone. Stage with:`);
  console.log(`  git add ${path.relative(Deno.cwd(), indexPath)}`);
} else {
  console.log(`\nDone. Stage with:`);
  console.log(`  git add ${path.relative(Deno.cwd(), indexPath)}`);
}
