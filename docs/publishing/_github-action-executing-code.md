### Executing Code

If you prefer, you can also configure a GitHub Action to execute R, Python, or Julia code as part of rendering. While this might reflexively seem like the best approach, consider the following requirements imposed when you execute code within a CI service like GitHub Actions:

{{< include _ci-execute-requirements.md >}}

#### Prerequisites

The best way to ensure that your code can be executed within a GitHub Action is to use a virtual environment like [venv](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment) or [renv](https://rstudio.github.io/renv/articles/renv.html) with your project (below we'll provide example actions for each). If you aren't familiar with using these tools check out the article on using [Virtual Environments](../projects/virtual-environments.qmd) with Quarto to learn more.

Once you've decided to execute code within your GitHub Action you can remove the `freeze: auto` described above from your `_quarto.yml` configuration. Note that if you want to use `freeze` selectively for some documents or directories that is still possible (for a directory, create a `_metadata.yml` file in the directory and specify your freeze configuration there---this is what Quarto does by default for the `posts` folder of blog projects).

#### Example: Jupyter with venv

Here is a complete example of a GitHub Action that installs Python, Jupyter, and package dependencies from `requirements.txt`, then executes code and renders output to GitHub Pages:

**.github/workflows/publish.yml**

``` yaml
on:
  push:
    branches: main

name: Quarto Publish

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v2 

      - name: Set up Quarto
        uses: quarto-dev/quarto-actions/setup@v2
        
      - name: Install Python and Dependencies
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
          cache: 'pip'
      - run: pip install jupyter
      - run: pip install -r requirements.txt
      
      - name: Render and Publish 
        uses: quarto-dev/quarto-actions/publish@v2
        with:
          target: {{< meta provider >}}
          env:
            {{< meta provider-token >}}: ${{ secrets.{{< meta provider-token >}} }}
```

#### Example: Knitr with renv

Here is a complete example of a GitHub Action that installs R and package dependencies from `renv.lock`, then executes code and renders output to GitHub Pages:

**.github/workflows/publish.yml**

``` yaml
on:
  push:
    branches: main

name: Quarto Publish

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v2 

      - name: Set up Quarto
        uses: quarto-dev/quarto-actions/setup@v2
        
      - name: Install R
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.2.0'
      
      - name: Install R Dependencies 
        uses: r-lib/actions/setup-renv@v2
        with:
          cache-version: 1
      
      - name: Render and Publish
        uses: quarto-dev/quarto-actions/publish@v2
        with:
          target: {{< meta provider >}}
          env:
            {{< meta provider-token >}}: ${{ secrets.{{< meta provider-token >}} }}
```

