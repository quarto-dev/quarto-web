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

### Serve

If you are creating a project extension for another publishing system that includes its own preview server (for example, [Hugo](../../output-formats/hugo.qmd) or [Docusaurus](../../output-formats/docusaurus.qmd)) then use the `preview: serve` options to customize the behavior of the preview server.

::: {#table-serve}
:::

See the [Hugo](https://github.com/quarto-dev/quarto-cli/blob/main/src/resources/extensions/quarto/hugo/_extension.yml) and [Docusaurus](https://github.com/quarto-dev/quarto-cli/blob/main/src/resources/extensions/quarto/docusaurus/_extension.yml) extension source code for example usages of `preview: serve`.
