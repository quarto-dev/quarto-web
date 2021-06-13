---
title: "Installation"
knit: quarto render
---

## Quarto CLI

Installing the Quarto CLI (command-line interface) provides you with everything you need to render basic markdown documents (including a recent version of [Pandoc](https://pandoc.org)). You can install the latest release of the Quarto CLI from:

<https://github.com/quarto-dev/quarto-cli/releases/latest>

You can verify that Quarto has been installed correctly with:

``` {.bash}
$ quarto help
```

If you need to install a version more recent than the latest release, see the documentation on installing the [Development Version].

## Computational Tools

If you are creating computational documents with Quarto, you'll want to be sure to install the additional dependencies required to work with [Knitr](https://yihui.name/knitr) and/or [Jupyter](https://jupyter.org).

### Knitr

To use Quarto with R, you should install the Quarto R package:

``` {.r}
> install.packages("quarto")
```

### Jupyter

If you already have Python/Jupyter installed in your environment, then you should have everything required to render Jupyter notebooks with Python kernels.

If you are in a fresh environment, installing the `jupyter` or `jupyterlab` package will provide everything required to run Quarto:

``` {.bash}
# Jupyter classic 
$ pip install jupyter

# JupyterLab IDE
$ pip install jupyterlab
```

It's generally a good practice to use virtual environments with Quarto projects to ensure that your documents are reproducible. See the documentation below on [Virtual Environments](#virtual-environments) for additional details.

#### Julia

If you are using Julia, please see the [IJulia documentation](https://github.com/JuliaLang/IJulia.jl) on installing and using the Julia kernel.

Note that it's also strongly recommended that you use [Revise.jl](https://timholy.github.io/Revise.jl/stable/) to optimize away kernel startup time. See the documentation on [using Revise within Jupyter](https://timholy.github.io/Revise.jl/stable/config/#Using-Revise-automatically-within-Jupyter/IJulia-1) for additional details.

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
$ quarto install tinytex
```

If you prefer TeX Live, you can find instructions for installing it here: <https://tug.org/texlive/>.

## Development Version

To install the development version of the Quarto CLI, clone the quarto-cli repository then run the configure script for your platform (`configure-linux.sh`, `configure-macos.sh`, or `configure-windows.cmd`). For example:

``` {.bash}
$ git clone https://github.com/quarto-dev/quarto-cli
$ cd quarto-cli
$ ./configure-macos.sh
```

To update to the latest development version, just `git pull` from the local repo directory:

``` {.bash}
$ cd quarto-cli
$ git pull
```

## Virtual Environments {#virtual-environments}

Virtual environments provide a project-specific version of installed Pytohn packages. This both helps you to faithfully reproduce your environment (e.g. if you are collaborating with a colleague or deploying to a server) as well as isolate the use of packages so that upgrading a package in one project doesn't break other projects.

There are two popular flavors of Python virtual environment:

1.  [venv](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment) (built into Python 3).

2.  [Conda](https://conda.io/projects/conda/en/latest/user-guide/getting-started.html#managing-envs) (built in to Anaconda/Miniconda).

Below we'll provide some example workflows for using these tools with Quarto. In these examples we'll assume that you are already within a project directory that contains Quarto documents (so the environment will be created as a subdirectory of the project).

### Using venv

To create a new environment in the directory `.venv`:

``` {.bash}
python -m venv .venv
```

To use the environment you need to activate it. This differs slightly depending on which platform / shell you are using:

::: {.panel-tabset}
## Bash/Zsh

``` {.bash}
source .venv/bin/activate
```

## Windows

``` {.bash}
.venv\Scripts\activate.bat
```

## PowerShell

``` {.bash}
.venv\Scripts\Activate.ps1
```

Note that you may receive an error about running scripts being disabled when activating within PowerShell. If you get this error then execute the following command:

``` {.bash}
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```
:::

Once you've activated the environment, you need to ensure that you have the packages required to render your documents. This will typically encompass `jupyter` / `jupyterlab` plus whatever other packages are used in your Python code. Use a normal `pip install` to install packages into your environment. For example:

``` {.bash}
pip install jupyterlab
pip install pandas matplotlib 
```

Assuming you installed all of the required packages (likely more than just `pandas` and `matplotlib`) you should now be able to `quarto render` documents within the directory.

To make your environment reproducible, you need to create a `requirements.txt` file that enumerates all of the packages in use. To do this use the `pip freeze` command:

``` {.bash}
pip freeze > requirements.txt
```

You should generally check the `requirements.txt` file into version control.

To reproduce the environment on another machine you create an empty environment, activate it, and then `pip install` using `requirements.txt`:

``` {.bash}
# create a new environment
python -m venv .venv

# activate it (note this is for bash, see above for windows)
source .venv/bin/activate

# install packages from requirements.txt
pip install -r requirements.txt
```

### Using conda

To create a new environment in the directory `.condaenv`:

``` {.bash}
conda create --prefix .condaenv 
```

::: {.callout-warning}
Note that if you are using PowerShell on Windows, you may need to execute the following command before using other conda commands:

``` {.bash}
conda init powershell
```
:::

To use the environment you need to activate it, which you do as follows:

::: {.panel-tabset}
## Bash/Zsh

``` {.bash}
conda activate ./.condaenv/
```

## Windows

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

To make your environment reproducible, you need to create a `environment.yml` file that enumerates all of the packages in use. Do this using the `conda env export` command:

``` {.bash}
conda env export > environment.yml
```

You should generally check the `environment.yml` file into version control.

To reproduce the environment on another machine you just pass the `environment.yml` file as an argument to `conda create`:

``` {.bash}
conda create --prefix .condaenv -f environment.yml
```
