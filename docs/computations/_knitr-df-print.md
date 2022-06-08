

You can control how data frames are printed by default using the `df-print` document option. Available options include:

| Option    | Description                                                                                                                                                       |
|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `default` | Use the default S3 method for the data frame.                                                                                                                     |
| `kable`   | Markdown table using the [`knitr::kable()`](https://bookdown.org/yihui/rmarkdown-cookbook/kable.html) function.                                                   |
| `tibble`  | Plain text table using the [`tibble`](https://tibble.tidyverse.org/) package.                                                                                     |
| `paged`   | HTML table with paging for row and column overflow (implemented using [`rmarkdown::paged_table()`](https://pkgs.rstudio.com/rmarkdown/reference/paged_table.html))|


For example, here we specify that we want `paged` printing for data frames:

```yaml
---
title: "Document"
format: 
   html:
     df-print: paged
---
```
