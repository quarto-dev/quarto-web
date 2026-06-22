# Git Hooks

This directory contains project git hooks. Activate with:

```bash
git config core.hooksPath .githooks
```

## Hooks

**`pre-commit`** — Blocks commits where a `.qmd` file with a `_freeze/` entry was edited but `_freeze/` was not updated. Fix: `quarto render <file.qmd>`, then commit the updated `_freeze/` output alongside the source.
