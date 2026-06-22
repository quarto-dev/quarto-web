---
paths:
  - "docs/**/*.qmd"
---

# Docs Authoring

## Prerelease shortcodes

When documenting a feature introduced in a specific Quarto version, add at the top of the section:

```
{{< prerelease-callout X.Y >}}
```

Shows a pre-release callout before X.Y ships, disappears automatically after — never remove them manually. For blog posts use `type="blog"`. For URLs use `{{< prerelease-docs-url X.Y >}}`. See `_extensions/prerelease/` for details.

## Format name convention

When referring to a Quarto format by its identifier (the value used in `format:` YAML), use inline code with lowercase: `` `html` ``, `` `pdf` ``, `` `typst` ``, `` `docx` ``, etc. Use prose (HTML, PDF, Typst) only when referring to the file type generically — not the format identifier. This avoids ambiguity (e.g., "PDF" could describe output from both `format: pdf` and `format: typst`).
