Installs a global dependency (TinyTex or Chromium).

``` {.bash}
quarto install [target...]
```


## Options

|Flags           |Arguments  |Description                                 |
|:---------------|:----------|:-------------------------------------------|
|`-h`, `--help`  |           |Show this help.                             |
|`--no-prompt`   |           |Do not prompt to confirm actions            |
|`--update-path` |           |Update system path when a tool is installed |
|`--log`         |`<file>`   |Path to log file                            |
|`--log-level`   |`<level>`  |Log level (info, warning, error, critical)  |
|`--log-format`  |`<format>` |Log format (plain, json-stream)             |
|`--quiet`       |           |Suppress console output.                    |
|`--profile`     |           |Active project profile(s)                   |
## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Install TinyTeX

``` {.bash filename='Terminal'}
quarto install tinytex
```
## Examples
### Install Chromium

``` {.bash filename='Terminal'}
quarto install chromium
```
## Examples
### Choose tool to install

``` {.bash filename='Terminal'}
quarto install
```

