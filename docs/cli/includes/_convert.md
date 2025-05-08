Convert documents to alternate representations.

``` {.bash}
quarto convert <input:string>
```


## Options

|Flags            |Arguments       |Description                                |
|:----------------|:---------------|:------------------------------------------|
|`-h`, `--help`   |                |Show this help.                            |
|`-o`, `--output` |`[path:string]` |Write output to PATH.                      |
|`--with-ids`     |                |Include ids in conversion                  |
|`--log`          |`<file>`        |Path to log file                           |
|`--log-level`    |`<level>`       |Log level (info, warning, error, critical) |
|`--log-format`   |`<format>`      |Log format (plain, json-stream)            |
|`--quiet`        |                |Suppress console output.                   |
|`--profile`      |                |Active project profile(s)                  |


## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Convert notebook to markdown

``` {.bash filename='Terminal'}
quarto convert mydocument.ipynb 
```

### Convert markdown to notebook

``` {.bash filename='Terminal'}
quarto convert mydocument.qmd
```

### Convert notebook to markdown, writing to file

``` {.bash filename='Terminal'}
quarto convert mydocument.ipynb --output mydoc.qmd
```

