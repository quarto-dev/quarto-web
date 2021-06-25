---
title: Hugo
format: html
---

## Overview

[Hugo](https://gohugo.io/) is a very popular open source website publishing system. Pages in Hugo websites are typically written in plain markdown, so don't have a straightforward way to automatically and reproducibly incorporate computational output.

Using the Quarto `hugo` format, you can incorporate computational output (e.g. R or Python code that produces plots) into Hugo websites. This article explains how.

## Creating a Page

Hugo articles and posts that use Quarto should live in their own directory (taking advantage of the Hugo [Page Bundles](https://gohugo.io/content-management/page-bundles/) feature). This allows any content generated/referenced by the page (e.g. plot output) to live right alongside the markdown source.

To create a new page that uses Quarto:

1.  Create a new directory at the location in your site's `content` directory where you want the article to live.

2.  Add a markdown file to that directory (usually with the same name as the directory). This file should not use the `.md` extension (to prevent Hugo from rendering it). For example, use the extension `.qmd` (for Jupyter) or `.Rmd` (for Knitr).

3.  Add the requisite Hugo metadata to the document's front matter, then also specify `format: hugo` and any other required Quarto options.

For example, let's say we wanted to create a new article named `hello-quarto` within the `content` directory. The filesystem would look like this:

``` {.ini}
mysite/
  content/
    hello-quarto/
      hello-quarto.qmd
```

Here's what the source code `hello-quarto.qmd` might look like:

```` {.yaml}
---
title: Hello, Quarto
format: hugo
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

## Workflow

Generating pages for Hugo requires just a simple Quarto render:

``` {.bash}
quarto render hello-quarto.qmd
```

Whenever your render the `hello-quarto.qmd` file, Quarto will execute the code in the file (writing any generated plots, etc. into the article's directory) and then generate an `index.md` file that is subsequently processed by Hugo.

If you are running the `hugo server` command for live preview, you will see the updated version of your page whenever you render.

Note that the `index.md` file is *only* updated when you explicitly render with Quarto. Running the `hugo` command to build your site just renders the `index.md` file --- if you want to regenerate this file based on updated code or data you need to explicitly `quarto render` it.
