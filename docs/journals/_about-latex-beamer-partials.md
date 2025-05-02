Starting with Quarto 1.7, which provides Pandoc 3.6.3, there are two sets of partials: those specific to Quarto and those inherited from Pandoc. The source directory contains: 

- partials with `.latex` extension that are inherited from Pandoc, 
- partials with `.tex` extension that are provided by Quarto directly for more granular customization.

template.tex

:   The core LaTeX template which includes the basic document skeleton plus the following partials. This can't be replaced as a `template-partial`, instead use the `template` option to provide your own template.

passoptions.latex

:   Contains declarations using the `\PassOptionsToPackage` command to modify options for packages that may be used later in the template.

doc-class.tex

:   Contains the document class declaration and options. By default we provide an identical document class to Pandoc, which implements many features. If you override this (which will be common), you will need to either implement support for the document class options or be aware that those options (e.g. `font-size`, `paper-size`, `classoption`, etc...) will not be supported in your output.

fonts.latex

:    Contains declarations to load LaTeX packages useful for fonts

font-settings.latex

:    Contains declarations to configure font packages, depending on which packages and LaTeX engine are used.

common.latex

:    Contains mostly declarations related to Pandoc features for LaTeX (like `linestretch`, `indent`, `verbatim-in-note`, `listings`, ...). Quarto modifies this template from Pandoc to use more specific partials by splitting content between `common.latex` and `pandoc.tex`. You can either replace this partial entirely or a more specific one from `pandoc.tex`. In general, the `common.latex` and `pandoc.tex` partials must always be included within your custom template.

::: {style="margin-left: 2em;"}

pandoc.tex

:   This includes configuration for most Pandoc features like text highlighting, tables, graphics, tight lists, citations, and header includes. In general, this partial must always be included within your custom template. In some circumstances, you may know that certain capabilities will not be needed, so this partial is further composed of the following partials, which could be used if sensible:


::: {style="margin-left: 4em;"}

tables.tex

:    Provides configuration for the output of tables, table captioning, and footnotes within tables.

graphics.tex

:    Provides image scaling and placement configuration.

citations.tex

:    When using CSL references, provides configuration and commands for outputting the bibliography.

babel-lang.tex

:    When `lang` option is used, provides configuration and command for babel support and other language related LaTeX configuration.

tightlist.tex

:    Provides the tight list command.

biblio-config.tex

:    Provides natbib or biblatex configurations. To opt-out of these configurations (e.g. for a custom format where a specific documentclass handles it already), rather than provide an empty partial, use `biblio-config: false` for your document configuration.

:::

:::

after-header-includes.latex

:    Contains what needs to be inserted after user specific header includes, like bookmark configuration.

hypersetup.latex

:    Contains the `\hypersetup` command configuration.

before-title.tex

:   Appears in the document premable just before the title block. By default, this partial is empty.

title.tex

:   Provides configuration of document metadata for writing the title block. Note that in addition to these templates and partials, Quarto will also make normalized authors and affiliations data available to the template, making is easy to write custom title blocks against a standard schema.

before-body.tex

:   Implements the frontmatter, title page, and abstract.

toc.tex

:   Creates the table of contents, list of figures, and list of tables.

before-bib.tex

:   Placed after the content of the document, but before the bibliography. By default contains nothing.

biblio.tex

:   Creates the bibliography using either natbib or biblatex if used.

after-body.tex

:   Provides a placeholder to attach content at the end of the body, right before `\end{document}`

A copy of some of Pandoc's original files are also kept in Quarto's source as a reference. These files are: `latex.template`, the main template used as `template.tex` containing all the partials; and `latex.common` the original version of `common.latex`,  which is tweaked to support Quarto's more specific partials.