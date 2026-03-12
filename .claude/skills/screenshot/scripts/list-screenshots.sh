#!/usr/bin/env bash
set -euo pipefail
# List all registered screenshots from the manifest.
# Self-resolves repo root so it works regardless of CWD.
REPO_ROOT="$(git rev-parse --show-toplevel)" || { echo "Error: not in a git repository" >&2; exit 1; }
node "$REPO_ROOT/tools/screenshots/scripts/list.js"
