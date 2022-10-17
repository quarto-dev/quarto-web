### Rendering

You can use `quarto render` command line options to control caching behavior without changing the document's code. Use options to force the use of caching on all chunks, disable the use of caching on all chunks (even if it's specified in options), or to force a refresh of the cache even if it has not been invalidated:

```{.bash filename="Terminal"}
# use a cache (even if not enabled in options)
quarto render example.qmd --cache 

# don't use a cache (even if enabled in options)
quarto render example.qmd --no-cache 

# use a cache and force a refresh 
quarto render example.qmd --cache-refresh 
```

### Alternatives

If you are using caching to mitigate long render-times, there are some alternatives you should consider alongside caching.

#### Disabling Execution

If you are working exclusively with prose / markdown, you may want to disable execution entirely. Do this by specifying the `enabled: false` execute option For example:

``` yaml
---
title: "My Document"
format: html
execute: 
  enabled: false
---
```

Note that if you are authoring using Jupyter `.ipynb` notebooks (as opposed to plain-text `.qmd` files) then this is already the default behavior: no execution occurs when you call `quarto render` (rather, execution occurs as you work within the notebook).

#### Freezing Execution

If you are working within a project and your main concern is the cumulative impact of rendering many documents at once, consider using the `freeze` option.

{{< include ../projects/_freeze-basics.md >}} 

Learn more about using `freeze` with projects in the article on [managing project execution](https://quarto.org/docs/projects/code-execution.html#freeze).
