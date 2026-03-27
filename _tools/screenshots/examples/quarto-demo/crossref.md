---
title: "Markdown Crossrefs"
author: "Jane Doe"
date: "March 22nd, 2021"
format: html
---

::: {.callout-tip}
## Learn more
See the full guide on [Cross References](https://quarto.org/docs/authoring/cross-references.html).
:::

## Figures

#### Markdown

``` {.markdown}
![Elephant](elephant.png){#fig-elephant width=4in}

See @fig-elephant for an illustration.
```

#### Output

![Elephant](elephant.png){#fig-elephant width="4in"}

See @fig-elephant for an illustration.

## Tables

#### Markdown

``` {.markdown}
| Col1 | Col2 | Col3 |
|------|------|------|
| A    | B    | C    |
| E    | F    | G    |
| A    | G    | G    |

: My Caption {#tbl-letters}

See @tbl-letters.
```

#### Output

| Col1 | Col2 | Col3 |
|------|------|------|
| A    | B    | C    |
| E    | F    | G    |
| A    | G    | G    |

: My Caption {#tbl-letters}

See @tbl-letters.

## Equations

#### Markdown

``` {.markdown}
$$
P\left(A=2\middle|\frac{A^2}{B}>4\right)
$$ {#eq-testmath}

See @eq-testmath.
```

#### Output

$$
P\left(A=2\middle|\frac{A^2}{B}>4\right)
$$ {#eq-testmath}

See @eq-testmath.

## Sections {#sec-sections}

#### Markdown

``` {.markdown}
# Sections {#sec-sections}

This is a section.

See @sec-sections.
```

#### Output

This is a section.

See [sec. 1.4](#sec-sections).

## References

#### Markdown

``` {.markdown}
@fig-elephant

@Fig-elephant

[Figure @fig-elephant; @eq-testmath]

See table [-@tbl-letters].
```

#### Output

@fig-elephant

@Fig-elephant

[Figure @fig-elephant; @eq-testmath]

See table [-@tbl-letters].

## Listings

#### Markdown

```` {.markdown}
``` {#lst-pandas .python lst-cap="Pandas"}
import pandas as pd
d = {'one' : [1., 2., 3., 4.],
     'two' : [4., 3., 2., 1.]}
df = pd.DataFrame(d)
df
```

See @lst-pandas
````

#### Output

``` {#lst-pandas .python lst-cap="Pandas"}
import pandas as pd
d = {'one' : [1., 2., 3., 4.],
     'two' : [4., 3., 2., 1.]}
df = pd.DataFrame(d)
df
```

See @lst-pandas

## Theorems

#### Markdown

``` {.markdown}
::: {#thm-line name="Line"}
The equation of any straight line, called a linear equation, can be written as:

$$
y = mx + b
$$
:::

See @thm-line.
```

#### Output

::: {#thm-line name="Line"}
The equation of any straight line, called a linear equation, can be written as:

$$
y = mx + b
$$
:::

See @thm-line.
