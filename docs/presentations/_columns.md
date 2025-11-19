## Multiple Columns

To put material in side by side columns, you can use a native div container with class `.columns`, containing two or more div containers with class `.column`[ and a `width` attribute]{.content-visible unless-meta="is_pptx"}:

::: {.content-visible unless-meta="is_pptx"}
``` markdown
:::: {.columns}

::: {.column width="40%"}
contents...
:::

::: {.column width="60%"}
contents...
:::

::::
```
:::


::: {.content-hidden unless-meta="is_pptx"}
``` markdown
:::: {.columns}

::: {.column}
contents...
:::

::: {.column}
contents...
:::

::::
```

:::