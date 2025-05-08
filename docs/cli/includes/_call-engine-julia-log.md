Print the content of the julia server log file if it exists which can be used to diagnose problems.

``` {.bash}
quarto call engine julia log 
```


## Options

|Flags          |Arguments  |Description                                |
|:--------------|:----------|:------------------------------------------|
|`--log`        |`<file>`   |Path to log file                           |
|`--log-level`  |`<level>`  |Log level (info, warning, error, critical) |
|`--log-format` |`<format>` |Log format (plain, json-stream)            |
|`--quiet`      |           |Suppress console output.                   |
|`--profile`    |           |Active project profile(s)                  |
|`-h`, `--help` |           |Show this help.                            |


## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |



