---
title: "Markdown Layout"
author: "Jane Doe"
date: "March 22nd, 2021"
format: html
---

::: {.callout-tip}
## Learn more
See the full guide on [Figures](https://quarto.org/docs/authoring/figures.html) and [Article Layout](https://quarto.org/docs/authoring/article-layout.html).
:::

## Layout by Column

::: {layout-ncol="2"}
![Elephant 1](elephant.png)

![Elephant 2](elephant.png)
:::

\pagebreak

## Layout by Row

::: {layout.nrow="2"}
![Elephant 1](elephant.png)

![Elephant 2](elephant.png)

![Elephant 3](elephant.png)
:::

\pagebreak

## Custom Layout

::: {layout="[[4,-1,4],[3,3,3]]"}
![Elephant 1](elephant.png)

![Elephant 2](elephant.png)

![Elephant 3](elephant.png)

![Elephant 4](elephant.png)

![Elephant 5](elephant.png)
:::

\pagebreak

## Layout Any Content

::: {layout="[[4,-1,4],[3,3,3]]"}
![Elephant 1](elephant.png)

![Elephant 2](elephant.png)

![Elephant 3](elephant.png)

$$
P\left(A=2\middle|\frac{A^2}{B}>4\right)
$$

![Elephant 5](elephant.png)
:::

\pagebreak


## Layout Lists

::: {layout-ncol="2"}
### List 1

- Item 1
- Item 2
- Item 3

### List 2

- Item 1
- Item 2
- Item 3
:::

## Layout Tables

::: {#tbl:panel layout.nrow="1"}
| Col1 | Col2 | Col3 |
|------|------|------|
| A    | B    | C    |
| E    | F    | G    |
| A    | G    | G    |

: My Caption {#tbl:foo-1}

| Col1 | Col2 | Col3 |
|------|------|------|
| A    | B    | C    |
| E    | F    | G    |
| A    | G    | G    |

: My Caption2 {#tbl:foo-2}

Caption
:::
