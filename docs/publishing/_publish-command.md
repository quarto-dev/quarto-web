## Publish Command

The `quarto publish` command is the easiest way to publish locally rendered content. From the directory where your project is located, execute the `quarto publish` command for {{< meta provider-name >}}:

``` bash
quarto publish {{< meta provider >}}
```

If you haven't published to {{< meta provider-name >}} before, the publish command will prompt you to authenticate. After confirming that you want to publish, your content will be rendered and deployed, and then a browser opened to view your site.

A record of your previous publishes will be stored in a `_publish.yml` file within the project or document directory. This file stores the service, id, and URL of the published content. For example:

``` yaml
- source: project
  {{< meta provider >}}:
    - id: "5f3abafe-68f9-4c1d-835b-9d668b892001"
      url: "{{< meta provider-publish-url >}}"
```

Account information is not stored in this file, so it is suitable for checking in to version control and being shared by multiple publishers.

You can customize the behavior of `quarto publish` by providing the following command line options:

{{< include _cli-options.md >}}

To publish a document rather than a website or book, provide the path to the document:

``` bash
quarto publish {{< meta provider >}} document.qmd
```
