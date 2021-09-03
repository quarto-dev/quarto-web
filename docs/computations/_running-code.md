## Overview

Quarto supports executable code blocks within markdown. This allows you to create fully reproducible documents and reports---the code required to produce your output is part of the document itself, and is automatically re-run whenever the document is rendered.

There are currently two engines supported for running computations:

-   [Jupyter](https://jupyter.org/), for running code from Python and many other languages.

-   [Knitr](https://yihui.org/knitr/), for running code from R.

Extensive customization of code chunk output is supported, including the ability to hide code and/or output as well as fold code (make it visible only on demand).

## Code Blocks

Code blocks that use braces around the language name (e.g. ```` ```{python} ````) are executable, and will be run by Quarto during render. Here are a couple of simple examples in Python and R to illustrate (the output produced by the code block is shown on the Output tab):

### Python (Jupyter)

::: panel-tabset
## Code

    ---
    title: "Jupyter Document"
    format: 
      html:
        code-background: true
    jupyter: python3
    ---

    ```{{python}}
    import matplotlib.pyplot as plt
    plt.plot([1,2,3,4])
    plt.show()
    ```

    ```{{python}}
    import pandas as pd
    d = {'one' : [1., 2., 3., 4.],
         'two' : [4., 3., 2., 1.]}
    df = pd.DataFrame(d)
    df
    ```

## Output

![](/docs/computations/images/jupyter-document.png){.border fig-alt="The resulting document rendered from the source code in the `Code` tab using the Jupyter engine. At the top of the page is the title `Jupyter Document` in large text. There is a block of code with a gray background underneath the title. Underneath this block is a line plot of y = x. There is another code block with a gray background under this and a table underneath that."}
:::

Note that we added the `code-background: true` option to provide a background color for the code chunks (see the documentation on [Code Block](/docs/output-formats/html-code.qmd) options for additional details on customizing code block output).

### R (Knitr)

::: panel-tabset
## Code

    ---
    title: "Knitr Document"
    format: 
      html:
        code-background: true
    execute:
      warning: false
    ---

    ```{{r}}
    library(ggplot2)
    ggplot(airquality, aes(Temp, Ozone)) + 
            geom_point() + 
            geom_smooth(method = "loess", se = FALSE)
    ```

    ```{{r}}
    summary(airquality)
    ```

## Output

![](/docs/computations/images/knitr-document.png){.border .preview-image fig-alt="The resulting document rendered from the source code in the `Code` tab using the Knitr engine. At the top of the page is the title `Knitr Document` in large text. There is a block of code with a gray background underneath the title. Underneath this block is a scatterplot of the `airquality` dataset fit with a polynomial regression line and overlaid with a grey ribbon representing the confidence interval. There is another code block with a gray background under this plot with the output of `summary(airquality)`."}
:::

Note that we added the `execute: warning: false` option to suppress printing of warnings. See [Execution Options](/docs/computations/execution-options.md) for additional details.

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

### Escaping

If you need to write *about* executable code blocks (e.g. a Quarto tutorial like this one) without the blocks themselves becoming executable, use two curly braces rather than one. For example:

``` {{{python}}}
1 + 1
```

This will be output into the document as:

``` {{python}}
1 + 1
```

If you want to show an example with multiple code blocks and other markdown, just enclose the entire example in 4 backticks (e.g. ````` ```` `````) and use the two curly brace syntax for code blocks within. For example:

    ````
    ---
    title: "My document"
    ---

    Some markdown content.

    ```{{{python}}}
    1 + 1
    ```

    Some additional markdown content.

    ````

## Rendering

### Markdown

Quarto will automatically run computations in any markdown document that contains executable code blocks. For example, the Python example shown above might be rendered with:

``` bash
quarto render jupyter-document.qmd
```

The R example might have been rendered with:

``` bash
quarto render knitr-document.qmd
```

### Notebooks

The Python example above uses a markdown input file, Quarto can also render any Jupyter notebook (.ipynb):

``` bash
quarto render jupyter-document.ipynb
```

``` include
_jupyter-execute.md
```

## Inline Code

Both Jupyter and Knitr support executing inline code within markdown (e.g. to allow narrative to automatically use the most up to date computations). The syntax for this varies across the engines.

### Jupyter

To include executable expressions within markdown in a Jupyter notebook, you use [`IPython.display.Markdown`](https://ipython.readthedocs.io/en/stable/api/generated/IPython.display.html) to dynamically generate markdown from within an ordinary code cell. For example, if we have a variable `radius` we can use it within markdown as follows:

``` {{python}}
#| echo: false
radius = 10
from IPython.display import display, Markdown
display(Markdown("""
## Circle

The radius of the circle is {radius}.
""".format(radius = radius)))
```

Note that we also include the `echo: false` option to ensure that the code used to generate markdown isn't included in the final output.

### Knitr

To include executable expressions within markdown for Knitr, enclose the expression in `` `r ` ``. For example, if we have a variable `radius` we can use it within markdown as follows:

``` markdown
## Circle

The radius of the circle is `r radius`.
```
