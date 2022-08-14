## Publish Command

The `quarto publish` command is the easiest way to publish locally rendered content. From the directory where your project is located, execute the `quarto publish` command for {{< meta provider-name >}}:

```{.bash filename="Terminal"}
quarto publish {{< meta provider >}}
```

If you haven't published to {{< meta provider-name >}} before, the publish command will prompt you to authenticate. After confirming that you want to publish, your content will be rendered and deployed, and then a browser opened to view your site.

### \_publish.yml

The `_publish.yml` file is used to to specify the publishing destination. This file is automatically created (or updated) whenever you execute the `quarto publish` command, and is located within the project or document directory.

The service, id, and URL of the published content is specified in `_publish.yml`. For example:

``` yaml
- source: project
  {{< meta provider >}}:
    - id: "5f3abafe-68f9-4c1d-835b-9d668b892001"
      url: "{{< meta provider-publish-url >}}"
```

If you have an existing {{< meta provider-name >}} site that you want to publish to, you should manually create a `_publish.yml` file that looks like the example above, but with the appropriate `id` and `url` values for your site.

Account information is not stored in `_publish.yml`, so it is suitable for checking in to version control and being shared by multiple publishers.

### Options

You can customize the behavior of `quarto publish` by providing the following command line options:

{{< include _cli-options.md >}}

To publish a document rather than a website or book, provide the path to the document:

```{.bash filename="Terminal"}
quarto publish {{< meta provider >}} document.qmd
```
