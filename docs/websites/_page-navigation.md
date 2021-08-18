## Page Navigation

If you have a {{< meta project-type >}} with several pages in a section or subsection, it is often convenient to offer the user the ability to navigate to the next page (or previous page) at the bottom of the page that they've just finished reading. You can enable this using:

``` yaml
{{< meta project-type >}}:
  page-navigation: true
```

When enabled, page navigation will be displayed at the bottom of the page whenever there is a next or previous page (including in the next or previous section). This option is enabled by default for books but not for websites.

