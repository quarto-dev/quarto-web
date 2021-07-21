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
