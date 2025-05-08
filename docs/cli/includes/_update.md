Updates an extension or global dependency.

``` {.bash}
quarto update [target...]
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
### Update extension (Github)

``` {.bash filename='Terminal'}
quarto update extension <gh-org>/<gh-repo>
```

### Update extension (file)

``` {.bash filename='Terminal'}
quarto update extension <path-to-zip>
```

### Update extension (url)

``` {.bash filename='Terminal'}
quarto update extension <url>
```

### Update TinyTeX

``` {.bash filename='Terminal'}
quarto update tool tinytex
```

### Update Chromium

``` {.bash filename='Terminal'}
quarto update tool chromium
```

### Choose tool to update

``` {.bash filename='Terminal'}
quarto update tool
```

