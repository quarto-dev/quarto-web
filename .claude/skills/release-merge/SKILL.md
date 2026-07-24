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

The authoritative release steps live in quarto-cli `dev-docs/checklist-make-a-new-quarto-release.md`. This skill covers only the quarto-web merge mechanics.

## Steps

1. Choose the merge path — direct push, or a PR to `main` for CI build verification.
2. Resolve conflicts to the new-stable content.
3. Handle `_freeze` conflicts.
4. Regenerate `cli-info.json` against the stable tag.
5. Sync `main` back into `prerelease`.

## Details

**REQUIRED:** read `references/release-merge.md` before executing — it carries the label, merge-commit, conflict, and freeze specifics.
