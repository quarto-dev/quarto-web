---
title: "Installation"
knit: quarto render
---

## Quarto CLI

Installing the Quarto CLI (command-line interface) provides you with everything you need to render basic markdown documents (including a recent version of [Pandoc](https://pandoc.org)). You can install the latest release of the Quarto CLI from:

<https://github.com/quarto-dev/quarto-cli/releases/latest>

You can verify that Quarto has been installed correctly with:

``` {.bash}
quarto check install
```

If you need to install a version more recent than the latest release, see the documentation on installing the [Development Version].

## Computational Tools

If you are creating computational documents with Quarto, you'll want to be sure to install the additional dependencies required to work with [Knitr](https://yihui.name/knitr) and/or [Jupyter](https://jupyter.org).

### Knitr

To use Quarto with R, you should install the Quarto R package:

``` {.r}
install.packages("quarto")
```

Installation of the **quarto** package will also install the **knitr** package so you will everything required to render documents containing R code. You can verify that Quarto is configured correctly for Knitr with:

``` {.bash}
quarto check knitr
```

### Jupyter

If you already have Python/Jupyter installed in your environment, then you should have everything required to render Jupyter notebooks with Python kernels.

If you are in a fresh environment, installing the `jupyter` or `jupyterlab` package will provide everything required to run Quarto:

::: {.panel-tabset}
#### Pip (MacOS/Linux)

``` {.bash}
# Jupyter classic 
python3 -m pip install jupyter

# JupyterLab IDE
python3 -m pip install jupyterlab
```

#### Pip (Windows)

``` {.bash}
# Jupyter classic 
py -3 -m pip install jupyter

# JupyterLab IDE
py -3 -m pip install jupyterlab
```


#### Conda

``` {.bash}
# Jupyter classic 
conda install jupyter

# JupyterLab IDE
conda install jupyterlab
```
:::

You can verify that Quarto is configured correctly for Jupyter with:

``` {.bash}
quarto check jupyter
```

### Environments

If you are using [Quarto Projects](getting-started/quarto-projects.md) and want to create a project-local virtual environment for your Python and/or R dependencies see the documentation below on using [Virtual Environments](#virtual-environments).

## Additional Tools

### Pandoc

A recent version of Pandoc (v2.14) is installed alongside Quarto. This version of Pandoc won't interfere with others you may have on your system (it's not added to the system PATH).

To interact directly with the version of Pandoc installed with Quarto, use the `quarto pandoc` command. For example:

``` {.bash}
quarto pandoc --version
quarto pandoc --list-output-formats
```

### TeX

If you expect to use Quarto to create PDFs, you will need to install a recent distribution of TeX. While you can employ whatever toolchain you like for LaTeX compilation, we strongly recommend the use of [TinyTeX](https://yihui.org/tinytex/), which is a distribution of [TeX Live](https://tug.org/texlive/) that provides a reasonably sized initial download (\~100 MB) that includes the 200 or so most commonly used TeX packages for Pandoc documents.

To install TinyTeX, use the following command:

``` {.bash}
quarto install tinytex
```

If you prefer TeX Live, you can find instructions for installing it here: <https://tug.org/texlive/>.

## Development Version

To install the development version of the Quarto CLI, clone the quarto-cli repository then run the configure script for your platform (`configure-linux.sh`, `configure-macos.sh`, or `configure-windows.cmd`). For example:

``` {.bash}
git clone https://github.com/quarto-dev/quarto-cli
cd quarto-cli
./configure-macos.sh
```

To update to the latest development version, just `git pull` from the local repo directory:

``` {.bash}
cd quarto-cli
git pull
```

## Virtual Environments {#virtual-environments}

Virtual environments provide a project-specific version of installed packages. This both helps you to faithfully reproduce your environment (e.g. if you are collaborating with a colleague or deploying to a server) as well as isolate the use of packages so that upgrading a package in one project doesn't break other projects.

There are several popular flavors of virtual environment, we will cover the following ones here:

1.  [venv](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment) (built into Python 3)

2.  [conda](https://conda.io/projects/conda/en/latest/user-guide/getting-started.html#managing-envs) (built in to Anaconda/Miniconda)

3.  [renv](https://rstudio.github.io/renv/articles/renv.html) (package for managing R environments)

Below we'll provide some example workflows for using these tools with Quarto. In these examples we'll assume that you are already within a project directory that contains Quarto documents (so the environment will be created as a sub-directory of the project).

We'll also cover using virtual environments with [JupyterLab](#jupyterlab) and [RStudio](#rstudio).

### Using venv {#using-venv}

To create a new Python 3 virtual environment in the directory `.venv`:

::: {.panel-tabset}
#### Mac/Linux

``` {.bash}
python3 -m venv .venv
```

#### Windows

``` {.bash}
py -3 -m venv .venv
```

Note that using `py -3` ensures that you are invoking the most recent version of Python 3 for Windows installed on your system. If this command fails, you should run the [Python for Windows](https://www.python.org/downloads/windows/) installer and then re-execute it.
:::

To use the environment you need to activate it. This differs slightly depending on which platform / shell you are using:

::: {.panel-tabset}
#### Mac/Linux {.panel-tabset}

``` {.bash}
source .venv/bin/activate
```

#### Windows (Cmd) {.panel-tabset}

``` {.bash}
.venv\Scripts\activate.bat
```

#### Windows (PowerShell) {.panel-tabset}

``` {.bash}
.venv\Scripts\Activate.ps1
```

Note that you may receive an error about running scripts being disabled when activating within PowerShell. If you get this error then execute the following command:

``` {.bash}
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```
:::

Once you've activated the environment, you need to ensure that you have the packages required to render your documents. This will typically encompass `jupyter` / `jupyterlab` plus whatever other packages are used in your Python code. 

Assuming you installed all of the required packages you should now be able to `quarto render` documents within the directory.

#### Saving Environments

To make your environment reproducible, you need to create a `requirements.txt` file that enumerates all of the packages in use. To do this use the `pip freeze` command:


::: {.panel-tabset}
#### MacOS/Linux

``` {.bash}
python3 -m pip freeze > requirements.txt
```

#### Windows

``` {.bash}
py -3 -m pip freeze > requirements.txt
```
:::

You should generally check the `requirements.txt` file into version control.

#### Restoring Environments

To reproduce the environment on another machine you create an empty environment, activate it, and then `pip install` using `requirements.txt`:

1.  Follow the [instructions above](#using-venv) for creating and activating a virtual environment for your platform/shell.

2.  Install packages from `requirements.txt`:

    ::: {.panel-tabset}
    #### MacOS/Linux

    ``` {.bash}
    python3 -m pip install -r requirements.txt
    ```

    #### Windows

    ``` {.bash}
    py -3 -m pip install -r requirements.txt
    ```
    :::

### Using conda

To create a new environment in the directory `.condaenv`:

``` {.bash}
conda create --prefix .condaenv python
```

If this is the first time you've used conda in your shell, you may need to execute one of the following commands before using other conda tools:

``` {.bash}
# linux / older macos
conda init bash

# newer macos
conda init zsh

# windows
conda init cmd.exe
conda init powershell
```

You will likely need to exit and restart your terminal for `conda init` to be reflected in your session.

To use the environment you need to activate it, which you do as follows:

::: {.panel-tabset}
#### Mac/Linux {.panel-tabset}

``` {.bash}
conda activate ./.condaenv/
```

#### Windows {.panel-tabset}

``` {.bash}
conda activate .\.condaenv\
```
:::

Once you've activated the environment, you need to ensure that you have the packages required to render your documents. This will typically encompass `jupyter` / `jupyterlab` plus whatever other packages are used in your Python code. Use `conda install` to install packages into your environment. For example:

``` {.bash}
conda install jupyterlab
conda install pandas matplotlib 
```

Assuming you installed all of the required packages (likely more than just `pandas` and `matplotlib`) you should now be able to `quarto render` documents within the directory.

#### Saving Environments

To make your environment reproducible, you need to create a `environment.yml` file that enumerates all of the packages in use. Do this using the `conda env export` command:

``` {.bash}
conda env export > environment.yml
```

You should generally check the `environment.yml` file into version control.

#### Restoring Environments

To reproduce the environment on another machine you just pass the `environment.yml` file as an argument to `conda create`:

``` {.bash}
conda create --prefix .condaenv -f environment.yml
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

### JupyterLab {#jupyterlab}

To use Jupyter or JupyterLab within a Python virtual environment you just need to activate the environment and then launch the Jupyter front end. For example:

::: {.panel-tabset}
#### Mac/Linux {.panel-tabset}

``` {.bash}
# activate environment
source .venv/bin/activate

# launch jupyterlab
jupyter lab
```

#### Windows (Cmd) {.panel-tabset}

``` {.bash}
# activate environment
.venv\Scripts\activate.bat

# launch jupyterlab
jupyter lab
```

#### Windows (PowerShell) {.panel-tabset}

``` {.bash}
# activate environment
.venv\Scripts\Activate.ps1

# launch jupyterlab
jupyter lab
```
:::

All of the Python packages installed within the `.venv` will be available in your Jupyter notebook session. The workflow is similar if you are using conda environments.

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

If you are using RStudio as a Quarto editing front end for Python/Jupyter, you may not be using **renv** at all. In this case you'll want to configure RStudio to use the `.venv` directory for executing Python code.

To do this you need to modify your `.Rprofile` to add the appropriate directory to the system `PATH`. This is the code to add to `.Rprofile` for `.venv`:

``` {.r}
bin <- ifelse(.Platform$OS.type == "windows", "Scripts", "bin")
venv_bin <- file.path(getwd(), ".venv", bin)
Sys.setenv(PATH = paste(venv_bin, Sys.getenv("PATH"),  
                        sep = .Platform$path.sep))
```

The directory containing the Python executable differs between Windows and other systems, which is we need the `ifelse` on the first line.

Note that while in principle you could also use **conda** in this configuration, **venv** is much better tested and debugged with Quarto under RStudio so is strongly recommended.
