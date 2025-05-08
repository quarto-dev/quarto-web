Access functionality specific to the julia rendering engine.

``` {.bash}
quarto call engine julia 
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

|Command  |Description                                                                                                             |
|:--------|:-----------------------------------------------------------------------------------------------------------------------|
|`help`   |Show this help or the help of a sub-command.                                                                            |
|`status` |Get status information on the currently running Julia server process.                                                   |
|`kill`   |Kill the control server if it is currently running. This will also kill all notebook worker processes.                  |
|`log`    |Print the content of the julia server log file if it exists which can be used to diagnose problems.                     |
|`close`  |Close the worker for a given notebook. If it is currently running, it will not be interrupted.                          |
|`stop`   |Send a message to the server that it should close all notebooks and exit. This will fail if any notebooks are not idle. |



