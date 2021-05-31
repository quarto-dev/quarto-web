---
title: PDF Basics
format: html
---

## Overview

Use the `pdf` format to create PDF output. For example:

``` {.yaml}
---
title: "My document"
format:
  pdf:
    toc: true
    documentclass: report
    colorlinks: true
---
```

This example highlights a few of the options available for PDF output. This article covers these and other options in detail.

::: {.callout-note}
Note that while we will focus here exclusively on the use LaTeX to create PDFs, Pandoc also has support for creating PDFs using ConTeXt, roff ms, or HTML (via wkhtmltopdf). See the Pandoc documentation on [Creating a PDF](https://pandoc.org/MANUAL.html#creating-a-pdf) for additional details.
:::

### Prerequisites

In order to create PDFs you will need to install a recent distribution of TeX. We recommend the use of TinyTeX (which is based on TexLive), which you can install with the following command:

``` {.bash}
$ quarto install tinytex
```

See the article on [PDF Engines](pdf-engine.md) for details on using other TeX distributions and PDF compilation engines.

```{.include}
../authoring/_document-options-begin.md
```

## Output Options

There are numerous options available for customizing PDF output, including:

-   Specifying document classes and their options

-   Including lists of figures and tables

-   Using the `geometry` and `hyperref` packages

-   Numerous options for customizing fonts and colors.

For example, here we use a few of these options:

``` {.yaml}
---
title: "My Document"
format: 
  pdf: 
    documentclass: report
    classoption: [twocolumn, landscape]
    lof: true
    lot: true
    geometry:
      - top=30mm
      - left=20mm
      - heightrounded
    fontfamily: libertinus
    colorlinks: true
---
```

See the Pandoc documentation on metadata [variables for LaTeX](https://pandoc.org/MANUAL.html#variables-for-latex) for documentation on all available options.

## Citations

When creating PDFs, you can choose to use either the default Pandoc [citation handling](https://pandoc.org/MANUAL.html#citations) based on citeproc, or alternatively use [natbib](https://ctan.org/pkg/natbib) or [BibLaTeX](https://ctan.org/pkg/biblatex). This can be controlled using the `cite-method` option. For example:

``` {.yaml}
format:
  pdf: 
    cite-method: biblatex
```

The default is to use `citeproc` (Pandoc's built in citation processor).

See the main article on using [Citations](../authoring/footnotes-and-citations.md) with Quarto for additional details on citation syntax, available bibliography formats, etc.

### Options

When using natbib or biblatex you can specify the following additional options to affect how bibliographies are rendered:

| Option          | Description                  |
|-----------------|------------------------------|
| biblatexoptions | List of options for biblatex |
| natbiboptions   | List of options for natbib   |
| biblio-title    | Title for bibliography       |
| biblio-style    | Style for bibliography       |

## Raw LaTeX

When creating a PDF document, Pandoc allows the use of [raw LaTeX](https://pandoc.org/MANUAL.html#extension-raw_tex) directives intermixed with markdown. For example:

``` {.tex}
\begin{tabular}{|l|l|}\hline
Age & Frequency \\ \hline
18--25  & 15 \\
26--35  & 33 \\
36--45  & 22 \\ \hline
\end{tabular}
```

Raw LaTeX commands will be preserved and passed unchanged to the LaTeX writer.

::: {.callout-warning}
While it's very convenient to use raw LaTeX, raw LaTeX is ignored when rendering to other formats like HTML and MS Word. If you plan on rendering to other formats then the example above would be better written using native [markdown tables](../authoring/markdown-basics.md#tables).
:::

In some cases raw LaTeX will require additional LaTeX packages. The [LaTeX Includes] section below describes how to include `\usepackage` commands for these packages in your document.

## LaTeX Includes

If you want to include additional content in your document from another file, you can use the `include-in` options:

+-------------------------+--------------------------------------------------------------------------------------------------------------------------+
| Option                  | Description                                                                                                              |
+=========================+==========================================================================================================================+
| `include-in-header`     | Include contents of *file*, verbatim, into the LaTeX preamble.                                                           |
+-------------------------+--------------------------------------------------------------------------------------------------------------------------+
| `include-before-body`   | Include contents of *file*, verbatim, at the beginning of the document body (e.g. after the `\begin{document}` command). |
+-------------------------+--------------------------------------------------------------------------------------------------------------------------+
| `include-after-body`    | Include contents of *file*, verbatim, at the end of the document body (before the the `\end{document}`).                 |
+-------------------------+--------------------------------------------------------------------------------------------------------------------------+

You can specify a single file for multiple files for each of these options. For example:

``` {.yaml}
format:
  html:
    include-in-header:
      - packages.tex
      - macros.tex
    include-before-body: before.tex
```

There are also a set of options you can use for inline includes (i.e. specifying the included content right within YAML):

| Option            | Description                             |
|-------------------|-----------------------------------------|
| `header-includes` | Inline version of `include-in-header`   |
| `include-before`  | Inline version of `include-before-body` |
| `include-after`   | Inline version `include-after-body`     |

For example:

``` {.yaml}
format:
  pdf: 
    header-includes: |
      \usepackage{eplain}
      \usepackage{easy-todo}
```

Note the use of the `|` character on the line with `header-includes` to indicate that the value is a multi-line string.

If you don't already have these packages installed locally, then Quarto will automatically install them during rendering of the document.
