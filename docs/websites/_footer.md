## Page Footer

Use the `footer` option to provide a common footer for all of the pages in a {{< meta project-type >}}. The simplest footer just provides text that will be centered and displayed in a lighter typeface:

``` yaml
{{< meta project-type >}}:
  footer: "Copyright 2021, Norah Jones" 
```

You can alternatively target the `left`, `right`, and `center` regions of the footer individually:

``` yaml
{{< meta project-type >}}:
  footer: 
    left: "Copyright 2021, Norah Jones" 
    right: 
      - icon: github
        href: https://github.com/
      - icon: twitter 
        href: https://twitter.com/ 
```

Note for the `right` region of the footer we included navigational items for GitHub and Twitter rather than text. You can include navigational items in any region of the footer.

You can use the `background` and `border` options to further control the appearance of the footer. By default, the footer has no background color and a top border. To eliminate the border you would do this:

``` yaml
{{< meta project-type >}}:
  border: false
```

To use a light background (e.g. to match a navigation bar) you would do this:

``` yaml
{{< meta project-type >}}:
  background: light
```
