## Page Navigation

If you have a website or book with a number of pages in a section or subsection, it is often convenient to offer the user the ability to navigate to the next page (or previous page) at the bottom of the page that they've just finished reading. You can enable this using:

``` yaml
site:
  page-navigation: true
```

When enabled, page navigation will be displayed at the bottom of the page whenever there is a next or previous page (including in the next or previous section). This option is enabled by default for books but not for websites.

### Separators

If you include a page separator in the sidebar (either between sections or items), page navigation controls will not appear to continue pagination across the separator. For example, in the following sidebar:

``` yaml
site:
  sidebar:
    contents:
      - section: "First Section"
        - contents:
          - href: document1.qmd
          - href: document2.qmd
          - href: document3.qmd
      - section: "---"
      - section: "Second Section"
        contents:
          - href: document4.qmd
          - href: document5.qmd
          - href: document6.qmd
          
```

When the user reaches the bottom of document3.qmd, they will see previous navigation to go back to document2.qmd, but they will not see next navigation to continue onto document 4. This behavior is useful when you have sections of contents that don't naturally flow together in sequential order. Use the separator to denote this in the sidebar and break up pagination