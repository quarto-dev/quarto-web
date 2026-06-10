#!/bin/bash
# Claude Code PreToolUse hook: check _freeze/ before git commit or push.
# Reads tool input JSON from stdin, routes to check-freeze.sh.

COMMAND=$(jq -r '.tool_input.command // ""' 2>/dev/null)

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

if echo "$COMMAND" | grep -qE 'git[[:space:]]+commit'; then
  exec bash "$HOOK_DIR/check-freeze.sh" commit
elif echo "$COMMAND" | grep -qE 'git[[:space:]]+push'; then
  exec bash "$HOOK_DIR/check-freeze.sh" push
fi

exit 0
