### Executing Code

If you prefer, you can also configure a GitHub Action to execute R, Python, or Julia code as part of rendering. While this might reflexively seem like the best approach, consider the following requirements imposed when you execute code within a CI service like GitHub Actions:

{{< include _ci-execute-requirements.md >}}

#### Prerequisites

The best way to ensure that your code can be executed within a GitHub Action is to use a virtual environment like [venv](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment) or [renv](https://rstudio.github.io/renv/articles/renv.html) with your project (below we'll provide example actions for each). If you aren't familiar with using these tools check out the article on using [Virtual Environments](../projects/virtual-environments.qmd) with Quarto to learn more.

Once you've decided to execute code within your GitHub Action you can remove the `freeze: auto` described above from your `_quarto.yml` configuration. Note that if you want to use `freeze` selectively for some documents or directories that is still possible (for a directory, create a `_metadata.yml` file in the directory and specify your freeze configuration there---this is what Quarto does by default for the `posts` folder of blog projects).
