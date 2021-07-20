---
title: Using JupyterLab
description: "Quarto can render Jupyter notebooks represented as plain text (.qmd) or as a normal notebook file (.ipynb). One benefit of using .ipynb is that you can use JupyterLab as your editor."
format: html
---

## Overview

Quarto can render Jupyter notebooks represented as plain text (.qmd) or as a normal notebook file (.ipynb). One benefit of using .ipynb is that you can use [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/) as your editor.

Here is the "Hello, Quarto" example from the homepage inside JupyterLab:

![](images/jupyter-lab.png){.border .preview-image}

There are a few things to point out about this notebook:

-   The first cell contains document level options in a YAML front matter block.

-   The markdown cell immediately below uses the Quarto markdown cross-reference syntax (`@fig-polar`) to refer to the figure below.

-   There are a couple of comment lines at the top of the code cell providing output options.

We'll describe each of these in more depth below. First though, let's render the notebook to HTML with Quarto:

``` bash
quarto render basics-jupyter.ipynb
```

![](images/hello-quarto.png){.border}

``` include
_jupyter-execute.md
```

There are many other execution options available (e.g. to control caching, optimizing kernel start-up time, etc.). Learn more about these options in [Execution Options](execution-options.md).

## Running JupyterLab {.platform-table}

To run JupyterLab, invoke the `jupyter` module from within the shell where you are using Quarto:

+-----------+------------------------+
| Platform  | Command                |
+===========+========================+
| Windows   | ``` bash               |
|           | py -m jupyter lab      |
|           | ```                    |
+-----------+------------------------+
| Mac/Linux | ``` bash               |
|           | python3 -m jupyter lab |
|           | ```                    |
+-----------+------------------------+

## YAML Front Matter

The first cell of your notebook should be a **Raw** cell that contains the document title, author, and any other options you need to specify. Note that you can switch the type of a call to **Raw** using the notebook toolbar:

![](images/jupyter-lab-yaml.png){.border}

In this example we specify that we want code to appear collapsed by default. There are YAML options to control many other aspects of document rendering. See the documentation on [Authoring](../authoring/markdown-basics.md) and [Output Formats](../docs/output-formats/html-basics.qmd) for additional details.

## Markdown Cells

Here's the underlying code for the markdown cell:

![](images/jupyter-lab-markdown.png){.border}

Note that a Quarto cross-reference (`@fig-polar`) is included in the markdown. Any valid Pandoc markdown syntax can be included in markdown cells.

## Output Options

Quarto uses leading comments with a special prefix (`#|`) to denote cell options. Here we specify the `label` and `fig.cap` options so that the plot generated from the cell can be cross-referenced.

![](images/jupyter-lab-output-options.png)

Note that options must appear at the very beginning of the cell. As with document front-matter, option names/values use YAML syntax.

There are many output options available, including options to optionally hide code, warnings, and/or output. See the documentation on [Output Outputs](../computations/execution-options.md#output-options) for additional details.

## Plain Text Editing

It's also possible to edit Jupyter notebooks in a plain-text markdown format. You might prefer this if there is more narrative than code in your notebook or if you want to use a file format that is more version control friendly.

Markdown files with embedded code chunks should use the file extension `.qmd` to indicate that they aren't ordinary markdown files but rather contain embedded computations to be run by Quarto.

To make a code block executable in a markdown notebook, just add braces around the name of the language. For example:

```` python
```{python}
1 + 1
```
````

Here is the plain text markdown version of the notebook used in the previous examples:

```` python
---
title: "Matplotlib Demo"
author: "Norah Smith"
date: "May 22nd, 2021"
format: 
  html:
    code-fold: true
jupyter: python3
---

## Polar Axis

For a demonstration of a line plot on a polar axis, see @fig-polar.

```{python}
#| label: fig-polar
#| fig.cap: "A line plot on a polar axis"

import numpy as np
import matplotlib.pyplot as plt

r = np.arange(0, 2, 0.01)
theta = 2 * np.pi * r
fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
ax.plot(theta, r)
ax.set_rticks([0.5, 1, 1.5, 2])
ax.grid(True)
plt.show()
```
````

Note that we've added the `jupyter: python3` option to the YAML front matter to indicate which Jupyter kernel to render with. You would render this document with:

``` bash
quarto render basics-jupyter.qmd
```

You can convert between .ipynb and .qmd representations of a notebook using the `quarto convert` command. For example:

``` bash
quarto convert basics-jupyter.ipynb --to markdown
quarto convert basics-jupyter.qmd --to notebook
```

See `quarto convert help` for additional details on converting notebooks.
