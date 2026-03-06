# Sub-plan: CI oxipng Workflow

Parent: `glistening-beaming-thunder.md` | Task #7

## Overview

GitHub Action that runs oxipng on changed PNG files in PRs. Ensures all committed PNGs are optimized without requiring contributors to install oxipng locally.

## Strategy

- **Locally:** `capture.js` runs `oxipng` if found in PATH, silently skips if not
- **CI:** Catches any unoptimized PNGs, commits optimized versions back to PR
- **Result:** Contributors never need oxipng installed — CI is the safety net

## Workflow: `.github/workflows/optimize-images.yml`

Based on [Simon Willison's approach](https://github.com/simonw/til/blob/main/github-actions/oxipng.md):

```yaml
name: Optimize PNG Images
on:
  pull_request:
    paths:
      - '**/*.png'

jobs:
  optimize:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.head_ref }}

      - name: Cache Oxipng
        uses: actions/cache@v4
        with:
          path: ~/.cargo/
          key: ${{ runner.os }}-cargo-oxipng

      - name: Install Oxipng
        run: which oxipng || cargo install oxipng

      - name: Get changed PNG files
        id: changed
        run: |
          git fetch origin ${{ github.base_ref }} --depth=1
          FILES=$(git diff --name-only origin/${{ github.base_ref }}...HEAD -- '*.png')
          echo "files<<EOF" >> "$GITHUB_OUTPUT"
          echo "$FILES" >> "$GITHUB_OUTPUT"
          echo "EOF" >> "$GITHUB_OUTPUT"

      - name: Optimize PNGs
        if: steps.changed.outputs.files != ''
        run: |
          echo "${{ steps.changed.outputs.files }}" | xargs oxipng -o 4 -i 0 --strip safe

      - name: Commit optimized images
        if: github.ref != 'refs/heads/main'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add -A '*.png'
          git diff --staged --quiet || git commit -m "ci: optimize PNG images with oxipng"
          git push
```

## Key oxipng Flags

- `-o 4` — highest recommended optimization level
- `-i 0` — remove interlacing (saves 25-50% file size)
- `--strip safe` — strip metadata that doesn't affect rendering

## Implementation Notes

- Check existing quarto-web CI workflows first — adapt to match their patterns
- The `actions/cache` on `~/.cargo/` avoids recompiling oxipng on every run (~1 min compile)
- `which oxipng || cargo install oxipng` — skip install if already cached
- Only commit back on PR branches, not on main
- Existing quarto-web workflows are in `.github/workflows/` — review before creating
