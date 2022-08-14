To make sure that R, Python, and Julia code is only executed locally, configure your project to use Quarto's [freeze](../projects/code-execution.html#freeze) feature by adding this to your `_quarto.yml`:


```{.yaml filename="_quarto.yml"}
execute:
  freeze: auto
```

Now, fully re-render your site:

```{.bash filename="Terminal"}
quarto render
```

If you have executable code in your project you'll notice that a `_freeze` directory has been created at the top level of your project. This directory stores the results of computations and should be checked in to version control. Whenever you change a `.qmd` file with executable code, it will automatically be re-run during your next render and the updated computations will be stored in `_freeze`.