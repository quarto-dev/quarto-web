---
title: "Websites"
format: html
---

::: {.callout-tip}
## Learn more
See the full guide on [Creating a Website](https://quarto.org/docs/websites/).
:::

-   Dev Server

-   Navigation

-   Resource Discovery

-   Search/Sitemap

## Projects

Quarto Projects are a generic facility not tied to websites, that nevertheless provide some important features for creating websites and books:

-   A way to render all or some of the files in a directory with a single command.

-   A way to share YAML configuration across multiple files.

-   The ability to redirect output artifacts to another directory.

-   The ability to freeze rendered output (e.g. don't re-execute an .Rmd or .ipynb) either unqualified or tied to the content of the source file (via hash).

For example, here is a `_quarto.yml` config file for a website project:

``` {.yaml}
project:
  title: "Quarto Demo"
  type: website
  output-dir: _site

format:
  html:
    theme: cosmo
    toc: true
    
freeze: auto
```

-   Render files (globs)

```{=html}
<!-- -->
```
-   Execution directory and path resolution
