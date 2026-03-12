---
title: "Basics"
format: html
---

::: {.callout-tip}
## Learn more
See the full guide on [Creating a Website](https://quarto.org/docs/websites/).
:::

## Projects

Quarto Projects are a generic facility not tied to websites, that nevertheless provide some important features for creating websites and books:

-   A way to render all or some of the files in a directory with a single command.

-   A way to share YAML configuration across multiple files.

-   The ability to redirect output artifacts to another directory.

-   The ability to freeze rendered output (e.g. don't re-execute an .Rmd or .ipynb) either unqualified or tied to the content of the source file (via hash).

For example, here is a `_quarto.yml` config file for a website project:

``` {.yaml}
project:
  type: site
  
site:
  title: "Quarto Demo"

format:
  html:
    theme: cosmo
    toc: true
    
bibliography: references.bib
```

For this project, output files will go to the `_site` directory by default. You can override this by adding an `output-dir` option to the `project` section of your config.

## Rendering

To render all of the files within a project, use `quarto render`:

``` {.bash}
$ quarto render
```

The above command renders the project in the current working directory. You can also target another directory:

``` {.bash}
$ quarto render mysite
```

To render from R, use the **quarto** package:

``` {.r}
library(quarto)
quarto_render()
```

By default, all valid Quarto input files (.Rmd, .ipynb, .md) in the project directory will be rendered, save for ones with a file or directory prefix of `.` (hidden files) or `_` (typically used for non top-level files, e.g. ones included in other files).

You can however explicitly control which files are rendered using the `render` option (which is a list of file globs to be rendered, with globs preceded by `!` excluded). For example:

``` {.yaml}
project:
  type: site
  render: 
    - *.Rmd
    - *.ipynb
    - !import.Rmd
```

## Dev Server

Quarto includes a live-reloading development server that you will likely find convenient to use while working on websites. Start the server with:

``` {.bash}
$ quarto serve
```

If you are using Quarto from R, you can also use the **quarto** package to run the development server:

``` {.r}
library(quarto)
quarto_serve()
```

The browser will automatically refresh when you render a computational input (e.g. Rmd) or save a markdown file that doesn't require computation.

Changes to configuration files (e.g. `_quarto.yml`) as well site resources (e.g. theme or CSS files) will also cause an automatic refresh.

Note that development server updates do not cause an update to the final site output. Consequently, you should always `quarto render` your site before deploying it, even if you have already previewed the changes with the development server.

## RStudio

RStudio v1.4 automatically uses Quarto to render Rmd documents whenever it sees a `format` key in the YAML front matter (as opposed to an `output` key). For projects, you typically provide the `format` configuration in `_quarto.yml` so may not have a `format` key in individual documents.

However, since RStudio v1.4 is not aware of Quarto projects, you should still add an explicit `format: html` entry in each document's front matter (in spite of the fact that it's already declared at the project level) to ensure that it's rendered with Quarto. For example:

``` {.yaml}
---
title: "My Page"
html: format
---
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

#### Freeze

You can use the `freeze` option to denote that computational documents should never be re-rendered, or alternatively only be re-rendered when their source file changes:

``` {.yaml}
freeze: true  # never re-render
freeze: auto  # re-render only when source changes
```

#### Cache

You can use the `cache` option to cache the results of computations (using the [knitr cache](https://yihui.org/knitr/demo/cache/) for Rmd documents, and [Jupyter Cache](https://jupyter-cache.readthedocs.io/en/latest/) for .ipynb or Jupyter Markdown documents):

``` {.yaml}
cache: true
```

Note that cache invalidation is triggered by changes in chunk source code (or other cache attributes you've defined). You may however need to manually refresh the cache if you know that some other input (or even time) has changed sufficiently to warrant an update. To do this, render either individual files or an entire project using the `--cache-refresh` option:

``` {.bash}
$ quarto render mydoc.Rmd --cache-refresh # single doc
$ quarto render --cache-refresh           # entire project
```

#### No Execute

Finally, if you are using Jupyter Notebooks as inputs, you may prefer to execute all code within interactive notebook sessions, and *never* have Quarto execute the code cells:

``` {.yaml .yml}
execute: false
```

You can specify this option either globally or per-notebook.

## Resources

Besides input and configuration files, your site likely also includes a variety of resources (e.g. images) that you will want to publish along with your site. Quarto will automatically detect any files that you reference within your site and copy them to the output directory (e.g. `_site`).

If this auto-detection fails for any reason, of if you want to publish a file not explicitly linked to from within your site, you can add a `resources` entry to your configuration. For example, here we specify that we want to include all Excel spreadsheets within the project directory as part of the website:

``` {.yaml .yml}
project:
  type: site
  resources: 
    - *.xlsx
```

You can also add a `resources` metadata value to individual files. For example:

``` {.yaml}
title: "My Page"
resources:
  - sheet.xlsx
```

Images are the most commonly used type of resource file. If you have global images (e.g. a logo) that you want to reference from various pages within your site, you can use an site-absolute path to refer to the images, and it will be automatically converted to a relative path during publishing. For example:

``` {.markdown}
![](/images/logo.png)
```
