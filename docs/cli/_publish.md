Publish a document or project to a provider.

Available providers include:

 - Quarto Pub (quarto-pub)
 - GitHub Pages (gh-pages)
 - Posit Connect (connect)
 - Posit Cloud (posit-cloud)
 - Netlify (netlify)
 - Confluence (confluence)
 - Hugging Face Spaces (huggingface)

Accounts are configured interactively during publishing.
Manage/remove accounts with: quarto publish accounts

``` {.bash}
quarto publish [provider] [path]
```


## Options

|Flags          |Arguments         |Description                                        |
|:--------------|:-----------------|:--------------------------------------------------|
|`-h`, `--help` |                  |Show this help.                                    |
|`--id`         |`<id:string>`     |Identifier of content to publish                   |
|`--server`     |`<server:string>` |Server to publish to                               |
|`--token`      |`<token:string>`  |Access token for publising provider                |
|`--no-render`  |                  |Do not render before publishing.                   |
|`--no-prompt`  |                  |Do not prompt to confirm publishing destination    |
|`--no-browser` |                  |Do not open a browser to the site after publishing |
|`--log`        |`<file>`          |Path to log file                                   |
|`--log-level`  |`<level>`         |Log level (info, warning, error, critical)         |
|`--log-format` |`<format>`        |Log format (plain, json-stream)                    |
|`--quiet`      |                  |Suppress console output.                           |
|`--profile`    |                  |Active project profile(s)                          |
## Commands

|Command |Description                                  |
|:-------|:--------------------------------------------|
|`help`  |Show this help or the help of a sub-command. |


## Examples
### Publish project (prompt for provider)

``` {.bash filename='Terminal'}
quarto publish
```
## Examples
### Publish document (prompt for provider)

``` {.bash filename='Terminal'}
quarto publish document.qmd
```
## Examples
### Publish project to Hugging Face Spaces

``` {.bash filename='Terminal'}
quarto publish huggingface
```
## Examples
### Publish project to Netlify

``` {.bash filename='Terminal'}
quarto publish netlify
```
## Examples
### Publish with explicit target

``` {.bash filename='Terminal'}
quarto publish netlify --id DA36416-F950-4647-815C-01A24233E294
```
## Examples
### Publish project to GitHub Pages

``` {.bash filename='Terminal'}
quarto publish gh-pages
```
## Examples
### Publish project to Posit Connect

``` {.bash filename='Terminal'}
quarto publish connect
```
## Examples
### Publish with explicit credentials

``` {.bash filename='Terminal'}
quarto publish connect --server example.com --token 01A24233E294
```
## Examples
### Publish project to Posit Cloud

``` {.bash filename='Terminal'}
quarto publish posit-cloud
```
## Examples
### Publish without confirmation prompt

``` {.bash filename='Terminal'}
quarto publish --no-prompt
```
## Examples
### Publish without rendering

``` {.bash filename='Terminal'}
quarto publish --no-render
```
## Examples
### Publish without opening browser

``` {.bash filename='Terminal'}
quarto publish --no-browser
```
## Examples
### Manage/remove publishing accounts

``` {.bash filename='Terminal'}
quarto publish accounts
```

