---
title: "HTML document"
format: html
---

On this page, you'll find documentation for using the Quarto HTML document format.

If you are new to Quarto, please visit [get started](link) to learn how to use Quarto.

<a href="#usage" class="btn btn-primary" role="button">Jump to list of options</a>

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

The Quarto HTML document format can be customized using one or several options, depending on how much and how quickly you want to customize your output. The quickest way is to use a built-in [theme](#themes) that bundles fonts and color palettes for you, without writing CSS yourself. Themes can also be fine-tuned with [CSS custom properties](link), but you may also supply your [own CSS](link) to fully customize your output.

### Themes

::: {.row}
::: {.col-md-6}
Quarto includes a set of 20 built-in themes that bundle fonts and color palettes together, without the need to know or write CSS.
:::

::: {.col-md-6}
<!--# img carousel here  -->

![](http://placekitten.com/300/200)
:::
:::

::: {.row}
::: {.col-md-5}
To use the theme options, add the theme key to your YAML and select a theme by name: \<splat all 20 names here\>
:::

::: {.col-md-7}
<ul class="nav nav-tabs" id="theme" role="tablist">

<li class="nav-item" role="presentation">

<button class="nav-link active" id="yaml-theme-tab" data-bs-toggle="tab" data-bs-target="#yaml-theme" type="button" role="tab" aria-controls="yaml-theme" aria-selected="true">

YAML

</button>

</li>

<li class="nav-item" role="presentation">

<button class="nav-link" id="cli-theme-tab" data-bs-toggle="tab" data-bs-target="#cli-theme" type="button" role="tab" aria-controls="cli-theme" aria-selected="false">

Command line

</button>

</li>

</ul>

::: {.tab-content}
::: {#yaml-theme .tab-pane .fade .show .active role="tabpanel" aria-labelledby="yaml-theme"}
``` {.yaml}
---
format:
  html:
    theme: minty
---
```
:::

::: {#cli-theme .tab-pane .fade role="tabpanel" aria-labelledby="cli-theme"}
``` {.bash}
$ quarto render doc.md --to html --toc --theme minty
```
:::

<!--# close tabbed content -->
:::
:::
:::

### Custom CSS properties

In addition to or instead of using [theme](#themes), you can also fine-tune values for one or multiple CSS properties to further customize the appearance of your HTML document. These variables will override those present in the theme, when combined with a theme.

(https://getbootstrap.com/docs/5.0/customize/overview/)

::: {.row}
::: {.col-md-5}
To use custom CSS properties, add the name of the property to your YAML and set the value.


Use the table below to find all property names and valid values for each property.
:::

::: {.col-md-7}
<ul class="nav nav-tabs" id="css-props" role="tablist">

<li class="nav-item" role="presentation">

<button class="nav-link active" id="yaml-props-tab" data-bs-toggle="tab" data-bs-target="#yaml-props" type="button" role="tab" aria-controls="yaml-props" aria-selected="true">

YAML

</button>

</li>

<li class="nav-item" role="presentation">

<button class="nav-link" id="cli-props-tab" data-bs-toggle="tab" data-bs-target="#cli-props" type="button" role="tab" aria-controls="cli-props" aria-selected="false">

Command line

</button>

</li>

</ul>

::: {.tab-content}
::: {#yaml-props .tab-pane .fade .show .active role="tabpanel" aria-labelledby="yaml-props"}
``` {.yaml}
---
format:
  html:
    max-width: 800px
    linestretch: 1.7
---
```
:::

::: {#cli-props .tab-pane .fade role="tabpanel" aria-labelledby="cli-props"}
``` {.bash}
$ quarto render doc.md --to html --toc --theme minty
```
:::

<!--# close tabbed content -->
:::
:::
:::

+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                                                       | Description                                                                                                                                                    |
+==============================================================+================================================================================================================================================================+
| `max-width`                                                  | The maximum width of the main text column. Defaults to 900px for bootstrap themes and 36em for the pandoc theme.                                               |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `mainfont`                                                   | Sets the [`font-family`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-family) property for the document.                                              |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `fontsize`                                                   | Sets the base CSS [`font-size`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-size) for the document.                                                  |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `fontcolor`                                                  | Sets the default text [`color`](https://developer.mozilla.org/en-US/docs/Web/CSS/color) for the document.                                                      |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `linkcolor`                                                  | Sets the default text [`color`](https://developer.mozilla.org/en-US/docs/Web/CSS/color) for hyperlinks.                                                        |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `monofont`                                                   | Sets the [`font-family`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-family) property for `<code>` elements.                                         |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `monobackgroundcolor`                                        | Sets the [`background-color`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-color) property for `<code>` elements.                               |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `linestretch`                                                | Sets the CSS [`line-height`](https://developer.mozilla.org/en-US/docs/Web/CSS/line-height) property (affects distance between lines of text, defaults to 1.5). |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `backgroundcolor`                                            | Sets the [`background-color`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-color) for the document.                                             |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `margin-left`, `margin-right`, `margin-top`, `margin-bottom` | Sets the CSS [`margin`](https://developer.mozilla.org/en-US/docs/Web/CSS/margin) properties for the document body.                                             |
+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
