---
name: review-extension-prs
description: Use when asked to review open pull requests that add Quarto extensions
  to the listing YAML files in docs/extensions/listings/. Triggers include "review
  extension PRs", "check extension submissions", "are there new listing PRs", or any
  request to triage or verify community extension submissions before merge.
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/*), Bash(gh *), Read
---

# Review Extension Listing PRs

Verify community Quarto extension submissions before merge.

## Background

The listing files live in `docs/extensions/listings/`:
- `filters.yml`, `formats.yml`, `shortcodes-and-filters.yml`, `revealjs.yml`, `journal-articles.yml`

Each entry has: `name`, `path` (GitHub URL), `author`, `description`.

PRs adding extensions touch one of these files. Your job: check each new entry is legitimate, not a duplicate, and correctly categorized.

## Workflow

### 1. Find qualifying PRs

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/list-listing-prs.sh"
```

Returns open PRs touching listing files. If user named a specific PR number, skip this and target that PR directly.

### 2. Extract new entries

For each PR:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/pr-new-entries.sh <PR_NUMBER>"
```

Returns `[{file, name, path, author, description}]` for added entries.

### 3. Verify each entry

For each entry, check:

1. **Duplicate** — `bash "${CLAUDE_SKILL_DIR}/scripts/check-duplicate.sh" "<name>" "<owner/repo>"` — empty output = no duplicate
2. **Repo exists** — `gh repo view <owner/repo> --json name,description,licenseInfo,isArchived` — must exist and not archived
3. **License** — from repo view above; MIT/Apache/GPL preferred; missing license = flag
4. **README** — `gh repo read-file README.md --repo <owner/repo>` — must have `quarto add` install command and usage example
5. **Category** — does the entry file match the extension type? (filters→filters.yml, themes/templates→formats.yml, etc.)
6. **Alphabetical order** — `bash "${CLAUDE_SKILL_DIR}/scripts/check-order.sh" "<file>" "<name>"` — checks the new entry's `name` sorts correctly (case-insensitive) relative to its immediate neighbours in the file; empty output = correctly placed. Entries are meant to stay alphabetical by `name` — a PR that appends at end-of-file instead of inserting in place is a common contributor mistake (e.g. PR #2090 tacked `simpleicons` after `wordcount` instead of near `si`/`simple-vars`).
7. **Description quality** — one clear sentence; not just repo name repeated
8. **Extension validity** — `bash "${CLAUDE_SKILL_DIR}/scripts/validate-extension.sh" "<owner/repo>"` — checks:
   - `_extension.yml` in valid location (`<name>/` or `_extensions/<name>/` — root-level fails quarto add with "Found 0 extensions")
   - Required fields present: `title`, `author`, `version`, `contributes`
   - No document-header fields at root: `execute`, `jupyter`, `bibliography`, `format`, etc. — signals LLM-generated garbage
   - All file paths in `contributes` (`reference-doc`, `template`, `format-resources`, `filters`) actually exist in repo tree

9. **Install test** — `bash "${CLAUDE_SKILL_DIR}/scripts/test-install.sh" "<owner/repo>" "<name>"` — runs `quarto add --no-prompt` in a temp dir and checks `_extensions/<owner>/<name>/_extension.yml` was created. Also warns if the repo installs more than one extension (unrelated/leftover extension dirs shipped in the same repo) or if the listed `<name>` doesn't match what got installed. Slow (network); run last.

10. **Security** — `gh api repos/<owner/repo>/git/trees/HEAD?recursive=1 --jq '[.tree[] | select(.path | test("\\.(lua|js|ts|py|sh)$"))] | .[].path'` — read key source files; flag outbound network calls, shell execution, obfuscation

### 4. Report

For each PR, one block:

```
PR #N — <title> (@author)
  Entry: <name> → <file>
  Repo:  <owner/repo>
  ✓/✗ duplicate        <result>
  ✓/✗ license          <result>
  ✓/✗ readme           <result>
  ✓/✗ category         <result>
  ✓/✗ order            <result>
  ✓/✗ extension valid  <result>
  ✓/✗ install test     <result>
  ✓/✗ security         <result>

→ RECOMMEND: APPROVE / REQUEST_CHANGES / INVESTIGATE
   <reason if not APPROVE>
```

All checks pass → APPROVE. Any FAIL → REQUEST_CHANGES with specific reason. Security concern → INVESTIGATE.

### 5. Draft a PR comment

For every PR that is not a clean APPROVE, draft a comment text the reviewer could post as-is (never post it automatically — output it for the human to review and send).

Generic style rules (no external style skill assumed — keep this self-contained so the skill works standalone in any repo):

- Open by thanking the contributor for the submission — one short sentence, not effusive.
- State findings as plain facts, not accusations: "the new entry appears after `wordcount` instead of near `si`/`simple-vars`" not "you broke alphabetical order."
- Give the exact fix, not just the problem: name the correct location, the missing file, the field to add.
- One issue per line/bullet when there's more than one finding; no filler paragraphs.
- Never mention internal tooling, script names, check numbers, or that the review was automated — write as a normal maintainer comment.
- Never include a merge/approval promise — the fix is a precondition for further review, not a guarantee.
- For APPROVE-with-minor-nit cases, say the PR looks good and note the nit as optional.

Never auto-post comments or merge PRs — recommendations and drafts only.
