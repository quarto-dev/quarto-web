{{< include ../_tool-chooser.md >}}

## Overview

Quarto has a wide variety of options available for controlling how code and computational output appear within rendered documents.
In this tutorial we'll take a `.qmd` file that has some numeric output and plots, and cover how to apply these options.

This tutorial will make use of the `matplotlib` and `plotly` Python packages.
The commands you can use to install them are given in the table below.

+-----------+---------------------------------------------------------+
| Platform  | Commands                                                |
+===========+=========================================================+
| Mac/Linux | ```{.bash filename="Terminal"}                          |
|           | python3 -m pip install jupyter matplotlib plotly pandas |
|           | ```                                                     |
+-----------+---------------------------------------------------------+
| Windows   | ```{.powershell filename="Terminal"}                    |
|           | py -m pip install jupyter matplotlib plotly pandas      |
|           | ```                                                     |
+-----------+---------------------------------------------------------+

If you want to follow along step-by-step in your own environment, create a `computations.qmd` file and copy the following content into it.

```` markdown
---
title: Quarto Computations
jupyter: python3
---

## NumPy

```{{python}}
import numpy as np
a = np.arange(15).reshape(3, 5)
a
```

## Matplotlib

```{{python}}
import matplotlib.pyplot as plt

fig = plt.figure()
x = np.arange(10)
y = 2.5 * np.sin(x / 20 * np.pi)
yerr = np.linspace(0.05, 0.2, 10)

plt.errorbar(x, y + 3, yerr=yerr, label='both limits (default)')
plt.errorbar(x, y + 2, yerr=yerr, uplims=True, label='uplims=True')
plt.errorbar(x, y + 1, yerr=yerr, uplims=True, lolims=True,
             label='uplims=True, lolims=True')

upperlimits = [True, False] * 5
lowerlimits = [False, True] * 5
plt.errorbar(x, y, yerr=yerr, uplims=upperlimits, lolims=lowerlimits,
             label='subsets of uplims and lolims')

plt.legend(loc='lower right')
plt.show(fig)
```

## Plotly

```{{python}}
import plotly.express as px
import plotly.io as pio
gapminder = px.data.gapminder()
gapminder2007 = gapminder.query("year == 2007")
fig = px.scatter(gapminder2007, 
                 x="gdpPercap", y="lifeExp", color="continent", 
                 size="pop", size_max=60,
                 hover_name="country")
fig.show()
```
````

Now, open a Terminal and run `quarto preview`, then position your editor side-by-side with the browser showing the preview.

``` {.bash filename="Terminal"}
quarto preview computations.qmd
```

![](images/text-editor-computations-preview.png){.border .column-page-outset-right fig-alt="Side-by-side preview of text editor on the left and live preview in the browser on the right."}

## Cell Output

All of the code in the source file is displayed within the rendered document.
However, in some cases, you may want to hide all of the code and just show the output.
Let's go ahead and specify `echo: false` within the document `execute` options to prevent code from being printed.

``` yaml
---
title: Quarto Computations
execute:
  echo: false
jupyter: python3
---
```

Save the file after making this change.
The preview will update to show the output with no code.

![](images/exec-echo-false-preview.png){.border fig-alt="Output of computations.qmd with 'echo: false' set, shows Title, resulting array in NumPy section, line chart in Matplotlib section, and interactive bubble chart in Plotly section."}

You might want to selectively enable code `echo` for some cells.
To do this add the `echo: true` cell option.
Try this with the NumPy cell.

```` markdown
```{{python}}
#| echo: true

import numpy as np
a = np.arange(15).reshape(3, 5)
a
```
````

Save the file and note that the code is now included for the NumPy cell.

![](images/exec-echo-true-preview.png){.border fig-alt="Rendered NumPy section of computations.qmd which shows the code and the resulting array."}

There a large number of other options available for cell output, for example `warning` to show/hide warnings (which can be especially helpful for package loading messages), `include` as a catch all for preventing any output (code or results) from being included in output, and `error` to prevent errors in code execution from halting the rendering of the document (and print the error in the rendered document).

See the [Jupyter Cell Options](/docs/reference/cells/cells-jupyter.qmd) documentation for additional details.

## Code Folding

Rather than hiding code entirely, you might want to fold it and allow readers to view it at their discretion.
You can do this via the `code-fold` option.
Remove the `echo` option we previously added and add the `code-fold` HTML format option.

