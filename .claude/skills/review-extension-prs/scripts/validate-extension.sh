#!/usr/bin/env bash
set -uo pipefail
# Validate _extension.yml schema and referenced files for a Quarto extension repo.
# Usage: validate-extension.sh <owner/repo> [listing-name]
# Output: PASS/FAIL/INFO lines. Always exits 0 — caller interprets output.

REPO="${1:?Usage: validate-extension.sh <owner/repo> [listing-name]}"
OWNER="${REPO%%/*}"
REPO_NAME="${REPO#*/}"
# The extension directory may differ from the repository name.
EXT_NAME="${2:-${REPO_NAME#quarto-}}"

TMPYAML=$(mktemp)
TMPTREE=$(mktemp)
trap 'rm -f "$TMPYAML" "$TMPTREE"' EXIT

# Fetch file tree
if ! FETCH_ERR=$(gh api "repos/$REPO/git/trees/HEAD?recursive=1" --jq '[.tree[] | .path]' 2> >(cat) > "$TMPTREE"); then
  case "$FETCH_ERR" in
    *"Not Found"*|*"Could not resolve"*)
      echo "FAIL: repo or default branch not found" ;;
    *)
      echo "UNVERIFIED: could not fetch repo tree (${FETCH_ERR:-unknown error}); extension validity not checked" ;;
  esac
  exit 0
fi

# Only these two manifest paths are installable. The filter also excludes
# manifests vendored in documentation sites and fixtures.
mapfile -t CANDIDATES < <(
  jq -r '.[]' "$TMPTREE" | grep -E '^([^/]+/_extension\.yml|_extensions/[^/]+/_extension\.yml)$'
)

FOUND_PATH=""
EXT_NAME_LOWER=$(printf '%s' "$EXT_NAME" | tr '[:upper:]' '[:lower:]')
for candidate in "${CANDIDATES[@]:-}"; do
  [ -n "$candidate" ] || continue
  dir_name=$(basename "$(dirname "$candidate")")
  if [ "$(printf '%s' "$dir_name" | tr '[:upper:]' '[:lower:]')" = "$EXT_NAME_LOWER" ]; then
    FOUND_PATH="$candidate"
    break
  fi
done

if [ -z "$FOUND_PATH" ] && [ "${#CANDIDATES[@]}" -eq 1 ] && [ -n "${CANDIDATES[0]}" ]; then
  FOUND_PATH="${CANDIDATES[0]}"
  echo "INFO: extension directory is named '$(basename "$(dirname "$FOUND_PATH")")', not '${EXT_NAME}'; verify the listing name matches what quarto add installs"
fi

if [ -z "$FOUND_PATH" ] && [ "${#CANDIDATES[@]}" -gt 1 ]; then
  echo "INVESTIGATE: repo ships ${#CANDIDATES[@]} extensions and none is named '${EXT_NAME}':"
  printf '  %s
' "${CANDIDATES[@]}"
  echo "INVESTIGATE: pass the listing name as the second argument to pick one"
  exit 0
fi

if [ -n "$FOUND_PATH" ] && ! gh repo read-file "$FOUND_PATH" --repo "$REPO" > "$TMPYAML" 2>/dev/null; then
  echo "UNVERIFIED: found $FOUND_PATH in the tree but could not read it"
  exit 0
fi

if [ -z "$FOUND_PATH" ] && jq -r '.[]' "$TMPTREE" | grep -qx "_extension.yml"; then
  echo "FAIL: _extension.yml at repo root - quarto add requires it in a named subdirectory; this explains 'Found 0 extensions' install error"
  # Continue with schema checks to report all findings.
  gh repo read-file _extension.yml --repo "$REPO" > "$TMPYAML" 2>/dev/null || true
  FOUND_PATH="_extension.yml (invalid location)"
fi

if [ -z "$FOUND_PATH" ]; then
  echo "FAIL: _extension.yml not found in any valid location"
  exit 0
fi

