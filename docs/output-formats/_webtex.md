## WebTeX Math

The `{{< meta format-name >}}` format uses [WebTeX](https://github.com/KTHse/webtex) to display LaTeX equations. This is done by setting the Pandoc `html-math-method` to `webtex` by default. The `webtex` method works for any web page that can display images, and requires no special JavaScript or CSS.

Any inline or display equations contained within your document will be converted to an image URL that requests a rendered version of the equation. For example, the following markdown:

``` markdown
$x + 1$
```

Will be converted to:

``` markdown
![](https://latex.codecogs.com/svg.latex?x%20%2B%201)
```

SVG is used as the default rendering method because it has the best overall appearance. However, if your `{{< meta format-name >}}` document is being rendered on a dark background, you may want to switch to PNG. You can do this as follows:

``` yaml
format:
   {{< meta format-name >}}:
     html-math-method: 
       method: webtex
       url: https://latex.codecogs.com/png.latex?
```

You might wish to override the use of `webtex` if you have another means of rendering markdown equations. You can do this as follows:

``` yaml
format:
  {{< meta format-name >}}:
    html-math-method: plain
```

Note that you can also specify any of the other math rendering techniques (e.g. `mathjax` or `katex`) however equations rendered this way won't display correctly unless the environment hosting your markdown has direct support for it.

See the Pandoc documentation on [Math Rendering in HTML](https://pandoc.org/MANUAL.html#math-rendering-in-html) for additional details.
