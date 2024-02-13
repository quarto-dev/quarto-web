

Often you'll want to include a fenced code block purely as documentation (not executable). You can do this by using two curly braces around the language (e.g. `python`, `r`, etc.) rather than one. For example:

```{{{python}}}
1 + 1
```

Will be output into the document as:

```{{python}}
1 + 1
```

If you want to show an example with multiple code blocks and other markdown, just enclose the entire example in 4 backticks (e.g. ````` ```` `````) and use the two curly brace syntax for code blocks within. For example:

    ````
    ---
    title: "My document"
    ---

    Some markdown content.

    ```{{{python}}}
    1 + 1
    ```

    Some additional markdown content.

    ````
