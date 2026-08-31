---
name: review-extension-prs
description: Use when asked to review open pull requests that add Quarto extensions
  to the listing YAML files in docs/extensions/listings/. Triggers include "review
  extension PRs", "check extension submissions", "are there new listing PRs", or any
  request to triage or verify community extension submissions before merge.
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/*), Bash(gh *), Bash(grep *), Read
---

# Review Extension Listing PRs

Verify community Quarto extension submissions before merge.

## Background

The listing files live in `docs/extensions/listings/`: `custom-formats.yml`, `journal-articles.yml`, `revealjs-formats.yml`, `revealjs.yml`, `shortcodes-and-filters.yml`. Each entry has `name`, `path` (GitHub URL), `author`, `description`.

Reference files, loaded on demand:
- `references/category-guide.md` — which listing file an extension belongs in, including the ambiguous cases.
- `references/verification-checklist.md` — per-check pass/warn/fail rules, license nuance, search traps, verdict table.

After changing this file, a script, or a reference document, run `bash "${CLAUDE_SKILL_DIR}/scripts/self-test.sh"`. Add `--network` to test extension discovery against real repositories.

The review has two parts. The substantive review identifies the problem the extension solves, whether it is worth listing, and whether users have requested it upstream. The mechanical review checks the entry, category, duplicates, and installation. Complete step 3 first so the mechanical results have context.

## Workflow

### 1. Find qualifying PRs

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/list-listing-prs.sh"
```

If the user named a PR, target it and skip this. If no PRs qualify, say so and stop.

### 2. Extract new entries

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/pr-new-entries.sh <PR_NUMBER>"
```

Returns `[{file, name, path, author, description}]` for added entries. A PR may touch several listing files; review every entry. A PR that only edits or removes existing entries yields nothing here — review that diff by hand and say that is what happened.

### 3. Understand what the extension does

Read the extension's README and docs site first, then answer four questions in the report. `references/verification-checklist.md` Check 0 has the verdict rules.

**a. What problem does it solve?** One sentence, in the author's terms. If you cannot write it after reading the docs, the description is inadequate and that is a finding.

**b. Does Quarto already do this natively?**

```bash
grep -rniE '<feature keyword>' docs/ --include=*.qmd -l
```

Three outcomes: no native support (name the gap), native and equivalent (flag the redundancy), or native but narrower (state which formats the built-in feature covers, what authors must write, and which limitations the extension removes). "Quarto sort of does this" is not a finding.

**c. Does an existing listing entry already solve it?** Check 1's script matches `name` and `owner/repo`, never function.

```bash
grep -rniE '<feature keyword>' docs/extensions/listings/*.yml
```

Two extensions can legitimately overlap; near-identical scope under a different name is worth raising.

**d. Is the substance there?** Judgement call, reported as context, not a gate. Signals in Check 0.

### 4. Verify each entry

1. **Duplicate** — `bash "${CLAUDE_SKILL_DIR}/scripts/check-duplicate.sh" "<name>" "<owner/repo>"` — empty output = no duplicate.
2. **Repo exists** — `gh repo view <owner/repo> --json name,description,licenseInfo,isPrivate,isArchived,createdAt,pushedAt,stargazerCount` — must exist and be public. Archived is a WARN, not a gate; `createdAt` and `stargazerCount` are context for step 3d.
3. **License** — from the repo view above. A detector miss is not absence: look for a `LICENSE` file and a README license section before concluding anything. Genuinely unlicensed is a FAIL, since the listing requires one. See Check 4 for the lookup order.
4. **README** — `gh repo read-file README.md --repo <owner/repo>` — must have a `quarto add` command and a usage example.
5. **Category** — does the entry's file match the extension type? See `references/category-guide.md`, which also covers formats that ship shortcodes, cross-format extensions, and non-journal academic templates.
6. **Alphabetical order** — `bash "${CLAUDE_SKILL_DIR}/scripts/check-order.sh" "<file>" "<name>"` — empty output = correctly placed. Appending at end-of-file instead of inserting in place is a common contributor mistake.

   The script greps the path it is given, and the local checkout does not contain the entry while the PR is unmerged. Fetch the PR head version first:

   ```bash
   PR=<PR_NUMBER>
   HEAD_SHA=$(gh api repos/quarto-dev/quarto-web/pulls/$PR -q .head.sha)
   HEAD_REPO=$(gh api repos/quarto-dev/quarto-web/pulls/$PR -q .head.repo.full_name)
   gh repo read-file docs/extensions/listings/<file> --repo "$HEAD_REPO" --ref "$HEAD_SHA" --output <tmp>/listing.yml
   bash "${CLAUDE_SKILL_DIR}/scripts/check-order.sh" <tmp>/listing.yml "<name>"
   ```

   `ORDER_CHECK_ERROR: name '<name>' not found` means the wrong file was passed, not that the entry is misplaced.
7. **Description quality** — one clear sentence, not the repo name restated. Cross-check against step 3a: a description that misstates what the extension does is a finding even when it reads well.
8. **Extension validity** — `bash "${CLAUDE_SKILL_DIR}/scripts/validate-extension.sh" "<owner/repo>" "<name>"` — pass the listing `name` as the second argument because the extension directory may differ from the repository name. The script finds installable manifests at `<dir>/_extension.yml` or `_extensions/<dir>/_extension.yml` and prefers the directory matching `<name>`. It checks the location, required `title`/`author`/`version`/`contributes` fields, misplaced document-header fields, and paths referenced by `contributes`.
9. **Install test** — `bash "${CLAUDE_SKILL_DIR}/scripts/test-install.sh" "<owner/repo>" "<name>"` — runs `quarto add --no-prompt` in a temp dir. Also warns when the repo installs more than one extension, or when the listed `<name>` is not what got installed. Slow (network); run last.
10. **Security** — list shipped source, then read everything inside the extension root:

    ```bash
    gh api repos/<owner/repo>/git/trees/HEAD?recursive=1 --jq '.tree[].path' | grep -E '\.(lua|js|mjs|cjs|ts|py|rb|pl|sh|ps1|html|wasm|[Rr])$'
    ```

    The filter orders the reading, it does not bound it: the scope is every file under the extension root. An `include-in-header` HTML file carrying a `<script>` tag ships the same executable surface as a `.js` file.

    The extension root is whichever path check 8 reported, `_extensions/<name>/` or a root-level `<name>/`. `quarto add` copies that directory wholesale, so read everything under it regardless of directory name; a `tests/` subdirectory inside the root is shipped code. Files outside the root never reach a user, so weigh those as authorship signal rather than attack surface. Flag outbound network calls, shell execution, obfuscation. For file IO, check where paths resolve: a store under the project's `.quarto/` scratch directory is expected, a write outside the project tree is not.

    Do not inline the file-extension regex into `--jq`; `\.` is an invalid escape in a jq string literal.

If a `gh` call fails mid-checklist, record that check as unverified and finish the rest rather than abandoning the PR.

### 5. Find upstream threads it addresses

Run this once the mechanical checks in step 4 have passed. A submission already heading for REQUEST_CHANGES needs no upstream comment draft, and these searches are the most expensive part of the review. Steps 3b and 3c stay mandatory either way: whether Quarto already does this, and whether the listing already carries it, decide whether the entry belongs at all.

If the extension addresses an existing request, surface it in the relevant thread because users may not discover it through the listing. Search for feature terms rather than the extension name.

```bash
# Issues
gh issue list --repo quarto-dev/quarto-cli --state all --limit 20 \
  --search "<keyword> OR <synonym>" \
  --json number,title,state --jq '.[] | "\(.state)\t#\(.number)\t\(.title)"'

# Discussions — note the nested JSON: .discussions[], and `closed` rather than `state`
gh discussion list --repo quarto-dev/quarto-cli --state all --limit 30 \
  --search "<keyword> OR <synonym>" \
  --json number,title,closed,category,createdAt \
  --jq '.discussions[] | "closed=\(.closed)\t#\(.number)\t\(.createdAt[0:10])\t\(.category.name)\t\(.title)"'
```

Feature requests of this kind appear more often in discussions than in issues. Search both with `--state all`; a closed thread often names the canonical open one. Query one concept at a time with synonyms joined by `OR`. Whitespace means `AND`, so additional terms narrow the results. Search for the underlying mechanism and the requested user-facing behavior. Check 8 lists other search constraints and venue-selection rules.

Read each candidate with `gh discussion view <N> --repo quarto-dev/quarto-cli --comments --order oldest`. Without `--comments` only the body prints, and the comments hold the duplicate pointers, accepted answers and maintainer context that identify the right venue.

### 6. Report

For each PR, one block:

Each check reports one of `PASS`, `WARN`, `FAIL`, `INVESTIGATE` or `UNVERIFIED`, followed by the result. A tick and a cross cannot express the middle three, and a check that was not reached must not read as one that passed.

```
PR #N — <title> (@author)
  Entry: <name> → <file>
  Repo:  <owner/repo>
  Solves: <one sentence, from step 3a>
  Native: <none | equivalent | narrower: what Quarto does today and its limit>
  duplicate        <status> <result, mechanical>
  overlap          <status> <no functional overlap | overlaps <name>>
  repo             <status> <exists, public, archived?>
  license          <status> <license name, or how it was established>
  readme           <status> <install command and usage example present?>
  category         <status> <file matches extension type?>
  order            <status> <placement relative to neighbours>
  description      <status> <matches what the extension does?>
  extension valid  <status> <_extension.yml location and fields>
  install test     <status> <what quarto add produced>
  security         <status> <what was read and what was found>
  Substance: <implementation weight, repo age, users, authorship signals>
  Upstream: <threads this answers, with number, state and category | none found | not searched>

→ RECOMMEND: APPROVE / REQUEST_CHANGES / INVESTIGATE
   <reason if not APPROVE>
```

With several entries in one PR, report a block each and take the worst verdict across them as the PR's recommendation.

Verdict rules are in the reference checklist's Verdict Rules table. State plainly what was and was not verified: installing an extension and reading its source is not the same as rendering a document with it.

### 7. Draft comments

Never post anything. Output drafts for the human to review and send.

**PR comment** — for every PR that is not a clean APPROVE.

- Open by thanking the contributor for the submission, one short sentence.
- State findings as plain facts, not accusations: "the new entry appears at the end of the file rather than next to its alphabetical neighbours", not "you broke alphabetical order".
- Give the exact fix: the correct location, the missing file, the field to add.
- One issue per bullet; no filler paragraphs.
- Never mention internal tooling, script names, check numbers, or that the review was automated.
- Never promise a merge; the fix is a precondition for further review.
- APPROVE-with-a-nit: say the PR looks good and mark the nit optional.

**Upstream thread comment** — when step 5 found a venue. One draft per thread, each labelled with its target.

- Lead with what the extension does in the thread's own vocabulary, then link the extension repo.
- Credit the author by name, no `@` mention: the repo link already notifies them.
- Carry an explicit disclaimer, once: externally contributed, not maintained by the project, not tried by the person posting, and it *claims* to solve the problem. A maintainer's pointer must not read as an endorsement.
- Do not reference the listing PR; it is not relevant to that audience.
- On a misrouted Q&A, name the canonical thread too, so the conversation converges there.
- Flag to the human that pointing at a young extension in public is their call.

Never auto-post comments or merge PRs — recommendations and drafts only.
