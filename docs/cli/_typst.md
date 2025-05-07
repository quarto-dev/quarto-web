Run the version of Typst embedded within Quarto.

You can pass arbitrary command line arguments to quarto typst (they will
be passed through unmodified to Typst)

``` {.bash}
quarto typst [...args]
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
### Compile Typst to PDF

``` {.bash filename='Terminal'}
quarto typst compile document.typ
```
## Examples
### List all discovered fonts in system and custom font paths

``` {.bash filename='Terminal'}
quarto typst fonts
```

