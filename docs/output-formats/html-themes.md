---
title: "HTML Themes"
description: "Quarto includes 25 themes from the Bootswatch project (for example, the website uses the cosmo theme). You can disable this theming or use SASS to create your own themes."
---

## Overview

HTML documents rendered with Quarto use Bootstrap 5 by default. This can be disabled or customized via the `theme` option:

``` {.yaml}
theme: default # bootstrap 5 default
theme: cosmo   # cosmo bootswatch theme
theme: pandoc  # pandoc default html treatment
theme: none    # no css added to document
```

Note that all of the features described in [HTML Basics](html-basics.Rmd) (e.g. code folding, citation hover, commenting, etc.) are still available with `theme: pandoc` or `theme: none`. However the features described in [HTML Bootstrap](html-bootstrap.Rmd) (e.g. floating toc, callouts, tabs) are only available for documents with Bootstrap.

Quarto includes 25 themes from the [Bootswatch](https://bootswatch.com/) project (for example, the website uses the [cosmo](https://bootswatch.com/cosmo/) theme). Below we describe how to use SASS to create your own themes.

## Basic Options

Pandoc supports a set of basic metadata options for customizing document appearance without directly using CSS. These options are available for both the `pandoc` theme as well as for all Bootstrap themes.

If you are using a Bootstrap theme or the Pandoc theme, there are a set of options you can provide in document metadata to customize it's appearance. These include:

+--------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                                                       | Description                                                                                                                                                    |
+==============================================================+================================================================================================================================================================+
| `max-width`                                                  | The maximum width occupied by page content. Defaults to 1400px for bootstrap themes and 36em for the pandoc theme.                                             |
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

For example. here we set the font-size a bit larger and specify that we want a bit more space between lines of text:

``` {.yaml}
title: "My Document"
format:
  html: 
    theme: cosmo
    font-size: 1.1em
    linestretch: 1.7
```

## Theme Options

While the basic customization described above handles many common requirements, you can do extensive additional customization using [SASS](https://sass-lang.com/) theme files. Bootstrap defines over 1,400 variables that control fonts, colors, padding, borders, and much more. You can see all of the variables here:

<https://github.com/twbs/bootstrap-sass/blob/master/assets/stylesheets/bootstrap/_variables.scss>

SASS theme files can define both *variables* that globally set things like colors and fonts, as well as *rules* that define more fine grained behavior. To customize an existing Bootstrap theme with your own set of variables and/or rules, just provide the base theme and then your custom theme file(s):

``` {.yaml}
theme:
  - cosmo
  - custom.scss
```

Your `custom.scss` file might look something like this:

``` {.css}
/*-- scss:defaults --*/
$h2-font-size:          1.6rem !default;
$headings-font-weight:  500 !default;
$body-color:            $gray-700 !default;

/*-- scss:rules --*/
h1, h2, h3, h4, h5, h6 {
  text-shadow: -1px -1px 0 rgba(0, 0, 0, .3);
}
```

Note that the variables section is denoted by the `/*-- scss:defaults --*/` comment and the rules section (where normal CSS rules go) is denoted by the `/*-- scss:rules --*/` comment.

## Custom Themes

You can naturally also create an entirely custom theme and provide only that (in this case you will inherit from the default Bootstrap theme):

``` {.yaml}
theme: custom.scss
```

For example, here are the theme files for the 25 built-in Bootswatch themes:

<https://github.com/quarto-dev/quarto-cli/tree/main/src/resources/formats/html/bootstrap/themes>

You can read more about the custom theming design here:

<https://github.com/quarto-dev/quarto-cli/blob/main/design/quarto-themes.md>
