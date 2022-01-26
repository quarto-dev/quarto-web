When creating PDFs, you can choose to use either the default Pandoc [citation handling](https://pandoc.org/MANUAL.html#citations) based on citeproc, or alternatively use [natbib](https://ctan.org/pkg/natbib) or [BibLaTeX](https://ctan.org/pkg/biblatex). This can be controlled using the `cite-method` option. For example:

``` yaml
format:
  pdf: 
    cite-method: biblatex
```

The default is to use `citeproc` (Pandoc's built in citation processor).

See the main article on using [Citations](../authoring/footnotes-and-citations.qmd) with Quarto for additional details on citation syntax, available bibliography formats, etc.

### Options

When using natbib or biblatex you can specify the following additional options to affect how bibliographies are rendered:

| Option          | Description                  |
|-----------------|------------------------------|
| biblatexoptions | List of options for biblatex |
| natbiboptions   | List of options for natbib   |
| biblio-title    | Title for bibliography       |
| biblio-style    | Style for bibliography       |
