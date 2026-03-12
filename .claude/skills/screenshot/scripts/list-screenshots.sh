#!/usr/bin/env bash
# List all registered screenshots from the manifest.
# Self-resolves repo root so it works regardless of CWD.
REPO_ROOT="$(git rev-parse --show-toplevel)"
node "$REPO_ROOT/tools/screenshots/scripts/list.js"
