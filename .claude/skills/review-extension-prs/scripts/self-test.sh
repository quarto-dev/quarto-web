#!/usr/bin/env bash
set -uo pipefail
# Regression tests for the review-extension-prs scripts and cross-file consistency.
# Usage: self-test.sh [--network]
# Use --network to test extension discovery against real GitHub repositories.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(git -C "$SKILL_DIR" rev-parse --show-toplevel)"
LISTINGS="$REPO_ROOT/docs/extensions/listings"

PASS=0
FAIL=0
NETWORK=0
[ "${1:-}" = "--network" ] && NETWORK=1

ok()   { PASS=$((PASS+1)); printf 'PASS  %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf 'FAIL  %s\n     %s\n' "$1" "$2"; }

expect_empty() { # <label> <output>
  if [ -z "$2" ]; then ok "$1"; else bad "$1" "expected no output, got: $2"; fi
}
expect_match() { # <label> <output> <substring>
  case "$2" in *"$3"*) ok "$1" ;; *) bad "$1" "expected to contain '$3', got: ${2:-<empty>}" ;; esac
}
expect_absent() { # <label> <file> <pattern> <why>
  if grep -qiE "$3" "$2"; then bad "$1" "$4"; else ok "$1"; fi
}

echo "-- check-duplicate.sh: contributor input is data, not a pattern"

expect_empty "regex metacharacter in name does not match" \
  "$(bash "$SCRIPT_DIR/check-duplicate.sh" 's.' 'nobody/nothing-xyz' 2>&1)"

expect_empty "repo path does not match a longer sibling" \
  "$(bash "$SCRIPT_DIR/check-duplicate.sh" 'zzz-absent-name' 'shafayetshafee/reveal' 2>&1)"

