---
paths:
  - "_axe-baseline.json"
---

# Axe baseline

`quarto call axe` reads `_axe-baseline.json` with a strict schema. Do not add keys that the schema does not allow, for example comments.

## Notes

Write each `note` in this format:

```
<type>: <issue-ref>. <Description>.
```

- `<type>` is `upstream`, `third-party`, `false-positive`, or `intentional`.
- For `third-party`, put the library name after the type: `third-party: Observable Plot, observablehq/plot#2018.`
- Write every issue reference as `org/repo#number`, also inside the description. Do not write `quarto-cli#123` or `#123`.
- If no issue exists, write `no upstream issue` in place of the reference.
- Do not put the description in parentheses.
- Do not use Markdown links or URLs. An extension makes links from the `org/repo#number` text.
- Give the cause and the condition to remove the entry. Do not add commentary, for example "open since 2023" or "by design, not oversight".
- If the entry is limited to some pages, give the reason: the signature that also matches content that quarto-web can fix.

## Pages

- Use `"pages": []` (all pages) only when the selector matches nothing but the third-party or Quarto markup.
- If the selector is generic, for example `pre`, `th`, `a`, or `.collapsed`, list the pages.

## Order

The scanner does not use the order of the entries. For human readers, keep entries grouped by owner, in the order: upstream Quarto by issue, then reveal.js, then each third-party library, then false positives, then intentional examples.

## Intentional examples

Use `intentional` only when the author chose the violation as part of the lesson. For example, a linked image with no alt text on a page that teaches what happens when alt text is missing ([WCAG 1.1.1 Non-text Content](https://www.w3.org/TR/WCAG22/#non-text-content)).

These are not intentional: a defect in Quarto or in a library, a false positive, or a fix that nobody has done yet. Fix them, report them upstream, or use the type that applies.

To record an intentional example:

1. In the source, add an `<!-- a11y: ... -->` comment next to the example. See "Keep examples in sync with their output" in `_style-guide.md`.
2. Add a baseline entry with `intentional:` in the note. Always list the pages.

A baseline entry matches a signature on a page. It cannot tell one example from an identical element on the same page. If you add an element that has the same signature to that page, the baseline hides its finding. Keep the `pages` list accurate.

There is no source-side marker (a class that the scanner ignores). One was considered and not built in 2026-10, because quarto.org had only 6 such findings, all on `docs/authoring/markdown-basics.qmd`. Propose it again only if intentional examples become common enough that page-level entries hide real findings.