``` yaml
---
title: Quarto Computations
format:
  html:
    code-fold: true
jupyter: python3
---
```

Save the file.
Now a "Code" widget is available above the output of each cell.

![](images/code-fold-preview.png){.border fig-alt="Rendered NumPy section of computations.qmd which shows a toggleable section that is labelled 'Code' and the resulting array."}

You can also provide global control over code folding.
Try adding `code-tools: true` to the HTML format options.

``` yaml
---
title: Quarto Computations
format:
  html:
   code-fold: true
   code-tools: true
jupyter: python3
---
```

Save the file and you'll see that a code menu appears at the top right of the document that provides global control over showing and hiding code.

![](images/text-editor-code-tools-preview.png){.border fig-alt="Rendered version of the computations.qmd document. A new code widget appears on top right of the document. The screenshot shows that the widget is clicked on, which reveals a drop down menu with three choices: Show All Code, Hide All Code, and View Source. In the background is the rendered document. The title is followed by some text, which is followed by a Code widget that would expand if clicked on, which is followed by the output of the code. The Code widgets are folded, so the code is not visible in the rendered document."}

## Figures

Let's improve the appearance of our Matplotlib output.
It could certainly stand to be wider, and it would be nice to provide a caption and a label for cross-referencing.

Go ahead and modify the Matplotlib cell to include `label` and `fig-cap` options as well as a call to `fig.set_size_inches()` to set a larger figure size with a wider aspect ratio:

```` markdown
```{{python}}
#| label: fig-limits
#| fig-cap: "Errorbar limit selector"

import matplotlib.pyplot as plt

fig = plt.figure()
fig.set_size_inches(12, 7)
```
````

Save the file to re-render and see the updated plot:

![](images/figure-options-preview.png){.border fig-alt="Rendered Matplotlib section of computations.qmd which includes a toggleable code-folding widget, the figure, and a caption under the figure that reads 'Figure 1: Errorbar limit selection.'"}

## Multiple Figures

The Plotly cell visualizes GDP and life expectancy data from a single year (2007).
Let's plot another year next to it for comparison and add a caption and subcaptions.
Since this will produce a wider visualization we'll also use the `column` option to lay it out across the entire page rather than being constrained to the body text column.

There are quite a few changes to this cell.
Copy and paste this code into `computations.qmd` if you want to try them locally:

``` python
#| label: fig-gapminder
#| fig-cap: "Life Expectancy and GDP"
#| fig-subcap:
#|   - "Gapminder: 1957"
#|   - "Gapminder: 2007"
#| layout-ncol: 2
#| column: page

import plotly.express as px
import plotly.io as pio
gapminder = px.data.gapminder()
def gapminder_plot(year):
    gapminderYear = gapminder.query("year == " + 
                                    str(year))
    fig = px.scatter(gapminderYear, 
                     x="gdpPercap", y="lifeExp",
                     size="pop", size_max=60,
                     hover_name="country")
    fig.show()
    
gapminder_plot(1957)
gapminder_plot(2007)
```

Save the file, the preview will update as follows:

![](images/plotly-preview.png){.border fig-alt="Output of Plotly section which shows two charts side-by-side. The first has a caption below that reads '(a) Gapminder: 1957', the second's caption reads '(b) Gapminder 2007'. Below both figures, there's a caption that reads 'Figure 1: Life Expectancy and GDP (Data from World Bank via gapminder.org).'"}

Let's discuss some of the new options used here.
You've seen `fig-cap` before but we've now added a `fig-subcap` option:

``` python
#| fig-cap: "Life Expectancy and GDP"
#| fig-subcap:
#|   - "Gapminder: 1957"
#|   - "Gapminder: 2007"
```

For code cells with multiple outputs adding the `fig-subcap` option enables us to treat them as subfigures.

We also added an option to control how multiple figures are laid out---in this case we specified side-by-side in two columns:

``` python
#| layout-ncol: 2
```

If you have 3, 4, or more figures in a panel there are many options available for customizing their layout.
See the article [Figures](/docs/authoring/figures.qmd) for details.

Finally, we added an option to control the span of the page that our figures occupy:

``` python
#| column: page
```

This allows our figure display to span out beyond the normal body text column.
See the documentation on [Article Layout](/docs/authoring/article-layout.qmd) to learn about all of the available layout options.

{{< include _footer.md >}}
