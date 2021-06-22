---
title: "Website Tools"
description: "Learn more about the additional tools that you can use to customize your Quarto website."
---

## Social Metadata

You can enhance your website and the content that you publish to it by including additional types of metadata, including:

-   Twitter Cards
-   Open Graph

### Twitter Cards

[Twitter Cards](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards) provide an enhanced appearance when someone links to content on Twitter. When a link to your content is included in a Tweet, Twitter automatically crawls your site and fetches any Twitter Card metadata. To enable the automatic generation of Twitter Card metadata for your content, you can add the following to your `_quarto.yml` configuration file:

``` {.yaml}
site:
  twitter-card: true
```

In this case, Quarto will automatically generated a title, description, and preview image for the content. For more information about how Quarto finds preview images, see [Preview Images].

You may also provide additional metadata to be used when generating the Twitter Card, including:

+---------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Key           | Description                                                                                                                                                                                                                                                                            |
+===============+========================================================================================================================================================================================================================================================================================+
| `title`       | The title of the content. Quarto will automatically use the `title` metadata from the page metadata. If you'd like you can override this just for the Twitter Card by including a `title` in the `twitter-card` metadata.                                                              |
+---------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `description` | A short description of the content. Quarto will automatically use the `description` metadata from the page metadata. If you'd like you can override this just for the Twitter Card by including a `description` in the `twitter-card` metadata.                                        |
+---------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `image`       | The path to a preview image for this content. By default, Quarto will use the `image` value from the `site:` metadata. If you provide an image, you may also optionally provide an `image-width` and `image-height` to improve the appearance of your Twitter Card.                    |
|               |                                                                                                                                                                                                                                                                                        |
|               | If `image` is not provided, Quarto will automatically attempt to locate a preview image. For more information, see [Preview Images].                                                                                                                                                   |
+---------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `card-style`  | Either `summary` or `summary_large_image`. If this is not provided, the best style will automatically selected based upon other metadata. You can learn more about Twitter Card styles [here](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards). |
+---------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `creator`     | `@username` of the website. Note that strings with special characters such as `@` must be quoted in yaml.                                                                                                                                                                              |
+---------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `site`        | `@username` of content creator. Note that strings with special characters such as `@` must be quoted in yaml.                                                                                                                                                                          |
+---------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Here is a more comprehensive example of specifying Twitter Card metadata in a `quarto.yml` file:

``` {.yaml}
site:
  twitter-card:
    creator: "@dragsonstyle"
    site: "@rstudio"
```

Quarto will automatically merge global metadata found in the `site: twitter-card` key with any metadata provided in the document itself in the `twitter-card` key. This is useful when need to specify a mix of global options (for example, `site`) with per document options such as `title` or `image`.

### Open Graph

The [Open Graph protocol](http://ogp.me/) is a specification that enables richer sharing of links to articles on the web. It will improve the previews of your content when a link to it is pasted into applications like Slack, Discord, Facebook, Linkedin, and more. To enable the automatic generation of Open Graph metadata for your content, include the following in your `_quarto.yml` configuration file:

``` {.yaml}
site:
  opengraph: true
```

In this case, Quarto will automatically generated a title, description, and preview image for the content. For more information about how Quarto finds preview images, see [Preview Images].

You may also provide additional metadata to be used when generating the Open Graph metadata, including:

+---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Key           | Description                                                                                                                                                                                                                                          |
+===============+======================================================================================================================================================================================================================================================+
| `title`       | The title of the content. Quarto will automatically use the `title` metadata from the page metadata. If you'd like you can override this just for the Open Graph metadata by including a `title` in the `open-graph` metadata.                       |
+---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `description` | A short description of the content. Quarto will automatically use the `description` metadata from the page metadata. If you'd like you can override this just for the Open Graph metadata by including a `description` in the `open-graph` metadata. |
+---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `image`       | The path to a preview image for this content. By default, Quarto will use the `image` value from the `site:` metadata. If you provide an image, you may also optionally provide an `image-width` and `image-height`.                                 |
|               |                                                                                                                                                                                                                                                      |
|               | If `image` is not provided, Quarto will automatically attempt to locate a preview image. For more information, see [Preview Images].                                                                                                                 |
+---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `locale`      | The locale that the Open Graph metadata is marked up in.                                                                                                                                                                                             |
+---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `site_name`   | The name which should be displayed for the overall site. If not explicitly provided in the `open-graph` metadata, Quarto will use the `site:title` value.                                                                                            |
+---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Here is a more comprehensive example of specifying Open Graph metadata in a `quarto.yml` file:

``` {.yaml}
site:
  open-graph:
    locale: es_ES
    site_name: Quarto
```

Quarto will automatically merge global metadata found in the `site: open-graph` key with any metadata provided in the document itself in the `open-graph` key. This is useful when need to specify a mix of global options (for example, `site`) with per document options such as `title` or `image`.

### Preview Images

You can specify a preview image for your article in several different ways:

1.  You can explicitly provide a full url to the preview image using the `image` field in the appropriate metadata. For example:

    ``` {.yaml}
    title: "My Document"
    twitter-card:
      image: "https://quarto.org/images/preview-code.png"
    ```

2.  You may provide a document relative path to an image (such as `images/preview-code.png`) or a project relative path to an image (such as `/images/preview-code.png`). If you provide a relative path such as this, you must also provide a `site-url` in your site's metadata. For example in your `_quarto.yml` configuration file:

    ``` {.yaml}
    site:
      site-url: "https://www.quarto.org"
    ```

    and in your document front matter:

    ``` {.yaml}
    title: "My Document"
    twitter-card:
      image: "/images/preview-code.png"
    ```

3.  Any image that is being rendered in the page may also be used as a preview image by giving it the class name `preview-image`. Quarto will select the first image it finds with this class. For example, the following image will be used as the preview image when included on a page:

    ``` {.markdown}
    ![](images/jupyter-document.png){.border .preview-image}
    ```

    If you label an image with this class, you must also provide a `site-url` in your site's metadata.

4.  If none of the above ways of specifying a preview image have been used, Quarto will attempt to find a preview image by looking for an image included in the rendered document with one of the following names:

    -   `preview`
    -   `feature`
    -   `cover`
    -   `thumbail`

    If you rely in image names to provide a preview image, you must also provide a `site-url` in your site's metadata.

## Website Variables

If you have commonly repeating values or content in your website, you can create a `_variables.yml` file alongside your `_quarto.yml` project file, and then include references to those variables within any page on your site.

Variables can be either simple values or can include arbitrary markdown content.

### Defining Variables

To define variables, create a `_variables.yml` file in the root directory of your project. For example:

``` {.yaml}
version: 1.2

email:
  info: info@example.com
  support: support@example.com

engine:
  jupyter: "[Jupyter](https://jupyter.org)"
  knitr: "[Knitr](<https://yihui.name/knitr>)"
```

Note that the `engine` variable values include markdown for hyperlinks.

### Using Variables

To include the value of a variable, use the `{{< var >}}` shortcode, for example:

``` {.markdown}
Version {{< var version >}} is a minor upgrade.

Please contact us at {{< var email.info >}}.

Quarto includes {{< var engine.jupyter >}} and 
{{< var engine.knitr >}} computation engines.
```
