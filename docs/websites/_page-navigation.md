## Page Navigation

If you have a {{< meta project-type >}} with several pages in a section or subsection, it is often convenient to offer the user the ability to navigate to the next page (or previous page) at the bottom of the page that they've just finished reading. You can enable this using:

``` yaml
{{< meta project-type >}}:
  page-navigation: true
```

When enabled, page navigation will be displayed at the bottom of the page whenever there is a next or previous page (including in the next or previous section). This option is enabled by default for books but not for websites.

You can also enable or disable page navigation at the page level by specifying `page-navigation` in the YAML header, e.g.:

```{.yaml filename="basics.qmd"}
---
page-navigation: false
---
```

Or to control page navigation for all pages in a directory specify `page-navigation` in [`_metadata.yml`](https://quarto.org/docs/projects/quarto-projects.qmd#directory-metadata):

``` {.yaml filename="_metadata.yml"}
page-navigation: false
```
