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

This project will use 

- **renv** for R environment (https://rstudio.github.io/renv/) - it will be installed automatically first time the project is ran with R.
- **pipenv** for Python environment (https://pipenv.pypa.io/en/latest/) - Please install pipenv manually if you don't have it yet.

#### R environment for Knitr engine

This project uses R 4.3.2 and **renv** to manage its R dependencies. To install the R environment, you can use the following command at the project root:

```bash
Rscript -e "renv::restore()"
```

Project library will be located under `renv` folder.

**renv** works in a specific way that it sets up `.Rprofile` to activate the project library when R is ran from project's root. So you don't need to worry about the R environment when you are working on this project. Just run your R code as usual and **renv** will be activated automatically, meaning R will correctly use project's library.

If you are adding a new document that may use a new package, follow these steps:

- Dependencies are explicitly declared in `DESCRIPTION` file. So add the new package to the list.
- Run `renv::install('package_name')` to add the new package to project library, and render your document to test everything is working fine.
- Run `renv::snapshot()` to update the `renv.lock` file with the new package and its dependencies.
- Commit the modified `DESCRIPTION` and `renv.lock` files with your document change (don't forget any change in the `_freeze` folder if needed).

**Note: Python dependencies are not tracked through renv and only using pipenv.** See below

#### Python environment for Jupyter engine and Knitr through reticulate

This project uses **pipenv** (https://pipenv.pypa.io/zh-cn/stable/index.html) to handle the Python dependencies. **pipenv** takes care of managing dependencies and virtual environments for you.

When in the root of the project, you can run `pipenv shell` to activate the virtual environment associated with the project. Any `quarto` command should use the correct python environment. 
You can also run `pipenv run quarto ...` to run the `quarto` command in the virtual environment without activating it.

To install the Python environment, you can use the following command at the project root:

```bash
pipenv sync
```

The virtual environment will be located in the project directory under `.venv` (following configuration of `pipenv` in the `.env` file).

If you are adding a new document that may use a new package, follow these steps:

- Run `pipenv install <package_name>` to add the new package to the project. It will update the `Pipfile` and `Pipfile.lock` files with the new package and its dependencies. 
  - `Pipfile` could be manually edited but using the command is recommended.
- Commit the modified `Pipfile` and `Pipfile.lock` files with your document change (don't forget any change in the `_freeze` folder if needed).

For any document running python with Knitr engine,it will go through **reticulate** which will use the python version defined with `pipenv` when a `PipFile` is present. So the same Python version from `.venv` will be used. No specific configuration is needed for **reticulate**. 