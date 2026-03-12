## Quarto Demo

You can browse the demo site at <https://quarto-dev.github.io/quarto-demo>.

To run the demo locally, first install the [Quarto CLI](https://quarto.org/docs/get-started/).

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
