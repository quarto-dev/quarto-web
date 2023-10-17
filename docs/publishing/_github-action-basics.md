Using the `quarto publish {{< meta provider >}}` command to publish locally rendered content is the most simple and straightforward way to publish. Another option is to use [GitHub Actions](https://docs.github.com/en/actions) to render and publish your site (you might prefer this if you want execution and/or rendering to be automatically triggered from commits).

There are a few different ways to approach rendering and publishing content. Below, we'll provide a how-to guide for publishing with GitHub Actions. For more conceptual background on the various approaches, see the discussion on [Rendering for CI](ci.qmd#rendering-for-ci).

### Publish Record

Prior to attempting to publish with a GitHub Action, you should have completed at least one publish using the [Publish Command](#publish-command) (described immediately above). This publish will create a `_publish.yml` file that records the publishing destination to be used by the GitHub Action. For example:

``` yaml
- source: project
  {{< meta provider >}}:
    - id: "5f3abafe-68f9-4c1d-835b-9d668b892001"
      url: "{{< meta provider-publish-url >}}"
```

You can also manually create a `_publish.yml` file that looks like the example above, but with the appropriate `id` and `url` values for your site.

Do not proceed to the next step(s) until you have a `_publish.yml` that indicates your publishing destination.

### Freezing Computations

{{< include _freeze-basics.md >}}

Note that an alternative approach is to execute the code as part of the GitHub Action. For now we'll keep things simpler by executing code locally and storing the computations by using freeze. Then, further below, we'll cover [Executing Code](#executing-code) within a GitHub Action.

### Publish Action

Add a `publish.yml` GitHub Action to your project by creating this YAML file and saving it to `.github/workflows/publish.yml`:
