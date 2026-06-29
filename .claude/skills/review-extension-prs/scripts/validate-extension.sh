#!/usr/bin/env bash
set -uo pipefail
# Validate _extension.yml schema and referenced files for a Quarto extension repo.
# Usage: validate-extension.sh <owner/repo>
# Output: PASS/FAIL/INFO lines. Always exits 0 — caller interprets output.

REPO="${1:?Usage: validate-extension.sh <owner/repo>}"
OWNER="${REPO%%/*}"
REPO_NAME="${REPO#*/}"
EXT_NAME="${REPO_NAME#quarto-}"  # strip quarto- prefix if present

TMPYAML=$(mktemp)
TMPTREE=$(mktemp)
trap 'rm -f "$TMPYAML" "$TMPTREE"' EXIT

# Fetch file tree
if ! gh api "repos/$REPO/git/trees/HEAD?recursive=1" --jq '[.tree[] | .path]' > "$TMPTREE" 2>/dev/null; then
  echo "FAIL: could not fetch repo tree"
  exit 0
fi

# Locate _extension.yml.
# Valid locations for quarto add: <name>/_extension.yml or _extensions/<name>/_extension.yml
# Root-level _extension.yml is NOT valid — quarto add reports "Found 0 extensions".
FOUND_PATH=""
for candidate in "${EXT_NAME}/_extension.yml" "_extensions/${EXT_NAME}/_extension.yml"; do
  if jq -r '.[]' "$TMPTREE" | grep -qx "$candidate"; then
    if gh repo read-file "$candidate" --repo "$REPO" > "$TMPYAML" 2>/dev/null; then
      FOUND_PATH="$candidate"
      break
    fi
  fi
done

# Root-level _extension.yml: structural failure (quarto add cannot find it)
if [ -z "$FOUND_PATH" ] && jq -r '.[]' "$TMPTREE" | grep -qx "_extension.yml"; then
  echo "FAIL: _extension.yml at repo root — quarto add requires it in a named subdirectory (${EXT_NAME}/_extension.yml); this explains 'Found 0 extensions' install error"
  # Still read it for schema checks so caller gets the full picture
  gh repo read-file _extension.yml --repo "$REPO" > "$TMPYAML" 2>/dev/null || true
  FOUND_PATH="_extension.yml (invalid location)"
fi

if [ -z "$FOUND_PATH" ]; then
  echo "FAIL: _extension.yml not found in any valid location"
  exit 0
fi

echo "INFO: _extension.yml at $FOUND_PATH"

uv run --with pyyaml python - "$TMPYAML" "$TMPTREE" <<'PYEOF'
import sys, json, yaml

with open(sys.argv[1], encoding="utf-8") as f:
    content = f.read()
with open(sys.argv[2], encoding="utf-8") as f:
    tree_set = set(json.load(f))

try:
    data = yaml.safe_load(content)
except yaml.YAMLError as e:
    print(f"FAIL: invalid YAML — {e}")
    sys.exit(0)

if not isinstance(data, dict):
    print("FAIL: _extension.yml is empty or not a YAML mapping")
    sys.exit(0)

# Required fields (name is inferred from directory; not required in yml)
for field in ["title", "author", "version", "contributes"]:
    if field in data:
        print(f"PASS: required field '{field}' present")
    else:
        print(f"FAIL: required field '{field}' missing")

# Document-header fields that must never appear at root of _extension.yml.
# Their presence signals LLM-generated garbage (pasting doc YAML into extension yml).
BAD_ROOT = {"execute", "jupyter", "bibliography", "format", "filters",
            "toc", "toc-depth", "number-sections", "echo", "warning", "error", "engine"}
bad_found = sorted(f for f in BAD_ROOT if f in data)
if bad_found:
    print(f"FAIL: document-header fields at root level: {bad_found} — these belong in a document YAML header, not in _extension.yml; signals LLM-generated garbage")
else:
    print("PASS: no invalid root-level fields")

# Extract all file path references from contributes and check they exist
FILE_SCALAR_KEYS = {"reference-doc", "template", "css", "csl",
                    "include-in-header", "include-before-body", "include-after-body"}
FILE_LIST_KEYS = {"filters", "format-resources"}

def collect_refs(obj):
    refs = []
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k in FILE_SCALAR_KEYS:
                if isinstance(v, str):
                    refs.append(v)
                elif isinstance(v, list):
                    refs += [x for x in v if isinstance(x, str)]
            elif k in FILE_LIST_KEYS:
                if isinstance(v, list):
                    refs += [x for x in v if isinstance(x, str)]
                elif isinstance(v, str):
                    refs.append(v)
            else:
                refs += collect_refs(v)
    elif isinstance(obj, list):
        for item in obj:
            refs += collect_refs(item)
    return refs

refs = collect_refs(data.get("contributes", {}))
if not refs:
    print("INFO: no file references found in contributes")
for ref in refs:
    clean = ref.lstrip("./")
    if clean in tree_set:
        print(f"PASS: referenced file exists — {ref}")
    else:
        print(f"FAIL: referenced file missing from repo — {ref}")
PYEOF
