Removes an extension.

``` {.bash}
quarto remove [target...]
```


## Options

|Flags          |Arguments       |Description                                                                           |
|:--------------|:---------------|:-------------------------------------------------------------------------------------|
|`-h`, `--help` |                |Show this help.                                                                       |
|`--no-prompt`  |                |Do not prompt to confirm actions                                                      |
|`--embed`      |`<extensionId>` |Remove this extension from within another extension (used when authoring extensions). |
|`--log`        |`<file>`        |Path to log file                                                                      |
|`--log-level`  |`<level>`       |Log level (info, warning, error, critical)                                            |
|`--log-format` |`<format>`      |Log format (plain, json-stream)                                                       |
|`--quiet`      |                |Suppress console output.                                                              |
|`--profile`    |                |Active project profile(s)                                                             |
## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Remove extension using name

``` {.bash filename='Terminal'}
quarto remove <extension-name>
```

