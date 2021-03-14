---
title: "Quarto Extensions"
format: html
---


## Quarto Extensions

This article is a placeholder for documentation on the (yet to be developed) Quarto extension system.

Our plan is to provide facilities for creating the following extension types:

| **Type**                            | Description                                                                                                                                                                                                                                                 |
|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Document Format                     | New formats derived from the built in pandoc formats. For example, PDF formats that enable creating articles using the LaTeX templates of various journals (much like the [rticles](https://github.com/rstudio/rticles) suite of custom R Markdown formats) |
| Project Format                      | Output formats for `website` or `book` [Quarto Projects](quarto-projects.html) (both still under development).                                                                                                                                                                  |
| Document Template                   | Pandoc [templates](https://pandoc.org/MANUAL.html#templates) and scaffold content for documents (e.g. to provide a common structure or look and feel across documents).                                                                                     |
| Document Filter                     | Pandoc [Lua filters](https://pandoc.org/lua-filters.html) for low-level transformation of the Pandoc AST.                                                                                                                                                   |
