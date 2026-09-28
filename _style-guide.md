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

## Headings and Example Labels

Use a heading only when it starts a section. A section continues until the next heading of the same level or higher. Screen readers use headings to move through a page, and the page TOC lists them.

Do not skip heading levels. After `##`, the next level is `###`.

A short label for one example is a caption, not a heading. Labels such as "Markdown Syntax", "Output", "HTML output", and "Arrow (light)" are captions. If you use a heading for a caption, the text after the example becomes part of the caption's section. This is incorrect when that text applies to the whole section.

Use one of these patterns for a caption:

* For a code block, use the `filename` attribute. The label shows in the header of the block.

  ````markdown
  ``` {.markdown filename="Markdown Syntax"}
  | Right | Left |
  |------:|:-----|
  ```
  ````

* For an image, use the image caption. The caption becomes a `<figcaption>` for the image. If a page shows several captioned images in a sequence, set `fig-cap-location: top` in the page front matter. Then each caption is directly above its image.

  ```markdown
  ![Arrow (light)](images/arrow.png){fig-alt="A block of code showcasing the Arrow (light) theme."}
  ```

* For rendered output that follows its source, write a lead-in sentence, for example "This renders as:".

* For a set of source and output pairs, use a table with `Markdown Syntax` and `Output` column headers. See "Other Blocks" in `docs/authoring/markdown-basics.qmd`.

* For output that has no other pattern, use a bold label paragraph, for example `**PDF output**`.

Do not add `{.unlisted}` to a heading to hide a caption from the TOC. The heading is still in the page structure.
