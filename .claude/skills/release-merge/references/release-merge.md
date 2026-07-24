# Release merge — details

## Merge paths

Two ways to merge `prerelease` into `main`:

- **Direct push to `main`** (the quarto-cli checklist default). A direct push does not trigger `port-to-prerelease.yml`, so no backport PR is created.
- **PR to `main`** — lets CI (`build-deploy-preview`) verify the site builds before it lands. Label the PR `no-sync-prerelease` so the backport action does not try to cherry-pick the whole prerelease history back onto `prerelease` (it fails with a noisy comment otherwise). Merge with a **merge commit, not squash**, to preserve the merge topology so the branches don't re-diverge.

## Resolving conflicts

Resolve to the **prerelease / new-stable** content, except where `main` is a strict superset (e.g. a direct-push edit that `prerelease` never received). Expect version-string and `quarto check` sample-output conflicts — take the new version.

## cli-info.json

`docs/cli/cli-info.json` is generated, not hand-edited. Regenerate it against the stable release tag after the merge; otherwise it ships the development/prerelease version content.

## Freeze on a release merge

The site is `freeze: true`, so `quarto render <file>` only *thaws* the existing freeze — it does not rewrite it.

Markdown-engine pages (mermaid/`dot` diagrams, no `r`/`python`/`julia` cells — confirm with `quarto inspect <file>`) produce no computational output, so an `execute-results/html.json` under `_freeze/` for such a page is vestigial: delete it rather than regenerate it. The check-freeze hook's `git show HEAD:` fallback currently re-flags an intentional freeze deletion, so clearing it needs the hook fix or a confirmed `--no-verify`.

## After merging

Sync `main` back into `prerelease` per the checklist.
