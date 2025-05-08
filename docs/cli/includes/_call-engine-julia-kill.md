Kill the control server if it is currently running. This will also kill all notebook worker processes.

``` {.bash}
quarto call engine julia kill 
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



