---
title: "Quarto Projects"
description: "Quarto projects are directories that provide additional group functionality on top of individual documents within the project."
format: html
---

## Overview

Quarto projects are directories that provide:

-   A way to render all or some of the files in a directory with a single command (e.g. `quarto render myproject`).

-   A way to share YAML configuration across multiple documents.

-   The ability to redirect output artifacts to another directory.

-   The ability to freeze rendered output (i.e. don't re-execute documents unless they have changed).

In addition, projects can have special "types" that introduce additional behavior (e.g. [websites](../websites/website-basics.md) or [books](../books/book-basics.md)).

::: {.callout-note}
If you are just getting started with Quarto and/or you don't have previous experience with markdown publishing systems, you probably want to skip learning about projects for now. Once you are comfortable with the basics, come back to this article to learn more.
:::

## Creating Projects

Use the `quarto create-project` command to create a new project. If you have an existing directory of documents that you want to treat as a project just invoke `create-project` with no arguments from within the directory:

``` {.bash}
quarto create-project
```

To create a project in a new directory just provide a directory name on the command line:

``` {.bash}
quarto create-project myproject
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
# render project in current dir
quarto render 

# render project in 'myproject'
quarto render myproject
```

You can also render only the files within a sub-directory of a project. For example, if the current directory contains a project with sub-directories `tutorials`, `how-to`, and `articles`, you can render just the contents of `articles` as follows:

``` {.bash}
# render only documents in the 'articles' sub-directory
quarto render articles
```

Note that when rendering a project, command line arguments you pass to `quarto render` will be used for each file in the project. For example. this command will render each document in a project as a PDF:

``` {.bash}
quarto render --to pdf
quarto render myproject --to pdf
```

If you are working with Quarto from R, you can also render a project from the R console using the **quarto** R package.

``` {.r}
library(quarto)
quarto_render()
```

## Render Targets

By default, all valid Quarto input files (.Rmd, .ipynb, .md) in the project directory will be rendered, save for ones with a file or directory prefix of `.` (hidden files) or `_` (typically used for non top-level files, e.g. ones included in other files).

If you don't want to render all of the target documents in a project, or you wish to control the order of rendering more precisely, you can add a `project: render: [files]` entry to your project metadata. For example:

``` {.yaml}
project:
  render:
    - section1.md
    - section2.md
```

Note that you can use wildcards when defining the `render` list. For example:

``` {.yaml}
project:
  render:
    - section*.md
```

## Code Execution

Rendering a list of input files has the potential to be quite time consuming depending on the computations required. There are a number of techniques you can use to minimize the time required to rebuild a site that has expensive computations.

### Freeze

You can use the `freeze` option to denote that computational documents should never be re-rendered during a global project render, or alternatively only be re-rendered when their source file changes:

``` {.yaml}
execute:
  freeze: true  # never re-render during project render
```

``` {.yaml}
execute:
  freeze: auto  # re-render only when source changes
```

Note that `freeze` controls whether execution occurs during global project renders. If you do an incremental render of either a single document or a project sub-directory then code is always executed. For example:

``` {.bash}
# render single document (always executes code)
quarto render document.qmd

# render project subdirectory (always executes code)
quarto render articles
```

#### Using Freeze

Freeze is generally used when you have either a large number of collaborators or many computational documents created over a longer period of time. In both cases it can be challenging to fully re-execute every document when you render the site. This could be because some documents have esoteric or environment-specific requirements (e.g. require access/authentication to a data source) or due to general fragility of dependencies over time. Using freeze ensures that you can always reproducibly render your site.

The computational results of documents executed with `freeze` are stored in the `_freeze` directory, and re-used when needed to fulfill document renders. You should check the contents of `_freeze` into version control so that others rendering the project don't need to reproduce your computational environment to render it in their environment.

#### Virtual Environments {#freeze-virtual-environments}

You can also combine `freeze` with the use of virtual environments to divide your project into sub-directories that each have their own set of dependencies. This allows multiple collaborators to use a set of localized dependencies for the documents they are responsible for, but at the same time still be able to render the entire project without requiring all of it's dependencies.

To learn how to create and use a virtual environment, see the documentation on [Virtual Environments](#virtual-environments) below.

Here's an example workflow of using virtual environments with freeze:

1.  Include `freeze: true` in the project execution options:

    ``` {.yaml}
    execute:
      freeze: true
    ```

2.  Create a sub-directory of documents (e.g. `research`), and initialize and use a virtual environment within it:

     ``` {.default}
    research/
       document1.qmd
       document2.qmd
       env/
       requirements.txt
    ```

3.  When working wihtin this sub-directory, activate the virtual environment before rendering it's documents. For example:

    ``` {.bash}
    cd research
    source venv/bin/activate
    quarto render               # render all files in subdir
    quarto render document.qmd  # render a single-file
    ```
    

This sub-directory render won't use the cached `freeze` results but instead will re-run all of the computations using the directory-specific virtual environment. You can of course also include sub-directories within this directory and their documents will also be rendered using the parent virtual environment.

### Cache

You can use the `cache` option to cache the results of computations (using the [knitr cache](https://yihui.org/knitr/demo/cache/) for R documents, and [Jupyter Cache](https://jupyter-cache.readthedocs.io/en/latest/) for Jupyter documents):

``` {.yaml}
execute:
  cache: true
```

Note that cache invalidation is triggered by changes in chunk source code (or other cache attributes you've defined). You may however need to manually refresh the cache if you know that some other input (or even time) has changed sufficiently to warrant an update. To do this, render either individual files or an entire project using the `--cache-refresh` option:

``` {.bash}
quarto render mydoc.Rmd --cache-refresh # single doc
quarto render --cache-refresh           # entire project
```

### No Execute

Finally, if you are using Jupyter Notebooks as inputs, you may prefer to execute all code within interactive notebook sessions, and *never* have Quarto execute the code cells:

``` {.yaml}
execute: false
```

### Working Dir

By default, the working directory for rendering files within a project is the directory of the file itself. If you prefer to use the main project directory instead, you can add the `execute-dir: project` option to your config:

``` {.yaml}
project:
  execute-dir: project
```

Note that from within your code you can always determine the location of the currently executing Quarto project using the `QUARTO_PROJECT_DIR` environment variable.

## Virtual Environments {#virtual-environments}

Virtual environments provide a project-specific version of installed packages. This both helps you to faithfully reproduce your environment (e.g. if you are collaborating with a colleague or deploying to a server) as well as isolate the use of packages so that upgrading a package in one project doesn't break other projects.

There are several popular flavors of virtual environment, we will cover the following ones here:

1.  [venv](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment) (built into Python 3)

2.  [conda](https://towardsdatascience.com/managing-project-specific-environments-with-conda-406365a539ab) (built in to Anaconda/Miniconda)

3.  [renv](https://rstudio.github.io/renv/articles/renv.html) (package for managing R environments)

Below we'll provide some example workflows for using these tools with Quarto. In these examples we'll assume that you are already within a project directory that contains Quarto documents (so the environment will be created as a sub-directory of the project).

We'll also cover using virtual environments with [JupyterLab](#jupyterlab) and [RStudio](#rstudio).

### Using venv {#using-venv .platform-table}

Here we'll provide a brief run through of creating a venv for a Quarto project. See the [full documentation](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment) on using virtual environments with Python for additional details.

To create a new Python 3 virtual environment in the directory `env`:

+-----------+-----------------------+
| Platform  | Command               |
+===========+=======================+
| Windows   | ``` {.bash}           |
|           | py -m venv env        |
|           | ```                   |
+-----------+-----------------------+
| Mac/Linux | ``` {.bash}           |
|           | python3 -m venv env   |
|           | ```                   |
+-----------+-----------------------+

To use the environment you need to activate it. This differs slightly depending on which platform / shell you are using:

+------------------------+--------------------------------------------+
| Shell                  | Command                                    |
+========================+============================================+
| Windows\               | ``` {.default}                             |
| (Command)              | env\Scripts\activate.bat                   |
|                        | ```                                        |
+------------------------+--------------------------------------------+
| Windows\               | ``` {.default}                             |
| (PowerShell)           | env\Scripts\Activate.ps1                   |
|                        | ```                                        |
+------------------------+--------------------------------------------+
| Mac/Linux              | ``` {.bash}                                |
|                        | source env/bin/activate                    |
|                        | ```                                        |
+------------------------+--------------------------------------------+

::: {.callout-note}
#### PowerShell Note

Note that you may receive an error about running scripts being disabled when activating within PowerShell. If you get this error then execute the following command:

``` {.bash}
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```
:::

Once you've activated the environment, you need to ensure that you have the packages required to render your documents. This will typically encompass `jupyter` / `jupyterlab` plus whatever other packages are used in your Python code.

Assuming you installed all of the required packages you should now be able to `quarto render` documents within the directory.

To deactivate an environment use the `deactivate` command:

``` {.bash}
deactivate
```

#### Saving Environments {.platform-table}

To make your environment reproducible, you need to create a `requirements.txt` file that enumerates all of the packages in use. To do this use the `pip freeze` command:

+--------------+-------------------------------------------------------+
| Platform     | Command                                               |
+==============+=======================================================+
| Windows      | ``` {.bash}                                           |
|              | py -m pip freeze > requirements.txt                   |
|              | ```                                                   |
+--------------+-------------------------------------------------------+
| Mac/Linux    | ``` {.bash}                                           |
|              | python3 -m pip freeze > requirements.txt              |
|              | ```                                                   |
+--------------+-------------------------------------------------------+

You should generally check the `requirements.txt` file into version control.

#### Restoring Environments {.platform-table}

To reproduce the environment on another machine you create an empty environment, activate it, and then `pip install` using `requirements.txt`:

First, follow the [instructions above](#using-venv) for creating and activating a virtual environment for your platform/shell.

Then, install packages from `requirements.txt`:

+----------------+-----------------------------------------------------+
| Platform       | Command                                             |
+================+=====================================================+
| Windows        | ``` {.bash}                                         |
|                | py -m pip install -r requirements.txt               |
|                | ```                                                 |
+----------------+-----------------------------------------------------+
| Mac/Linux      | ``` {.bash}                                         |
|                | python3 -m pip install -r requirements.txt          |
|                | ```                                                 |
+----------------+-----------------------------------------------------+

### Using conda {.platform-table}

This section will cover the basics of creating and using conda environments with Quarto projects. See this article on [managing project specific environments](hhttps://towardsdatascience.com/managing-project-specific-environments-with-conda-406365a539ab) with Conda for additional details.

To create a new environment in the directory `env`:

``` {.bash}
conda create --prefix env python
```

If this is the first time you've used conda in your shell, you may need to execute one of the following commands before using other conda tools:

+------------------------+---------------------------------------------+
| Shell                  | Command                                     |
+========================+=============================================+
| Windows\               | ``` {.bash}                                 |
| (Command)              | conda init cmd.exe                          |
|                        | ```                                         |
+------------------------+---------------------------------------------+
| Windows\               | ``` {.bash}                                 |
| (PowerShell)           | conda init powershell                       |
|                        | ```                                         |
+------------------------+---------------------------------------------+
| Linux / Older Mac\     | ``` {.bash}                                 |
| (Bash)                 | conda init bash                             |
|                        | ```                                         |
+------------------------+---------------------------------------------+
| Newer Mac\             | ``` {.bash}                                 |
| (Zsh)                  | conda init zsh                              |
|                        | ```                                         |
+------------------------+---------------------------------------------+

You will likely need to exit and restart your terminal for `conda init` to be reflected in your session.

To use the environment you need to activate it, which you do as follows:

+----------------+-----------------------------------------------------+
| Platform       | Command                                             |
+================+=====================================================+
| Windows        | ``` {.bash}                                         |
|                | conda activate .\env                                |
|                | ```                                                 |
+----------------+-----------------------------------------------------+
| Mac/Linux      | ``` {.bash}                                         |
|                | conda activate ./env                                |
|                | ```                                                 |
+----------------+-----------------------------------------------------+

Once you've activated the environment, you need to ensure that you have the packages required to render your documents. This will typically encompass `jupyter` / `jupyterlab` plus whatever other packages are used in your Python code. Use `conda install` to install packages into your environment. For example:

``` {.bash}
conda install jupyterlab
conda install pandas matplotlib 
```

Assuming you installed all of the required packages (likely more than just `pandas` and `matplotlib`) you should now be able to `quarto render` documents within the directory.

Use `conda deactivate` to exit an activated environment:

``` {.bash}
conda deactivate
```

#### Saving Environments

To make your environment reproducible, you need to create a `environment.yml` file that enumerates all of the packages in use. Do this using the `conda env export` command:

``` {.bash}
conda env export > environment.yml
```

You should generally check the `environment.yml` file into version control.

#### Restoring Environments

To reproduce the environment on another machine you just pass the `environment.yml` file as an argument to `conda create`:

``` {.bash}
conda create --prefix env -f environment.yml
```

### Using renv

The [renv](https://rstudio.github.io/renv/articles/renv.html) package provides functionality similar to the venv and conda, but for R packages. To create a new renv environment, install the **renv** package from GitHub then call the `renv::init()` function:

``` {.r}
remotes::install("rstudio/renv")
renv::init()
```

As part of initialization, your `.Rprofile` file is modified to ensure that the renv is activated automatically at the start of each R session.

If you plan on using **both** R and Python in your project, you can have renv automatically create and manage a Python virtual environment as follows:

``` {.r}
renv::use_python()
```

To install R packages use the standard R `install.packages` function. You can also install GitHub packages using the `renv::install` function. For example:

``` {.r}
install.packages("ggplot2")      # install from CRAN
renv::install("tidyverse/dplyr") # install from GitHub
```

To install Python packages just use `pip` as described above from the built-in RStudio terminal.

#### Saving Environments

To record the current versions of all R (and optionally Python) packages, use the `renv::snapshot()` function:

``` {.r}
renv::snapshot()
```

This will record an `renv.lock` file for R packages and a `requirements.txt` file for Python packages). These files should be checked into version control.

#### Restoring Environments

To reproduce the environment on another machine use the `renv::restore()` function:

``` {.r}
renv::restore()
```

### JupyterLab {#jupyterlab .platform-table}

To use Jupyter or JupyterLab within a Python virtual environment you just need to activate the environment and then launch the Jupyter front end. For example:

+----------------------+------------------------------------------------+
| Shell                | Command                                        |
+======================+================================================+
| Windows\             | ``` {.default}                                 |
| (Command)            | env\Scripts\activate.bat                       |
|                      | py -m jupyter lab                              |
|                      | ```                                            |
+----------------------+------------------------------------------------+
| Windows (PowerShell) | ``` {.default}                                 |
|                      | env\Scripts\Activate.ps1                       |
|                      | py -m jupyter lab                              |
|                      | ```                                            |
+----------------------+------------------------------------------------+
| Mac/Linux            | ``` {.bash}                                    |
|                      | source env/bin/activate                        |
|                      | python3 -m jupyter lab                         |
|                      | ```                                            |
+----------------------+------------------------------------------------+

All of the Python packages installed within the `env` will be available in your Jupyter notebook session. The workflow is similar if you are using conda environments.

### RStudio {#rstudio}

We'll cover two different scenarios for using RStudio with Quarto:

1.  Using RStudio with **renv** (R and optionally some Python packages)
2.  Using RStudio with **venv** (Python packages only)

::: {.callout-note}
#### RStudio v1.5

If you are using RStudio with Quarto, it is strongly recommended that you run the daily build of RStudio v1.5, as it has many small improvements required to handle Quarto documents correctly. You can download the daily build at <https://dailies.rstudio.com>.
:::

#### renv

If you are using **renv**, RStudio v1.5 will automatically do the right thing in terms of binding Quarto to the R and/or Python packages in your project environments.

If you need to install R packages just use `install.packages`; if you need to install Python packages simply use `pip install` or `conda install` within the RStudio Terminal.

#### venv

If you are using RStudio as a Quarto editing front end for Python/Jupyter, you may not be using **renv** at all. In this case you'll want to configure RStudio to use the `env` directory for executing Python code.

To do this you need to modify your `.Rprofile` to add the appropriate directory to the system `PATH`. This is the code to add to `.Rprofile` for `env`:

``` {.r}
bin <- ifelse(.Platform$OS.type == "windows", "Scripts", "bin")
venv_bin <- file.path(getwd(), "env", bin)
Sys.setenv(PATH = paste(venv_bin, Sys.getenv("PATH"),  
                        sep = .Platform$path.sep))
```

The directory containing the Python executable differs between Windows and other systems, which is we need the `ifelse` on the first line.

Note that while in principle you could also use **conda** in this configuration, **venv** is much better tested and debugged with Quarto under RStudio so is strongly recommended.

## Project Types

There are a couple of special project types available:

-   [Websites](../websites/website-basics.md) includes additional navigational elements (e.g. navbar/sidebar/etc.) and copy all output files to a deployment directory (e.g. `_site`) by default.

-   [Books](../books/book-basics.md) support combineing all of the included documents into a single manuscript (e.g. a PDF or EPUB) as well as creating a book website from the same source documents.
