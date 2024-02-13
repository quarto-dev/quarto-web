## Overview

In this tutorial we'll explore more of Quarto's authoring features. We'll cover rendering documents in multiple formats and show you how to add components like table of contents, equations, citations, cross-references, and more.

## Output Formats

Quarto supports rendering notebooks to dozens of different [output formats](/docs/output-formats/all-formats.qmd). By default, the `html` format is used, but you can specify an alternate format (or formats) within document options.

### Format Options

Let's create a new file (`authoring.qmd`) and define various formats for it to be rendered to, adding some options to each of the formats. As a reminder, document options are specified in YAML at the beginning of the source file.

``` yaml
---
title: "Quarto Document"
author: "Norah Jones"
format: pdf
---
```

We specified `pdf` as the default output format (if we exclude the `format` option then it will default to `html`).

Let's add some options to control our PDF output.

``` yaml
---
title: "Quarto Document"
author: "Norah Jones"
format: 
  pdf: 
    toc: true
    number-sections: true
---
```

### Multiple Formats

Some documents you create will have only a single output format, however in many cases it will be desirable to support multiple formats. Let's add the `html` and `docx` formats to our document.

``` yaml
---
title: "Quarto Document"
author: "Norah Jones"
toc: true
number-sections: true
highlight-style: pygments
format: 
  html: 
    code-fold: true
    html-math-method: katex
  pdf: 
    geometry: 
      - top=30mm
      - left=20mm
  docx: default
---
```

There's a lot to take in here! Let's break it down a bit. The first two lines are generic document metadata that aren't related to output formats at all.

``` yaml
title: "Quarto Document"
author: "Norah Jones"
```

The next three lines are document format options that *apply to all formats*. which is why they are specified at the root level.

``` yaml
toc: true
number-sections: true
highlight-style: pygments
```

Next, we have the `format` option, where we provide format-specific options.

``` yaml
format:
  html: 
    code-fold: true
    html-math-method: katex
  pdf:
    geometry: 
      - top=30mm
      - left=20mm
  docx: default
```

The `html` and `pdf` formats each provide an option or two. For example, for the HTML output we want the user to have control over whether to show or hide the code (`code-fold: true`) and use `katex` for math text. For PDF we define some margins. The `docx` format is a bit different---it specifies `docx: default`. This means just use all of the default options for the format.

## Rendering

The formats specified within document options define what is rendered by default. If we render the document with all the options given above using the following.

``` {.bash filename="Terminal"}
quarto render authoring.qmd
```

Then the following files would be created.

-   `authoring.html`
-   `authoring.pdf`
-   `authoring.docx`

We can select one or more formats using the `--to` option.

``` {.bash filename="Terminal"}
quarto render authoring.qmd --to docx
quarto render authoring.qmd --to docx,pdf
```

Note that the target file (in this case `authoring.qmd`) should always be the very first command line argument.

If needed we can also render formats that aren't specified within document options.

``` {.bash filename="Terminal"}
quarto render authoring.qmd --to odt
```

Since the `odt` format isn't included within document options, the default options for the format will be used.

## Sections

You can use a table of contents and/or section numbering to make it easier for readers to navigate your document. Do this by adding the `toc` and/or `number-sections` options to document options. Note that these options are typically specified at the root level because they are shared across all formats.

``` markdown
---
title: Quarto Basics
author: Norah Jones
date: 'May 22, 2021'
toc: true
number-sections: true
---

## Colors

- Red
- Green 
- Blue

## Shapes

- Square
- Circle
- Triangle

## Textures

- Smooth
- Bumpy
- Fuzzy
```

Here's what this document looks like when rendered to HTML.

![](images/sections-render.png){.border}

There are lots of options available for controlling how the table of contents and section numbering behave. See the output format documentation (e.g. [HTML](/docs/output-formats/html-basics.qmd), [PDF](/docs/output-formats/pdf-basics.qmd), [MS Word](/docs/output-formats/ms-word.qmd)) for additional details.

## Equations

You can use LaTeX equations within markdown.

``` markdown
Einstein's theory of special relatively that expresses the equivalence of mass and energy:

$E = mc^{2}$
```

This appears as follows when rendered.

::: {.card style="padding: 10px;"}
Einstein's theory of special relatively that expresses the equivalence of mass and energy:

$E = mc^{2}$
:::

