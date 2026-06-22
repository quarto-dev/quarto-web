# Prerelease Extension

Version-aware shortcodes for prerelease content on quarto-web. Both shortcodes use the `version` key from `_quarto.yml` (or `_quarto-prerelease-docs.yml` on the prerelease profile) to determine whether a feature version has been released.

## Shortcodes

### `prerelease-docs-url`

Returns `"prerelease."` when the referenced version's docs live on prerelease.quarto.org, or `""` when they're on quarto.org. Use in link URLs:

```markdown
[documentation](https://{{< prerelease-docs-url 1.9 >}}quarto.org/docs/feature.html)
```

### `prerelease-callout`

Shows a version-aware callout note. Two modes:

**Feature docs** (default) — callout disappears after release:

```markdown
{{< prerelease-callout 1.9 >}}
```

- Unreleased: shows "Pre-release Feature" callout with link to prerelease download
- Released: shows nothing

**Blog posts** (`type="blog"`) — callout text changes after release:

```markdown
{{< prerelease-callout 1.9 type="blog" >}}
```

- Unreleased: shows "Pre-release Feature" callout with link to prerelease download
- Released: shows "Quarto X.Y Feature" callout with link to stable download page

## Version comparison logic

On the **main site** (`version` = current stable release): a feature is unreleased when `ref_version > site_version`.

On the **prerelease site** (profile `prerelease-docs`, `version` = current prerelease cycle): a feature is unreleased when `ref_version >= site_version`.

The `>=` vs `>` difference handles the fact that the prerelease site's version equals the in-progress release, while main's version equals the last stable release.

### Example scenarios (feature docs)

| Phase | Site | `version` | ref | Unreleased? | Output |
|---|---|---|---|---|---|
| 1.9 in dev | main | 1.8 | 1.9 | 1.9 > 1.8 ✓ | Pre-release callout |
| 1.9 in dev | prerelease | 1.9 | 1.9 | 1.9 >= 1.9 ✓ | Pre-release callout |
| 1.9 released | main | 1.9 | 1.9 | 1.9 > 1.9 ✗ | Nothing |
| 1.9 released | prerelease | 2.0 | 1.9 | 1.9 >= 2.0 ✗ | Nothing |
