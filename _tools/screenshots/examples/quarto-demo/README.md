## Quarto Demo

You can browse the demo site at <https://quarto-dev.github.io/quarto-demo>.

## Local Development

First, install the [Quarto CLI](https://quarto.org/docs/get-started/).

Then, clone this repo:

``` {.bash}
$ git clone https://github.com/quarto-dev/quarto-demo
$ cd quarto-demo
```

Next, install the Python dependencies using [uv](https://docs.astral.sh/uv/):

``` {.bash}
$ uv sync
```

Then, install the R dependencies:

``` {.r}
> renv::restore()
```

Finally, render or serve the site locally:

``` {.bash}
$ quarto render
$ quarto preview
```

## Publishing

The site is published to GitHub Pages via a [GitHub Actions workflow](.github/workflows/publish.yml). On every push to `main`, the workflow renders the site and deploys it to the `gh-pages` branch.

This project uses [`freeze: true`](https://quarto.org/docs/projects/code-execution.html#freeze) so that the CI workflow does not need R or Python installed. Computational outputs (figures, tables, etc.) are cached in `_freeze/` and committed to the repo. When the CI renders the site, it reuses these cached results instead of re-executing code.

Since `freeze: true` applies to global project renders, you need to render changed files individually to re-execute their code and update `_freeze/`:

``` {.bash}
$ quarto render basics-jupyter.qmd   # re-executes this file
$ quarto render layout-knitr.Rmd     # re-executes this file
$ git add _freeze
$ git commit -m "Update freeze results"
```

A project-level `quarto render` will use the existing freeze cache without re-executing any code.
