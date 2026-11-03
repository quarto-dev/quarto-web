# Release merge — details

## Merge paths

Two ways to merge `prerelease` into `main`:

- **Direct push to `main`** (the quarto-cli checklist default). A direct push does not trigger `port-to-prerelease.yml`, so no backport PR is created.
- **PR to `main`** — lets CI (`build-deploy-preview`) verify the site builds before it lands. Label the PR `no-sync-prerelease` so the backport action does not try to cherry-pick the whole prerelease history back onto `prerelease` (it fails with a noisy comment otherwise). Merge with a **merge commit, not squash**, to preserve the merge topology so the branches don't re-diverge.

## Resolving conflicts

| Path | Keep |
|---|---|
| `_axe-report.md` | `main` |
| `_freeze/` entries | whatever happens to their page, deletions included |
| everything else (`_quarto.yml`, pages, `docs/cli/cli-info.json`, `_axe-baseline.json`) | `prerelease`, deletions included |

Expect version-string and `quarto check` sample-output conflicts; the `prerelease` side carries the new version.

After committing the merge, `git diff --stat upstream/prerelease HEAD` must list only `_axe-report.md`. Any other path is drift between the branches.

## _axe-report.md

The weekly axe scan (`axe-report.yml`) commits `_axe-report.md` to both `main` and `prerelease`, so every release merge conflicts on it. Keep the `main` version. After the merge, run the Axe Report workflow manually so both reports match the new sites.

## cli-info.json

`docs/cli/cli-info.json` is generated, not hand-edited. Before the merge, check its `version` on `prerelease`. If it already equals the stable version (`1.x.N`), the merge keeps the `prerelease` side as is. Otherwise regenerate it on `prerelease` first with `quarto dev-call cli-info` from a `1.x.N` binary and push that, then merge.

## Freeze on a release merge

A `_freeze/` entry follows its page (table above). If the freeze-check hook blocks an intentional deletion, see the `_freeze/` section of `.claude/rules/quarto-web-workflow.md`.

## After merging

Sync `main` back into `prerelease` per the checklist.
