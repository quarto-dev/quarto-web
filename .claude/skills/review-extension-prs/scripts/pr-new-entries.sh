#!/usr/bin/env bash
set -euo pipefail
# Extract net-new YAML entries added by a PR diff.
# Usage: pr-new-entries.sh <PR_NUMBER>
# Emits JSON: [{file, name, path, author, description}, ...]

PR_NUMBER="${1:?Usage: pr-new-entries.sh <PR_NUMBER>}"
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

gh pr diff "$PR_NUMBER" --repo quarto-dev/quarto-web > "$TMPFILE"

uv run python - "$TMPFILE" <<'PYEOF'
import sys, re, json

def parse_added_entries(fname, lines):
    entries = []
    current = {}
    desc_lines = []
    in_desc = False

    def flush():
        nonlocal desc_lines, in_desc
        if current.get('name') and current.get('path'):
            if desc_lines:
                current['description'] = ' '.join(desc_lines).strip()
            entries.append(dict(current))
        current.clear()
        desc_lines.clear()
        in_desc = False

    for line in lines:
        if re.match(r'^- name:\s', line):
            flush()
            current.update({
                'file': fname,
                'name': line.split('name:', 1)[1].strip(),
                'path': '', 'author': '', 'description': ''
            })
            in_desc = False
        elif re.match(r'^\s+path:\s', line) and current:
            current['path'] = line.split('path:', 1)[1].strip()
            in_desc = False
        elif re.match(r'^\s+author:\s', line) and current:
            current['author'] = line.split('author:', 1)[1].strip()
            in_desc = False
        elif re.match(r'^\s+description:', line) and current:
            in_desc = True
            rest = re.sub(r'^\s+description:\s*[>|]?\s*', '', line).strip()
            if rest:
                desc_lines.append(rest)
        elif in_desc and re.match(r'^\s{4}', line):
            desc_lines.append(line.strip())
        else:
            in_desc = False

    flush()
    return entries

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    diff = f.read()

entries = []
current_file = None
added_lines = []

for line in diff.splitlines():
    m = re.match(r'^\+\+\+ b/(.+)', line)
    if m:
        if current_file and added_lines:
            entries.extend(parse_added_entries(current_file, added_lines))
        path = m.group(1)
        m2 = re.search(r'docs/extensions/listings/([^_].+\.yml)$', path)
        current_file = m2.group(1) if m2 else None
        added_lines = []
    elif current_file and line.startswith('+') and not line.startswith('+++'):
        added_lines.append(line[1:])

if current_file and added_lines:
    entries.extend(parse_added_entries(current_file, added_lines))

print(json.dumps(entries, indent=2))
PYEOF