echo "INFO: _extension.yml at $FOUND_PATH"

uv run --with pyyaml python - "$TMPYAML" "$TMPTREE" "$FOUND_PATH" "$REPO" <<'PYEOF'
import sys, json, yaml, os, re, subprocess

with open(sys.argv[1], encoding="utf-8") as f:
    content = f.read()
with open(sys.argv[2], encoding="utf-8") as f:
    tree_set = set(json.load(f))
found_path = sys.argv[3] if len(sys.argv) > 3 else ""
ext_dir = os.path.dirname(found_path) if "(" not in found_path else ""
repo = sys.argv[4] if len(sys.argv) > 4 else ""

try:
    data = yaml.safe_load(content)
except yaml.YAMLError as e:
    print(f"FAIL: invalid YAML - {e}")
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

# These document fields do not belong at the manifest root.
BAD_ROOT = {"execute", "jupyter", "bibliography", "format", "filters",
            "toc", "toc-depth", "number-sections", "echo", "warning", "error", "engine"}
bad_found = sorted(f for f in BAD_ROOT if f in data)
if bad_found:
    print(f"FAIL: document-header fields at root level: {bad_found} - move these fields to the document YAML header")
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
    qualified = (ext_dir + "/" + clean) if ext_dir else clean
    if qualified in tree_set or clean in tree_set:
        print(f"PASS: referenced file exists - {ref}")
    else:
        print(f"FAIL: referenced file missing from repo - {ref}")

# Reverse check: Lua files in extension dir not referenced in manifest.
# For each unreferenced file, read all Lua files in the extension and scan for require() calls.
# require()'d internally → INFO; genuinely unreferenced → WARN (dead code).
if ext_dir:
    all_refs_raw = collect_refs(data)  # full manifest, not just contributes
    all_refs_normalized = set()
    for r in all_refs_raw:
        clean = r.lstrip("./")
        all_refs_normalized.add(clean)
        if ext_dir:
            all_refs_normalized.add(f"{ext_dir}/{clean}")
            if clean.startswith(f"{ext_dir}/"):
                all_refs_normalized.add(clean[len(ext_dir)+1:])

    lua_files = sorted(p for p in tree_set if p.startswith(f"{ext_dir}/") and p.endswith(".lua"))
    unreferenced = [p for p in lua_files
                    if p not in all_refs_normalized and p[len(ext_dir)+1:] not in all_refs_normalized]

    if unreferenced and repo:
        # Fetch all Lua files in the extension dir to scan for require() calls
        lua_contents = {}
        for lua_path in lua_files:
            result = subprocess.run(
                ["gh", "repo", "read-file", lua_path, "--repo", repo],
                capture_output=True, text=True, encoding="utf-8", errors="replace"
            )
            if result.returncode == 0 and result.stdout:
                lua_contents[lua_path] = result.stdout

        # Collect every module name passed to require() across all Lua files
        require_pat = re.compile(r"""require\s*[\(\s]["']([^"']+)["']""")
        required_modules = set()
        for lua_src in lua_contents.values():
            for m in require_pat.finditer(lua_src):
                mod = m.group(1)
                required_modules.add(mod)                          # "path.to.module"
                required_modules.add(mod.replace(".", "/"))        # "path/to/module"
                required_modules.add(mod.split(".")[-1])           # "module"
                required_modules.add(mod.split("/")[-1])

        for lua_path in unreferenced:
            base = os.path.splitext(os.path.basename(lua_path))[0]
            lua_rel = lua_path[len(ext_dir)+1:]
            lua_rel_noext = os.path.splitext(lua_rel)[0]
            if (base in required_modules
                    or lua_rel_noext in required_modules
                    or lua_rel_noext.replace("/", ".") in required_modules):
                print(f"INFO: Lua file not in manifest but require()'d internally - {lua_path}")
            else:
                print(f"WARN: Lua file not referenced in manifest and not require()'d - {lua_path} (dead code?)")
PYEOF
