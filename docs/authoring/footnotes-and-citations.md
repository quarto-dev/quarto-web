---
title: Footnotes & Citations
format: html
suppress-bibliography: true
---

## Citations

Quarto will use Pandoc to automatically generate citations and a bibliography in a number of styles. To use this capability, you will need:

-   A quarto document formatted with citations (see [Citation Markdown](#sec-citations)).

-   A bibliographic data source (for example a `.bibtex` file)

-   Optionally, a `CSL` file which specifies the formatting to use when generating the citations and bibliography.

### Bibliographies

Quarto supports bibliographies in a wide variety of formats including BibTeX and CSL. Add a bibliography to your document using the `bibliography` YAML metadata field. For example:

``` {.yaml}
---
title: "My Document"
bibliography: references.bib
link-citations: true
---
```

You can provide more than one bibliography file if you would like by setting the `bibliography` field's value to a YAML array.

Note that we've also specified the `link-citations` option, which will make your citations hyperlinks to the corresponding bibliography entries.

See the [Pandoc Citations](https://pandoc.org/MANUAL.html#citations) documentation for additional information on bibliography formats.

### Citation Syntax {#sec-citations}

Quarto uses the standard Pandoc markdown representation for citations (e.g. `[@citation]`) --- citations go inside square brackets and are separated by semicolons. Each citation must have a key, composed of '\@' + the citation identifier from the database, and may optionally have a prefix, a locator, and a suffix. The citation key must begin with a letter, digit, or `_`, and may contain alphanumerics, `_`, and internal punctuation characters (`:.#$%&-+?<>~/`). Here are some examples:

+-----------------------------------------------------------------------+-------------------------------------------------------------------+
| Markdown Format                                                       | Output                                                            |
+=======================================================================+===================================================================+
|     Blah Blah [see @knuth1984, pp. 33-35; also @wickham2015, chap. 1] | Blah Blah [see @knuth1984, pp. 33-35; also @wickham2015, chap. 1] |
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
|     Blah Blah [@knuth1984, pp. 33-35, 38-39 and passim]               | Blah Blah [@knuth1984, pp. 33-35, 38-39 and passim]               |
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
|     Blah Blah [@wickham2015; @knuth1984].                             | Blah Blah [@wickham2015; @knuth1984].                             |
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
|     Smith says blah [-@wickham2015]                                   | Wickham says blah [-@wickham2015]                                 |
+-----------------------------------------------------------------------+-------------------------------------------------------------------+

You can also write in-text citations, as follows:

+-----------------------------------+-------------------------------+
| Markdown Format                   | Output                        |
+===================================+===============================+
|     @knuth1984 says blah.         | @knuth1984 says blah.         |
+-----------------------------------+-------------------------------+
|     @knuth1984 [p. 33] says blah. | @knuth1984 [p. 33] says blah. |
+-----------------------------------+-------------------------------+

See the [Pandoc Citations](https://pandoc.org/MANUAL.html#citations) documentation for additional information on citation syntax.

### Citation Style

Quarto uses Pandoc to format citations and bibliographies. By default, Pandoc will use the [Chicago Manual of Style](https://chicagomanualofstyle.org/) author-date format, but you can specify a custom formatting using CSL ([Citation Style Language](https://citationstyles.org)). To provide a custom citation stylesheet, provide a path to a CSL file using the `csl` metadata field in your document, for example:

``` {.yaml}
---
title: "My Document"
bibliography: references.bib
csl: nature.csl
---
```

You can find CSL files or learn more about using styles at the [CSL Project](https://github.com/citation-style-language/styles). You can browse the list of more than 8,500 Creative Commons CSL definitions in the CSL Project's [central repository](https://github.com/citation-style-language/styles) or Zotero's [style repository](https://www.zotero.org/styles).
