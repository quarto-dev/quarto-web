Typst comes with its [own citation processing system for bibliographies](https://typst.app/docs/reference/model/bibliography/) and using `format: typst` defaults to it. To specify a bibliography style using Typst's system, use the `bibliographystyle` option. Provide a string from [Typst's list of built-in styles](https://typst.app/docs/reference/model/bibliography/#parameters-style), e.g.:

  ``` yaml
  bibliography: refs.bib
  bibliographystyle: apa
  ```
  
  Or alternatively, provide a path to a local CSL file:
  
  ``` yaml
  bibliography: refs.bib
  bibliographystyle: my-csl-style.csl
  ```
  
  If you prefer to use Pandoc's citation processing, set `citeproc: true` explicitly in YAML header:
  
  ``` yaml
  citeproc: true
  bibliography: refs.bib
  csl: https://www.zotero.org/styles/apa-with-abstract
  ```
  
  To provide a citation style file to Pandoc's citation processing system use the `csl` option, as described in [Citation Style](/docs/authoring/citations.qmd#sec-citations-style).
  
  