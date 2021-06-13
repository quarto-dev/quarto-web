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

## Computational Tools

If you are creating computational documents with Quarto, you'll want to be sure to install the additional dependencies required to work with [Knitr](https://yihui.name/knitr) and/or [Jupyter](https://jupyter.org).

### Knitr

To use Quarto with R, you should install the Quarto R package:

```r
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

<!---
### Windows

```bash
python -m venv .venv

# powershell
.venv\Scripts\Activate.ps1

# venv\Scripts\Activate.ps1 cannot be loaded because running scripts is disabled # on this system. For more information, see about_Execution_Policies
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# git bash
source .venv/Scripts/activate
# (note that daemon mode currently doesn't work in Git Bash but one shot does)

# cmd
.venv\Scripts\activate.bat


# conda (powershell/cmd)
conda init powershell
conda create --prefix .condaenv python=3.8
conda activate .\.condaenv\

conda install jupyter_core nbformat nbclient ipykernel pyyaml
conda install matplotlib pandas

# for git bash, may need to add conda to system path or add conda activation
# to .bashrc
https://fmorenovr.medium.com/how-to-add-conda-to-git-bash-windows-21f5e5987f3d


```

```r
renv::use_python(type = "virtualenv")
pip install quarto
pip install matplotlib pandas
```

```r
renv::use_python(type = "conda")
library(reticulate)
py_install(c("jupyter_core", "nbformat", "nbclient", "ipykernel", "pyyaml"), method = "conda")
py_install(c("matplotlib", "pandas"), method="conda")
```


-->

### Julia

If you are using Julia, please see the [IJulia documentation](https://github.com/JuliaLang/IJulia.jl) on installing and using the Julia kernel.

Note that it's also strongly recommended that you use [Revise.jl](https://timholy.github.io/Revise.jl/stable/) to optimize away kernel startup time. See the documentation on [using Revise within Jupyter](https://timholy.github.io/Revise.jl/stable/config/#Using-Revise-automatically-within-Jupyter/IJulia-1) for additional details.


## Additional Tools

### Pandoc

A recent version of Pandoc (v2.14) is installed alongside Quarto. This version of Pandoc won't interfere with others you may have on your system (it's not added to the system PATH).

To interact directly with the version of Pandoc installed with Quarto, use the `quarto pandoc` command. For example:

```bash
quarto pandoc --version
quarto pandoc --list-output-formats
```

### TeX

If you expect to use Quarto to create PDFs, you will need to install a recent distribution of TeX. While you can employ whatever toolchain you like for LaTeX compilation, we strongly recommend the use of [TinyTeX](https://yihui.org/tinytex/), which is a distribution of [TeX Live](https://tug.org/texlive/) that provides a reasonably sized initial download (\~100 MB) that includes the 200 or so most commonly used TeX packages for Pandoc documents.

To install TinyTeX, use the following command:

```bash
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
