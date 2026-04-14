# Project Scripts (`_tools/`)

Utility scripts for the quarto-web project. Run with `quarto run` (TypeScript, R, Python, or Lua).

## Scripts

| Script | Language | Description |
|--------|----------|-------------|
| `publish-date.ts` | TypeScript | Set a blog post date to today and rename its directory to match |
| `algolia-add-custom-attribute.ts` | TypeScript | Post-render hook: adds custom attributes to Algolia search index |
| `reference.ts` | TypeScript | Generate reference documentation |
| `reference-cli-generate-md.R` | R | Generate CLI reference markdown |
| `gallery-screenshot.R` | R | Capture gallery screenshots |
| `sort-gallery.R` | R | Sort gallery entries |
| `release-notes.R` | R | Generate release notes content |
| `snapshot-typst.ts` | TypeScript | Capture Typst document snapshots as PNG |

## Usage

```bash
# Run any script
quarto run _tools/<script> [args]

# Examples
quarto run _tools/publish-date.ts docs/blog/posts/2026-04-10-my-post
quarto run _tools/snapshot-typst.ts source.qmd dest.png
```

TypeScript scripts use the Deno runtime bundled with Quarto (no external install needed).
R scripts require R/Rscript on PATH, and Python scripts require Python on PATH.

R and Python dependencies are managed at the project level via **renv** (R) and
**pipenv** (Python). See the [project README](../README.md) for setup instructions.
