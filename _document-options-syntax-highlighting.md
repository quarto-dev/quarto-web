
## Syntax Highlighting

Pandoc will automatically highlight syntax in [fenced code blocks](https://pandoc.org/MANUAL.html#fenced-code-blocks) that are marked with a language name.

You can specify the code highlighting style using `highlight-style` and specifying one of the supported themes. Supported themes include: arrow, pygments, tango, espresso, zenburn, kate, monochrome, breezedark, haddock, atom-one, ayu, breeze, dracula, github, gruvbox, monokai, nord, oblivion, printing, radical, solarized, and vim.

For example:

``` {.yaml}
highlight-style: github
```

Highlighting themes can provide either a single highlighting definition or two definitions, one optimized for a light colored background and another optimized for a dark color background. When available, Quarto will automatically select the appropriate style based upon the code chunk background color's darkness. You may may always opt to specify the full name (e.g. `atom-one-dark`) to bypass this automatic behavior.

By default, code is highlighted using the `arrow` theme, which is optimized for accessibility. Here are examples of the `arrow` light and dark themes:

::: {.panel-tabset}
#### Light

![](images/arrow.png)

#### Dark

![](images/arrow-dark.png)
:::
