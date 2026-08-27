#!/usr/bin/env bash
set -euo pipefail
# Check if a name or GitHub repo is already in any listing file.
# Usage: check-duplicate.sh <name> <owner/repo>
# Output: empty = no duplicate; NAME_DUPLICATE/PATH_DUPLICATE lines = conflict found.
# Always exits 0 — caller interprets output.
# Treat contributor-supplied names and paths as fixed strings, not patterns.

NAME="${1:?Usage: check-duplicate.sh <name> <owner/repo>}"
OWNER_REPO="${2:?Usage: check-duplicate.sh <name> <owner/repo>}"
REPO_ROOT="$(git rev-parse --show-toplevel)"
LISTINGS="$REPO_ROOT/docs/extensions/listings"

uv run python - "$NAME" "$OWNER_REPO" "$LISTINGS" <<'PYEOF'
import glob, os, re, sys

name, owner_repo, listings = sys.argv[1], sys.argv[2], sys.argv[3]

def norm_repo(value):
    """Reduce a GitHub URL or owner/repo string to a canonical lowercase owner/repo."""
    v = value.strip().strip('"\'')
    v = re.sub(r'^https?://(www\.)?github\.com/', '', v, flags=re.I)
    v = re.sub(r'\.git$', '', v, flags=re.I)
    v = re.sub(r'/(blob|tree)/.*$', '', v)
    parts = [p for p in v.split('/') if p]
    return '/'.join(parts[:2]).lower()

target_name = name.strip().strip('"\'').lower()
target_repo = norm_repo(owner_repo)

for path in sorted(glob.glob(os.path.join(listings, '*.yml'))):
    base = os.path.basename(path)
    with open(path, encoding='utf-8') as fh:
        for lineno, line in enumerate(fh, 1):
            stripped = line.strip()
            if stripped.startswith('- name:'):
                value = stripped[len('- name:'):].strip().strip('"\'').lower()
                if value == target_name:
                    print(f"NAME_DUPLICATE: {base}:{lineno}:{line.rstrip()}")
            elif stripped.startswith('path:'):
                value = stripped[len('path:'):].strip()
                if norm_repo(value) == target_repo:
                    print(f"PATH_DUPLICATE: {base}:{lineno}:{line.rstrip()}")
PYEOF
