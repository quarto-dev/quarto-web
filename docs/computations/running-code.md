---
title: Running Code
description: "Quarto supports executable code blocks within markdown. This allows you to create fully reproducible documents and reports---the code required to produce your output is part of the document itself, and is automatically re-run whenever the document is rendered."
format: html
---

## Overview

Quarto supports executable code blocks within markdown. This allows you to create fully reproducible documents and reports---the code required to produce your output is part of the document itself, and is automatically re-run whenever the document is rendered.

There are currently two engines supported for running computations:

-   [Jupyter](https://jupyter.org/), for running code from Python, Julia, and many other languages.

-   [Knitr](https://yihui.org/knitr/), for running code from R.

Extensive customization of code chunk output is supported, including the ability to hide code and/or output as well as fold code (make it visible only on demand).

## Executing Code Blocks

Code blocks that use braces around the language name (e.g. ```` ```{python} ````) are executable, and will be run by Quarto during render. Here are a couple of simple examples in Python and R to illustrate (the output produced by the code block is shown beneath the code).

### Python (Jupyter)

```` {.python}
---
title: "Jupyter Document"
format: 
  html:
    code-background: true
jupyter: python3
---

```{python}
import matplotlib.pyplot as plt
plt.plot([1,2,3,4])
plt.show()
```

```{python}
import pandas as pd
d = {'one' : [1., 2., 3., 4.],
     'two' : [4., 3., 2., 1.]}
df = pd.DataFrame(d)
df
```
````

![](images/jupyter-document.png){.border}

Note that we added the `code-background: true` option to provide a background color for the code chunks (see the documentation on [Code Block](../output-formats/html-extensions.Rmd#code-blocks) options for additional details on customizing code block output).

### R (Knitr)

```` {.r}
---
title: "Knitr Document"
format: 
  html:
    code-background: true
execute:
  warning: false
---

```{r}
library(ggplot2)
ggplot(airquality, aes(Temp, Ozone)) + 
        geom_point() + 
        geom_smooth(method = "loess", se = FALSE)
```

```{r}
summary(airquality)
```
````

![](images/knitr-document.png){.border .preview-image}

Note that we added the `execute: warning: false` option to suppress printing of warnings. See the [Execution Options] section below for additional details.

You can produce a wide variety of output types from executable code blocks, including:

-   Static plots (e.g. from matplotlib or ggplot2).

-   Interactive plots (e.g. from plotly or leaflet).

-   Tabular output (e.g. from printing R or Pandas data frames)

-   Plain text output (e.g. printing the results of statistical summaries).

### Non-Executable Blocks

Note that code blocks that use convential markdown code block syntax (either ```` ```python ```` or ```` ```{.python} ````) are not executable:

+-------------------+-------------+
| Code Block Syntax | Executable? |
+===================+:===========:+
|     ```{python}   | Yes         |
|     1 + 1         |             |
|     ```           |             |
+-------------------+-------------+
|     ```python     | No          |
|     1 + 1         |             |
|     ```           |             |
+-------------------+-------------+
|     ```{.python}  | No          |
|     1 + 1         |             |
|     ```           |             |
+-------------------+-------------+

Non-executable code blocks are printed but not executed.

## Rendering

Quarto will automatically run computations in any markdown document that contains executable code blocks. For example, the Python example shown above might be rendered with:

``` {.bash}
quarto render jupyter-document.qmd
```

The R example might have been rendered with:

``` {.bash}
quarto render knitr-document.Rmd
```

::: {.callout-note}
While the .Rmd extension is not required for using the Knitr engine (you could instead use .qmd), it's still recommended that you use .Rmd since many editors (e.g. RStudio) will make features like interactive chunk execution available when the .Rmd extension is present. See the article on [Using RStudio](using-rstudio.md) for additional details.
:::

The Python example above uses a markdown input file, Quarto can also render any Jupyter notebook (.ipynb) and use all of the same computational features described here. For example:

``` {.bash}
quarto render jupyter-document.ipynb
```

Jupyter users have a choice of authoring in .ipynb (and using the JupyterLab or VS Code notebook editor) or authoring in plain text markdown using their favorite text editor. See the article on [Using Jupyter Lab](using-jupyter-lab.md) for additional details.

::: {.callout-note}
You can convert between notebook (.ipynb) and markdown (.qmd) representations of a document using the `quarto convert` command (see `quarto convert help` for details).
:::

## Inline Code

Both Jupyter and Knitr support executing inline code within markdown (e.g. to allow narrative to automatically use the most up to date computations). The syntax for this varies across the engines.

### Jupyter

To include executable expressions within markdown in a Jupyter notebook, you use [`IPython.display.Markdown`](https://ipython.readthedocs.io/en/stable/api/generated/IPython.display.html) to dynamically generate markdown from within an ordinary code cell. For example, if we have a variable `radius` we can use it within markdown as follows:

```` {.python}
```{python}
#| echo: false

from IPython.display import Markdown
Markdown("""
## Circle

The radius of the circle is {radius}.
""".format(radius = radius))
```
````

Note that we also include the `echo: false` option to ensure that the code used to generate markdown isn't included in the final output.

### Knitr

To include executable expressions within markdown for Knitr, enclose the expression in `` `r ` ``. For example, if we have a variable `radius` we can use it within markdown as follows:

``` {.markdown}
## Circle

The radius of the circle is `r radius`.
```

## Engine Binding

Earlier we said that the engine used for computations was determined automatically. You may want to customize this---for example you may want to use the Jupyter [R kernel](https://github.com/IRkernel/IRkernel) rather than Knitr, or you may want to use Knitr with Python code (via [reticulate](https://rstudio.github.io/reticulate/)).

Here are the basic rules for automatic binding:

+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Extension | Engine Binding                                                                                                                                                                                     |
+===========+====================================================================================================================================================================================================+
| .qmd      | Use Knitr engine if an `{r}` code block is discovered within the file                                                                                                                              |
|           |                                                                                                                                                                                                    |
|           | Use Jupyter engine if an executable code block (e.g. `{python}`) is discovered within the file. The kernel used is determined based on the language of the first executable code block discovered. |
|           |                                                                                                                                                                                                    |
|           | Use no engine if no executable code blocks are discovered.                                                                                                                                         |
+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| .ipynb    | Jupyter engine                                                                                                                                                                                     |
+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| .Rmd      | Knitr engine                                                                                                                                                                                       |
+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| .md       | No engine                                                                                                                                                                                          |
+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

You can override the engine used via the `engine` option. For example:

``` {.markdown}
engine: jupyter
```

``` {.markdown}
engine: knitr
```

You can also specify that no engine should be used via `engine: none`.

The presence of the `knitr` or `jupyter` option will also override the default engine:

``` {.markdown}
knitr: true
```

``` {.markdown}
jupyter: python3
```

Variations with additional engine-specific options also work to override the default engine:

``` {.markdown}
knitr:
  opts_knit:
    verbose: true
```

``` {.markdown}
jupyter:
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
```
