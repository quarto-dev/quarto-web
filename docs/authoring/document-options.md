---
title: Document Options
format: html
---

Quarto supports a number of global document options that allow you to customize how documents are rendered (e.g. section numbering, table of contents, etc.). This article summarizes those options.

## Format

The most important option is the format to render to (e.g. HTML, PDF, etc.). This is specified using the `format` key. For example:

``` {.yaml}
format: pdf
```

You can also specify more than one format, as well as options that apply to only a given format. For example, here we provide some format-specific options:

``` {.yaml}
format:
  html:
    html-math-method: katex
  pdf:
    documentclass: report
```

## Section Numbering

Use the `number-sections` option to number section headings in the output document. For example:

``` {.yaml}
number-sections: true
```

Use the `number-depth` option to specify the deepest level of heading to add numbers to (by default all headings are numbered). For example:

``` {.yaml}
number-depth: 3
```

To exclude an individual heading from numbering, add the `.unnumbered` class to it:

``` {.markdown}
### More Options {.unnumbered}
```

## Table of Contents

Use the `toc` option to include an automatically generated table of contents in the output document. Use the `toc-depth` option to specify the number of section levels to include in the table of contents. The default is 3 (which means that level-1, 2, and 3 headings will be listed in the contents). For example:

``` {.markdown}
toc: true
toc-depth: 2
```

Note that HTML documents implement support for floating the table of contents to the right of the page. See the [Floating TOC](../output-formats/html-bootstrap.md#floating-toc) documentation for additional details.

If you want to exclude a heading from the table of contents, add both the `.unnumbered` and `.unlisted` classes to it:

``` {.markdown}
### More Options {.unnumbered .unlisted}
```

## Syntax Highlighting

Pandoc will automatically highlight syntax in [fenced code blocks](https://pandoc.org/MANUAL.html#fenced-code-blocks) that are marked with a language name. Currently highlighting is supported only for HTML, EPUB, Docx, Ms, and LaTeX/PDF output. To see a list of language names that pandoc will recognize, type `pandoc --list-highlight-languages`.

You can specify the code highlighting style using `highlight-style` and specifying one of the supported themes. Supported themes include all the themes included in Pandoc (pygments, tango, espresso, zenburn, kate, monochrome, breezedark, haddock) as well as an additional set of extended themes here:

<https://github.com/quarto-dev/quarto-cli/tree/main/src/resources/pandoc/highlight-styles>

For example:

``` {.yaml}
highlight-style: github
```

Highlighting themes can provide either a single highlighting definition or two definitions, one optimized for a light colored background and another optimized for a dark color background. When available, Quarto will automatically select the appropriate style based upon the code chunk background color's darkness. Users may always opt to specify the full name (e.g. `atom-one-dark`) to bypass this automatic behavior.

By default, code is highlighted using the `arrow` theme. We've additionally introduced the `arrow-dark` theme which is designed to provide beautiful, accessible highlighting against dark backgrounds.

Examples of some light and dark themes:

#### Arrow

::: {.tabset}
#### Light

![](images/arrow.png)

#### Dark

![](images/arrow-dark.png)
:::

#### Ayu

::: {.tabset}
#### Light

![](images/ayu.png)

#### Dark

![](images/ayu-dark.png)
:::

## Includes

If you want to include additional content in your document from another file, you can use the `include-in` options:

| Option                | Description                                                                                                                                                                                                                              |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `include-in-header`   | Include contents of *file*, verbatim, at the end of the header. This can be used, for example, to include special CSS or JavaScript in HTML documents or to inject commands into the LaTeX preamble.                                     |
| `include-before-body` | Include contents of *file*, verbatim, at the beginning of the document body (e.g. after the `<body>` tag in HTML, or the `\begin{document}` command in LaTeX). This can be used to include navigation bars or banners in HTML documents. |
| `include-after-body`  | Include contents of *file*, verbatim, at the end of the document body (before the `</body>` tag in HTML, or the `\end{document}` command in LaTeX).                                                                                      |

You can specify a single file for multiple files for each of these options. For example:

``` {.yaml}
format:
  html:
    include-in-header:
      - analytics.html
      - comments.html
    include-before-body: header.html
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
