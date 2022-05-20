## WebTeX Math

The `{{< meta format-name >}}` format renders LaTeX equations using standard dollar-delimited inline (`$...$`) and display (`$$...$$`) syntax. However, if the web environment you are publishing into doesn't support dollar-delimited math, you can alternatively use  [WebTeX](https://github.com/KTHse/webtex) to display math. This is done by setting the Pandoc `html-math-method` to `webtex`. For example:

``` yaml
format:
  {{< meta format-name >}}:
    html-math-method: webtex
```

The `webtex` method works for any web page that can display images, and requires no special JavaScript or CSS. Any inline or display equations contained within your document will be converted to an image URL that requests a rendered version of the equation. For example, the following markdown:

``` markdown
$x + 1$
```

Will be converted to:

``` markdown
![](https://latex.codecogs.com/svg.latex?x%20%2B%201)
```

### Dark Background

SVG is used as the default rendering method because it has the best overall appearance. However, if your `{{< meta format-name >}}` document is being rendered on a dark background, you may want to switch to PNG with a dark background specified. You can do this as follows:

``` yaml
format:
   {{< meta format-name >}}:
     html-math-method: 
       method: webtex
       url: https://latex.codecogs.com/png.image?%5Cbg_black&space;
```

