---
title: "Shortcodes & Filters"
description: "Shortcodes and filters provide extensions to Pandoc markdown. If the base features of Pandoc and Quarto don’t do exactly what you need, you can very likely create a a filter that bridges the gap."
format: html
---

## Shortcodes

Shortcodes are special markdown directives that generate various types of content. Quarto shortcodes are similar in form and function to [Hugo shortcodes](https://gohugo.io/content-management/shortcodes/) and [WordPress shortcodes](https://codex.wordpress.org/Shortcode).

Quarto currently supports just two shortcodes: `meta` and `var`. Additional shortcodes (e.g. for inserting videos, tweets, gists, etc.) will be developed soon.

### meta 

The `meta` shortcode allows you to insert content from Pandoc metadata (e.g. YAML at the top of the document and/or in `_quarto.yml`).

For example, the following shortcode inserts the value of the `title` field from YAML metadata:

``` {.markdown shortcodes="false"}
{{< meta title >}}
```

You can dereference sub-keys using the dot (`.)` delimiter. For example:

``` {.markdown shortcodes="false"}
{{< meta author.affiliation >}}
```

### var

The `var` shortcode enables you to insert content from a project-level `_variables.yml` file. Create this file alongside your `_quarto.yml` project file, and then include references to those variables within any document in your project.

Variables can be either simple values or can include arbitrary markdown content. To define variables, create a `_variables.yml` file in the root directory of your project. For example:

``` {.yaml}
version: 1.2

email:
  info: info@example.com
  support: support@example.com

engine:
  jupyter: "[Jupyter](https://jupyter.org)"
  knitr: "[Knitr](<https://yihui.name/knitr>)"
```

Note that the `engine` variable values include markdown for hyperlinks.

To include the value of a variable, use the `{{</* var */>}}` shortcode, for example:

``` {.markdown shortcodes="false"}
Version {{< var version >}} is a minor upgrade.

Please contact us at {{< var email.info >}}.

Quarto includes {{< var engine.jupyter >}} and 
{{< var engine.knitr >}} computation engines.
```

### Escaping

If you are writing documentation about using shortcodes (for example, this article!) you might need to prevent them from being processed. You can do this in two ways:

1.  Escape the shortcode reference like this:

    ``` {.markdown shortcodes="false"}
    {{</* var version */>}}
    ```

2.  Add a `shortcodes=false` attribute to any code block you want to prevent processing of shortcodes within:

    ```` {.markdown shortcodes="false"}
    ```{shortcodes=false}
    {{< var version >}}
    ```
    ````

## Filters

If the base features of Pandoc and Quarto don't do exactly what you need, you can very likely create a [Pandoc Filter](https://pandoc.org/filters.html) that bridges the gap.

Pandoc consists of a set of readers and writers. When converting a document from one format to another, text is parsed by a reader into pandoc's intermediate representation of the document---an "abstract syntax tree" or AST---which is then converted by the writer into the target format. The pandoc AST format is defined in the module [`Text.Pandoc.Definition`](https://hackage.haskell.org/package/pandoc-types-1.22/docs/Text-Pandoc-Definition.html) in the pandoc-types package.

A "filter" is a program that modifies the AST, between the reader and the writer.

    INPUT --reader--> AST --filter--> AST --writer--> OUTPUT

Pandoc's built-in citation processing is implemented as a filter, as are many of Quarto's extensions (e.g. cross-references, figure layout, etc.). Some other examples include:

+--------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| Filter                                                                                     | Description                                                                                                                          |
+============================================================================================+======================================================================================================================================+
| [include-files](https://github.com/pandoc/lua-filters/tree/master/include-files)           | Filter to include other files in the document.                                                                                       |
+--------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| [include-code-files](https://github.com/pandoc/lua-filters/tree/master/include-code-files) | Filter to include code from source files.                                                                                            |
+--------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| [pagebreak](https://github.com/pandoc/lua-filters/tree/master/pagebreak)                   | Converts paragraps containing only the LaTeX `\newpage` or `\pagebreak` command into appropriate pagebreak markup for other formats. |
+--------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------+

### Using Filters

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

### Writing Filters

You can write Pandoc filters using Lua (via Pandoc's built-in Lua interpreter) or using any other language using a JSON representation of the Pandoc AST piped to/from an external process.

We strongly recommend using Lua Filters, which have the following advantages:

-   No external dependencies

-   High performance (no serialization or process execution overhead)

-   Access to Pandoc's library of [Lua helper functions](https://pandoc.org/lua-filters.html#pandoc-module).

See the documentation on [Writing Lua Filters](https://pandoc.org/lua-filters.html) for additional details.

If you want to write a JSON filter, see the documentation on [Writing JSON filters](https://pandoc.org/filters.html).
