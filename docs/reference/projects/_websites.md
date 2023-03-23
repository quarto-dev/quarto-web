## Navbar

Options that define the top navigation bar for a {{< meta project-type >}} For example:

``` yaml
---
{{< meta project-type >}}:
  navbar:
    search: true
---
```

::: {#table-navbar}
:::

## Nav Items

Nav items appear in the `left` or `right` key of `navbar` definitions. For example:

``` yaml
---
{{< meta project-type >}}:
  navbar:
    right:
      - icon: github
        href: https://github.com/
        aria-label: GitHub
---
```

::: {#table-navitem}
:::

Note that the `icon` option is available for items in the Navbar, however items in the Sidebar do not support the `icon` option.

## Sidebar

Options that define the side navigation area for a {{< meta project-type >}}. For example:

``` yaml
---
{{< meta project-type >}}:
  sidebar:
    search: true
---
```

::: {#table-sidebar}
:::

### Sidebar Tools

Action buttons that appear on the sidebar. For example:

``` yaml
---
{{< meta project-type >}}:
  sidebar:
    tools:
      - icon: github
        href: https://github.com/
---
```

::: {#table-sidebartool}
:::

## Footer

{{< meta project-type-upper >}} page footer definition. For example:

``` yaml
---
{{< meta project-type >}}:
  page-footer:
    center: 
      - text: "About"
        href: about.qmd
      - text: "License"
        href: license.qmd
      - text: "Trademark"
        href: trademark.qmd
---
```

::: {#table-pagefooter}
:::

## Search

Search options are specified under the `search` key of `{{< meta project-type >}}`. For example:

``` yaml
{{< meta project-type >}}:
  search:
    location: navbar
    type: overlay
---
```

::: {#table-search}
:::

### Algolia Options

You can use an [Algolia](../../websites/website-search.qmd#using-algolia) index as the back end of {{< meta project-type >}} search. Specify Algolia options using the `algolia` sub-key of `search`, for example:

``` yaml
---
{{< meta project-type >}}:
  search:
    algolia:
      index-name: <my-index-name>
      application-id: <my-application-id>
      search-only-api-key: <my-search-only-api-key>
---
```

::: {#table-algolia}
:::

The `index-fields` option provides sub-fields within the Algolia index to target for searches:

::: {#table-algolia-index-fields}
:::

## Social

Social metadata is provided as a subkey of `{{< meta project-type >}}` options. You can specify `true` to generate social metadata using a set of default option, or specify one or more Twitter or Open Graph specific options as enumerated below. For example:

``` yaml
---
{{< meta project-type >}}:
  open-graph: true
  twitter-card: 
    site: "@sitehandle"
---
```

### Twitter Card

::: {#table-twitter}
:::

### Open Graph

::: {#table-open-graph}
:::

## Comments

You can add commenting to your {{< meta project-type >}} using either [Hypothesis](https://web.hypothes.is/), [Utterances](https://utteranc.es/), or [Giscus](https://giscus.app/).

### Hypothesis

Enable and configure Hypothesis commenting via `comments` key. For example:

``` yaml
---
website:
  comments: 
    hypothesis:
      theme: clean
      openSidebar: false
---
```

::: {#table-hypothesis}
:::

For additional documentation on the Hypothesis options enumerated above, see the [Hypothesis Publisher Config](https://h.readthedocs.io/projects/client/en/latest/publishers/config/) documentation.

### Utterances

Enable and configure Utterances commenting via the `comments` key. For example:

``` yaml
---
website:
  comments: 
    utterances:
      repo: quarto-dev/quarto-web
---
```

::: {#table-utterances}
:::

### Giscus

Enable and configure usage of the [Giscus app](https://giscus.app) via the `comments` key. For example:

``` yaml
---
website:
  comments:
    giscus:
      repo: quarto-dev/quarto-web
---
```

::: {#table-giscus}
:::

## Listings

[Listings](/docs/websites/website-listings.qmd) enable you to automatically generate the contents of a page (or region of a page) from a list of Quarto documents or other custom data. You can enable listings on a page using the `listing` option in the document front matter, for example:

``` yaml
---
title: "Listing Example"
listing: default
---
```

::: {#table-listing}
:::

### Feed

Enable an RSS feed for your listing by including the `feed` option.

::: {#table-feed}
:::

## About

Layout a simple about page for an individual or organization. For more, see the [About Pages](/docs/websites/website-about.qmd) documentation.

::: {#table-about}
:::
