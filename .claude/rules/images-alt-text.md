---
paths:
  - "**/*.qmd"
  - "docs/**/*.md"
---

# Images and Alt Text

Before you add or edit an image, read "Images and Alt Text" in `_style-guide.md`. That section is the source of truth. This file is the short form.

- Give every image a `fig-alt`, or `fig-alt=""` if it is decorative. Text in `![...]` is a visible caption, not alt text.
- Find out what the section teaches before you write. A stand-in image (kittens in a positioning demo) gets a short label, not a description.
- Search for other uses of the same image, and reuse the alt text that is there.
- If the file is an include (`_*.md`), an iframe target, or a `code-preview` target, find each page that shows it. Write the alt text for those pages.
- If code for this image appears anywhere (`code-preview`, `echo: fenced`, or a copy in its own code block, on this page or another), update each copy to match, `fig-alt` included. Search code blocks for the image file name to find copies.
- For a UI icon, use the bold control name and an icon font with `aria-hidden="true"`. Do not use an image.
- After you render, grep the `<img>` tags in `_site/` and make sure that each one has `alt`. Axe does not examine images on hidden slides or in closed tabs, so do this check also when the scan is clean.
