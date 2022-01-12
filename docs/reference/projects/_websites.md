## Navbar

Options that define the top navigation bar for a {{< meta project-type >}} For example:

``` yaml
---
{{< meta project-type >}}:
  navbar:
    search: true
---
```

::: {#table-navbar}
:::

## Nav Items

Nav items appear in the `left` or `right` key of `navbar` definitions. For example:

``` yaml
---
{{< meta project-type >}}:
  navbar:
    right:
      - icon: github
        href: https://github.com/
---
```

::: {#table-navitem}
:::

## Sidebar

Options that define the side navigation area for a {{< meta project-type >}}. For example:

``` yaml
---
{{< meta project-type >}}:
  sidebar:
    search: true
---
```

::: {#table-sidebar}
:::

### Sidebar Tools

Action buttons that appear on the sidebar. For example:

``` yaml
---
{{< meta project-type >}}:
  sidebar:
    tools:
      - icon: github
        href: https://github.com/
---
```

::: {#table-sidebartool}
:::

## Footer

{{< meta project-type-upper >}} page footer definition. For example:

``` yaml
---
{{< meta project-type >}}:
  page-footer:
    center: 
      - text: "About"
        href: about.qmd
      - text: "License"
        href: license.qmd
      - text: "Trademark"
        href: trademark.qmd
---
```

::: {#table-pagefooter}
:::

## Social

Social metadata is provided as a subkey of `{{< meta project-type >}}` options. You can specify `true` to generate social metadata using a set of default option, or specify one or more Twitter or Open Graph specific options as enumerated below. For example:

```yaml
---
{{< meta project-type >}}:
  open-graph: true
  twitter-card: 
    site: "@sitehandle"
---

```

### Twitter Card

::: {#table-twitter}
:::

### Open Graph

::: {#table-open-graph}
:::

