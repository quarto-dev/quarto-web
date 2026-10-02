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
