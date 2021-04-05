---
title: "HTML document"
format: html
---

On this page, you'll find documentation for using the Quarto HTML document format.

If you are new to Quarto, please visit [get started](link) to learn how to use Quarto.

<!--# insert button jump to list of options  -->

## Usage

::: {.row}
::: {.col-md-6}
To use the HTML document format without options, add the format key to your YAML and choose html.
:::

::: {.col-md-6}
<ul class="nav nav-tabs" id="usage" role="tablist">

<li class="nav-item" role="presentation">

<button class="nav-link active" id="yaml-usage-tab" data-bs-toggle="tab" data-bs-target="#yaml-usage" type="button" role="tab" aria-controls="yaml-usage" aria-selected="true">

YAML

</button>

</li>

<li class="nav-item" role="presentation">

<button class="nav-link" id="cli-usage-tab" data-bs-toggle="tab" data-bs-target="#cli-usage" type="button" role="tab" aria-controls="cli-usage" aria-selected="false">

Command line

</button>

</li>

</ul>

::: {#usage .tab-content}
::: {#yaml-usage .tab-pane .fade .show .active role="tabpanel" aria-labelledby="yaml-usage"}
``` {.yaml}
---
format: html
---
```
:::

::: {#cli-usage .tab-pane .fade role="tabpanel" aria-labelledby="cli-usage"}
``` {.bash}
$ quarto render doc.md --to html
```
:::

<!--# close tabbed content -->
:::

<!--# close column -->
:::

<!--# close row -->
:::

## Usage with options

::: {.row}
::: {.col-md-6}
To use the HTML document format with options, list each option on separate lines nested under the format key.

All options available are described in the sections below, and summarized [here](link).
:::

::: {.col-md-6}
<ul class="nav nav-tabs" id="options" role="tablist">

<li class="nav-item" role="presentation">

<button class="nav-link active" id="yaml-options-tab" data-bs-toggle="tab" data-bs-target="#yaml-options" type="button" role="tab" aria-controls="yaml-options" aria-selected="true">

YAML

</button>

</li>

<li class="nav-item" role="presentation">

<button class="nav-link" id="cli-options-tab" data-bs-toggle="tab" data-bs-target="#cli-options" type="button" role="tab" aria-controls="cli-options" aria-selected="false">

Command line

</button>

</li>

</ul>

::: {#options .tab-content}
::: {#yaml-options .tab-pane .fade .show .active role="tabpanel" aria-labelledby="yaml-options"}
``` {.yaml}
---
format:
  html:
    toc: true
---
```
:::

::: {#cli-options .tab-pane .fade role="tabpanel" aria-labelledby="cli-options"}
``` {.bash}
$ quarto render doc.md --to html --toc
```
:::

<!--# close tabbed content -->
:::

<!--# close column -->
:::

<!--# close row -->
:::

## Customize style

The Quarto HTML document format can be customized using one or several options, depending on how much and how quickly you want to customize your output. The quickest way is to use a built-in [theme](link) that bundles fonts and color palettes for you, without writing CSS yourself. Themes can also be fine-tuned with [CSS custom properties](link), but you may also supply your [own CSS](link) to fully customize your output.

### Themes

::: {.row}
::: {.col-md-6}
Quarto includes a set of 20 built-in themes that bundle fonts and color palettes together, without the need to know or write CSS.
:::

::: {.col-md-6}
<!--# img carousel here  -->
:::
:::

::: {.row}
::: {.col-md-6}
To use the theme options, add the theme key to your YAML and select a theme by name: \<splat all 20 names here\>
:::

::: {.col-md-6}
``` {.yaml}
---
format:
  html:
    theme: minty
---
```
:::
:::
