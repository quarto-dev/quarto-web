
## Overview

Quarto projects are directories that provide:

-   A way to render all or some of the files in a directory with a single command (e.g. `quarto render myproject`).

-   A way to share YAML configuration across multiple documents.

-   The ability to redirect output artifacts to another directory.

-   The ability to freeze rendered output (i.e. don't re-execute documents unless they have changed).

In addition, projects can have special "types" that introduce additional behavior (e.g. [websites](/docs/websites/website-basics.qmd) or [books](/docs/books/book-basics.qmd)).

::: callout-note
If you are just getting started with Quarto and/or you don't have previous experience with markdown publishing systems, you probably want to skip learning about projects for now. Once you are comfortable with the basics, come back to this article to learn more.
:::

## Creating Projects

Use the `quarto create-project` command to create a new project. If you have an existing directory of documents that you want to treat as a project just invoke `create-project` with no arguments from within the directory:

``` bash
quarto create-project
```

To create a project in a new directory just provide a directory name on the command line:

``` bash
quarto create-project myproject
```

## Shared Metadata

When you create a project, a `_quarto.yml` config file is created. Here is an example of what the `_quarto.yml` file might look like:

``` yaml
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

``` bash
# render project in current dir
quarto render 

# render project in 'myproject'
quarto render myproject
```

You can also render only the files within a sub-directory of a project. For example, if the current directory contains a project with sub-directories `tutorials`, `how-to`, and `articles`, you can render just the contents of `articles` as follows:

``` bash
# render only documents in the 'articles' sub-directory
quarto render articles
```

Note that when rendering a project, command line arguments you pass to `quarto render` will be used for each file in the project. For example. this command will render each document in a project as a PDF:

``` bash
quarto render --to pdf
quarto render myproject --to pdf
```

If you are working with Quarto from R, you can also render a project from the R console using the **quarto** R package.

``` r
library(quarto)
quarto_render()
```

## Render Targets

By default, all valid Quarto input files (.qmd, .ipynb, .md, .Rmd) in the project directory will be rendered, save for ones with a file or directory prefix of `.` (hidden files) or `_` (typically used for non top-level files, e.g. ones included in other files).

If you don't want to render all of the target documents in a project, or you wish to control the order of rendering more precisely, you can add a `project: render: [files]` entry to your project metadata. For example:

``` yaml
project:
  render:
    - section1.md
    - section2.md
```

Note that you can use wildcards when defining the `render` list. For example:

``` yaml
project:
  render:
    - section*.md
```

