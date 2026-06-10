# quarto-web Workflow

## Stable → Prerelease

1. PRs target `main` (stable/released docs)
2. On merge, `port-to-prerelease.yml` (korthout/backport-action) auto-creates a cherry-pick PR to `prerelease`
3. Prerelease-specific changes (e.g., v1.10 features) are layered in a follow-up PR after the backport merges

Always PR to `main` first for shared content. Never PR directly to `prerelease` for changes that apply to both stable and prerelease.

## `_freeze/` Updates

Any source change to a `.qmd` that has a `_freeze/` entry — even non-executable content like text or includes — invalidates the freeze hash. A stale hash causes the deploy preview to show the old cached page.

**Wrong reasoning to avoid:** "I only added markdown, not executable code, so no `_freeze/` update needed." The cache is per-page, not per-cell.

**Before committing:** `git diff HEAD -- _freeze/` — every edited frozen `.qmd` must have a corresponding `_freeze/` change. (Use `HEAD` to show both staged and unstaged changes.)

**If the freeze-check hook blocks a commit or push:** run `quarto render <file.qmd>` then commit the updated `_freeze/` output alongside the source change.

## Avoid duplicating doc content

When a plan touches 3+ pages with similar prose, **scan for an existing shared-partial / include pattern in the repo before locking duplication into the plan.** quarto-web uses Quarto's `{{< include _foo.md >}}` shortcode extensively — examples in `docs/computations/` (e.g. `_jupyter-rendering.md`, `_jupyter-install.md`, `_caching-more.md`), `docs/tools/` (`_chunk-options.md`), and `docs/get-started/authoring/` (`_text-editor.md`). Many partials pair `{{< include >}}` with `.content-visible when-meta="..."` so the same source renders differently per consuming page.

Per-page tuning is fine when each page's audience genuinely needs different framing (issue-thread #13514 endorsed per-language snippets in computation pages for this exact reason). But near-identical prose across pages — same sentences with minor word swaps — is a signal to extract into a shared `_*.md` partial.

Apply the check at plan-writing time. After writing the plan, scan it for near-duplicate paragraphs across files and propose extraction before the user has to point it out.

