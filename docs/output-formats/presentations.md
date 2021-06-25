---
title: Presentations
description: "This article covers the core syntax for presentations (slides, incremental bullets, columns, etc.)."
format: html
---

## Overview

Pandoc markdown supports a wide variety of formats for creating presentations, including:

-   [PowerPoint](https://en.wikipedia.org/wiki/Microsoft_PowerPoint) (MS Office)

-   [Beamer](https://en.wikipedia.org/wiki/Beamer_(LaTeX)) (LaTeX/PDF)

-   [reveal.js](https://revealjs.com/), [Slidy](https://www.w3.org/Talks/Tools/Slidy2/), [S5](https://meyerweb.com/eric/tools/s5/), [DZSlides](https://paulrouget.com/dzslides/), or [Slideous](https://goessner.net/articles/slideous/) (HTML)

This article covers the core syntax for presentations (slides, incremental bullets, columns, etc.). This documentation is an edited version of the complete Pandoc [documentation on slide shows](https://pandoc.org/MANUAL.html#slide-shows). After you learn the basics here you should consult the full documentation to learn about all available options.

## Slide Markdown

Here's an example of a simple markdown side show. The H1 headers are used to delimit sections; the H2 headers and horizontal rule are used to delimit slides:

``` {.markdown}
---
title: "Habits"
author: "John Doe"
date: "March 22, 2005"
format: revealjs
---

# In the morning

## Getting up

- Turn off alarm
- Get out of bed

## Breakfast

- Eat eggs
- Drink coffee

# In the evening

## Dinner

- Eat spaghetti
- Drink wine

------------------

![picture of spaghetti](images/spaghetti.jpg)

## Going to sleep

- Get in bed
- Count sheep
```

By default, the *slide level* is the highest heading level in the hierarchy that is followed immediately by content, and not another heading, somewhere in the document.

In the example above, level-1 headings are always followed by level-2 headings, which are followed by content, so the slide level is 2. This default can be overridden using the [`slide-level`](https://pandoc.org/MANUAL.html#option--slide-level) option. See the Pandoc documentation on [structuring the slide show](https://pandoc.org/MANUAL.html#structuring-the-slide-show) for additional details.

## Incremental Lists

By default number and bullet lists within slides are displayed all at once. You can override this globally using the `incremental` option. For example:

``` {.yaml}
title: "My Presentation"
format:
  revealjs:
    incremental: true   
```

You can also explicitly make any list incremental or non-incremental by surrounding it in a div with an explicit class that determines the mode. To make a list incremental do this:

```markdown
::: {.incremental}

- Eat spaghetti
- Drink wine

:::
```

To make a list non-incremental do this:

```markdown
::: {.nonincremental}

- Eat spaghetti
- Drink wine

:::
```

You can also insert a pause within a slide (keeping the content after the pause hidden) by inserting three dots separated by spaces:

```markdown
## Slide with a pause

content before the pause

. . .

content after the pause

```

::: {.callout-warning}
The incremental/nonincremental and pause markdown syntax described above do not currently work for PowerPoint output.
:::

## Multiple Columns

To put material in side by side columns, you can use a native div container with class `.columns`, containing two or more div containers with class `.column` and a `width` attribute:

```markdown
:::: {.columns}

::: {.column width="40%"}
contents...
:::

::: {.column width="60%"}
contents...
:::

::::
```


## Speaker Notes

Speaker notes are supported in reveal.js and PowerPoint (pptx) output. You can add notes to your Markdown document thus:

```markdown
## Slide with speaker notes

Slide content

::: {.notes}

Speaker notes go here.

:::
```

To show the notes window in reveal.js, press <kbd>s</kbd> while viewing the presentation. Speaker notes in PowerPoint will be available, as usual, in handouts and presenter view.

Notes are not yet supported for other slide formats, but the notes will not appear on the slides themselves.




