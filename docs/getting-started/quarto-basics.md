---
title: "Quarto Basics"
description: "Quarto is a publishing system used to create documents in a wide variety of formats including HTML, PDF, Office (docx and pptx), OpenOffice, JATS, and many more."
format: html
---

## Overview

Quarto is a publishing system used to create documents in a wide variety of formats including HTML, PDF, Office (docx and pptx), OpenOffice, JATS, and [many more](https://pandoc.org/).

You author these documents using [markdown](https://pandoc.org/MANUAL.html#pandocs-markdown), an easy to write plain-text format. You then optionally add code (e.g. Python, R, Julia, etc.) to the documents to dynamically create figures, tables, etc. and then **render** the documents to their final format using Quarto.

## Markdown Inputs

There are three types of markdown input files that Quarto can render:

1.  Plain markdown (with no embedded code)

2.  Markdown with embedded code chunks

3.  Jupyter notebooks which have a combination of markdown and code cells

R users will typically use the second approach (in fact, existing .Rmd files can be rendered directly with Quarto).

Jupyter users will user either the second or third approach, depending on whether they prefer to work in a text editor or in the standard notebook user interface.

## Rendering Output

Use the `quarto render` command to transform a markdown input file into HTML, a PDF, or any of the other supported output formats. Here are examples of rendering the input types described above:

``` bash
quarto render document.md
quarto render document.qmd
quarto render document.ipynb
```

For plain markdown, the document is sent straight to Pandoc. For markdown with executable code, it is first processed by [Jupyter](https://jupyter.org) or [Knitr](https://yihui.name/knitr), then passed on to Pandoc.

By default, Quarto renders to HTML, however any of Pandoc's over 40 [output formats](https://pandoc.org/) are supported. For example:

``` bash
quarto render document.md --to pdf
quarto render document.qmd --to odt
quarto render document.ipynb --to docx
```

Pandoc supports a wide variety of [command line options](https://pandoc.org/MANUAL.html#general-options) and all of these options are supported by `quarto render`. For example:

``` bash
quarto render document.ipynb --to pdf --toc --number-sections
```

We'll talk in more depth about the mechanics of using code chunks in the articles on [Running Code](../computations/running-code.md). However, for the remainder of this article we'll just focus on things applicable to all markdown input types whether they contain code or not.

## YAML Options

Note that while it is possible to pass many options via the command line, it's often much more convenient to provide these options within the document itself as YAML front matter. For example:

``` yaml
---
title: "My Document"
author: "Jane Doe"
format: pdf
toc: true
number-sections: true
---
```

If you do this then the following command is equivalent to the previous example (but no options are provided on the command line b/c they are already defined in YAML):

``` bash
quarto render document.qmd
```

Note that in this case rendering with no explicit `--to` argument results in a PDF, since `format: pdf` is specified in YAML.

Options may include any of the defined Pandoc metadata [variables](https://pandoc.org/MANUAL.html#variables) or [defaults](https://pandoc.org/MANUAL.html#default-files). For example, here we take advantage of quite a few more options for PDF generation:

``` yaml
---
title: "My Document"
author: "Jane Doe"
format: pdf
toc: true
number-sections: true
documentclass: report
geometry:
  - top=30mm
  - left=20mm
  - heightrounded
links-as-notes: true
highlight-style: pygments
---
```

## Multiple Formats

The above example includes a simple `format: pdf` value to set the default format. It's also possible to provide multiple formats along with YAML options set on a per-format basis. For example, this document defines HTML, PDF, and Word output:

``` yaml
---
title: "My Document"
author: "Jane Doe"
toc: true
toc-depth: 2
format:
  html:
    max-width: 800px
    fontsize: 18px
    html-math-method: katex
  pdf:
    documentclass: report
    margin-left: 30mm
    margin-right: 30mm
  docx:
    number-sections: true
    reference-docx: mytemplate.docx
---
```

Note that the `toc` and `toc-depth` options are shared across all formats, and the options listed below `html`, `pdf`, and `docx` are only applied to their respective formats.

If you render this document without a `--to` argument, it will be rendered as `html` since that is the first format listed in the file. To render as another format just provide an explicit `--to` argument:

``` bash
quarto render document.qmd # will render to html
quarto render document.qmd --to pdf
quarto render document.qmd --to docx
```

You can learn about the available options for each format in the Pandoc documentation on metadata [variables](https://pandoc.org/MANUAL.html#variables) and [defaults](https://pandoc.org/MANUAL.html#default-files).

Note that you can share format options across a set of documents using [Quarto Projects](quarto-projects.html).

## Learning More

[Running Code](../computations/running-code.md) covers creating computational documents with Quarto in more depth, including how to use Quarto with [JupyterLab](../computations/using-jupyter-lab.md) and [RStudio](../computations/using-rstudio.md).

The [Authoring](../authoring/markdown-basics.md) section describes the capabilities of Pandoc markdown, as well as Quarto extensions for [Cross References](../authoring/cross-references.md), [Figures and Layout](../authoring/figures-and-layout.md), and [Callout Blocks](../authoring/callouts.md).

The output formats section provides additional details on creating [HTML](../output-formats/html-basics.qmd), [PDF](../output-formats/pdf-basics.md), and [MS Word](../output-formats/ms-word.md) documents, as well as describes a few special output types including [Presentations](../output-formats/presentations.md), [EPUBs](../output-formats/epub.md), and pages in [Hugo](../output-formats/hugo.md) static sites.

[Creating a Website](../websites/website-basics.md) and [Creating a Book](../books/book-basics.md) describe some special Quarto project types.
