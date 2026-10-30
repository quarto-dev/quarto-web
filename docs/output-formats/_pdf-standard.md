## PDF Accessibility & Standards

Create PDFs that work with screen readers and meet archival requirements using the `pdf-standard` option. This enables PDF/UA for accessibility, PDF/A for long-term archival, or explicit PDF version control.

### Basic Example

For an accessible PDF that works with screen readers:

::: {.content-visible when-meta="pdf-standard-typst-examples"}
```yaml
---
title: "Accessible Report"
format:
  typst:
    pdf-standard: ua-1
---
```
:::

::: {.content-visible when-meta="pdf-standard-latex-examples"}
```yaml
---
title: "Accessible Report"
format:
  pdf:
    documentclass: article
    pdf-standard: ua-2
---
```
:::

### Supported Standards

You can specify one or more standards. Quarto checks that the standards are supported by your output format and infers a compatible PDF version (some standards have maximum version requirements).

::: {.content-visible when-meta="pdf-standard-typst-examples"}
+------------------+------------------------------------------+
| Standard         | Description                              |
+==================+==========================================+
| `ua-1`           | PDF/UA-1 for screen reader accessibility |
+------------------+------------------------------------------+
| `a-1a`, `a-1b`   | PDF/A-1 for long-term archival           |
+------------------+------------------------------------------+
| `a-2a`, `a-2b`,  | PDF/A-2 archival with newer features     |
| `a-2u`           |                                          |
+------------------+------------------------------------------+
| `a-3a`, `a-3b`,  | PDF/A-3 archival allowing embedded files |
| `a-3u`           |                                          |
+------------------+------------------------------------------+
| `a-4`, `a-4e`,   | PDF/A-4 (based on PDF 2.0)               |
| `a-4f`           |                                          |
+------------------+------------------------------------------+
| `1.4`, `1.5`,    | Explicit PDF version                     |
| `1.6`, `1.7`,    |                                          |
| `2.0`            |                                          |
+------------------+------------------------------------------+
:::

::: {.content-visible when-meta="pdf-standard-latex-examples"}
+------------------+------------------------------------------+
| Standard         | Description                              |
+==================+==========================================+
| `ua-2`           | PDF/UA-2 for screen reader accessibility |
+------------------+------------------------------------------+
| `a-1b`           | PDF/A-1 for long-term archival           |
+------------------+------------------------------------------+
| `a-2a`, `a-2b`,  | PDF/A-2 archival with newer features     |
| `a-2u`           |                                          |
+------------------+------------------------------------------+
| `a-3a`, `a-3b`,  | PDF/A-3 archival allowing embedded files |
| `a-3u`           |                                          |
+------------------+------------------------------------------+
| `a-4`, `a-4f`    | PDF/A-4 (based on PDF 2.0)               |
+------------------+------------------------------------------+
| `x-4`, `x-4p`,   | PDF/X for print production               |
| `x-5g`, `x-5n`,  |                                          |
| `x-5pg`, `x-6`,  |                                          |
| `x-6n`, `x-6p`   |                                          |
+------------------+------------------------------------------+
| `1.4`, `1.5`,    | Explicit PDF version                     |
| `1.6`, `1.7`,    |                                          |
| `2.0`            |                                          |
+------------------+------------------------------------------+
:::

::: {.callout-warning}
## Quote numeric-only versions
When specifying only a PDF version like `1.7` or `2.0`, use quotes so YAML treats it as a string: `pdf-standard: "1.7"`.
:::

### Combining Standards

It's common to combine PDF/A (archival) with PDF/UA (accessibility) for documents that need both long-term preservation and screen reader support:

::: {.content-visible when-meta="pdf-standard-typst-examples"}
```yaml
format:
  typst:
    pdf-standard: [a-2b, ua-1]
```
:::

::: {.content-visible when-meta="pdf-standard-latex-examples"}
```yaml
format:
  pdf:
    documentclass: article
    pdf-standard: [a-4f, ua-2]
```
:::

You can only specify one standard from each family (one PDF/A variant, one PDF/UA variant, etc.).

### Accessibility Requirements

Although Quarto can't on its own guarantee accessibility requirements are met, many are satisfied through the Markdown structure of the document:

- **Document metadata**: YAML fields like `title`, `author`, `date`, and `lang` are propagated into the PDF document metadata, fulfilling metadata requirements for accessibility and archival standards.

::: {.content-visible when-meta="pdf-standard-typst-examples"}
- **Document tagging**: Markdown provides the semantic structure to fulfill tagging requirements. Typst always has PDF tagging enabled.
:::

::: {.content-visible when-meta="pdf-standard-latex-examples"}
- **Document tagging**: Markdown provides the semantic structure to fulfill tagging requirements. Pandoc enables PDF tagging for LaTeX when you specify a standard that requires it (PDF/UA standards and PDF/A "a" variants like `a-2a`).
:::

- **Alt text propagation**: Alt text from `fig-alt` attributes is passed through to the PDF for screen readers. See [Figures](/docs/authoring/figures.qmd#alt-text) for details on specifying alt text.

Use validation (described below) to identify accessibility issues in your documents that may require manual attention.

::: {.content-visible when-meta="pdf-standard-latex-examples"}
### Document Class and Tagging {#pdf-document-class-tagging}

Quarto's default [KOMA-Script](/docs/output-formats/pdf-basics.qmd#document-class) classes (`scrartcl` for documents, `scrreprt` for books) don't yet support LaTeX PDF tagging. When you set `pdf-standard` with a KOMA class, the PDF still renders, declares the standard, and can pass validation, but its structure tags are incomplete. For example, headings are tagged as plain paragraphs (`P`) instead of heading tags (`H2`, `H3`, ...), so screen reader users can't navigate the document by its headings.

To get a correctly tagged PDF, for PDF/UA (`ua-2`) or a PDF/A "a" level (such as `a-3a`), use a standard LaTeX class:

```yaml
format:
  pdf:
    documentclass: article
    pdf-standard: ua-2
```

For books, use `report` or `book` instead of `scrreprt` or `scrbook`.

The same applies if you set a KOMA class explicitly. Switching to a standard class changes the page layout, and KOMA-only options, such as `DIV` in `classoption` or `\KOMAoption` commands, no longer have any effect.
:::

### Validation with veraPDF

When `pdf-standard` is set, Quarto can validate your output against PDF/A and PDF/UA specifications using [veraPDF](https://verapdf.org/). Install it with:

```{.bash filename="Terminal"}
quarto install verapdf
```

::: {.callout-note}
## Java required
veraPDF requires a stable version of Java: 8, 11, 17, or 21.
:::

Alternatively, set the `QUARTO_VERAPDF` environment variable to your veraPDF command or path, or have veraPDF available in your   {{< kbd win="%PATH%" mac="$PATH" linux="$PATH" >}}.

Once installed, validation runs automatically after rendering. Any compliance issues appear as warnings in your render output, helping you identify accessibility or archival problems in your documents.
