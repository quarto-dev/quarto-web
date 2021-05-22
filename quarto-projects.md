---
title: "Quarto Projects"
format: html
---

## Project Basics

Quarto projects are directories that provide:

-   A way to render all or some of the files in a directory with a single command (e.g. `quarto render myproject`).

-   A way to share YAML configuration across multiple documents.

-   The ability to redirect output artifacts to another directory.

-   The ability to freeze rendered output (e.g. don't re-execute an .Rmd or .ipynb) either unqualified or tied to the content of the source file (via hash).

In addition, projects can have special "types" that introduce additional behavior (e.g. [websites](website-basics.md) or [books](book-basics.md)).


## Creating Projects

Use the `quarto create-project` command to create a new project. If you have an existing directory of documents that you want to treat as a project just invoke `create-project` with no arguments from within the directory:

``` {.bash}
$ quarto create-project
```

To create a project in a new directory just provide a directory name on the command line:

``` {.bash}
$ quarto create-project myproject
```

## Shared Metadata

When you create a project, a `_quarto.yml` config file is created. Here is an example of what the `_quarto.yml` file might look like:

``` {.yaml}
project:
  output-dir: _output

toc: true
number-sections: true
bibliography: references.bib  
  
format:
  html:
    css: styles.css
    html-math-method: katex
  pdf:
    documentclass: report
    margin-left: 30mm
    margin-right: 30mm
```

Any document rendered within the project directory will automatically inherit the metadata defined at the project level.

Note that the project file contains both global options that apply to all formats (e.g. `toc` and `bibliograph`) as well as format-specific options.

## Rendering Projects

You can render files within a project either one-by-one or all at once (in either case, shared project metadata will be used).

To render all of the documents within a project, just use `quarto render` within the project directory (or target a specific directory with a command line argument):

``` {.bash}
$ quarto render # render current dir
$ quarto render myproject
```

Note that when rendering an entire project, command line arguments you pass to `quarto render` will be used for each file in the project. For example. this command will render each document in a project as a PDF:

``` {.bash}
$ quarto render --to pdf
$ quarto render myproject --to pdf
```

If you are working with Quarto from R, you can also render a project from the R console using the **quarto** R package.

``` {.r}
library(quarto)
quarto_render("document.Rmd")
```

## Render Targets

By default, all valid Quarto input files (.Rmd, .ipynb, .md) in the project directory will be rendered, save for ones with a file or directory prefix of `.` (hidden files) or `_` (typically used for non top-level files, e.g. ones included in other files).

If you don't want to render all of the target documents in a project, or you wish to control the order of rendering more precisely, you can add a `project: render: [files]` entry to your project metadata. For example:

``` {.yaml}
project:
  name: myproject
  render:
    - section1.md
    - section2.md
```

Note that you can use wildcards when defining the `render` list. For example:

``` {.yaml}
project:
  name: myproject
  render:
    - section*.md
```

## Working Dir

By default, the working directory for rendering files within a project is the directory of the file itself. If you prefer to use the main project directory instead, you can add the `execute-dir` option to your config:

``` {.yaml}
project:
  type: site
  execute-dir: project
```

Note that you can always determine the location of the currently executing Quarto project using the `QUARTO_PROJECT_DIR` environment variable.

## Execution

Rendering a list of input files has the potential to quite time consuming depending on the computations required. There are a number of techniques you can use to minimize the time required to rebuild a site that has expensive computations.

### Freeze

You can use the `freeze` option to denote that computational documents should never be re-rendered, or alternatively only be re-rendered when their source file changes:

``` {.yaml}
execute:
  freeze: true  # never re-render
```

``` {.yaml}
execute:
  freeze: auto  # re-render only when source changes
```

### Cache

You can use the `cache` option to cache the results of computations (using the [knitr cache](https://yihui.org/knitr/demo/cache/) for Rmd documents, and [Jupyter Cache](https://jupyter-cache.readthedocs.io/en/latest/) for .ipynb or Jupyter Markdown documents):

``` {.yaml}
execute:
  cache: true
```

Note that cache invalidation is triggered by changes in chunk source code (or other cache attributes you've defined). You may however need to manually refresh the cache if you know that some other input (or even time) has changed sufficiently to warrant an update. To do this, render either individual files or an entire project using the `--cache-refresh` option:

``` {.bash}
$ quarto render mydoc.Rmd --cache-refresh # single doc
$ quarto render --cache-refresh           # entire project
```

### No Execute

Finally, if you are using Jupyter Notebooks as inputs, you may prefer to execute all code within interactive notebook sessions, and *never* have Quarto execute the code cells:

``` {.yaml .yml}
execute:
  eval: false
```

When rendering .ipynb files with Quarto, `eval: false` is the default behavior (it's assumed that you want to only execute cells in the Notebook UI). To always execute the cells in your .ipynb just do this:


``` {.yaml .yml}
execute:
  eval: true
```

## Project Types

There are a couple of special project types available:

-   [Websites](website-basics.md) includes additional navigational elements (e.g. navbar/sidebar/etc.) and copy all output files to a deployment directory (e.g. `_site`) by default.

-   [Books](book-basics.md) support combineing all of the included documents into a single manuscript (e.g. a PDF or EPUB) as well as creating a book website from the same source documents.

