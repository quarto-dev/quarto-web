# Release merge — details

Commands for step 9 of quarto-cli `dev-docs/checklist-make-a-new-quarto-release.md`. The checklist says what to do and when to stop; when it and this file disagree, the checklist wins: report the mismatch.

## Merge paths

Two ways to merge `prerelease` into `main`:

- **Direct push to `main`** (the quarto-cli checklist default). A direct push does not trigger `port-to-prerelease.yml`, so no backport PR is created.
- **PR to `main`** — lets CI (`build-deploy-preview`) verify the site builds before it lands. Label the PR `no-sync-prerelease` so the backport action does not try to cherry-pick the whole prerelease history back onto `prerelease` (it fails with a noisy comment otherwise). Merge with a **merge commit, not squash**, to preserve the merge topology so the branches don't re-diverge.

## Variables

Run in bash (Git Bash on Windows). When `make-release` drives the release, its variables file already defines these; `source` it. Otherwise write this block to a file in a temp dir and `source` it in every tool call.

```bash
export MSYS_NO_PATHCONV=1                 # Git Bash: keep "ref:path" arguments intact
REL=<1.x>; TAG=<v1.x.N>; STABLE=${TAG#v}  # release minor and the promoted tag, e.g. REL=1.11 TAG=v1.11.9
QW='<quarto-web clone>'; SCRATCH='<temp dir>'
P="$QW.worktrees/release-$REL-prerelease"; M="$QW.worktrees/release-$REL-main"
```

Guarded push of worktree `<wt>` to branch `<b>` (a GATE: confirm with the user first):

```bash
git -C "<wt>" fetch upstream
git -C "<wt>" merge-base --is-ancestor upstream/<b> HEAD || { echo "STOP: upstream/<b> moved"; exit 1; }
git -C "<wt>" push upstream HEAD:<b>
git -C "<wt>" ls-remote --heads upstream <b>      # must equal: git -C "<wt>" rev-parse HEAD
```

Build check after pushing `<sha>` to `<b>`: take the run whose `headSha` is `<sha>` from `gh run list --repo quarto-dev/quarto-web --workflow publish.yml --branch <b> --limit 5 --json databaseId,headSha,status,conclusion`, then `gh run watch <id> --repo quarto-dev/quarto-web --exit-status`.

## Before the merge

Drift: commits on `main` that never reached `prerelease`.

```bash
git -C "$QW" fetch upstream
git -C "$QW" log upstream/main..upstream/prerelease --format=%B | grep -o 'cherry picked from commit [0-9a-f]*' | awk '{print $5}' | sort -u > "$SCRATCH/ported.txt"
git -C "$QW" log upstream/prerelease..upstream/main --no-merges --format='%H %an %s' | grep -vFf "$SCRATCH/ported.txt"
git -C "$QW" log upstream/prerelease --oneline --fixed-strings --grep='<subject or #PR>'   # per remaining commit
```

Ignore bot commits (`Apply automatic changes`, `Update the axe accessibility report`, `Update downloads`) and the step-6 profile flip. List every other remaining commit with its diff stat and ask the user: cherry-pick onto `prerelease`, or leave as intentional divergence. Cherry-picks: in `$P`, `git cherry-pick -x <sha>`, guarded push to `prerelease`, build check.

CLI reference: `docs/cli/cli-info.json` is generated, not hand-edited.

```bash
git -C "$QW" show upstream/prerelease:docs/cli/cli-info.json | jq -r .version     # $STABLE: nothing to do
```

Anything else: stop and ask the user for a `$STABLE` binary (`qvm`). In `$P`, run `quarto dev-call cli-info > docs/cli/cli-info.json` with it, commit as `Regenerate CLI reference for $TAG`, guarded push to `prerelease`, build check. The merge then takes `prerelease`'s file like any other.

## Merge and resolve

| Path | Keep |
|---|---|
| `_axe-report.md` | `main` |
| `_freeze/` entries | whatever happens to their page, deletions included |
| everything else (`_quarto.yml`, pages, `docs/cli/cli-info.json`, `_axe-baseline.json`) | `prerelease`, deletions included |

Exception: if checklist step 6 flipped the profile group, keep `main`'s `[prerelease, rc]` hunk of `_quarto.yml`.

The weekly axe scan (`axe-report.yml`) commits `_axe-report.md` to both branches, so every release merge conflicts on it. Expect version-string and `quarto check` sample-output conflicts too; the `prerelease` side carries the new version.

Reuse `$M` if step 6 created it, after `git -C "$M" fetch upstream && git -C "$M" merge --ff-only upstream/main`.

```bash
git -C "$QW" worktree add "$M" upstream/main -b "release/$REL-main" --no-track
git -C "$M" merge upstream/prerelease
git -C "$M" diff --name-only --diff-filter=U          # conflicted paths
git -C "$M" status --short | grep -E '^(DU|UD) '      # modify/delete conflicts
git -C "$M" checkout --ours -- _axe-report.md && git -C "$M" add _axe-report.md
git -C "$M" checkout --theirs -- <each other conflicted path> && git -C "$M" add <path>
# modify/delete: if the path is absent on prerelease, git -C "$M" rm <path>; else checkout --theirs as above
git -C "$M" commit --no-edit
git -C "$M" diff --stat upstream/prerelease HEAD      # only _axe-report.md (plus _quarto.yml if step 6 flipped)
git -C "$M" show HEAD:_quarto.yml | grep '^version'   # version: '$REL'
```

Any other path in the `diff --stat` is drift the check missed: stop and report.

If the freeze-check hook blocks an intentional `_freeze/` deletion, see the `_freeze/` section of `.claude/rules/quarto-web-workflow.md`.

Then guarded push of `$M` to `main`, build check.

## After merging

Continue with checklist step 10: merge `main` back into `prerelease`, tag, and only after the merge-back push run the Axe Report workflow. It commits to both branches, so running it earlier breaks the fast-forward.
