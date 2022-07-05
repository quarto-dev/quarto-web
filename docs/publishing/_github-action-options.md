### Additional Options

It's possible to have a Quarto project in a large GitHub repository, where the Quarto project does not reside at the top-level directory. In this case, add a `path` input to the invocation of the `render` or `publish` action. For example:

``` yaml
- name: Render and Publish
  uses: quarto-dev/quarto-actions/publish@v2
  with:
    target: {{< meta provider >}}
    path: subdirectory-to-use
```

By default, `quarto publish` will re-render your project before publishing it. However, if you store the rendered output in version control, you don't need the GitHub action to re-render the project. In that case, add the option `render: false` to the `publish` action:

``` yaml
- name: Render and Publish
  uses: quarto-dev/quarto-actions/publish@v2
  with:
    target: {{< meta provider >}}
    render: false
```

See the full definition of the Quarto [publish action](https://github.com/quarto-dev/quarto-actions/blob/main/publish/action.yml) to learn about other more advanced options.
