Run the version of Pandoc embedded within Quarto.

You can pass arbitrary command line arguments to quarto pandoc (they will
be passed through unmodified to Pandoc)

``` {.bash}
quarto pandoc [...args]
```


## Options

|Flags          |Arguments  |Description                                |
|:--------------|:----------|:------------------------------------------|
|`-h`, `--help` |           |Show this help.                            |
|`--log`        |`<file>`   |Path to log file                           |
|`--log-level`  |`<level>`  |Log level (info, warning, error, critical) |
|`--log-format` |`<format>` |Log format (plain, json-stream)            |
|`--quiet`      |           |Suppress console output.                   |
|`--profile`    |           |Active project profile(s)                  |
## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Render markdown to HTML

``` {.bash filename='Terminal'}
quarto pandoc document.md --to html --output document.html
```
## Examples
### List Pandoc output formats

``` {.bash filename='Terminal'}
quarto pandoc --list-output-formats
```

