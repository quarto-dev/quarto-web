---
title: Callout Blocks
format: html
---

Callouts are an excellent way to draw extra attention to certain concepts, or to more clearly indicate that certain content is supplemental or applicable to only some scenarios.

## Callout Types

There are five types of callouts available:

-   note
-   tip
-   important
-   caution
-   warning

Here is what the various types look like in HTML output:

::: {.callout-note}
Note that there are five types of callouts, including: `note`, `tip`, `warning`, `caution`, and `important`.
:::

::: {.callout-tip}
## Tip With Caption

This is an example of a callout with a caption.
:::


::: {.callout-important}
## This is Important

Danger, callouts will really improve your writing.
:::

::: {.callout-warning}
Callouts provide a simple way to attract attention, for example, to this warning.
:::


::: {.callout-caution collapse="true"}
## Expand To Learn About Collapse

This is an example of a 'collapsed' caution callout that can be expanded by the user. You can use `collapse="true"` to collapse it by default or `collapse="false"` to make a collapsible callout that is expanded by default.
:::


## Markdown Syntax

Create callouts in markdown using the following syntax (note that the first markdown heading used within the callout is used as the callout heading):

``` {.markdown}
:::{.callout-note}
Note that there are five types of callouts, including:
`note`, `tip`, `warning`, `caution`, and `important`.
:::

:::{.callout-tip}
## Tip With Caption

This is an example of a callout with a caption.
:::

:::{.callout-caution  collapse="true"}
## Expand To Learn About Collapse

This is an example of a 'folded' caution callout that can be expanded by the user. You can use `collapse="true"` to collapse it by default or `collapse="false"` to make a collapsible callout that is expanded by default.
:::
```

## Format Support

The following formats render callouts as illustrated above:

- HTML
- MS Word
- EPUB

In PDF output the [awesomebox](https://ctan.org/pkg/awesomebox?lang=en) LaTeX package is used for callouts.

In other formats, callouts are placed in a simple blockquote.
