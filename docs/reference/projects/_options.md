Options that define the type, render targets, and output of a project. Project options are specified under the `project` key. For example:

``` yaml
---
project:
  type: {{< meta project-type >}}
  output-dir: {{< meta project-output-dir >}}
---
```

::: {#table-project}
:::

### Preview

Specify options that control the behavior of `quarto preview` within the `preview` key. For example:

``` yaml
---
project:
  type: {{< meta project-type >}}
  output-dir: {{< meta project-output-dir >}}
  preview:
    port: 4200
    browser: false
---
```

Available `preview` options include:

::: {#table-preview}
:::
