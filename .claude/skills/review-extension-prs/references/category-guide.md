# Extension Category Guide

Derived from `docs/extensions/listings/README.md` (read that file for the authoritative description).

## File → Extension Type Mapping

### `shortcodes-and-filters.yml`
Special markdown directives that generate content and/or add new markdown rendering behaviors.

Belongs here if the extension:
- Provides a shortcode (`{{< myshortcode >}}`)
- Is a Lua filter that modifies the document AST
- Adds HTML features (lightbox, tooltips, interactive elements, animations)
- Modifies rendering behavior (code annotation, column layout, math, citations)
- Is **not** primarily a new output *format* (document look/style)

Examples: lightbox, fontawesome, academicons, animate, accordion, shinylive, quarto-live

### `custom-formats.yml`
New output formats bundling document options, templates, stylesheets.

Belongs here if the extension:
- Creates a new `format:` target (e.g. `format: myformat-pdf`)
- Bundles LaTeX, Typst, or HTML templates for a specific visual style
- Is primarily a document *look/appearance* rather than a behavior modifier
- Not a journal article format and not Reveal.js

Examples: PrettyPDF, bookup, lumo, clean-typst, awesomecv-typst, hikmah-pdf

### `journal-articles.yml`
Enable authoring professional journal articles, producing LaTeX/PDF and HTML outputs.

Belongs here if the extension:
- Targets a specific academic journal or publisher format
- Is designed for manuscript/preprint/article submission
- Typically produces both PDF (via LaTeX) and HTML outputs

Examples: jss, acs, plos, elsevier, biophysical-journal, jasa

### `revealjs.yml`
Extend the capabilities of HTML presentations created with Reveal.js.

Belongs here if the extension:
- Adds features **to** a Reveal.js presentation (plugins, behaviors)
- Not a new Reveal.js theme/template (those go in `revealjs-formats.yml`)

Examples: pointer, attribution, countdown, chalkboard, confetti

### `revealjs-formats.yml`
Custom Reveal.js output formats and templates.

Belongs here if the extension:
- Is a complete Reveal.js theme or visual template
- Creates a new `format: myformat-revealjs` target
- Primarily changes the *appearance* of slides

Examples: clean-revealjs, metropolis, coeos

## Ambiguous Cases

- **Format that also includes shortcodes**: use `custom-formats.yml` if the format is the primary value; `shortcodes-and-filters.yml` if the shortcodes are the main feature.
- **Interactive HTML elements**: `shortcodes-and-filters.yml` even if they look format-like (quarto-live, shinylive belong here).
- **Academic template not tied to a specific journal**: `custom-formats.yml` (not `journal-articles.yml`).
- **Extension supporting multiple output formats including Reveal.js**: `shortcodes-and-filters.yml` if it works across formats; `revealjs.yml` only if it's Reveal.js-specific.
