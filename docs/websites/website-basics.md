---
title: "Creating a Website"
description: "Quarto Websites are a convenient way to publish groups of documents. Document published as part of a website share navigational elements, rendering options, and visual style."
format: html
---

## Overview

Quarto Websites are a convenient way to publish groups of documents. Document published as part of a website share navigational elements, rendering options, and visual style.

Website navigation can be provided through a global navbar, a sidebar with links, or a combination of both for sites that have multiple levels of content. You can also enable full text search for websites.

This site is an example of a Quarto Website (you can see the source code for it here: <https://github.com/quarto-dev/quarto-docs>).

## Getting Started

To create a new website project, use the Quarto `create-project` command:

``` {.bash}
quarto create-project mysite --type site
```

This will create the scaffolding for a simple website in the `mysite` subdirectory. Here is what the `_quarto.yml` config file will look like for the site:

``` {.yaml}
project:
  type: site

site:
  title: "mysite"
  navbar:
    type: dark
    background: primary
    left:
      - href: index.md
        text: Home
      - about.md

format:
  html:
    theme: cosmo
    css: styles.css
    toc: true
```

To build the website into the `_site` directory:

``` {.bash}
quarto render mybook
```

See the [Quarto Projects](quarto-projects.md) article to learn more about working with projects.

## Workflow

Quarto includes a live-reloading development server that you will likely find convenient to use while working on websites. Start the server with:

``` {.bash}
quarto serve
```

The browser will automatically refresh whenever you save a markdown file (`.md`) or Jupyter Notebook (`.ipynb`). The browser will also refresh whenever you render a `.qmd` or `.Rmd` file.

Changes to configuration files (e.g. `_quarto.yml`) as well site resources (e.g. theme or CSS files) will also cause an automatic refresh.

Note that development server updates do not cause an update to the final site output. Consequently, you should always `quarto render` your site before deploying it, even if you have already previewed the changes with the development server.

### RStudio {.unlisted}

If you are using Quarto from R, you can also use the **quarto** package to run the development server:

``` {.r}
library(quarto)
quarto_serve()
```

Note that you should also be sure to disable the standard RStudio preview behavior when using this workflow:

![](images/rstudio-no-preview.png)

Note that the **(No Preview)** option is checked to disable the normal preview on render behavior.

RStudio v1.4 automatically uses Quarto to render Rmd documents whenever it sees a `format` key in the YAML front matter (as opposed to an `output` key). For projects, you typically provide the `format` configuration in `_quarto.yml` so may not have a `format` key in individual documents.

However, since RStudio v1.4 is not aware of Quarto projects, you should add an explicit entry in YAML front-matter to ensure that Quarto (rather than the **rmarkdown** package) is used for rendering:

``` {.yaml}
---
title: "My Page"
knit: quarto render
---
```

## Resources

Besides input and configuration files, your site likely also includes a variety of resources (e.g. images) that you will want to publish along with your site. Quarto will automatically detect any files that you reference within your site and copy them to the output directory (e.g. `_site`).

If this auto-detection fails for any reason, or if you want to publish a file not explicitly linked to from within your site, you can add a `resources` entry to your configuration. For example, here we specify that we want to include all Excel spreadsheets within the project directory as part of the website:

``` {.yaml .yml}
project:
  type: site
  resources: 
    - *.xlsx
```

You can also add a `resources` metadata value to individual files. For example:

``` {.yaml}
title: "My Page"
resources:
  - sheet.xlsx
```

Images are the most commonly used type of resource file. If you have global images (e.g. a logo) that you want to reference from various pages within your site, you can use an site-absolute path to refer to the images, and it will be automatically converted to a relative path during publishing. For example:

``` {.markdown}
![](/images/logo.png)
```
