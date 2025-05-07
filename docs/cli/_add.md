Add an extension to this folder or project

``` {.bash}
quarto add <extension:string>
```


## Options

|Flags          |Arguments       |Description                                                                     |
|:--------------|:---------------|:-------------------------------------------------------------------------------|
|`-h`, `--help` |                |Show this help.                                                                 |
|`--no-prompt`  |                |Do not prompt to confirm actions                                                |
|`--embed`      |`<extensionId>` |Embed this extension within another extension (used when authoring extensions). |
|`--log`        |`<file>`        |Path to log file                                                                |
|`--log-level`  |`<level>`       |Log level (info, warning, error, critical)                                      |
|`--log-format` |`<format>`      |Log format (plain, json-stream)                                                 |
|`--quiet`      |                |Suppress console output.                                                        |
|`--profile`    |                |Active project profile(s)                                                       |
## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Install extension (Github)

``` {.bash filename='Terminal'}
quarto add <gh-org>/<gh-repo>
```
## Examples
### Install extension (file)

``` {.bash filename='Terminal'}
quarto add <path-to-zip>
```
## Examples
### Install extension (url)

``` {.bash filename='Terminal'}
quarto add <url>
```

