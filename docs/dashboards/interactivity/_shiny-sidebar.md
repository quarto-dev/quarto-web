
![](/docs/dashboards/images/shiny-simple.png){.border}

Here is the source code for this dashboard (click on the numbers on the far right for additional explanation):

````{.python .pymd}
---
title: "Penguin Bills"
format: 
  dashboard: # <1>
    orientation: columns # <1>
server: shiny # <2>
---

```{{python}}
import seaborn as sns
penguins = sns.load_dataset("penguins")
```

## Column {.sidebar} # <3>

```{{python}}
from shiny import render, reactive, ui
ui.input_select("x", "Variable:",   # <4>
                choices=["bill_length_mm", "bill_depth_mm"])
ui.input_select("dist", "Distribution:", choices=["hist", "kde"])
ui.input_checkbox("rug", "Show rug marks", value = False)  # <4>
```

## Column

```{{python}}
@render.plot # <5>
def displot():
    sns.displot(
        data=penguins, hue="species", multiple="stack",
        x=input.x(), rug=input.rug(),kind=input.dist()) # <5>
```

````

1.  We specify `orientation: columns` for the dashboard so that we can layout a sidebar next to our main outputs.

2.  The `server: shiny` option instructs Quarto to run a Shiny Server behind the document.

3.  Create sidebars by adding the `.sidebar` class to any column. Sidebars can include code cells as well as images, narrative, and links.

4.  A series of Shiny input elements (interacting with them updates the `input` object)

5.  The plot is rendered and updated according to the current `input` values.


