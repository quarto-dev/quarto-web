## Render Targets

By default, all valid Quarto input files (.qmd, .ipynb, .md, .Rmd) in the project directory will be rendered, save for ones with:

1.  A file or directory prefix of `.` (hidden files)

2.  A file or directory prefix of `_` (typically used for non top-level files, e.g. ones [included](../authoring/includes.qmd) in other files)

3.  Files named `README.md` or `README.qmd` (which are typically not actual render targets but rather informational content about the source code to be viewed in the version control web UI).

If you don't want to render all of the target documents in a project, or you wish to control the order of rendering more precisely, you can add a `project: render: [files]` entry to your project metadata. For example:

``` yaml
project:
  render:
    - section1.qmd
    - section2.qmd
```

Note that you can use wildcards when defining the `render` list. For example:

``` yaml
project:
  render:
    - section*.qmd
```

You can also use the prefix `!` to ignore some files or directories in the `render` list. Note that in that case you need to start by specifying everything you *do* want to render. For example:

``` yaml
project:
  render:
    - "*.qmd"
    - "!ignored.qmd"
    - "!ignored-dir/"
```

::: callout-note
If the name of your output file needs to start with `.` or `_` (for instance `_index.md` for Hugo users), you must name the Quarto input file without the prefix (for instance `index.qmd`) and add an explicit `output-file` parameter in the YAML such as

``` yaml
---
output-file: _index.md
---
```
:::
