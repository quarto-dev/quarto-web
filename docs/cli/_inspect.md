Inspect a Quarto project or input path.

Inspecting a project returns its config and engines.
Inspecting an input path return its formats, engine, and dependent resources.

Emits results of inspection as JSON to output (or stdout if not provided).

``` {.bash}
quarto inspect [path] [output]
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
### Inspect project in current directory

``` {.bash filename='Terminal'}
quarto inspect
```
## Examples
### Inspect project in directory

``` {.bash filename='Terminal'}
quarto inspect myproject
```
## Examples
### Inspect input path

``` {.bash filename='Terminal'}
quarto inspect document.md
```
## Examples
### Inspect input path and write to file

``` {.bash filename='Terminal'}
quarto inspect document.md output.json
```

