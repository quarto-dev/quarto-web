# quarto-web

This is the repo for the documentation hosted at [quarto.org](https://quarto.org/).

## Reporting Issues

Please report issues on quarto.org by opening a "Documentation Issue" in the `quarto-dev/quarto-cli` repository: [New Issue](https://github.com/quarto-dev/quarto-cli/issues/new/choose)

## Contributing

This section discusses how to contribute to the documentation by rendering a document locally.

### Quarto-web uses a frozen state of computation

This Quarto project uses `freeze: true`, meaning it will never run computation engines during a project render. No Knitr or Jupyter configuration is needed to build the whole website. The `_freeze` folder is tracked on the git repo for this purpose. (See about [freeze](https://quarto.org/docs/projects/code-execution.html#freeze) for a reminder of how this works).

What is the impact if you modify (or add) a document: 

- If you modify a document that doesn't use any computation (i.e default `engine: markdown` is used), committing only the changes in the document is enough.
- If you modify a document that uses `engine: knitr` or `engine: jupyter`, you need to render the document locally and commit the changes in the `_freeze` folder as well. See [incremental render](https://quarto.org/docs/projects/code-execution.html#incremental-render).

### Rendering the whole website

To render the whole website locally, you can use the following command:

```bash
# Update freeze state if needed
quarto render /docs/path/to/modified-or-added-document.qmd
# Render the whole website using freeze state for all the other docs
quarto render
```

### Installing and managing computation environment

To manage computational dependencies this project uses

- **renv** for the R environment (https://rstudio.github.io/renv/) - it will be installed automatically first time the project is run with R.
- **pipenv** for the Python environment (https://pipenv.pypa.io/en/latest/) - Please install pipenv manually if you don't have it yet.

#### R environment for Knitr engine

This project uses R 4.3.2 and **renv** to manage its R dependencies. To install the R environment, you can use the following command at the project root:

```bash
Rscript -e "renv::restore()"
```

The project library will be located under the `renv` folder.

You don't need to worry about the R environment when you are working on this project. **renv** sets up `.Rprofile` to activate the project library when R is run from the project's root. Just run your R code as usual, and **renv** will be activated automatically, meaning R will correctly use the project's library.

If you are adding a new document that may use a new package, follow these steps:

- Dependencies are explicitly declared in `DESCRIPTION` file. So add the new package to the list.
- Run `renv::install('package_name')` to add the new package to project library, and render your document to test everything is working fine.
- Run `renv::snapshot()` to update the `renv.lock` file with the new package and its dependencies.
- Commit the modified `DESCRIPTION` and `renv.lock` files with your document change (don't forget any change in the `_freeze` folder if needed).

**Note: Python dependencies are not tracked through renv but are tracked with pipenv.** See below

#### Python environment for Jupyter engine and Knitr through reticulate

This project uses **pipenv** (https://pipenv.pypa.io/zh-cn/stable/index.html) to handle the Python dependencies. **pipenv** takes care of managing dependencies and virtual environments for you.

To install the Python environment, you can use the following command at the project root:

```bash
pipenv sync
```

If you are using `pyenv` to manage your python installation, `pipenv` will ask you to install a newer version of python if the one currently used does not match the one from `Pipfile.lock`. Though, the exact match of version isn't required and this should not be a problem to not upgrade your python installation.

The virtual environment will be located in the project directory under `.venv` (following the configuration of `pipenv` set in the `.env` file).

When in the root of the project, you can run `pipenv shell` to activate the virtual environment associated with the project. Any `quarto` command should then use the correct python environment. 
You can also run `pipenv run quarto ...` to run the `quarto` command in the virtual environment without activating it.


If you are adding a new document that may use a new package, follow these steps:

- Run `pipenv install <package_name>` to add the new package to the project. It will update the `Pipfile` and `Pipfile.lock` files with the new package and its dependencies. 
  - `Pipfile` could be manually edited but using the command is recommended.
- Commit the modified `Pipfile` and `Pipfile.lock` files with your document changes (don't forget any changes in the `_freeze` folder if needed).

Documents running python with the Knitr engine will go through **reticulate**. **reticulate**  will use the python version defined with `pipenv` when a `PipFile` is present. So, it will use the Python version from `.venv` --- no specific configuration is needed. 