FIRST_NAME=$(grep -h '^- name:' "$LISTINGS"/*.yml | head -1 | sed 's/^- name:[[:space:]]*//' | tr -d '"'"'"'')
expect_match "exact existing name is reported" \
  "$(bash "$SCRIPT_DIR/check-duplicate.sh" "$FIRST_NAME" 'nobody/nothing-xyz' 2>&1)" \
  "NAME_DUPLICATE"

FIRST_PATH=$(grep -h 'path:[[:space:]]*https://github.com/' "$LISTINGS"/*.yml | head -1 | sed 's|.*github.com/||' | tr -d '"'"'"' ')
expect_match "existing repo is reported when given as owner/repo" \
  "$(bash "$SCRIPT_DIR/check-duplicate.sh" 'zzz-absent-name' "$FIRST_PATH" 2>&1)" \
  "PATH_DUPLICATE"
expect_match "existing repo is reported when given as a full URL" \
  "$(bash "$SCRIPT_DIR/check-duplicate.sh" 'zzz-absent-name' "https://github.com/${FIRST_PATH}.git" 2>&1)" \
  "PATH_DUPLICATE"

echo
echo "-- check-order.sh: a wrong file is not a misplaced entry"

expect_match "absent name reports a check error, not a violation" \
  "$(bash "$SCRIPT_DIR/check-order.sh" "$LISTINGS/shortcodes-and-filters.yml" 'zzz-absent-name' 2>&1)" \
  "ORDER_CHECK_ERROR"

TMP_ORDER=$(mktemp)
printf -- '- name: aaa\n  path: x\n\n- name: zzz\n  path: x\n\n- name: mmm\n  path: x\n' > "$TMP_ORDER"
expect_match "out-of-order entry is reported" \
  "$(bash "$SCRIPT_DIR/check-order.sh" "$TMP_ORDER" 'zzz' 2>&1)" \
  "ORDER_VIOLATION"
expect_empty "correctly ordered entry is silent" \
  "$(bash "$SCRIPT_DIR/check-order.sh" "$TMP_ORDER" 'aaa' 2>&1)"
rm -f "$TMP_ORDER"

echo
echo "-- validate-extension.sh: only installable shapes are candidates"

# Keep the tested shape synchronized with the production filter.
SHAPE='^([^/]+/_extension\.yml|_extensions/[^/]+/_extension\.yml)$'

SCRIPT_SHAPE=$(grep -oE "grep -E '\^\([^']+\)\\$'" "$SCRIPT_DIR/validate-extension.sh"   | head -1 | sed "s/^grep -E '//; s/'\$//")
if [ "$SCRIPT_SHAPE" = "$SHAPE" ]; then
  ok "shape expression is in sync with the script"
else
  bad "shape expression is in sync with the script"     "script uses: ${SCRIPT_SHAPE:-<not found>} | test uses: $SHAPE"
fi

while read -r path verdict; do
  [ -n "$path" ] || continue
  if grep -qE "$SHAPE" <<<"$path"; then got=accept; else got=reject; fi
  if [ "$got" = "$verdict" ]; then
    ok "$verdict $path"
  else
    bad "$verdict $path" "shape filter returned $got"
  fi
done <<'SHAPES'
titlepage/_extension.yml accept
_extensions/storybook/_extension.yml accept
_extension.yml reject
src/foo/_extension.yml reject
packages/foo/_extension.yml reject
docs/_extensions/mcanouil/atelier/_extension.yml reject
example-site/_extensions/foo/_extension.yml reject
testdata/foo/_extension.yml reject
_extensions/foo/bar/_extension.yml reject
SHAPES

echo
echo "-- cross-file consistency: SKILL.md and the checklist must not contradict"

SKILL="$SKILL_DIR/SKILL.md"
CHECKLIST="$SKILL_DIR/references/verification-checklist.md"

# The declared listing files must exactly match the files on disk.
DECLARED=$(grep 'The listing files live in' "$SKILL" | grep -oE '[a-z-]+\.yml' | sort -u)
ACTUAL=$(cd "$LISTINGS" && ls *.yml | grep -v '^_' | sort -u)
if [ "$DECLARED" = "$ACTUAL" ]; then
  ok "SKILL.md declares exactly the listing files that exist"
else
  bad "SKILL.md declares exactly the listing files that exist"     "declared: $(echo $DECLARED) | actual: $(echo $ACTUAL)"
fi

for ref in category-guide.md verification-checklist.md; do
  if grep -q "references/$ref" "$SKILL"; then
    ok "SKILL.md points at references/$ref"
  else
    bad "SKILL.md points at references/$ref" "orphaned: an agent following SKILL.md will never open it"
  fi
done

expect_absent "archived is not stated as a hard requirement" "$SKILL" \
  'must (exist and be public and )?not (be )?archived' \
  "SKILL.md requires not-archived while the checklist only warns"

expect_absent "security scope does not exclude shipped subdirectories" "$CHECKLIST" \
  'skip tests and docs' \
  "quarto add ships everything under the extension root, including a tests/ subdirectory"

expect_absent "README check does not key on HTTP status codes" "$CHECKLIST" \
  '^\| (404|200)' \
  "gh repo read-file reports success or a non-zero exit, not HTTP codes"
for f in "$SKILL" "$CHECKLIST"; do
  if grep -qi 'UNVERIFIED' "$f"; then
    ok "$(basename "$f") distinguishes unverified from failed"
  else
    bad "$(basename "$f") distinguishes unverified from failed" \
      "no UNVERIFIED state, so a network failure reads as a real finding"
  fi
done

if grep -qE '^\s*✓/✗' "$SKILL"; then
  bad "report template expresses non-binary verdicts" \
    "tick/cross cannot represent WARN, INVESTIGATE or UNVERIFIED"
else
  ok "report template expresses non-binary verdicts"
fi

# Every check state needs a recommendation.
if grep -A20 '^## Verdict Rules' "$CHECKLIST" | grep -q 'UNVERIFIED'; then
  ok "Verdict Rules cover UNVERIFIED"
else
  bad "Verdict Rules cover UNVERIFIED" \
    "three checks emit UNVERIFIED but the table gives it no recommendation"
fi

# Keep the security filter synchronized across both documents.
SEC_FILTER='(lua|js|mjs|cjs|ts|py|rb|pl|sh|ps1|html|wasm|[Rr])'
for f in "$SKILL" "$CHECKLIST"; do
  if grep -qF "$SEC_FILTER" "$f"; then
    ok "$(basename "$f") carries the current security file filter"
  else
    bad "$(basename "$f") carries the current security file filter" \
      "expected $SEC_FILTER; broadening the filter must update both files and this test"
  fi
done

if grep -qi 'never FAIL' "$CHECKLIST"; then
  bad "unlicensed submission can fail" \
    "checklist still says a missing license is never a FAIL, but the listing requires one"
else
  ok "unlicensed submission can fail"
fi

if [ "$NETWORK" -eq 1 ]; then
  echo
  echo "-- validate-extension.sh: the extension directory is not the repo name (network)"
  # Verify discovery when extension and repository names differ.
  while read -r repo name dir; do
    [ -n "$repo" ] || continue
    out=$(bash "$SCRIPT_DIR/validate-extension.sh" "$repo" "$name" 2>&1)
    expect_match "$repo resolves to $dir" "$out" "$dir"
  done <<'CASES'
nmfs-opensci/quarto_titlepages titlepage-pdf _extensions/titlepage/_extension.yml
hchulkim/econ-paper-template aea _extensions/aea/_extension.yml
mcanouil/quarto-revealjs-storybook storybook-revealjs _extensions/storybook/_extension.yml
CASES

  # Ignore extensions vendored under docs/.
  out=$(bash "$SCRIPT_DIR/validate-extension.sh" mcanouil/quarto-revealjs-storybook storybook-revealjs 2>&1)
  if printf '%s' "$out" | grep -q 'docs/_extensions'; then
    bad "vendored docs/ extensions are excluded" "reported a docs/_extensions copy as a shipped extension"
  else
    ok "vendored docs/ extensions are excluded"
  fi

  expect_match "missing repo is reported as not found" \
    "$(bash "$SCRIPT_DIR/validate-extension.sh" quarto-dev/definitely-not-a-repo-xyz nothing 2>&1)" \
    "not found"
fi

echo
printf '%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
