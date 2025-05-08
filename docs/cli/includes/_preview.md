Render and preview a document or website project.

Automatically reloads the browser when input files or document resources (e.g. CSS) change.

For website preview, the most recent execution results of computational documents are used to render
the site (this is to optimize startup time). If you want to perform a full render prior to
previewing pass the --render option with "all" or a comma-separated list of formats to render.

For document preview, input file changes will result in a re-render (pass --no-watch to prevent).

You can also include arbitrary command line arguments to be forwarded to [1mquarto render[22m.

``` {.bash}
quarto preview [file:string] [...args:string]
```


## Options

|Flags               |Arguments         |Description                                                                                                                                                          |
|:-------------------|:-----------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`-h`, `--help`      |                  |Show this help.                                                                                                                                                      |
|`--port`            |`[port:number]`   |Suggested port to listen on (defaults to random value between 3000 and 8000).
If the port is not available then a random port between 3000 and 8000 will be selected. |
|`--host`            |`[host:string]`   |Hostname to bind to (defaults to 127.0.0.1)                                                                                                                          |
|`--render`          |`[format:string]` |Render to the specified format(s) before previewing                                                                                                                  |
|`--no-serve`        |                  |Don't run a local preview web server (just monitor and re-render input files)                                                                                        |
|`--no-navigate`     |                  |Don't navigate the browser automatically when outputs are updated.                                                                                                   |
|`--no-browser`      |                  |Don't open a browser to preview the site.                                                                                                                            |
|`--no-watch-inputs` |                  |Do not re-render input files when they change.                                                                                                                       |
|`--timeout`         |                  |Time (in seconds) after which to exit if there are no active clients.                                                                                                |
|`--log`             |`<file>`          |Path to log file                                                                                                                                                     |
|`--log-level`       |`<level>`         |Log level (info, warning, error, critical)                                                                                                                           |
|`--log-format`      |`<format>`        |Log format (plain, json-stream)                                                                                                                                      |
|`--quiet`           |                  |Suppress console output.                                                                                                                                             |
|`--profile`         |                  |Active project profile(s)                                                                                                                                            |


## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Preview document

``` {.bash filename='Terminal'}
quarto preview doc.qmd
```

### Preview document with render command line args

``` {.bash filename='Terminal'}
quarto preview doc.qmd --toc
```

### Preview document (don't watch for input changes)

``` {.bash filename='Terminal'}
quarto preview doc.qmd --no-watch-inputs
```

### Preview website with most recent execution results

``` {.bash filename='Terminal'}
quarto preview
```

### Previewing website using a specific port

``` {.bash filename='Terminal'}
quarto preview --port 4444
```

### Preview website (don't open a browser)

``` {.bash filename='Terminal'}
quarto preview --no-browser
```

### Fully render all website/book formats then preview

``` {.bash filename='Terminal'}
quarto preview --render all
```

### Fully render the html format then preview

``` {.bash filename='Terminal'}
quarto preview --render html
```

