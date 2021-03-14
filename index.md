---
format: 
  html:
    toc: false
---

Quarto is an academic, scientific, and technical publishing system built on [Pandoc](https://pandoc.org).

In addition to the core capabilities of Pandoc, Quarto includes:

1.  Support for embedding output from Python, R, and Julia via integration with [Jupyter](https://jupyter.org/) and [knitr](https://yihui.org/knitr/) .
2.  A project system for rendering groups of documents at once.
3.  Flexible ways to specify rendering options, including project-wide options and per-format options.
4.  Cross references for figures, tables, equations, sections, listings, proofs, and more.
5.  Sophisticated layout for panels of figures, tables, and other content.
6.  HTML output based on [Bootstrap](https://getbootstrap.com/) (including support for [Bootswatch](https://bootswatch.com/) themes).
7.  Automatic installation of required LaTeX packages when rendering PDF output.

The overall design of Quarto is influenced heavily by [R Markdown](https://rmarkdown.rstudio.com/), however unlike R Markdown the architecture is language agnostic. In it's current iteration, Quarto can render plain markdown, Rmd documents, and Jupyter notebooks.

Quarto is currently in alpha development, so not generally recommended for everyday use!

## Installation

You can install an alpha-build of the Quarto CLI (command-line interface) from here:

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

If you are a Python or Julia user, read the article on [Jupyter Markdown](jupyter-markdown.html) to learn how to use Quarto with Jupyter.

If you are an R user, read the [Rendering Rmds](rendering-rmds.html) article to learn how to render Rmd documents with Quarto.

If you are creating web content with Quarto, see the article on [HTML Themes](html-themes.html) to learn how to customize the appearance of your documents.

Advanced features of Quarto are covered in these articles:

-   [Cross References](cross-references.html) describes how to create numbered references to figures, tables, equations, sections, listings, etc.

-   [Figures and Layout](figures-and-layout.html) documents Quarto's layout primitives for creating figure panels, side-by-side tables, etc.

-   [PDFs and LaTeX](pdfs-and-latex.html) explains automatic TeX package installation as well as how to install and use [TinyTeX](https://yihui.org/tinytex/).

-   [Quarto Projects](quarto-projects.html) covers how to share YAML metadata options across documents and render all of the documents in directory with a single command.
