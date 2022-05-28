## Knitr Options

If you are using the Knitr cell execution engine, you can specify default document-level [Knitr chunk options](https://yihui.org/knitr/options/) in YAML. For example:

``` yaml
---
title: "My Document"
format: html
knitr:
  opts_chunk: 
    collapse: true
    comment: "#>" 
    R.options:
      knitr.graphics.auto_pdf: true
---
```

You can additionally specify global Knitr options using `opts_knit`.

The `R.options` chunk option is a convenient way to define R options that are set temporarily via [`options()`](https://rdrr.io/r/base/options.html) before the code chunk execution, and immediately restored afterwards.

In the example above, we establish default Knitr chunk options for a single document. You can also add shared `knitr` options to a project-wide `_quarto.yml` file or a project-directory scoped `_metadata.yml` file.
