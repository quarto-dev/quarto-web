# quarto-web Workflow

## Stable → Prerelease

1. PRs target `main` (stable/released docs)
2. On merge, `port-to-prerelease.yml` (korthout/backport-action) auto-creates a cherry-pick PR to `prerelease`
3. Prerelease-specific changes (e.g., v1.10 features) are layered in a follow-up PR after the backport merges

Always PR to `main` first for shared content. Never PR directly to `prerelease` for changes that apply to both stable and prerelease.

