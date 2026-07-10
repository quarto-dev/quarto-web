#!/usr/bin/env bash
# Run the axe accessibility audit against the already-built site.
#
#   1. Render the site WITH axe first (see README), which populates _site/:
#        quarto render --metadata-file _tools/axe/axe-meta.yml
#   2. Then this script serves _site, drives headless Chrome across the
#      page x viewport x theme matrix, and writes results to _axe-checks/.
#
# Usage:  _tools/axe/run.sh
# Env overrides:
#   SITE=_site  PAGES=_tools/axe/pages.txt  OUT=_axe-checks  PORT=8788  CDP=9222
#   CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
SITE="${SITE:-$ROOT/_site}"
PAGES="${PAGES:-$HERE/pages.txt}"
OUT="${OUT:-$ROOT/_axe-checks}"
# Page links in the committed report point at the live site (persist after the
# local server is gone). Override for a PR preview, or set "" for relative links.
REPORT_BASE="${REPORT_BASE:-https://quarto.org}"
PORT="${PORT:-8788}"
CDP="${CDP:-9222}"
CHROME_PROFILE="$(mktemp -d)"

# Locate a Chrome binary, mirroring Quarto's own order so `quarto install
# chrome-headless-shell` "just works": explicit override → QUARTO_CHROMIUM (the
# same env var Quarto honors) → Quarto's installed chrome-headless-shell →
# system Chrome/Chromium/Edge/Brave.
find_chrome() {
  [ -n "${CHROME:-}" ] && { echo "$CHROME"; return 0; }
  [ -n "${QUARTO_CHROMIUM:-}" ] && { echo "$QUARTO_CHROMIUM"; return 0; }
  local datadir
  case "$(uname -s)" in
    Darwin) datadir="$HOME/Library/Application Support/quarto" ;;
    *)      datadir="${XDG_DATA_HOME:-$HOME/.local/share}/quarto" ;;
  esac
  local installed
  installed="$(find "$datadir/chrome-headless-shell" "$datadir/chromium" \
    -type f \( -name chrome-headless-shell -o -name chrome -o -name chromium \) 2>/dev/null | head -1 || true)"
  [ -n "$installed" ] && { echo "$installed"; return 0; }
  local c
  for c in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    [ -x "$c" ] && { echo "$c"; return 0; }
  done
  for c in google-chrome-stable google-chrome chromium chromium-browser microsoft-edge brave-browser; do
    command -v "$c" >/dev/null 2>&1 && { command -v "$c"; return 0; }
  done
  return 1
}

if [ ! -d "$SITE" ] || [ -z "$(find "$SITE" -name '*.html' -maxdepth 2 2>/dev/null | head -1)" ]; then
  echo "!! $SITE has no built pages. Render first:" >&2
  echo "   quarto render --metadata-file _tools/axe/axe-meta.yml" >&2
  exit 1
fi
CHROME_BIN="$(find_chrome || true)"
if [ -z "$CHROME_BIN" ] || { [ ! -x "$CHROME_BIN" ] && ! command -v "$CHROME_BIN" >/dev/null 2>&1; }; then
  echo "!! No Chrome found. Install Quarto's headless build:" >&2
  echo "   quarto install chrome-headless-shell" >&2
  echo "   …or set \$QUARTO_CHROMIUM (or \$CHROME) to a Chrome/Chromium binary." >&2
  exit 1
fi
# chrome-headless-shell is already headless and rejects --headless; full Chrome needs it.
case "$CHROME_BIN" in
  *chrome-headless-shell*) HEADLESS_FLAG="" ;;
  *) HEADLESS_FLAG="--headless=new" ;;
esac

JSON="$OUT/json" # raw per-cell dumps; the products (findings.json, report.html) stay at $OUT top level
mkdir -p "$JSON"
HTTP_PID=""; CHROME_PID=""
cleanup() {
  [ -n "$CHROME_PID" ] && kill "$CHROME_PID" 2>/dev/null || true
  [ -n "$HTTP_PID" ] && kill "$HTTP_PID" 2>/dev/null || true
  wait 2>/dev/null || true # reap killed jobs quietly (no "Terminated" noise)
  rm -rf "$CHROME_PROFILE" 2>/dev/null || true
}
trap cleanup EXIT

echo "→ serving $SITE on :$PORT"
python3 -m http.server "$PORT" --directory "$SITE" >/dev/null 2>&1 &
HTTP_PID=$!

echo "→ launching headless Chrome (CDP :$CDP): $CHROME_BIN"
"$CHROME_BIN" $HEADLESS_FLAG --disable-gpu --remote-debugging-port="$CDP" \
  --user-data-dir="$CHROME_PROFILE" --no-first-run --no-default-browser-check \
  --force-color-profile=srgb about:blank >/dev/null 2>&1 &
CHROME_PID=$!

for _ in $(seq 1 50); do
  curl -s "http://localhost:$CDP/json/version" >/dev/null 2>&1 && break
  sleep 0.2
done

echo "→ scanning"
node "$HERE/scan.mjs" --base "http://localhost:$PORT" --pages "$PAGES" --out "$JSON"
echo "→ aggregating"
node "$HERE/aggregate.mjs" --dir "$JSON" --out "$OUT/findings.json"
echo "→ rendering report"
node "$HERE/report.mjs" --file "$OUT/findings.json" --format html --base "$REPORT_BASE" > "$OUT/report.html"
node "$HERE/report.mjs" --file "$OUT/findings.json" --format table

echo
echo "✓ wrote $OUT/findings.json and $OUT/report.html  (raw per-cell dumps in $JSON/)"
echo "  open the report:  open $OUT/report.html"
