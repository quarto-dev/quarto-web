#!/usr/bin/env bash
set -euo pipefail
# Check a new entry sits in correct alphabetical order (by `name`, case-insensitive)
# relative to its immediate neighbours in the listing file.
# Usage: check-order.sh <file> <name>
# Output: empty = correctly ordered; ORDER_VIOLATION lines = misplaced.
# Always exits 0 — caller interprets output.

FILE="${1:?Usage: check-order.sh <file> <name>}"
NAME="${2:?Usage: check-order.sh <file> <name>}"

mapfile -t RAW < <(grep -n '^- name:[[:space:]]*' "$FILE")

NAMES=()
for entry in "${RAW[@]}"; do
  rest="${entry#*:}"
  nm="${rest#*name:}"
  nm="$(printf '%s' "$nm" | sed -E "s/^[[:space:]]*//; s/[[:space:]]*\$//; s/^['\"]//; s/['\"]\$//")"
  NAMES+=("$nm")
done

TARGET_LOWER=$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]')
IDX=-1
for i in "${!NAMES[@]}"; do
  n_lower=$(printf '%s' "${NAMES[$i]}" | tr '[:upper:]' '[:lower:]')
  if [[ "$n_lower" == "$TARGET_LOWER" ]]; then
    IDX=$i
  fi
done

if [[ $IDX -eq -1 ]]; then
  echo "ORDER_CHECK_ERROR: name '$NAME' not found in $FILE"
  exit 0
fi

check_le() {
  local a b
  a=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  b=$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')
  [[ "$(printf '%s\n%s\n' "$a" "$b" | LC_ALL=C sort | head -n1)" == "$a" ]]
}

if [[ $IDX -gt 0 ]]; then
  PREV_NAME="${NAMES[$((IDX-1))]}"
  if ! check_le "$PREV_NAME" "$NAME"; then
    echo "ORDER_VIOLATION: '$NAME' should come before '$PREV_NAME' alphabetically, but appears after it"
  fi
fi

if [[ $IDX -lt $((${#NAMES[@]}-1)) ]]; then
  NEXT_NAME="${NAMES[$((IDX+1))]}"
  if ! check_le "$NAME" "$NEXT_NAME"; then
    echo "ORDER_VIOLATION: '$NAME' should come after '$NEXT_NAME' alphabetically, but appears before it"
  fi
fi
