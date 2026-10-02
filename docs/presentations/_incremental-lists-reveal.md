## Incremental Lists

By default number and bullet lists within slides are displayed all at once. You can override this globally using the `incremental` option. For example:

```{.yaml code-preview="examples/incremental-lists-1.qmd" code-preview-title="Example presentation with incremental lists"}
title: "My Presentation"
format:
  {{< meta slide-format >}}:
    incremental: true   
```

You can also explicitly make any list incremental or non-incremental by surrounding it in a div with an explicit class that determines the mode. To make a list incremental do this:

```{.markdown code-preview="examples/incremental-lists-2.qmd" code-preview-title="Example slide with an incremental list"}
::: {.incremental}
- Eat spaghetti
- Drink wine
:::
```

To make a list non-incremental do this:

```{.markdown code-preview="examples/incremental-lists-3.qmd" code-preview-title="Example slide with a non-incremental list"}
::: {.nonincremental}
- Eat spaghetti
- Drink wine
:::
```
