---
title: "Quarto Projects"
format: html
---

## Projects

Quarto projects are directories that:

-   Enable sharing of YAML metadata/options across multiple files. 
-   Can be rendered with a single command (e.g. `quarto render myproject`)
-   Can have "types" that introduce additional behavior (e.g. website, book, etc.)

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
  name: myproject
format:
  html:
    css: styles.css
    html-math-method: katex
  pdf:
    documentclass: report
    margin-left: 30mm
    margin-right: 30mm
toc: true
number-sections: true
bibliography: references.bib
```

Any document rendered within the project directory will automatically inherit the metadata defined at the project level.

## Rendering Projects

You can render files within a project either one-by-one or all at once (in either case, shared project metadata will be used).

To render all of the documents within a project, just use `quarto render` within the project directory (or target a specific directory with a command line argument):

``` {.bash}
$ quarto render # render current dir
$ quarto render myproject
```

Note that when rendering an entire project, command line arguments you pass to `quarto render` will be used for each file in the project. For example. theses command will render each document in a project as a PDF:

``` {.bash}
$ quarto render --to pdf
$ quarto render myproject --to pdf
```

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

## Project Types

The only type of project currently available is the vanilla "default" type described above. However, additional project types are under development including:

-   A `website` project type that includes navigational elements and copies all output files to a deployment directory.

-   A `book` project type that combines all of the included documents into a single manuscript.

You will also be able to define custom project types as [Quarto Extensions](quarto-extensions.html).
