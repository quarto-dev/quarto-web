## Table of Contents

Use the `toc` option to include an automatically generated table of contents in the output document. Use the `toc-depth` option to specify the number of section levels to include in the table of contents. The default is 3 (which means that level-1, 2, and 3 headings will be listed in the contents). For example:

``` yaml
toc: true
toc-depth: 2
```

You can customize the title used for the table of contents using the `toc-title` option:

``` yaml
toc-title: Contents
```

If you want to exclude a heading from the table of contents, add both the `.unnumbered` and `.unlisted` classes to it:

``` markdown
### More Options {.unnumbered .unlisted}
```

{{< include _document-options-section-numbering.md >}}

{{< include _document-options-syntax-highlighting.md >}}

{{< include _code-annotation.md >}}
