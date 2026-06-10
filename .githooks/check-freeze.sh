#!/bin/bash
# check-freeze.sh [commit|push]
#
# Checks that _freeze/ hash is current for any .qmd files being committed or pushed.
# Quarto's freeze hash is the MD5 of the source file (LF-normalized).
# Any content change to a page with executable code requires a _freeze/ update.

MODE="${1:-commit}"
STALE=()

if [ "$MODE" = "commit" ]; then
  mapfile -t FILES < <(git diff --cached --name-only 2>/dev/null | grep '\.qmd$' || true)
elif [ "$MODE" = "push" ]; then
  REMOTE=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null) || exit 0
  [ -n "$REMOTE" ] || exit 0
  mapfile -t FILES < <(git diff "${REMOTE}..HEAD" --name-only 2>/dev/null | grep '\.qmd$' || true)
else
  exit 0
fi

[ ${#FILES[@]} -gt 0 ] || exit 0

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

for qmd in "${FILES[@]}"; do
  freeze_json="${REPO_ROOT}/_freeze/${qmd%.qmd}/execute-results/html.json"
  [ -f "$freeze_json" ] || continue

  stored_hash=$(jq -r '.hash // empty' "$freeze_json" 2>/dev/null)
  [ -n "$stored_hash" ] || continue

  if [ "$MODE" = "commit" ]; then
    current_hash=$(git show ":$qmd" 2>/dev/null | tr -d '\r' | md5sum | cut -d' ' -f1)
  else
    current_hash=$(git show "HEAD:$qmd" 2>/dev/null | tr -d '\r' | md5sum | cut -d' ' -f1)
  fi

  [ -n "$current_hash" ] || continue
  [ "$current_hash" = "$stored_hash" ] || STALE+=("$qmd")
done

if [ ${#STALE[@]} -gt 0 ]; then
  echo "_freeze/ not updated for:"
  printf '  %s\n' "${STALE[@]}"
  echo ""
  echo "Re-render or update manually. See .claude/rules/quarto-web-workflow.md"
  exit 2
fi

exit 0
