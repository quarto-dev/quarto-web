Create a project for rendering multiple documents

``` {.bash}
quarto create-project [dir:string]
```


## Options

|Flags             |Arguments           |Description                                                                               |
|:-----------------|:-------------------|:-----------------------------------------------------------------------------------------|
|`-h`, `--help`    |                    |Show this help.                                                                           |
|`--title`         |`<title:string>`    |Project title                                                                             |
|`--type`          |`<type:string>`     |Project type (book, default, website, manuscript)                                         |
|`--template`      |`<type:string>`     |Use a specific project template                                                           |
|`--engine`        |`<engine:string>`   |Use execution engine ([object Object], [object Object], [object Object], [object Object]) |
|`--editor`        |`<editor:string>`   |Default editor for project ('source' or 'visual')                                         |
|`--with-venv`     |`[packages:string]` |Create a virtualenv for this project                                                      |
|`--with-condaenv` |`[packages:string]` |Create a condaenv for this project                                                        |
|`--no-scaffold`   |                    |Don't create initial project file(s)                                                      |
|`--log`           |`<file>`            |Path to log file                                                                          |
|`--log-level`     |`<level>`           |Log level (info, warning, error, critical)                                                |
|`--log-format`    |`<format>`          |Log format (plain, json-stream)                                                           |
|`--quiet`         |                    |Suppress console output.                                                                  |
|`--profile`       |                    |Active project profile(s)                                                                 |
## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Create a project in the current directory

``` {.bash filename='Terminal'}
quarto create-project
```
## Examples
### Create a project in the 'myproject' directory

``` {.bash filename='Terminal'}
quarto create-project myproject
```
## Examples
### Create a website project

``` {.bash filename='Terminal'}
quarto create-project mysite --type website
```
## Examples
### Create a blog project

``` {.bash filename='Terminal'}
quarto create-project mysite --type website --template blog
```
## Examples
### Create a book project

``` {.bash filename='Terminal'}
quarto create-project mybook --type book
```
## Examples
### Create a website project with jupyter

``` {.bash filename='Terminal'}
quarto create-project mysite --type website --engine jupyter
```
## Examples
### Create a website project with jupyter + kernel

``` {.bash filename='Terminal'}
quarto create-project mysite --type website --engine jupyter:python3
```
## Examples
### Create a book project with knitr

``` {.bash filename='Terminal'}
quarto create-project mybook --type book --engine knitr
```
## Examples
### Create jupyter project with virtualenv

``` {.bash filename='Terminal'}
quarto create-project myproject --engine jupyter --with-venv
```
## Examples
### Create jupyter project with virtualenv + packages

``` {.bash filename='Terminal'}
quarto create-project myproject --engine jupyter --with-venv pandas,matplotlib
```
## Examples
### Create jupyter project with condaenv 

``` {.bash filename='Terminal'}
quarto create-project myproject --engine jupyter --with-condaenv
```
## Examples
### Create jupyter project with condaenv + packages

``` {.bash filename='Terminal'}
quarto create-project myproject --engine jupyter --with-condaenv pandas,matplotlib
```

