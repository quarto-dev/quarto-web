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


## Google Analytics

You can add [Google Analytics](https://analytics.google.com/) to your website by adding adding a `google-analytics` key to your `_quarto.yml` file. In its simplest form, you can just pass your Google Analytics tracking Id (e.g. `UA-xxxxxxx`) or Google Tag measurement Id (e.g. `G-xxxxxxx`) like:

``` {.yaml}
site:
  google-analytics: "UA-XXXXXXXX"
```

Quarto will use the key itself to determine whether to embed Google Analytics (analytics.js) or Google Tags (gtag) as appropriate.

In addition to this basic configuration, you can exercise more fine grained control of your site analytics using the following keys.

+----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Key            | Description                                                                                                                                                                                         |
+================+=====================================================================================================================================================================================================+
| `tracking-id`  | The Google tracking Id or measurement Id of this website.                                                                                                                                           |
+----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `storage`      | **cookies -** Use cookies to store unique user and session identification (default).                                                                                                                |
|                |                                                                                                                                                                                                     |
|                | **none** - Do not use cookies to store unique user and session identification.                                                                                                                      |
|                |                                                                                                                                                                                                     |
|                | For more about choosing storage options see [Storage].                                                                                                                                              |
+----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `anonymize-ip` | Anonymize the user ip address. For more about this feature, see [IP Anonymization (or IP masking) in Google Analytics](https://support.google.com/analytics/answer/2763052?hl=en).                  |
+----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `version`      | The version number of Google Analytics to use. Currently supports either 3 (for analytics.js) or 4 (for gtag). This is automatically detected based upon the `tracking-id`, but you may specify it. |
+----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

### Storage

Google Analytics uses cookies to distinguish unique users and sessions. If you choose to use cookies to store this user data, you should consider whether you need to enable [Cookie Consent] in order to permit the viewer to control any tracking that you enable.

If you choose `none` for storage, this will have the following effects:

-   For Google Analytics v3 (analytics.js)\
    No tracking cookies will be used. Individual page hits will be properly tracked, enabling you to see which pages are viewed and how often they are viewed. Unique user and session tracking will not report data correctly since the tracking cookies they rely upon are not set.

-   For Google Tags (gtag)\
    User consent for ad and analytics tracking cookies will be withheld. In this mode, Google Analytics will still collect user data without the user identification, but that data is currently not displayed in the Google Analytics reports.

## Cookie Consent

Quarto includes the ability to request cookie consent before enabling scripts that set cookies, using [Cookie Consent](https://www.cookieconsent.com).

The user's cookie preferences will automatically control [Google Analytics] (if enabled) and can be used to control custom scripts you add as well (see [Custom Scripts and Cookie Consent]. You can enable the default request for cookie consent using the following:

``` {.yaml}
site:
  cookie-consent: true
```

You can further customize the appearance and behavior of the consent using the following:

+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Key          | Description                                                                                                                                                                         |
+==============+=====================================================================================================================================================================================+
| `type`       | The type of consent that should be requested, using one of these two values:                                                                                                        |
|              |                                                                                                                                                                                     |
|              | **implied -** (default)This will notify the user that the site uses cookies and permit them to change preferences, but not block cookies unless the user changes their preferences. |
|              |                                                                                                                                                                                     |
|              | **express -** This will block cookies until the user expressly agrees to allow them (or continue blocking them if the user doesn't agree).                                          |
+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `style`      | The style of the consent banner that is displayed:                                                                                                                                  |
|              |                                                                                                                                                                                     |
|              | **simple -** (default) A simple dialog in the lower right corner of the website.                                                                                                    |
|              |                                                                                                                                                                                     |
|              | **headline -** A full width banner across the top of the website.                                                                                                                   |
|              |                                                                                                                                                                                     |
|              | **interstitial -** An semi-transparent overlay of the entire website.                                                                                                               |
|              |                                                                                                                                                                                     |
|              | **standalone -** An opaque overlay of the entire website.                                                                                                                           |
+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `palette`    | Whether to use a dark or light appearance for the consent banner:                                                                                                                   |
|              |                                                                                                                                                                                     |
|              | **light -** A light colored banner.                                                                                                                                                 |
|              |                                                                                                                                                                                     |
|              | **dark -** A dark colored banner.                                                                                                                                                   |
+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `policy-url` | The url to the website's cookie or privacy policy.                                                                                                                                  |
+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| `prefs-text` | The text to display for the cookie preferences link in the website footer.                                                                                                          |
+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

A custom example might look more like:

``` {.yaml}
site:
  cookie-consent:
    type: express
    style: headline
    palette: dark
  google-analytics:
    tracking-id: "G-XXXXXXX"
    anonymize-ip: true
```

### Cookie Preferences

In addition to requesting consent when a new user visits your website, Cookie Consent will also add a cookie preferences link to the footer of the website. You can control the text of this link using `prefs-text`. If you would rather position this link yourself, just add a link with the id `open_preferences_center` to the website and Cookie Consent will not add the preferences link to the footer.

### Custom Scripts and Cookie Consent

Cookie Consent works by preventing the execution of scripts unless the user has expressed their consent. To control your custom scripts using Cookie Consent:

1.  Insert script tags as `type='text/plain'` (when the user consents, the type will be switched to `text/javascript` and the script will be executed).

<!-- -->

2.  Add a `cookie-consent` attribute to your script tag, setting it one of the following 4 levels:

    +----------------------+------------------------------------------------------------------------------------------------------------------------+
    | Level                | Description                                                                                                            |
    +======================+========================================================================================================================+
    | `strictly-necessary` | Strictly scripts are loaded automatically and cannot be disabled by the user.                                          |
    +----------------------+------------------------------------------------------------------------------------------------------------------------+
    | `functionality`      | Scripts that are required for basic functionality of the website, for example, remembering a user language preference. |
    +----------------------+------------------------------------------------------------------------------------------------------------------------+
    | `tracking`           | Scripts that are used to track users, for example [Google Analytics].                                                  |
    +----------------------+------------------------------------------------------------------------------------------------------------------------+
    | `targeting`          | Scripts that are used for the purposed of advertising to ad targeting, for example Google AdSense remarketing.         |
    +----------------------+------------------------------------------------------------------------------------------------------------------------+

An example script that is used for user tracking would look like:

``` {.javascript}
<script type="text/plain" cookie-consent="tracking">

// My tracking JS code here

</script>
```

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

To include the value of a variable, use the `{{</* var */>}}` shortcode, for example:

``` {.markdown shortcodes=false}
Version {{< var version >}} is a minor upgrade.

Please contact us at {{< var email.info >}}.

Quarto includes {{< var engine.jupyter >}} and 
{{< var engine.knitr >}} computation engines.
```

#### Escaping Variables

If you are writing documentation about using variables (for example, this article!) you might need to prevent them from being processed. You can do this in two ways:

1.  Escape the variable reference like this:

    ```{.markdown shortcodes=false}
    {{</* var version */>}}
    ```

2.  Add a `shortcodes=false` attribute to any code block you want to prevent processing of shortcodes within:

    ````{.markdown shortcodes=false}
    ```{shortcodes=false}
    {{< var version >}}
    ```
    ````



