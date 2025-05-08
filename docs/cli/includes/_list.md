Lists an extension or global dependency.

``` {.bash}
quarto list <type:string>
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
### List installed extensions

``` {.bash filename='Terminal'}
quarto list extensions
```

### List global tools

``` {.bash filename='Terminal'}
quarto list tools
```

