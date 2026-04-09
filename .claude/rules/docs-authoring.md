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
