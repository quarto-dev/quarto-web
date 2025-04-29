Since Quarto 1.7 providing Pandoc 3.6.3, there are two sets of partials: Quarto's specific partials and Pandoc's partials. The source directory contains both: 

- partials with `.latex` extension are the one inherited from Pandoc, 
- partials with `.tex` extension are the one provided by Quarto directly to offer more granular customization.

Quarto's partials and main template are based upon original template and partials from Pandoc - a copy of the file is kept in our source as reference when it was modified to fit Quarto's organization. Those files are: `latex.template` for the main template used as `template.tex` containing all the partials, and `latex.common` for the original version of `common.latex` as the original partial from Pandoc is tweaked to support Quarto's more specific partials.

template.tex

:   The core LaTeX template which includes the basic document skeleton plus the following partials. This can't be replaced as a `template-partial`, instead use the `template` option to provide your own template.

passoptions.latex

:   Contains declaration using `\PassOptionsToPackage` command to modify options for packages that may be used later in the template.

doc-class.tex

:   Contains the document class declaration and options. By default we provide the identical document class that Pandoc provides, implementing many features. If you override this (which will be common), you will need to either implement support for the document class options or be aware that those options (e.g. font-size, paper-size, classoption, etc...) will not be supported in your output.

fonts.latex

:    Contains declarations to load LaTeX packages useful for fonts

font-settings.latex

:    Contains declarations about fonts packages configuration, depending on packages used and LaTeX engine used.

common.latex

:    Contains mostly declarations related to Pandoc features for LaTeX (like `linestretch`, `indent`, `verbatim-in-note`, `listings`, ...). This template from Pandoc is modified by Quarto to use more specific partials by splitting content between `common.latex` and `pandoc.tex`. You can either replace on of this partial entirely or a more specific one from `pandoc.tex`. In general, `common.latex` and `pandoc.tex` partials must always be included within your custom template.

pandoc.tex

:   This includes configuration for most pandoc feature like text highlighting, tables, graphics, tight lists, citations, and header includes. In general, this partial must always be included within your custom template. In some circumstances, you may know that certain capabilities will not be needed, so you this partial is further composed of the following partials, which could be used if sensible:


::: {style="margin-left: 2em;"}

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

:    Provides natbib or biblatex configurations. Instead of providing an empty partial to opt-out those configurations (e.g. for a custom format where a specific documentclass handles it already), use `biblio-config: false` for your document configuration.

:::

after-header-includes.latex

:    Contains what needs to be inserted after user specific header includes, like bookmark configuration.

hypersetup.latex

:    Contains `\hypersetup` command configuration.

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