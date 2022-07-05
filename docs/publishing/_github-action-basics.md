Using the `quarto publish {{< meta provider >}}` command to publish locally rendered content is the most simple and straightforward way to publish. Another option is to use [GitHub Actions](https://docs.github.com/en/actions) to render and publish your site (you might prefer this if you want execution and/or rendering to be automatically triggered from commits).

There are a few different ways to approach rendering and publishing content. Below, we'll provide a how-to guide for publishing with GitHub Actions. For more conceptual background on the various approaches, see the discussion on [Rendering for CI](ci.qmd#rendering-for-ci).

### Freezing Computations

{{< include _freeze-basics.md >}}

Note that an alternative approach is to execute the code as part of the GitHub Action. For now we'll keep things simpler by executing code locally and storing the computations by using freeze. Then, further below, we'll cover [Executing Code] within a GitHub Action.

### Publish Action

Add a `publish.yml` GitHub Action to your project by creating this YAML file and saving it to `.github/workflows/publish.yml`:

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

      - name: Render and Publish 
        uses: quarto-dev/quarto-actions/publish@v2
        with:
          target: {{< meta provider >}}
          env:
            {{< meta provider-token >}}: ${{ secrets.{{< meta provider-token >}} }}
```
