
One important difference between R Markdown documents and Quarto documents is that in Quarto chunk options are typically included in special comments at the top of code chunks rather than within the line that begins the chunk. For example:

```{{r}}
#| echo: false
#| fig-cap: "Air Quality"

library(ggplot2)
ggplot(airquality, aes(Temp, Ozone)) + 
  geom_point() + 
  geom_smooth(method = "loess", se = FALSE)
```

Quarto uses this approach to both better accommodate longer options like `fig-cap`, `fig-subcap`, and `fig-alt` as well as to make it straightforward to edit chunk options within more structured editors that don't have an easy way to edit chunk metadata (e.g. most traditional notebook UIs).

::: callout-note
Note that if you prefer it is still possible to include chunk options on the first line (e.g. ```` ```{r, echo = FALSE} ````). That said, we recommend using the comment-based syntax to make documents more portable and consistent across execution engines.
:::

Chunk options included this way use YAML syntax rather than R syntax for consistency with options provided in YAML front matter. You can still however use R code for option values by prefacing them with `!expr`. For example:

``` r
#| fig-cap: !expr 'paste("Air", "Quality")'
```

::: callout-caution
the `!expr` syntax is an example of a YAML "tag" literal, and it can be unintuitive. `!expr` needs to be followed by a _single YAML "flow scalar"_: see the [YAML spec](https://yaml.org/spec/1.2.2/#73-flow-scalar-styles) for details on how double-quoted, single-quoted, and unquoted strings work.
:::
