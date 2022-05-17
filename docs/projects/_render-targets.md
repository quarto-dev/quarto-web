## Render Targets

By default, all valid Quarto input files (.qmd, .ipynb, .md, .Rmd) in the project directory will be rendered, save for ones with a file or directory prefix of `.` (hidden files) or `_` (typically used for non top-level files, e.g. ones included in other files).

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

You can also use the prefix `!` to ignore some paths in the `render` list. Note that in that case you need to start by specifying everything you _do_ want to render. For example:

``` yaml
project:
  render:
    - "*.qmd"
    - "!ignored.qmd"
    - "!ignored-dir/"
```

::: callout-note
If the name of your output file needs to start with `.` or `_` (for instance `_index.md` for Hugo users), you must name the Quarto input file without the prefix (for instance `index.qmd`) and add an explicit `output-file` parameter in the YAML such as

```yaml
---
output-file: _index.md
---
```
:::