# Git Hooks

This directory contains project git hooks. Activate with:

```bash
git config core.hooksPath .githooks
```

## Hooks

**`pre-commit`** — Blocks commits where a `.qmd` file with a `_freeze/` entry was edited but `_freeze/` was not updated. Inspect the page's engine first: computational pages need an explicit render with execution enabled and updated freeze output; Markdown pages need any vestigial computational freeze removed. Follow the [engine-aware freeze procedure](../.claude/rules/quarto-web-workflow.md), including its current hook-deletion limitation, with hooks enabled.
It first runs `_tools/check-site-format.ts`, which blocks a page or a `_metadata.yml` that sets `format: html`, since that drops the site theme.
Remove the `format` key, or use `quartoorg-html` when the page lists several formats.
