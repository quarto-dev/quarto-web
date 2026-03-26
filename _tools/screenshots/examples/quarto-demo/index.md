---
title: "Getting Started"
format: html
---

::: {.callout-tip}
## Learn more
See the full [Quarto Getting Started Guide](https://quarto.org/docs/get-started/).
:::

## Introduction

[Quarto](https://quarto.org) is an open-source scientific and technical publishing system built on [Pandoc](https://pandoc.org).

In addition to the core capabilities of Pandoc, Quarto includes:

1.  Support for embedding output from Python, R, and Julia via integration with [Jupyter](https://jupyter.org/) and [knitr](https://yihui.org/knitr/).
2.  A project system for rendering groups of documents at once.
3.  Flexible ways to specify rendering options, including project-wide options and per-format options.
4.  Cross references for figures, tables, equations, sections, listings, proofs, and more.
5.  Sophisticated layout for panels of figures, tables, and other content.
6.  HTML output based on [Bootstrap](https://getbootstrap.com/) (including support for [Bootswatch](https://bootswatch.com/) themes).
7.  Automatic installation of required LaTeX packages when rendering PDF output.

## Installation

Install the Quarto CLI from <https://quarto.org/docs/get-started/>.

You can verify that Quarto has been installed correctly with:

``` {.bash}
$ quarto check
```

## Demo Site

To run this demo site locally, first clone it from GitHub:

``` {.bash}
$ git clone https://github.com/quarto-dev/quarto-demo
$ cd quarto-demo
```

Then, install the Python dependencies using [uv](https://docs.astral.sh/uv/):

``` {.bash}
$ uv sync
```

Next, install the R dependencies:

``` {.r}
> renv::restore()
```

Finally, render or serve the site locally:

``` {.bash}
$ quarto render
$ quarto preview
```
