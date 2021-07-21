## Includes

If you want to include additional content in your document from another file, you can use the `include-in` options:

| Option                | Description                                                                                                                                                                                                                              |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `include-in-header`   | Include contents of *file*, verbatim, at the end of the header. This can be used, for example, to include special CSS or JavaScript in HTML documents or to inject commands into the LaTeX preamble.                                     |
| `include-before-body` | Include contents of *file*, verbatim, at the beginning of the document body (e.g. after the `<body>` tag in HTML, or the `\begin{document}` command in LaTeX). This can be used to include navigation bars or banners in HTML documents. |
| `include-after-body`  | Include contents of *file*, verbatim, at the end of the document body (before the `</body>` tag in HTML, or the `\end{document}` command in LaTeX).                                                                                      |

You can specify a single file for multiple files for each of these options. For example:

``` yaml
format:
  html:
    include-in-header:
      - analytics.html
      - comments.html
    include-before-body: header.html
```

There are also a set of options you can use for inline includes (i.e. specifying the included content right within YAML):

| Option            | Description                             |
|-------------------|-----------------------------------------|
| `header-includes` | Inline version of `include-in-header`   |
| `include-before`  | Inline version of `include-before-body` |
| `include-after`   | Inline version `include-after-body`     |

For example:

``` yaml
format:
  pdf: 
    header-includes: |
      \usepackage{eplain}
      \usepackage{easy-todo}
```
