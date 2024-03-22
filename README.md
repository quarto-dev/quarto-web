# quarto-web

This is the repo for the documentation hosted at [quarto.org](https://quarto.org/).

## Reporting Issues

Please report issues on quarto.org by opening a "Documentation Issue" in the `quarto-dev/quarto-cli` repository: [New Issue](https://github.com/quarto-dev/quarto-cli/issues/new/choose)

## Contributing

This part discusses how to contribute to the documentation by rendering document locally.

### Quarto-web uses frozen state of computation

This Quarto project uses `freeze: true`, meaning it will never run computation engines during a project render. No Knitr or Jupyter configuration is needed to build the whole website. The `_freeze` folder is tracked on the git repo for this purpose. (See about [freeze](https://quarto.org/docs/projects/code-execution.html#freeze) for a reminder of how this works).

What is the impact if you modify or add a document: 

- If you add a document not using any computation (i.e default `engine: markdown` is used), only committing the change in the document is enough.
- If you add a document using `engine: knitr` or `engine: jupyter`, you need to render the document locally and commit the changes in the `_freeze` folder too. See [incremental render](https://quarto.org/docs/projects/code-execution.html#incremental-render).

### Rendering the whole website

To render the whole website locally, you can use the following command:

```bash
# Update freeze state if needed
quarto render /docs/path/to/modified-or-added-document.qmd
# Render the whole website using freeze state for all the other docs
quarto render
```

### Installing and managing computation environment

#### R environment for Knitr engine

This project uses R 4.3.2 and **renv** to manage its R dependencies. To install the R environment, you can use the following command at the project root:

```bash
Rscript -e "renv::restore()"
```

If you are adding a new document that may use a new package, follow these steps:

- Dependencies are explicitly declared in `DESCRIPTION` file. So add the new package to the list.
- Run `renv::install('package_name')` to add the new package to project library, and render your document to test everything is working fine.
- Run `renv::snapshot()` to update the `renv.lock` file with the new package and its dependencies.
- Commit the modified `DESCRIPTION` and `renv.lock` files with your document change (don't forget any change in the `_freeze` folder if needed).

