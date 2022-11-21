### Rendering

Quarto will automatically run computations in any markdown document that contains executable code blocks. For example, the example shown above might be rendered to various formats with:

```{.bash filename="Terminal"}
quarto render document.qmd # defaults to html
quarto render document.qmd --to pdf
quarto render document.qmd --to docx
```

Quarto can also render any Jupyter notebook (.ipynb):

```{.bash filename="Terminal"}
quarto render document.ipynb
```

Note that the target file (in this case `document.qmd`) should always be the very first command line argument.

Note that when rendering an .ipynb Quarto will not execute the cells within the notebook by default (the presumption being that you already executed them while editing the notebook). If you want to execute the cells you can pass the `--execute` flag to render:

```{.bash filename="Terminal"}
quarto render notebook.ipynb --execute
```
