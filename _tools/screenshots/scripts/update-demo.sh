#!/usr/bin/env bash
# Update the quarto-demo git subtree from upstream.
# Run from anywhere inside the repo.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
PREFIX="_tools/screenshots/examples/quarto-demo"
REMOTE="https://github.com/quarto-dev/quarto-demo"
BRANCH="main"

cd "$REPO_ROOT"
git subtree pull --prefix="$PREFIX" "$REMOTE" "$BRANCH" --squash "$@"
