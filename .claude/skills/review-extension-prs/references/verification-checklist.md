# Extension Listing Verification Checklist

A topic assessment, then the mechanical checks per submission, then an upstream-thread search.

Official requirements (from `docs/extensions/listings/README.md`):
1. Hosted from a GitHub repository
2. README.md with install instructions and usage examples
3. Open-source license

---

## Check 0: Topic and Substance

Read the extension's README and docs site first. Answer in the report:

| Question | Verdict |
|----------|---------|
| What problem does it solve (one sentence, author's terms)? | Cannot write the sentence → WARN: description inadequate |
| Does Quarto do this natively? (`grep -rniE '<keyword>' docs/ --include=*.qmd -l`) | No native support → PASS, name the gap |
| | Native and equivalent → INVESTIGATE: redundant with a built-in feature |
| | Native but narrower → PASS, name the limit precisely |
| Does an existing listing entry solve it? (`grep -rniE '<keyword>' docs/extensions/listings/*.yml`) | Near-identical scope under another name → INVESTIGATE |
| Implementation weight, repository age, user count, number of authors, machine-generated prose | Context, not a gate. A new repository with one author warrants a cautious public description |

(Check 1 matches `name` and `owner/repo` only, not function.)

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

Tool: `gh repo view <owner/repo> --json name,description,licenseInfo,isPrivate,isArchived,createdAt,pushedAt,stargazerCount`

| Condition | Verdict |
|-----------|---------|
| `Could not resolve to a Repository` | FAIL: repo not found |
| Any other failure (auth, rate limit, network, 5xx) | UNVERIFIED: report as not checked, do not infer the repo is missing |
| `isPrivate: true` | FAIL: private repo |
| `isArchived: true` | WARN: archived (may be unmaintained) |
| Public, not archived | PASS |

`pushedAt` and `stargazerCount` are context-only (not gates).

---

## Check 3: README Present

Tool: `gh repo read-file README.md --repo <owner/repo>`

| Result | Verdict |
|--------|---------|
| `HTTP 404: Not Found` | FAIL: no README (Check 2 already established the repo exists) |
| Any other failure (auth, rate limit, network, 5xx) | UNVERIFIED: report as not checked, do not infer absence |
| Content with install + usage | PASS |
| Content, but thin (no install/usage examples) | WARN |

The exit code alone cannot tell these apart; a missing file and an unreachable API both exit non-zero. Read the message.

Look for: `quarto add`, install instructions, example syntax, usage section headers.

---

## Check 4: License

`docs/extensions/listings/README.md` requires a submission to indicate an open-source license, so an unlicensed repo cannot reach APPROVE. GitHub's detector does miss CC0, some BSD variants and custom OSS texts, so a detector miss is not itself absence — the two cases are separated below.

Priority order:
1. `licenseInfo` non-null from Check 2 → PASS (record `.name`)
2. `gh repo read-file LICENSE --repo <owner/repo>` → present → verify manually
3. Try `LICENSE.md`, `LICENSE.txt`, `COPYING`
4. Check the README for a license section naming a license
5. Nothing found by any route → FAIL

| Result | Verdict |
|--------|---------|
| licenseInfo detected | PASS: `<license name>` |
| Detector missed it, but a license file or README section exists | WARN: read the text and name the license; PASS once identified |
| No license detected, no license file, no README statement | FAIL: unlicensed, the listing requires one |
| Any lookup failed for another reason (auth, rate limit, network) | UNVERIFIED: report as not checked, do not infer absence |

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

## Check 7: Security Scan

List and read every file inside the extension root, starting with files that may contain executable code. The filter `\.(lua|js|mjs|cjs|ts|py|rb|pl|sh|ps1|html|wasm|[Rr])$` covers the expected scripting formats. The extension root is the directory containing the manifest reported by `validate-extension.sh`. Because `quarto add` copies that directory in full, review all of its contents, including `tests/` and `docs/` subdirectories.

Tool: `gh api repos/<owner/repo>/git/trees/HEAD?recursive=1` then `gh repo read-file <path> --repo <owner/repo>`

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

Files outside the extension root never reach a user's machine through `quarto add`. Weigh a test suite or docs tooling as authorship signal for Check 0, not as attack surface.

---

## Check 8: Upstream Threads

Search quarto-cli for issues and discussions the extension answers. Not a gate: it produces a comment draft, and a listed extension that resolves a standing request is worth surfacing to the people who asked.

Feature requests of this kind appear more often in discussions than in issues. Query both with `gh discussion list --search` and `gh issue list --search`, each with `--state all`.

Traps:

| Trap | Detail |
|------|--------|
| `gh search discussions` | Does not exist. `gh search` covers code, commits, issues, prs, repos only; use `gh discussion list --search`. |
| `gh discussion list --json` shape | `{discussions: [...]}`, so jq needs `.discussions[]`. No `state` field; use `closed` and `stateReason`. |
| `gh search issues --state all` | Rejected, accepts `open` or `closed` only. Use `gh issue list --search`, which also handles OR correctly with `--repo`. |
| `OR` | Works in both, real union across terms. Use it for true synonyms. |
| `AND` | Real operator, and whitespace already means it: [GitHub docs](https://docs.github.com/en/search-github/github-code-search/understanding-github-code-search-syntax#using-boolean-operations) state `sparse index` equals `sparse AND index`. Every added term narrows the result set, so a long phrase finds nothing. |
| Qualifiers | `in:title`, `category:`, `author:` all work inside `--search`. |

| Signal | Action |
|--------|--------|
| Open Feature Request with upvotes | Best venue. Draft a comment. |
| Q&A closed as duplicate | Comment on the canonical thread it names, not this one. |
| Open Q&A whose only answer misread the question | Good venue. Link the canonical thread too. |
| Related-looking thread that is a different problem (config error, not missing feature) | Skip, and say why. |
| Nothing found | Report "none found" — after several one-concept queries, not one long phrase. |

Search the feature vocabulary and the underlying mechanism, never the extension name; nobody upstream has used it yet. Combine synonyms with `OR` in a single query rather than running one query per word.

---

## Verdict Rules

| Conditions | Recommendation |
|------------|---------------|
| All PASS | APPROVE |
| WARN only on non-security checks (license, thin README, archived) | APPROVE with notes |
| Security WARN | INVESTIGATE |
| Any FAIL | REQUEST_CHANGES |
| UNVERIFIED on a gating check (repo, license, README, extension validity, install, security) | INVESTIGATE: verification is incomplete, so approval has nothing to rest on |
| INVESTIGATE (cross-listing duplicate) | INVESTIGATE |
| Redundant with native Quarto functionality | INVESTIGATE |
| Functional duplicate of an existing entry under another name | INVESTIGATE |
| Private or 404 repo | REQUEST_CHANGES |
