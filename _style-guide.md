## Terminology

## Link Recommendations

* Use relative paths for child or sibling documents. E.g. `images/fig-1.png`, `pdf-basics.qmd`. **Avoid** using `http://quarto.org` for internal links.
* Prefer absolute paths from the root of the project over relative paths involving `../`. E.g. use `/docs/output-formats/html-themes.qmd`, not `../output-formats/html-themes.qmd`. 
    * Possible exception: documents in a subfolder of a section that link to the section root, e.g. you may use `../index.qmd` to refer to `docs/manuscripts/index.qmd` from `docs/manuscripts/authoring/index.qmd`.  
* Use `.qmd` instead of `.html`. E.g. use `content.qmd#editing-tables`, not `content.html#editing-tables` 
    * Possible exception: links in blog posts

## Toolbar Icons

When prose points to a button or other control in a user interface:

* Name the control in bold. Use the name the control shows: its label, its tooltip, or its accessible name. Screen reader users hear this name, and voice control users say it.
* Add "button" after the name if the control is a button.
* Put the icon image after the name, with `alt=""` and the `.ui-icon` class. The name is already in the text, so the image is decorative.
* Do not use `<kbd>` for the icon or the name. `<kbd>` is for keyboard input.

```markdown
Use the **Render** button ![](images/rstudio-render-button.png){.ui-icon alt="" width="25" height="20"} in RStudio.
```

The `.ui-icon` class (`theme.scss` and `theme-dark.scss`) gives the image the same key-cap look as `<kbd>` in the light and dark themes.
