## Section Numbering

Use the `number-sections` option to number section headings in the output document. For example:

``` yaml
number-sections: true
```

Use the `number-depth` option to specify the deepest level of heading to add numbers to (by default all headings are numbered). For example:

``` yaml
number-depth: 3
```

To exclude an individual heading from numbering, add the `.unnumbered` class to it:

``` markdown
### More Options {.unnumbered}
```

::: {.content-visible when-meta="doc-type.typst"}
You can also customize the display of the section numbers with the `section-numbering` YAML option. This option expects a string that describes the numbering schema. For example, the following schema describes numbering sections with numerals, subsection with uppercase letters, and subsubsections with lower case letters, using `.` as a separator:

```yaml
---
section-numbering: 1.A.a
---
```

You can read more about specifying the numbering schema in the [Typst documentation for numbering](https://typst.app//docs/reference/model/numbering#parameters-numbering).
:::
