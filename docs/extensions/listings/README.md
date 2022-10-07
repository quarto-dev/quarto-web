## Extension Listings

If you have an extension you'd like to see us include in the listing of [available extensions](../index.qmd), send us a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests) that includes an addition to the appropriate YAML file in this directory.

You can edit the YAML files online and automatically submit a pull request using the following links (no contributor agreement is required for these pull requests):

| File                                                                                                                                 | Description                                                                                                                       |
|--------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| [shortcodes-and-filters.yml](https://github.com/quarto-dev/quarto-web/edit/main/docs/extensions/listings/shortcodes-and-filters.yml) | Special markdown directives that generate various types of content and/or add new markdown rendering behaviors                    |
| [journal-articles.yml](https://github.com/quarto-dev/quarto-web/edit/main/docs/extensions/listings/journal-articles.yml)             | Enable authoring of professional Journal articles using markdown, and produce both LaTeX (PDF) and HTML versions of the articles. |
| [custom-formats.yml](https://github.com/quarto-dev/quarto-web/edit/main/docs/extensions/listings/custom-formats.yml)                 | Create new output formats by bundling together document options, templates, stylesheets, and other content.                       |
| [revealjs-plugins.yml](https://github.com/quarto-dev/quarto-web/edit/main/docs/extensions/listings/revealjs-plugins.yml)             | Extend the capabilities of HTML presentations created with Revealjs.                                                              |

For example, here the entry for the [lighbox](https://github.com/quarto-ext/lightbox) filter:

``` yaml
- name: lightbox
  path: https://github.com/quarto-ext/lightbox
  author: "[quarto-ext](https://github.com/quarto-ext/)"
  description: |
    Create [lightbox]((https://biati-digital.github.io/glightbox/))
    treatments for images in your HTML documents.
```

Extensions submitted for listing should meet the following requirements:

1.  Hosted from a GitHub repository.
2.  Include a `README.md` file that describes how to install them and provides examples of syntax and usage.
3.  Clearly indicates that they are available under an open-source license.
