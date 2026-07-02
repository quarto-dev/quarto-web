#!/usr/bin/env bash
# Test that a Quarto extension installs successfully via quarto add.
# Usage: test-install.sh <owner/repo> [expected-extension-name]
# Output: PASS/FAIL/WARN lines. Always exits 0 — caller interprets output.
# Note: downloads from GitHub; slower than other checks — run last.

REPO="${1:?Usage: test-install.sh <owner/repo> [expected-extension-name]}"
EXPECTED_NAME="$2"
OWNER="${REPO%%/*}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

cd "$WORK_DIR"
if quarto add "$REPO" --no-prompt --quiet --log-level warning 2>"$WORK_DIR/quarto.err"; then
  INSTALL_OK=true
else
  INSTALL_OK=false
fi

if [ "$INSTALL_OK" = false ]; then
  ERR=$(head -5 "$WORK_DIR/quarto.err")
  echo "FAIL: quarto add exited non-zero"
  [ -n "$ERR" ] && echo "  $ERR"
  exit 0
fi

EXT_BASE="$WORK_DIR/_extensions/$OWNER"
if [ ! -d "$EXT_BASE" ]; then
  echo "FAIL: _extensions/${OWNER}/ not created; extension may lack proper package structure"
  exit 0
fi

shopt -s nullglob
installed=()
for d in "$EXT_BASE"/*/; do
  installed+=("$d")
done
shopt -u nullglob

if [ ${#installed[@]} -eq 0 ]; then
  echo "FAIL: no subdirectory under _extensions/${OWNER}/ after install"
  exit 0
fi

names=()
for ext_dir in "${installed[@]}"; do
  ext_name=$(basename "$ext_dir")
  names+=("$ext_name")
  if [ -f "${ext_dir}_extension.yml" ]; then
    echo "PASS: installed _extensions/${OWNER}/${ext_name}/ with _extension.yml"
  else
    echo "FAIL: installed _extensions/${OWNER}/${ext_name}/ but _extension.yml missing"
  fi
done

if [ ${#installed[@]} -gt 1 ]; then
  echo "WARN: repo installed ${#installed[@]} extensions (${names[*]}), not 1 — repo tree likely contains unrelated/leftover extension dirs"
fi

if [ -n "$EXPECTED_NAME" ] && [ ! -d "${EXT_BASE}/${EXPECTED_NAME}" ]; then
  echo "WARN: expected extension name '${EXPECTED_NAME}' not found under _extensions/${OWNER}/ (found: ${names[*]})"
fi
