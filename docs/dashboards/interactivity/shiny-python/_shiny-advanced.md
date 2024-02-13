```` {.python .pymd}
---
title: "Palmer Penguins"
author: "Cobblepot Analytics"
format: dashboard
server: shiny # <1>
---

```{{python}} # <2>
#| context: setup
import seaborn as sns
from shiny import render, reactive, ui
penguins = sns.load_dataset("penguins")
``` # <2>

# {.sidebar} # <3>

![](images/penguins.png){width="80%"}

```{{python}}
species = list(penguins["species"].value_counts().index) # <4>
ui.input_checkbox_group(
    "species", "Species:",
    species, selected = species
)

islands = list(penguins["island"].value_counts().index)
ui.input_checkbox_group(
    "islands", "Islands:",
    islands, selected = islands
) # <4>

@reactive.Calc # <5>
def filtered_penguins():
    data = penguins[penguins["species"].isin(input.species())]
    data = data[data["island"].isin(input.islands())]
    return data
``` # <5>

```{{python}}
ui.input_select("dist", "Distribution:", choices=["kde", "hist"]) # <6>
ui.input_checkbox("rug", "Show rug marks", value = False) # <6>
```

[Learn more](https://pypi.org/project/palmerpenguins/) about the
Palmer Penguins dataset.

# Plots # <7>

```{{python}}
@render.plot
def depth():
    return sns.displot(  # <8>
        filtered_penguins(), x = "bill_depth_mm",
        hue = "species", kind = input.dist(),
        fill = True, rug=input.rug()
    ) # <8>
```

```{{python}}
@render.plot
def length():
    return sns.displot(
        filtered_penguins(), x = "bill_length_mm",
        hue = "species", kind = input.dist(),
        fill = True, rug=input.rug()
    )
```

# Data

```{{python}} 
@render.data_frame
def dataview():
    return render.DataGrid(filtered_penguins()) # <9>
```
````

1.  The `server: shiny` option instructs Quarto to run a Shiny Server behind the document.

2.  The `context: setup` cell option indicates that this code cell should run when the application starts (as opposed to when each new client session starts). Expensive initialization code (e.g. loading data) should be placed in `context: setup`.

3.  Create global sidebars by adding the `.sidebar` class to a level 1 header. Sidebars can include code cells as well as images, narrative, and links.

4.  These checkbox input groups have their contents dynamically driven from the available categories in the `species` and `islands` fields of the dataset.

5.  When the user interacts with the checkbox groups this results in a different filtered view of the dataset. The `@reactive.Calc` function recomputes the filtered dataset and makes it available as `filtered_penguins()`.

6.  These inputs affect the display of plots but not the contents of the filtered dataset.

7. Level 1 headings (here `# Plots` and `# Data`) create pages within the dashboard.

8.  Plots are rendered by referencing the filtered dataset (`filtered_penguins()` as well as the plot display oriented inputs (`input.dist()` and `input.rug()`). Plots are automatically re-rendered when the dataset or these inputs change.

9. The Data tab also references `filtered_penguins()` and is updated whenever the filtered data changes.