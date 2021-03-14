---
title: "HTML Themes"
format: html
---

There are a wide variety of themes available for customizing the appearance of Quarto HTML output. Core themes are based on the [Bootstrap](https://getbootstrap.com/) CSS framework, but you can also use the standard Pandoc HTML theme or provide a completely custom theme based on your own CSS.

## Bootstrap Themes

The default theme for HTML output is based on the [Bootstrap](https://getbootstrap.com/) CSS framework. Bootstrap includes an attractive set of core typographic elements, as well as responsive layout for mobile devices.

### Bootswatch

The [Bootswatch](https://bootswatch.com/) project provides a set of over 20 custom Bootstrap themes, all of which are built-in to Quarto. To use a Bootswatch theme, just add a `theme` option with it's name. For example:

``` yaml
title: "My Document"
format:
  html:
    theme: cosmo
```

You can see a list of all available Bootstrap themes on the [Bootswatch website](https://bootswatch.com/).

### Custom

Bootstrap themes are just CSS files that replace the default Bootstrap stylesheet. You can [create your own](https://bootstrap.build/) theme or procure a [third-party](https://themes.getbootstrap.com/) theme and use it with Quarto. To use custom themes, just provide the theme's CSS file as the `theme` option. For example:

``` yaml
title: "My Document"
format:
  html:
    theme: mytheme.min.css
```

## Pandoc Theme

Pandoc comes with it's own default HTML theme. You can use this theme by specifying `theme: pandoc` in your document options. For example:

``` yaml
title: "My Document"
format:
  html: 
    theme: pandoc
```

You can then customize the appearance of the document using the [Theme Options](#theme-options) described below.

## Theme Options

If you are using a Bootstrap theme or the Pandoc theme, there are a set of options you can provide in document metadata to customize it's appearance. These include:

| Option                                                       | Description                                                                                                                                                    |
|--------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `max-width`                                                  | The maximum width of the main text column. Defaults to 900px for bootstrap themes and 36em for the pandoc theme.                                               |
| `mainfont`                                                   | Sets the [`font-family`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-family) property for the document.                                              |
| `fontsize`                                                   | Sets the base CSS [`font-size`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-size) for the document.                                                  |
| `fontcolor`                                                  | Sets the default text [`color`](https://developer.mozilla.org/en-US/docs/Web/CSS/color) for the document.                                                      |
| `linkcolor`                                                  | Sets the default text [`color`](https://developer.mozilla.org/en-US/docs/Web/CSS/color) for hyperlinks.                                                        |
| `monofont`                                                   | Sets the [`font-family`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-family) property for `<code>` elements.                                         |
| `monobackgroundcolor`                                        | Sets the [`background-color`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-color) property for `<code>` elements.                               |
| `linestretch`                                                | Sets the CSS [`line-height`](https://developer.mozilla.org/en-US/docs/Web/CSS/line-height) property (affects distance between lines of text, defaults to 1.5). |
| `backgroundcolor`                                            | Sets the [`background-color`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-color) for the document.                                             |
| `margin-left`, `margin-right`, `margin-top`, `margin-bottom` | Sets the CSS [`margin`](https://developer.mozilla.org/en-US/docs/Web/CSS/margin) properties for the document body.                                             |

For example. here we set the maximum width to 800px and specify that we want a bit more space between lines of text:

``` yaml
title: "My Document"
format:
  html: 
    theme: cosmo
    max-width: 800px
    linestretch: 1.7
```

For further customization, you can also include one or more CSS stylesheets using the `css` option. For example:

``` yaml
title: "My Document"
format:
  html: 
    theme: cosmo
    max-width: 800px
    linestretch: 1.7
    css: styles.css
```

## Custom Theme

You can disable HTML theming entirely by specifying `theme: null` in document options. This will result in a document that uses the default browser CSS, so you'll often want to provide your own styles in addition.

For example, here we disable all built-in themes and provide our own CSS:

``` yaml
title: "My Document"
format:
  html: 
    theme: null
    css: styles.css
```
