## Syntax Highlighting

Pandoc will automatically highlight syntax in [fenced code blocks](https://pandoc.org/MANUAL.html#fenced-code-blocks) that are marked with a language name. For example:

````
```python
1 + 1
```
````

Pandoc can provide syntax highlighting for over 140 different languages (see the output of `quarto pandoc --list-highlight-languages` for a list of all of them). If you want to provide the appearance of a highlighted code block for a language not supported, just use `default` as the language name.

You can specify the code highlighting style using `syntax-highlighting` and specifying one of the supported themes. Supported themes include: a11y, arrow, pygments, tango, espresso, zenburn, kate, monochrome, breezedark, haddock, atom-one, ayu, breeze, dracula, github, gruvbox, monokai, nord, oblivion, printing, radical, solarized, and vim.

For example:

``` yaml
syntax-highlighting: github
```

In addition to theme names, `syntax-highlighting` accepts two special values:

- `none` --- disables syntax highlighting entirely.
- `idiomatic` --- delegates highlighting to the output format's native system instead of Pandoc's built-in Skylighting engine. For LaTeX, this uses the `listings` package; for Typst, this uses Typst's built-in code highlighting. See each format's documentation for details.

::: {.content-visible when-meta="doc-type.pdf"}
For LaTeX/PDF output, `syntax-highlighting: idiomatic` uses the LaTeX `listings` package for code highlighting instead of Pandoc's default approach (which uses `fancyvrb` with `\Shaded`/`\Highlighting` environments). This may be preferred when working with LaTeX templates or publishers that expect `listings`-based code blocks.
:::

::::: {.content-visible when-meta="doc-type.typst"}

{{< include /docs/prerelease/1.9/_pre-release-feature.qmd >}}

::: callout-important
## Changed Default for Typst

Starting with Quarto 1.9, Typst output uses Pandoc's Skylighting engine for syntax highlighting by default, with the same themes available as HTML and LaTeX. Previously, Typst used its own native code highlighting.

To restore the previous behavior, set `syntax-highlighting: idiomatic`.
:::

Setting `syntax-highlighting: idiomatic` delegates highlighting to Typst's built-in code highlighting. In this mode, Typst receives plain fenced code blocks and applies its own styling. This may be preferred when using custom Typst templates that style code blocks.
:::::

Highlighting themes can provide either a single highlighting definition or two definitions, one optimized for a light colored background and another optimized for a dark color background. When available, Quarto will automatically select the appropriate style based upon the code chunk background color's darkness. You may always opt to specify the full name (e.g. `atom-one-dark`) to bypass this automatic behavior.

By default, code is highlighted using the `arrow` theme, which is optimized for accessibility. Here are examples of the `arrow` light and dark themes:

::: panel-tabset
#### Light

![](images/arrow.png){fig-alt="A block of code showcasing the Arrow light theme."}

#### Dark

![](images/arrow-dark.png){fig-alt="A block of code showcasing the Arrow dark theme."}
:::
