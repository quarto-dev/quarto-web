---
title: "Basic Usage"
format: html
---

## Rendering Documents

You can use the `quarto render` command to render HTML, PDF, Word and many other output formats from plain markdown, Rmd documents, Jupyter Markdown (a pure markdown representation of a notebook), or a Jupyter Notebook:

``` {.bash}
$ quarto render document.md
$ quarto render document.Rmd
$ quarto render jupyter.md
$ quarto render jupyter.ipynb
```

By default, Quarto renders to HTML, however any of Pandoc's over 40 [output formats](https://pandoc.org/) are supported. For example:

``` {.bash}
$ quarto render document.Rmd --to pdf
$ quarto render document.ipynb --to docx
```

Pandoc supports a wide variety of [command line options](https://pandoc.org/MANUAL.html#general-options) and all of these options are supported by `quarto render`. For example:

``` {.bash}
$ quarto render document.ipynb --to pdf --toc --number-sections
```

## YAML Options

Note that while it is possible to pass many options via the command line, it's often much more convenient to provide these options within the document itself as YAML front matter. For example:

``` {.yaml}
---
title: "My Document"
author: "Jane Doe"
format: pdf
toc: true
number-sections: true
---
```

If you do this then the following command is equivalent to the previous example (but no options are provided on the command line b/c they are already defined in YAML):

``` {.bash}
$ quarto render document.md
```

Options may include any of the defined Pandoc metadata [variables](https://pandoc.org/MANUAL.html#variables) or [defaults](https://pandoc.org/MANUAL.html#default-files). For example, here we take advantage of quite a few more options for PDF generation:

``` {.yaml}
---
title: "My Document"
author: "Jane Doe"
format: pdf
toc: true
number-sections: true
shift-heading-level-by: 1
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

``` {.yaml}
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

``` {.bash}
$ quarto render document.md # will render to html
$ quarto render document.md --to pdf
$ quarto render document.md --to docx
```

You can learn about the available options for each format in the Pandoc documentation on metadata [variables](https://pandoc.org/MANUAL.html#variables) and [defaults](https://pandoc.org/MANUAL.html#default-files).

Note that you can share format options across a set of documents using [Quarto Projects](quarto-projects.html).

## Next Steps

If you are a Python or Julia user, read the article on [Jupyter Markdown](jupyter-markdown.html) to learn how to use Quarto with Jupyter.

If you are an R user, read the [Rendering Rmds](rendering-rmds.html) article to learn how to render Rmd documents with Quarto.

If you are creating web content with Quarto, see the article on [HTML Themes](html-themes.html) to learn how to customize the appearance of your documents.

To learn about advanced features of Quarto see the articles on [Cross References](cross-references.html), [Figures and Layout](figures-and-layout.html), & [PDFs and LaTeX](pdfs-and-latex.html).
