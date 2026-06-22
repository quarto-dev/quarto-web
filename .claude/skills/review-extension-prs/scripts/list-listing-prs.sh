#!/usr/bin/env bash
set -euo pipefail
# Find open PRs that modify extension listing YAML files.
# Emits a JSON array of qualifying PRs with number, title, author, date, and files.

gh pr list \
  --repo quarto-dev/quarto-web \
  --state open \
  --json number,title,author,createdAt,files \
  --limit 100 | \
jq '[.[] | select(.files | any(.path | test("^docs/extensions/listings/[^_].+\\.yml$")))]'
