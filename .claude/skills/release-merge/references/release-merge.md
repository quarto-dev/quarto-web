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

A release merge can surface `_freeze/` conflicts. Resolve them per the `_freeze/` section of `.claude/rules/quarto-web-workflow.md` — most often it's a markdown-engine page carrying a vestigial freeze entry to delete.

## After merging

Sync `main` back into `prerelease` per the checklist.
