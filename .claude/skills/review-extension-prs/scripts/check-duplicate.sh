#!/usr/bin/env bash
set -euo pipefail
# Check if a name or GitHub repo is already in any listing file.
# Usage: check-duplicate.sh <name> <owner/repo>
# Output: empty = no duplicate; NAME_DUPLICATE/PATH_DUPLICATE lines = conflict found.
# Always exits 0 — caller interprets output.

NAME="${1:?Usage: check-duplicate.sh <name> <owner/repo>}"
OWNER_REPO="${2:?Usage: check-duplicate.sh <name> <owner/repo>}"
REPO_ROOT="$(git rev-parse --show-toplevel)"
LISTINGS="$REPO_ROOT/docs/extensions/listings"

NAME_LOWER=$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]')
OWNER_REPO_LOWER=$(printf '%s' "$OWNER_REPO" | tr '[:upper:]' '[:lower:]')

# Check exact name match (case-insensitive, anchored to entry start)
while IFS= read -r line; do
  printf 'NAME_DUPLICATE: %s\n' "${line/$LISTINGS\//}"
done < <(grep -rin "^- name:[[:space:]]*${NAME_LOWER}[[:space:]]*$" "$LISTINGS"/*.yml 2>/dev/null || true)

# Check path match: search for github.com/owner/repo in any path: line
while IFS= read -r line; do
  printf 'PATH_DUPLICATE: %s\n' "${line/$LISTINGS\//}"
done < <(grep -rin "path:.*github\.com/${OWNER_REPO_LOWER}" "$LISTINGS"/*.yml 2>/dev/null || true)
