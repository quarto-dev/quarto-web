## Knitr Options

If you are using the Knitr cell execution engine you can specify default document-level Knitr options in YAML. For example:

``` yaml
---
title: "My Document"
format: html
knitr:
  opts_chunk: 
    collapse: true
    comment: "#>"
---
```

You can additionally specify global Knitr options using `opts_knit`.

In the example above we establish default Knitr options for a single document. You can also add shared `knitr` options to a project-wide `_quarto.yml` file or a project-directory scoped `_metadata.yml` file.
