
## Sass Variables

The following Sass Variables can be specified within SCSS files (note that these variables should always be prefixed with a `$` and are specified within theme files rather than within YAML options):

### Colors

+---------------+------------------------------------------------------------------------------------+
| Variable      | Notes                                                                              |
+===============+====================================================================================+
| `$body-bg`    | The page background color.                                                         |
+---------------+------------------------------------------------------------------------------------+
| `$body-color` | The page text color.                                                               |
+---------------+------------------------------------------------------------------------------------+
| `$link-color` | The link color.                                                                    |
+---------------+------------------------------------------------------------------------------------+
| `$input-bg`   | The background color for HTML inputs.                                              |
+---------------+------------------------------------------------------------------------------------+
| `$popover-bg` | The background color for popovers (for example, when a citation preview is shown). |
+---------------+------------------------------------------------------------------------------------+

### Fonts

+---------------------------+------------------------------------------+
| Variable                  | Notes                                    |
+===========================+==========================================+
| `$font-family-sans-serif` | The sans-serif font family for the page. |
+---------------------------+------------------------------------------+
| `$font-family-monospace`  | The monospace font family for the page.  |
+---------------------------+------------------------------------------+
| `$font-size-root`         | The base font size for the page.         |
+---------------------------+------------------------------------------+
| `$toc-font-size`          | The font size for the page TOC.          |
+---------------------------+------------------------------------------+
| `$h1-font-size`           | Font sizes for the specified headings.   |
|                           |                                          |
| `$h2-font-size`           |                                          |
|                           |                                          |
| `$h3-font-size`           |                                          |
|                           |                                          |
| `$h4-font-size`           |                                          |
|                           |                                          |
| `$h5-font-size`           |                                          |
+---------------------------+------------------------------------------+

### Code Blocks

+---------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable                        | Notes                                                                                                                                                            |
+=================================+==================================================================================================================================================================+
| `$code-block-border-left`       | By default, Quarto does not display a left border on code blocks. Set this variable to a truthy value or a CSS color to enable the left border.                  |
+---------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$code-block-border-left-style` | The style of the left border displayed on code blocks. Defaults to `solid`.                                                                                      |
+---------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$code-block-border-left-size`  | The thickness of the left border displayed on code blocks. Defaults to `3px`;                                                                                    |
+---------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$code-block-padding-left`      | The amount of padding applied between the code and the border. Defaults to `0.6em`.                                                                              |
+---------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$code-block-bg`                | By default, Quarto sets a background on code blocks by adding transparency to the theme's `progress-bg` color. Set this variable to truthy value or a CSS color. |
+---------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$code-block-bg-padding`        | The padding applied to the code block. Defaults to `0.4em`.                                                                                                      |
+---------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$code-block-bg-alpha`          | The amount to alter the transparency fo the `progress-bg` color. This is not used if an explicit background color is set. Defaults to `-0.35`.                   |
+---------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+

#### Code Annotation

You can customize the colors used to highlight lines when [code annotation](/docs/authoring/code-annotation.qmd) is used:

+-----------------------------------+---------------------------------------------------------------------------+
| Variable                          | Notes                                                                     |
+===================================+===========================================================================+
| `$code-annotation-higlight-color` | The color used as a border on highlighted lines.                          |
+-----------------------------------+---------------------------------------------------------------------------+
| `$code-annotation-higlight-bg`    | The color used for the background of highlighted lines.                   |
+-----------------------------------+---------------------------------------------------------------------------+

#### Code Copy

You can also customize the colors of the button which appears for `code-copy: true` with the following variables:

+-------------------------------+---------------------------------------------------------------------------+
| Variable                      | Notes                                                                     |
+===============================+===========================================================================+
| `$btn-code-copy-color`        | The color used for the copy button at the top right of code blocks.       |
+-------------------------------+---------------------------------------------------------------------------+
| `$btn-code-copy-color-active` | The hover color used for the copy button at the top right of code blocks. |
+-------------------------------+---------------------------------------------------------------------------+

### Inline Code

+---------------+-------------------------------------------------------------------------------------------------+
| Variable      | Notes                                                                                           |
+===============+=================================================================================================+
| `$code-bg`    | The background color of inline code. Defaults to a mix between the `body-bg` and `body-color`.  |
+---------------+-------------------------------------------------------------------------------------------------+
| `$code-color` | The text color of inline code. Defaults to a generated contrasting color against the `code-bg`. |
+---------------+-------------------------------------------------------------------------------------------------+

### Table of Contents

+-----------------------------------+------------------------------------------------------------------------+
| Variable                          | Notes                                                                  |
+===================================+========================================================================+
| `$toc-color`                      | The color for table of contents text.                                  |
+-----------------------------------+------------------------------------------------------------------------+
| `$toc-font-size`                  | The font-size for table of contents text.                              |
+-----------------------------------+------------------------------------------------------------------------+
| `$toc-active-border`              | The left border color for the currently active table of contents item. |
+-----------------------------------+------------------------------------------------------------------------+
| `$toc-inactive-border`            | The left border colors for inactive table of contents items.           |
+-----------------------------------+------------------------------------------------------------------------+

### Layout

