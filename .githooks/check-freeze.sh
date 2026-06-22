#!/bin/bash
# check-freeze.sh [commit|push]
#
# Checks that _freeze/ hash is current for any .qmd files being committed or pushed.
# Quarto's freeze hash is the MD5 of the source file (LF-normalized).
# Any content change to a page with executable code requires a _freeze/ update.
#
# Compatible with bash 3.2+ (macOS system bash), Linux, and Windows Git Bash.

# Cross-platform MD5 of stdin, LF-normalized (strips \r before hashing)
md5_lf() {
    tr -d '\r' | (
        if command -v md5sum >/dev/null 2>&1; then
            md5sum | cut -d' ' -f1
        else
            md5 -r | cut -d' ' -f1
        fi
    )
}

MODE="${1:-commit}"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
STALE_FILE=$(mktemp)
trap 'rm -f "$STALE_FILE"' EXIT

if [ "$MODE" = "commit" ]; then
    QMDS=$(git diff --cached --name-only 2>/dev/null | grep '\.qmd$' || true)
elif [ "$MODE" = "push" ]; then
    REMOTE=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null) || exit 0
    [ -n "$REMOTE" ] || exit 0
    QMDS=$(git diff "${REMOTE}..HEAD" --name-only 2>/dev/null | grep '\.qmd$' || true)
else
    exit 0
fi

[ -n "$QMDS" ] || exit 0

while IFS= read -r qmd; do
    [ -n "$qmd" ] || continue
    freeze_rel="_freeze/${qmd%.qmd}/execute-results/html.json"

    # Read freeze JSON from git objects, not working tree, to avoid false passes
    # when the freeze file is updated on disk but not yet staged.
    if [ "$MODE" = "commit" ]; then
        freeze_content=$(git show ":${freeze_rel}" 2>/dev/null || git show "HEAD:${freeze_rel}" 2>/dev/null)
    else
        freeze_content=$(git show "HEAD:${freeze_rel}" 2>/dev/null)
    fi
    [ -n "$freeze_content" ] || continue

    stored_hash=$(printf '%s' "$freeze_content" | jq -r '.hash // empty' 2>/dev/null)
    [ -n "$stored_hash" ] || continue

    if [ "$MODE" = "commit" ]; then
        current_hash=$(git show ":$qmd" 2>/dev/null | md5_lf)
    else
        current_hash=$(git show "HEAD:$qmd" 2>/dev/null | md5_lf)
    fi

    [ -n "$current_hash" ] || continue
    [ "$current_hash" = "$stored_hash" ] || echo "$qmd" >> "$STALE_FILE"
done <<< "$QMDS"

if [ -s "$STALE_FILE" ]; then
    echo "_freeze/ not updated for:" >&2
    sed 's/^/  /' "$STALE_FILE" >&2
    echo "" >&2
    echo "Run: quarto render <file.qmd> then commit the updated _freeze/ output." >&2
    exit 2
fi

exit 0
