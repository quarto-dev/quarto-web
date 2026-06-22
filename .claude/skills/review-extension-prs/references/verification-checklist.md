# Extension Listing Verification Checklist

Eight checks per submission, applied by sub-agents in Step 3.

Official requirements (from `docs/extensions/listings/README.md`):
1. Hosted from a GitHub repository
2. README.md with install instructions and usage examples
3. Open-source license

---

## Check 1: Duplicate Detection

Script: `check-duplicate.sh <name> <owner/repo>`

| Result | Verdict |
|--------|---------|
| No output | PASS |
| `NAME_DUPLICATE` in same file as submission | FAIL |
| `PATH_DUPLICATE` in same file | FAIL |
| Match found in a *different* listing file | INVESTIGATE (cross-listing or misfile) |

Normalization: compare names case-insensitively; compare paths after extracting `owner/repo` (strip URL prefix, trailing slash, `.git`, `/blob/`, `/tree/` segments), lowercase.

---

## Check 2: Repo Exists and Is Public

Tool: `gh repo view <owner/repo> --json description,licenseInfo,isPrivate,isArchived,pushedAt,stargazerCount`

| Condition | Verdict |
|-----------|---------|
| Non-zero exit / "Could not resolve" | FAIL: repo not found |
| `isPrivate: true` | FAIL: private repo |
| `isArchived: true` | WARN: archived (may be unmaintained) |
| Public, not archived | PASS |

`pushedAt` and `stargazerCount` are context-only (not gates).

---

## Check 3: README Present

Tool: `gh api repos/<owner/repo>/readme` (case-insensitive, checks default branch)

| Result | Verdict |
|--------|---------|
| 404 | FAIL: no README |
| 200, has install + usage content | PASS |
| 200, thin (no install/usage examples) | WARN |

Look for: `quarto add`, install instructions, example syntax, usage section headers.

---

## Check 4: License

Priority order:
1. `licenseInfo` non-null from Check 2 → PASS (record `.name`)
2. `gh api repos/<owner/repo>/contents/LICENSE` → present → PASS
3. Try `LICENSE.md`, `LICENSE.txt`, `COPYING`
4. All absent → WARN (never FAIL — GitHub detector misses CC0, some BSD, custom OSS licenses)

| Result | Verdict |
|--------|---------|
| licenseInfo detected | PASS: `<license name>` |
| License file found | PASS: `license file present` |
| No detected license | WARN: `not auto-detected — verify manually` |

---

## Check 5: Category Fit

| File | Belongs here |
|------|-------------|
| `shortcodes-and-filters.yml` | Shortcodes, Lua filters, HTML rendering behavior, interactive elements |
| `custom-formats.yml` | New document formats (PDF, DOCX, Typst, HTML themes) |
| `journal-articles.yml` | Academic journal/manuscript templates (LaTeX/PDF focus) |
| `revealjs.yml` | Plugins that extend Reveal.js behavior |
| `revealjs-formats.yml` | Custom Reveal.js themes and format templates |

Clear mismatch → WARN with suggested file. Ambiguous (e.g., format that's also a shortcode wrapper) → PASS with note.

---

## Check 6: YAML Quality

| Field | Pass | Warn/Fail |
|-------|------|-----------|
| `author` | Valid `[text](url)` markdown link | WARN: malformed |
| `path` | Starts with `https://github.com/` | FAIL: not a GitHub URL |
| `description` | Clear English prose, 1–4 lines | WARN: spam/vague/too long |
| Description accuracy | Matches repo purpose | WARN: misleading |

---

---

## Check 7: Security Scan

List and read key source files from the repo (`*.lua`, `*.js`, `*.ts`, `*.py`, `*.sh`). Focus on extension code in `_extensions/` and root-level files. Up to ~5 files — skip tests and docs.

Tool: `gh api repos/<owner/repo>/git/trees/HEAD?recursive=1` then `gh api repos/<owner/repo>/contents/<path>`

| Pattern | Verdict |
|---------|---------|
| Code is straightforward, matches description | PASS |
| Pure template/config (Typst, LaTeX) with no scripting surface | PASS: minimal risk |
| `os.execute`/`io.popen` consistent with stated purpose (e.g., LaTeX format calling compiler) | WARN: note usage |
| JS fetching from external CDN | WARN: note domain |
| Outbound network calls not explained by description | FAIL |
| Shell execution with curl/wget/nc to external hosts | FAIL |
| Obfuscated/minified code with no clear purpose | FAIL |
| Code clearly mismatches description | FAIL |

**Security WARN → INVESTIGATE** (requires human review before merge, even if other checks pass).

---

## Verdict Rules

| Conditions | Recommendation |
|------------|---------------|
| All PASS | APPROVE |
| WARN only on non-security checks (license, thin README, archived) | APPROVE with notes |
| Security WARN | INVESTIGATE |
| Any FAIL | REQUEST_CHANGES |
| INVESTIGATE (cross-listing duplicate) | INVESTIGATE |
| Private or 404 repo | REQUEST_CHANGES |
