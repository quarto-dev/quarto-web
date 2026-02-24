Typst comes with its [own citation processing system for bibliographies](https://typst.app/docs/reference/model/bibliography/) and using `format: typst` defaults to it.

Use the `csl` option to specify a bibliography style for Typst's citation processing. The value can be a path to a CSL file or one of [Typst's built-in styles](https://typst.app/docs/reference/model/bibliography/#parameters-style):

:::{layout-ncol="2"}
```{.yaml filename="document.qmd"}
---
bibliography: refs.bib
csl: my-style.csl
---
```

```{.yaml filename="document.qmd"}
---
bibliography: refs.bib
csl: apa
---
```
:::

The `bibliographystyle` option is also supported and accepts the same values as `csl`.

If you prefer to use Pandoc's citation processing instead of Typst's, set `citeproc: true` explicitly:

```{.yaml filename="document.qmd"}
---
citeproc: true
bibliography: refs.bib
csl: https://www.zotero.org/styles/apa-with-abstract
---
```

See [Citation Style](/docs/authoring/citations.qmd#sec-citations-style) for more on specifying citation styles with Pandoc's system.
