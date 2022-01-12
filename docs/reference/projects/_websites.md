
## Navbar

Options that define the top navigation bar for a {{< meta project-type >}} For example:

```yaml
---
{{< meta project-type >}}:
  navbar:
    search: true
---
```

::: {#table-navbar}
:::

### Navbar Items

Navbar items appear in the `left` or `right` key of `navbar` definitions. For example:

```yaml
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

```yaml
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

```yaml
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




