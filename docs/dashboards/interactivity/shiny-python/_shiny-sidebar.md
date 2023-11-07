
![](/docs/dashboards/images/shiny-simple.png){.border fig-alt="A screenshot of a Penguin Bills dashboard. A sidebar on the left contains two dropdown menus, one for Variable and one for Distribution and a checkbox to show rugmarks. On the right a plot occupies the full page height and shows a histogram of bill_length_mm colored by species."}

Here is the source code for this dashboard (click on the numbers on the far right for additional explanation):

````{.python .pymd}
---
title: "Penguin Bills"
format: dashboard
server: shiny # <1>
---

```{{python}}
import seaborn as sns
penguins = sns.load_dataset("penguins")
```

## {.sidebar} # <2>

```{{python}}
from shiny import render, ui
ui.input_select("x", "Variable:",   # <3>
                choices=["bill_length_mm", "bill_depth_mm"])
ui.input_select("dist", "Distribution:", choices=["hist", "kde"])
ui.input_checkbox("rug", "Show rug marks", value = False)  # <3>
```

## Column

```{{python}}
@render.plot # <4>
def displot():
    sns.displot(
        data=penguins, hue="species", multiple="stack",
        x=input.x(), rug=input.rug(), kind=input.dist()) # <4>
```

````

1.  The `server: shiny` option instructs Quarto to run a Shiny Server behind the document.

2.  Create sidebars by adding the `.sidebar` class to a level 2 header. Sidebars can include code cells as well as images, narrative, and links.

3.  A series of Shiny input elements (interacting with them updates the `input` object)

4.  The plot is rendered and updated according to the current `input` values.


