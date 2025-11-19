## Creating Slides {#creating-slides}

In markdown, slides are delineated using headings. For example, here is a simple slide show with two slides (each defined with a level 2 heading (`##`):

``` {.markdown code-preview="examples/creating-slides-1.qmd"}
---
title: "Habits"
author: "John Doe"
format: {{< meta slide-format >}}
---

## Getting up

- Turn off alarm
- Get out of bed

## Going to sleep

- Get in bed
- Count sheep
```

You can also divide slide shows into sections with title slides using a level 1 heading (`#`). For example:

``` {.markdown code-preview="examples/creating-slides-2.qmd"}
---
title: "Habits"
author: "John Doe"
format: {{< meta slide-format >}}
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

## Going to sleep

- Get in bed
- Count sheep
```

Finally, you can also delineate slides using horizontal rules (for example, if you have a slide without a title):

``` {.markdown code-preview="examples/creating-slides-3.qmd"}
---
title: "Habits"
author: "John Doe"
format: {{< meta slide-format >}}
---

- Turn off alarm
- Get out of bed

---

- Get in bed
- Count sheep
```

The examples above all use level 2 headings for slides and level 1 headings for sections/title slides. You can customize this using the `slide-level` option (See the Pandoc documentation on [structuring the slide show](https://pandoc.org/MANUAL.html#structuring-the-slide-show) for additional details.

### Title Slide

You'll notice in the above examples that a title slide is automatically created based on the `title` and `author` provided in the document YAML options. However, sometimes you don't want an explicit title slide (e.g. if your first slide consists entirely of a background image). It's perfectly valid to create a presentation without a title slide, just exclude the `title` and `author` options:

``` markdown
---
format: {{< meta slide-format >}}
---

## Getting up

- Turn off alarm
- Get out of bed

## Going to sleep

- Get in bed
- Count sheep
```
