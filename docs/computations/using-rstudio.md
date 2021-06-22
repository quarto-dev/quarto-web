---
title: Using RStudio
description: "RStudio IDE v1.4 or higher includes support for editing and preview of Quarto documents. This works for plain markdown. Knitr (Rmd), as well as markdown files that use the Jupyter engine."
format: html
---

## Overview

RStudio IDE v1.4 or higher includes support for editing and preview of Quarto documents. This works for plain markdown. Knitr (Rmd), as well as markdown files that use the Jupyter engine.

Quarto is also designed to be highly compatible with existing [R Markdown](https://rmarkdown.rstudio.com/) documents. You should generally be able to use Quarto to render any existing Rmd document without changes.

## Knit with Quarto

You need to take one important measure to ensure that RStudio knows to use Quarto rather than R Markdown to render when you click the **Knit** button. To opt-in to rendering with Quarto, add the following `knit` option to the document's YAML metadata:

``` {.yaml}
---
title: "My Document"
author: "Jone Smith"
knit: quarto render
---
```

Another difference between R Markdown and Quarto is that R Markdown uses the `output` option to indicate the output format while Quarto uses `format`. As such, including a `format` option (and no `output` option) will also cause RStudio to use Quarto:

``` {.yaml}
---
title: "My Document"
author: "Jane Smith"
format: html
---
```

::: {.callout-note}
Future versions of RStudio will have more intelligence about when a document should be rendered with Quarto, and will no longer require the options described above. For the time being though you should provide the `knit` or the `format` option in documents you want to render with Quarto.
:::

## Chunk Options

One important difference between R Markdown documents and Quarto documents is that in Quarto chunk options are generally included in special comments at the top of code chunks rather than within the line that begins the chunk. For example:

```` {.python}
```{r}
#| echo: false
#| fig.cap: "Air Quality"

library(ggplot2)
ggplot(airquality, aes(Temp, Ozone)) + 
        geom_point() + 
        geom_smooth(method = "loess", se = FALSE)
```
````

Quarto uses this approach to both better accommodate longer options like `fig.cap`, `fig.subcap`, and `fig.alt` as well as to make it straightforward to edit chunk options within more structured editors that don't have an easy way to edit chunk metadata (e.g. most traditional notebook UIs).

::: {.callout-note}
Note that if you prefer it is still possible to include chunk options on the first line (e.g. ```` ```{r, echo = FALSE} ````). That said, we recommend using the comment-based syntax to make documents more portable and consistent across execution engines.
:::

Chunk options included this way use YAML syntax rather than R syntax for consistency with options provided in YAML front matter. You can still however use R code for option values by prefacing them with `!expr`. For example:

``` {.python}
#| fig.cap: !expr paste("Air", "Quality")
```

## Rmd Extension

While Quarto doesn't technically require that documents targeting the Knitr engine have an .Rmd extension, you will generally be better off using this extension. This is because many editors (including RStudio) will enable features like interactive chunk execution when they see the .Rmd extension.

If you prefer to use the .`md` or `.qmd` extension, you can still tell RStudio to enable .Rmd features by explicitly setting the file type to "R Markdown" using the popup menu at the bottom right of the editor:

![](images/rstudio-file-type.png){.preview-image}

## Jupyter Engine

You can also render Quarto markdown documents that target the Jupyter engine within RStudio. These files will generally have an `.qmd` extension and include a `jupyter` option in the YAML front matter indicating which kernel to use. For example:

``` {.yaml}
---
title: "Matplotlib Demo"
author: "Norah Smith"
jupyter: python3
```

Note that the presence of the `jupyter` option also provides a sufficient hint to RStudio that it should render the file using Quarto rather than R Markdown.

You can also enable interactive cell execution for `.qmd` files by setting the file type to "R Markdown" as described immediately above.

## R Package

You can render Quarto documents from the R console using the **quarto** R package. To install the R package:

``` {.r}
install.packages("quarto")
```

Then, to render a document:

``` {.r}
library(quarto)
quarto_render("document.Rmd")
```
