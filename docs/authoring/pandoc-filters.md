---
title: "Pandoc Filters"
format: html
---

## Overview

If the base features of Pandoc and Quarto don't do exactly what you need, you can very likely create a [Pandoc Filter](https://pandoc.org/filters.html) that bridges the gap.

Pandoc consists of a set of readers and writers. When converting a document from one format to another, text is parsed by a reader into pandoc's intermediate representation of the document---an "abstract syntax tree" or AST---which is then converted by the writer into the target format. The pandoc AST format is defined in the module [`Text.Pandoc.Definition`](https://hackage.haskell.org/package/pandoc-types-1.22/docs/Text-Pandoc-Definition.html) in the pandoc-types package.

A "filter" is a program that modifies the AST, between the reader and the writer.

    INPUT --reader--> AST --filter--> AST --writer--> OUTPUT

Pandoc's built-in citation processing is implemented as a filter, as are many of Quarto's extensions (e.g. cross-references, figure layout, etc.). Some other examples include:

| Filter                                                                                     | Description                                                                                                                          |
|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| [include-files](https://github.com/pandoc/lua-filters/tree/master/include-files)           | Filter to include other files in the document.                                                                                       |
| [include-code-files](https://github.com/pandoc/lua-filters/tree/master/include-code-files) | Filter to include code from source files.                                                                                            |
| [pagebreak](https://github.com/pandoc/lua-filters/tree/master/pagebreak)                   | Converts paragraps containing only the LaTeX `\newpage` or `\pagebreak` command into appropriate pagebreak markup for other formats. |

## Using Filters

Add one or more filters to document rendering using the `filters` option. For example:

``` {.yaml}
filters:
   - include-files.lua
   - pagebreak.lua
```

By default, user filters are run before Quarto's built-in filters. If you prefer to control the order of filters visa-vi Quarto just include `quarto` explicitly as a filter. For example, to run `include-files.lua` before Quarto filters and `pagebreak.lua` after, use this:

``` {.yaml}
filters:
  - include-files.lua
  - quarto
  - pagebreak.lua
```

## Writing Filters

You can write Pandoc filters using Lua (via Pandoc's built-in Lua interpreter) or using any other language using a JSON representation of the Pandoc AST piped to/from an external process.

We strongly recommend using Lua Filters, which have the following advantages:

-   No external dependencies

-   High performance (no serialization or process execution overhead)

-   Access to Pandoc's library of [Lua helper functions](https://pandoc.org/lua-filters.html#pandoc-module).

See the documentation on [Writing Lua Filters](https://pandoc.org/lua-filters.html) for additional details.

If you want to write a JSON filter, see the documentation on [Writing JSON filters](https://pandoc.org/filters.html).
