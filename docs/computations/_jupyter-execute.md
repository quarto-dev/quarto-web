Note that when rendering an `.ipynb` Quarto **will not** execute the cells within the notebook by default (the presumption being that you have already executed them while editing the notebook). If you want to execute the cells you can pass the `--execute` flag to render:

```{.bash filename="Terminal"}
quarto render notebook.ipynb --execute
```

You can also specify this behavior within the notebook's YAML front matter:

``` yaml
---
title: "My Notebook"
execute: 
  enabled: true
---
```