+------------------------+---------------------------------------------------------------------------------------------------+
| Variable               | Notes                                                                                             |
+========================+===================================================================================================+
| `$content-padding-top` | Padding that should appear before the main content area (including the sidebar, content, and TOC. |
+------------------------+---------------------------------------------------------------------------------------------------+

### Navigation

+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable      | Notes                                                                                                                                                                       |
+===============+=============================================================================================================================================================================+
| `$navbar-bg`  | The background color of the navbar. Defaults to the theme's `$primary` color.                                                                                               |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$navbar-fg`  | The color of foreground elements (text and navigation) on the navbar. If not specified, a contrasting color is automatically computed.                                      |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$navbar-hl`  | The highlight color for links in the navbar. If not specified, the `$link-color` is used or a contrasting color is automatically computed.                                  |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$sidebar-bg` | The background color for a sidebar. Defaults to `$light` except when a navbar is present or when the style is `floating`. In that case it defaults to the `$body-bg` color. |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$sidebar-fg` | The color of foreground elements (text and navigation) on the sidebar. If not specified, a contrasting color is automatically computed.                                     |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$sidebar-hl` | The highlight color for links in the sidebar. If not specified, the `$link-color` is used.                                                                                  |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$footer-bg`  | The background color for the footer. Defaults to the `$body-bg` color.                                                                                                      |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$footer-fg`  | The color of foreground elements (text and navigation) on the footer. If not specified, a contrasting color is automatically computed.                                      |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

### Callouts

+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable                 | Notes                                                                                                                                                              |
+==========================+====================================================================================================================================================================+
| `$callout-border-width`  | The left border width of callouts. Defaults to `5px`.                                                                                                              |
+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$callout-border-scale`  | The border color of callouts computed by shifting the callout color by this amount. Defaults to `0%`.                                                              |
+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$callout-icon-scale`    | The color of the callout icon computed by shifting the callout color by this amount. Defaults to `10%`.                                                            |
+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$callout-margin-top`    | The amount of top margin on the callout. Defaults to `1.25rem`.                                                                                                    |
+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$callout-margin-bottom` | The amount of bottom margin on the callout. Defaults to `1.25rem`.                                                                                                 |
+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `$callout-color-<type>`  | The colors for the various types of callouts. Defaults:                                                                                                            |
|                          |                                                                                                                                                                    |
|                          | | type        | default   |                                                                                                                                        |
|                          | |-------------|-----------|                                                                                                                                        |
|                          | | `note`      | `$blue`   |                                                                                                                                        |
|                          | | `tip`       | `$green`  |                                                                                                                                        |
|                          | | `caution`   | `$orange` |                                                                                                                                        |
|                          | | `warning`   | `$yellow` |                                                                                                                                        |
|                          | | `important` | `$red`    |                                                                                                                                        |
+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+

### Focus Ring

{{< prerelease-callout 1.11 >}}

When a reader moves through a page with the keyboard, Quarto shows a ring around the element that has focus. The ring has two tones: an outline, and an inner band that fills the gap between the outline and the element.

By default, one tone is a dark shade of `$primary` and the other tone is white. On light pages the dark tone is the outline. On dark pages the tones swap, so the white tone is the outline. The defaults follow W3C technique [C40](https://www.w3.org/WAI/WCAG22/Techniques/css/C40), so at least one of the two tones has a contrast of 3:1 or more against any solid background. 

To achieve this contrast the two tones need a contrast of 9:1 or more with each other. 
If the dark shade of `$primary` does not reach 9:1 against white, Quarto makes it darker until it does. This is true for every theme, built-in or custom.

You can change the ring with these variables:

| Variable | Notes |
|----|----|
| `$focus-ring-outer-color` | The color of the outline. Defaults to a dark shade of `$primary`, adjusted to have a contrast of 9:1 with `$focus-ring-inner-color`. |
| `$focus-ring-inner-color` | The color of the inner band. Defaults to `$white`. |
| `$focus-ring-outline-width` | The width of the outline. Defaults to `2px`. |
| `$focus-ring-outline-offset` | The width of the gap between the outline and the element, which the inner band fills. Defaults to `2px`. |

If you set `$focus-ring-outer-color`, `$focus-ring-inner-color`, or both, Quarto uses your colors as given. Quarto does not swap them on dark pages, and does not adjust a color that you set. If you set only `$focus-ring-inner-color`, Quarto still derives the outer color and adjusts it to 9:1 against your inner color.

Your own `:focus-visible` rules apply over the ring. For example, this rule replaces the outline on links:

``` scss
/*-- scss:rules --*/
a:focus-visible {
  outline: 3px dashed red;
}
```

The inner band stays, because the rule does not set `box-shadow`.

To remove the inner band, set the `--quarto-focus-ring-shadow` CSS property to `none`:

``` scss
/*-- scss:rules --*/
:root {
  --quarto-focus-ring-shadow: none;
}
```

Quarto does not use the Bootstrap variables `$focus-ring-color`, `$focus-ring-box-shadow`, `$btn-focus-width`, and `$btn-focus-box-shadow`. Use the variables above instead.

::: {.content-hidden unless-meta="is_dashboards"}

### Value Boxes

Use the `$valuebox-bg-<type>` variables to override the background color of value boxes that are set with `color: <type>`.

| Variable                     | Type                   |
|------------------------------|------------------------|
| `$valuebox-bg-primary`       |  `color: primary`      |
| `$valuebox-bg-secondary`     |  `color: secondary`    |
| `$valuebox-bg-success`       |  `color: success`      |
| `$valuebox-bg-info`          |  `color: info`         |
| `$valuebox-bg-warning`       |  `color: warning`      |
| `$valuebox-bg-danger`        |  `color: danger`       |
| `$valuebox-bg-light`         |  `color: light`        |
| `$valuebox-bg-dark`          |  `color: dark`         |

::: 

### Bootstrap Variables

In addition to the above Sass variables, Bootstrap itself supports hundreds of additional variables. You can [learn more about Bootstrap's use of Sass variables](https://getbootstrap.com/docs/5.1/customize/sass/) or review the [raw variables and their default values](https://github.com/twbs/bootstrap/blob/main/scss/_variables.scss).