Close the worker for a given notebook. If it is currently running, it will not be interrupted.

``` {.bash}
quarto call engine julia close <file:string>
```


## Options

|Flags           |Arguments  |Description                                                     |
|:---------------|:----------|:---------------------------------------------------------------|
|`--log`         |`<file>`   |Path to log file                                                |
|`--log-level`   |`<level>`  |Log level (info, warning, error, critical)                      |
|`--log-format`  |`<format>` |Log format (plain, json-stream)                                 |
|`--quiet`       |           |Suppress console output.                                        |
|`--profile`     |           |Active project profile(s)                                       |
|`-h`, `--help`  |           |Show this help.                                                 |
|`-f`, `--force` |           |Force closing. This will terminate the worker if it is running. |


## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |



