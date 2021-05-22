---
title: Welcome to Quarto
subtitle: A scientific and technical publishing system built on Pandoc
format: html
---

## Introduction

Quarto is a scientific and technical markdown publishing system built on [Pandoc](https://pandoc.org). In addition to the core capabilities of Pandoc, Quarto includes:

1.  Support for embedding output from Python, R, and Julia via integration with [Jupyter](https://jupyter.org/) and [knitr](https://yihui.org/knitr/) .
2.  A variety of extensions to Pandoc markdown useful for technical writing including callouts (admonitions), cross-references, sub-figures, layout panels, hover-able citations and footnotes, and more.
3.  A project system for rendering groups of documents at once, sharing options across documents, and producing aggregate output like books and websites.
4.  HTML output based on [Bootstrap](https://getbootstrap.com/) (including support for [Bootswatch](https://bootswatch.com/) themes).
5.  Automatic installation of required LaTeX packages when rendering PDF output.

The overall design of Quarto is influenced heavily by [R Markdown](https://rmarkdown.rstudio.com/), however unlike R Markdown the architecture is language agnostic. In it's current iteration, Quarto can render plain markdown, Jupyter Notebooks, and Knitr (Rmd) documents..

## Installation

You can install the Quarto CLI (command-line interface) from here:

<https://github.com/quarto-dev/quarto-cli/releases/latest>

You can verify that Quarto has been installed correctly with:

``` {.bash}
$ quarto help
```

To install the development version of the Quarto CLI, git clone this repo then run the configure script for your platform (`configure-linux.sh`, `configure-macos.sh`, or `configure-window.cmd`). For example:

``` {.bash}
$ git clone https://github.com/quarto-dev/quarto-cli
$ cd quarto-cli
$ ./configure-macos.sh
```

## Getting Started

See [Basic Usage](basic-usage.html) to learn the core mechanics of rendering markdown from the command line as well as how to specify different document formats.

See the article on [Jupyter and Knitr](computations.md) to learn more about creating computational documents with Quarto.

[Authoring Tools](authoring-tools.md) covers using Jupyter Lab, RStudio, or other text editors to author Quarto documents.

If you are creating HTML output, see the articles on [HTML Extensions](html-basics.md), [HTML w/ Bootstrap](html-bootstrap.Rmd), and the HTML [Theming System](html-themes.md).

Advanced features of Quarto are covered in these articles:

-   [Quarto Projects](quarto-projects.html) covers how to share YAML metadata options across documents and render all of the documents in directory with a single command. [Creating a Website](website-basics.md) and [Creating a Book](book-basics.md) describe some special project types.

```{=html}
<!-- -->
```
-   [Callout Blocks](callouts.md) outlines how to emphasize blocks of content (e.g. tips, notes, warning, etc.)

-   [Cross References](cross-references.html) describes how to create numbered references to figures, tables, equations, sections, listings, etc.

-   [Figures and Layout](figures-and-layout.html) documents Quarto's layout primitives for creating figure panels, side-by-side tables, etc.

-   [PDFs and LaTeX](pdfs-and-latex.html) explains automatic TeX package installation as well as how to install and use [TinyTeX](https://yihui.org/tinytex/).
