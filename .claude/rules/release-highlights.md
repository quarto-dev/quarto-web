---
paths:
  - "docs/prerelease/**/_highlights.qmd"
---

# Release Highlights

`_highlights.qmd` is a short summary. The download page shows it above the full changelog, so details belong in the changelog. Match the length of earlier releases' highlights (compare `docs/prerelease/1.11/_highlights.qmd`).

- Feature bullets: one or two sentences, linking to the docs section.
- A dependency update (Pandoc, Typst, Deno) is one line, such as "Pandoc updated to 3.13". Its user-facing additions go in that line or as feature bullets.
- "When upgrading" lists only changes users must act on: a render that now fails, or output that changes visibly. One sentence each, plus the fix when there is one.
- Edge cases, niche behavior changes and per-format details stay in the quarto-cli changelog.
- Before describing a behavior change that comes from a dependency, read the quarto-cli PR and changelog entry for it: Quarto often adjusts the result (a filter or finalizer), so the upstream release notes alone can misstate what users see.
