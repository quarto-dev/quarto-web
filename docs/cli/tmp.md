Render files or projects to various document types.

``` {.bash}
quarto render [input:string] [...args]
```


## Options

|Flags                      |Arguments  |Description                                                      |
|:--------------------------|:----------|:----------------------------------------------------------------|
|`-h`, `--help`             |           |Show this help.                                                  |
|`-t`, `--to`               |           |Specify output format(s).                                        |
|`-o`, `--output`           |           |Write output to FILE (use '--output -' for stdout).              |
|`--output-dir`             |           |Write output to DIR (path is input/project relative)             |
|`-M`, `--metadata`         |           |Metadata value (KEY:VALUE).                                      |
|`--site-url`               |           |Override site-url for website or book output                     |
|`--execute`                |           |Execute code (--no-execute to skip execution).                   |
|`-P`, `--execute-param`    |           |Execution parameter (KEY:VALUE).                                 |
|`--execute-params`         |           |YAML file with execution parameters.                             |
|`--execute-dir`            |           |Working directory for code execution.                            |
|`--execute-daemon`         |           |Keep Jupyter kernel alive (defaults to 300 seconds).             |
|`--execute-daemon-restart` |           |Restart keepalive Jupyter kernel before render.                  |
|`--execute-debug`          |           |Show debug output when executing computations.                   |
|`--use-freezer`            |           |Force use of frozen computations for an incremental file render. |
|`--cache`                  |           |Cache execution output (--no-cache to prevent cache).            |
|`--cache-refresh`          |           |Force refresh of execution cache.                                |
|`--no-clean`               |           |Do not clean project output-dir prior to render                  |
|`--debug`                  |           |Leave intermediate files in place after render.                  |
|`pandoc-args...`           |           |Additional pandoc command line arguments.                        |
|`--log`                    |`<file>`   |Path to log file                                                 |
|`--log-level`              |`<level>`  |Log level (info, warning, error, critical)                       |
|`--log-format`             |`<format>` |Log format (plain, json-stream)                                  |
|`--quiet`                  |           |Suppress console output.                                         |
|`--profile`                |           |Active project profile(s)                                        |
## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Render Markdown

``` {.bash filename='Terminal'}
quarto render document.qmd
quarto render document.qmd --to html
quarto render document.qmd --to pdf --toc
```
## Examples
### Render Notebook

``` {.bash filename='Terminal'}
quarto render notebook.ipynb
quarto render notebook.ipynb --to docx
quarto render notebook.ipynb --to pdf --toc
```
## Examples
### Render Project

``` {.bash filename='Terminal'}
quarto render
quarto render projdir
```
## Examples
### Render w/ Metadata

``` {.bash filename='Terminal'}
quarto render document.qmd -M echo:false
quarto render document.qmd -M code-fold:true
```
## Examples
### Render to Stdout

``` {.bash filename='Terminal'}
quarto render document.qmd --output -
```

