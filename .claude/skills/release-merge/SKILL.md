---
name: release-merge
description: Use when merging the quarto-web prerelease branch into main for a Quarto release (publishing new stable docs), or when a release-time merge hits conflicts, backport-action noise, or _freeze hook failures. Not for ordinary PRs to main.
---

# Release merge (prerelease → main)

## Overview

At release time the `prerelease` branch is merged into `main` to publish the new stable docs. Rare operation, with a few quarto-web-specific hazards worth knowing before you start.

## When to use

- Doing a Quarto release — bringing new-stable docs onto `main`.
- A release merge hit conflicts, backport-action noise, or a `_freeze` hook block.

Not for ordinary content PRs — those follow the normal Stable → Prerelease flow (see `.claude/rules/quarto-web-workflow.md`).

## Canonical checklist

The authoritative release steps live in quarto-cli `dev-docs/checklist-make-a-new-quarto-release.md`. This skill carries the commands for its step 9 (the quarto-web merge); quarto-cli's `make-release` skill hands that step to it. When the checklist and this skill disagree, the checklist wins: report the mismatch.

## Steps

1. Choose the merge path — direct push, or a PR to `main` for CI build verification.
2. Drift check: cherry-pick onto `prerelease` the `main` commits it never received.
3. Check `cli-info.json` on `prerelease`; regenerate it there only if its version is not the stable version.
4. Merge and resolve conflicts per the conflict table.
5. Verify `git diff --stat upstream/prerelease HEAD` lists only `_axe-report.md` (plus `_quarto.yml` if checklist step 6 flipped the profile group), then push.
6. Hand back to checklist step 10: merge back into `prerelease`, then the Axe Report.

## Details

**REQUIRED:** read `references/release-merge.md` before executing — it carries the commands, conflict table, label, merge-commit, and freeze specifics.
