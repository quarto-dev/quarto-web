## WebTeX Math

The `{{< meta format-name >}}` format renders LaTeX equations using standard dollar-delimited inline (`$...$`) and display (`$$...$$`) syntax. However, if the web environment you are publishing into doesn't support dollar-delimited math, you can alternatively use  [WebTeX](https://github.com/KTHse/webtex) to display math. This is done by setting the Pandoc `html-math-method` to `webtex`. For example:

``` yaml
format:
  {{< meta format-name >}}:
    html-math-method: webtex
```


{{< include _webtex-detail.md >}}