Inline equations are delimited with `$…$`. To create equations in a new line (display equation) use `$$…$$`. See the documentation on [markdown equations](/docs/authoring/markdown-basics.html#equations) for additional details.

## Citations

To cite other works within a Quarto document. First create a bibliography file in a supported format (BibTeX or CSL). Then, link the bibliography to your document using the `bibliography` YAML metadata option.

Here's a document that includes a bibliography and single citation.

```` markdown
---
title: Quarto Basics
format: html
bibliography: references.bib
jupyter: python3
---

## Overview

Knuth says always be literate [@knuth1984].

```{{python}}
1 + 1
```

## References
````

Note that items within the bibliography are cited using the `@citeid` syntax.

``` markdown
 Knuth says always be literate [@knuth1984].
```

References will be included at the end of the document, so we include a `## References` heading at the bottom of the source file.

Here is what this document looks like when rendered.

![](/docs/get-started/authoring/images/citations-render.png){.border width="600" fig-alt="Rendered document with references section at the bottom the content of which reads 'Knuth, Donald E. 1984. Literate Programming. The Computer Journal 27 (2): 97-111.'"}

\
The `@` citation syntax is very flexible and includes support for prefixes, suffixes, locators, and in-text citations. See the documentation on [Citations and Footnotes](/docs/authoring/footnotes-and-citations.qmd) to learn more.

## Cross References

Cross-references make it easier for readers to navigate your document by providing numbered references and hyperlinks to figures, tables, equations, and sections. Cross-reference-able entities generally require a label (unique identifier) and a caption.

This example illustrates cross-referencing various types of entities.

```` markdown
---
title: Quarto Crossrefs
format: html
jupyter: python3
---

## Overview

See @fig-simple in @sec-plot for a demonstration of a simple plot. 

See @eq-stddev to better understand standard deviation.

## Plot {#sec-plot}

```{{python}}
#| label: fig-simple
#| fig-cap: "Simple Plot"
import matplotlib.pyplot as plt
plt.plot([1,23,2,4])
plt.show()
```

## Equation {#sec-equation}

$$
s = \sqrt{\frac{1}{N-1} \sum_{i=1}^N (x_i - \overline{x})^2}
$$ {#eq-stddev}
````

We cross-referenced sections, figures, and equations. The table below shows how we expressed each of these.

+----------+---------------+----------------------------------+
| Entity   | Reference     | Label / Caption                  |
+==========+===============+==================================+
| Section  | `@sec-plot`   | ID added to heading:             |
|          |               |                                  |
|          |               | ``` {.default code-copy="false"} |
|          |               | # Plot {#sec-plot}               |
|          |               | ```                              |
+----------+---------------+----------------------------------+
| Figure   | `@fig-simple` | YAML options in code cell:       |
|          |               |                                  |
|          |               | ``` {.default code-copy="false"} |
|          |               | #| label: fig-simple             |
|          |               | #| fig-cap: "Simple Plot"        |
|          |               | ```                              |
+----------+---------------+----------------------------------+
| Equation | `@eq-stddev`  | At end of display equation:      |
|          |               |                                  |
|          |               | ``` default                      |
|          |               | $$ {#eq-stddev}                  |
|          |               | ```                              |
+----------+---------------+----------------------------------+

: {tbl-colwidths=\[20,30,50\]}

And finally, here is what this document looks like when rendered.

![](/docs/get-started/authoring/images/crossref-render.png){.border width="600" fig-alt="Rendered page with linked cross references to figures and equations."}

See the article on [Cross References](/docs/authoring/cross-references.qmd) to learn more, including how to customize caption and reference text (e.g. use "Fig." rather than "Figure").

## Callouts

Callouts are an excellent way to draw extra attention to certain concepts, or to more clearly indicate that certain content is supplemental or applicable to only some scenarios.

Callouts are markdown divs that have special callout attributes. To create a callout within a markdown cell, type the following in your document.

``` markdown
::: {.callout-note}
Note that there are five types of callouts, including:
`note`, `tip`, `warning`, `caution`, and `important`.
:::
```

This appears as follows when rendered.

::: callout-note
Note that there are five types of callouts, including `note`, `tip`, `warning`, `caution`, and `important`.
:::

You can learn more about the different types of callouts and options for their appearance in the [Callouts](/docs/authoring/callouts.qmd) documentation.

## Article Layout

The body of Quarto articles have a default width of approximately 700 pixels. This width is chosen to [optimize readability](https://medium.com/ben-shoemate/optimum-web-readability-max-and-min-width-for-page-text-dee9987a27a0). This normally leaves some available space in the document margins and there are a few ways you can take advantage of this space.

In this example, we use the `reference-location` option to indicate that we would like footnotes to be placed in the right margin.

We also use the `column: screen-inset` cell option to indicate we would like our figure to occupy the full width of the screen, with a small inset.

```` markdown
---
title: Quarto Layout
format: html
reference-location: margin
jupyter: python3
---

## Placing Colorbars

Colorbars indicate the quantitative extent of image data.
Placing in a figure is non-trivial because room needs to
be made for them. The simplest case is just attaching a 
colorbar to each axes:^[See the [Matplotlib Gallery](https://matplotlib.org/stable/gallery/subplots_axes_and_figures/colorbar_placement.html) to explore colorbars further].

```{{python}}
#| code-fold: true
#| column: screen-inset
import matplotlib.pyplot as plt
import numpy as np

fig, axs = plt.subplots(2, 2)
fig.set_size_inches(20, 8)
cmaps = ['RdBu_r', 'viridis']
for col in range(2):
    for row in range(2):
        ax = axs[row, col]
        pcm = ax.pcolormesh(
          np.random.random((20, 20)) * (col + 1),
          cmap=cmaps[col]
        )
        fig.colorbar(pcm, ax=ax)
plt.show()
```
````

Here is what this document looks like when rendered.

![](images/layout-render.png){.border fig-alt="Document with Quarto Layout title at the top followed by Placing Colorbars header with text below it. Next to the text is a footnote in the page margin. Below the text is a toggleable code widget to hide/reveal the code followed by four plots displayed in two rows and two columns."}

You can locate citations, footnotes, and [asides](https://quarto.org/docs/authoring/article-layout.html#asides) in the margin. You can also define custom column spans for figures, tables, or other content. See the documentation on [Article Layout](/docs/authoring/article-layout.qmd) for additional details.

{{< include _footer.md >}}


