Serve a Shiny interactive document.

By default, the document will be rendered first and then served. If you have previously rendered the document, pass --no-render to skip the rendering step.

``` {.bash}
quarto serve [input:string]
```


## Options

|Flags          |Arguments       |Description                                         |
|:--------------|:---------------|:---------------------------------------------------|
|`-h`, `--help` |                |Show this help.                                     |
|`--no-render`  |                |Do not render the document before serving.          |
|`-p`, `--port` |`[port:number]` |The TCP port that the application should listen on. |
|`--host`       |`[host:string]` |Hostname to bind to (defaults to 127.0.0.1)         |
|`--browser`    |                |Open a browser to preview the site.                 |
|`--log`        |`<file>`        |Path to log file                                    |
|`--log-level`  |`<level>`       |Log level (info, warning, error, critical)          |
|`--log-format` |`<format>`      |Log format (plain, json-stream)                     |
|`--quiet`      |                |Suppress console output.                            |
|`--profile`    |                |Active project profile(s)                           |
## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Serve an interactive Shiny document

``` {.bash filename='Terminal'}
quarto serve dashboard.qmd
```
## Examples
### Serve a document without rendering

``` {.bash filename='Terminal'}
quarto serve dashboard.qmd --no-render
```

