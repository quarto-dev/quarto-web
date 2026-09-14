# Quarto Documentation Style Guide

A guide to writing documentation consistent with quarto.org.

## Voice and Tone

### Address the reader directly

Use second person ("you") throughout. The reader is doing the work; speak to them.

**Do:** "You can add a table of contents using the `toc` option."

**Don't:** "One can add a table of contents..." or "Users can add..."

### Be instructional, not conversational

The tone is professional and direct—helpful without being chatty. Avoid filler phrases that don't add information.

**Do:** "Use the `fig-width` option to control figure dimensions."

**Don't:** "So, if you're looking to change how big your figures are, you'll want to check out the `fig-width` option!"

### Stay neutral and factual

Describe what options do without overselling. Let readers decide what's useful for their situation.

**Do:** "The `minimal` option disables built-in features including bootstrap themes, anchor sections, and reference popups."

**Don't:** "The amazing `minimal` option gives you complete control over your document!"

## Sentence Structure

### Lead with the goal, follow with the method

Start sentences with what the reader wants to accomplish, then explain how.

**Do:** "To add side navigation to a website, add a `sidebar` entry to the `website` section of `_quarto.yml`."

**Don't:** "Add a `sidebar` entry to the `website` section of `_quarto.yml` if you want side navigation."

### Use active voice and present tense

**Do:** "Quarto sets a default width and height for figures."

**Don't:** "A default width and height will be set by Quarto for figures."

### Keep explanations brief

One to two sentences of explanation is usually sufficient before showing an example.

**Example from the docs:**

> Use the `toc-expand` option to specify how much of the table of contents to show initially (defaults to 1 with auto-expansion as the user scrolls). Use `true` to expand all or `false` to collapse all.
>
> ``` yaml
> toc: true
> toc-expand: 2
> ```

## Code Examples

### Show examples immediately after explanations

Don't make readers wait. After explaining a concept, demonstrate it right away.

### Use "For example" to introduce examples

This phrase appears consistently throughout the docs and signals a transition from explanation to demonstration.

**Do:** "For example, the following YAML..."

### Include realistic, minimal examples

Examples should be complete enough to use but not cluttered with unrelated options.

### Always specify a language for code blocks

Every fenced code block needs a language identifier. Never use bare ` ``` ` fences.

**Do:**

````markdown
``` yaml
format: html
```
````

**Don't:**

````markdown
```
format: html
```
````

Common languages: `yaml`, `markdown`, `python`, `r`, `julia`, `bash`, `html`, `css`, `latex`, `json`.

### Use filename to clarify context

Use the `filename` attribute to indicate where code belongs.

````markdown
```{.markdown filename="document.qmd"}
---
title: "My Document"
format: html
---
```
````

````markdown
```{.yaml filename="_quarto.yml"}
project:
  type: website
```
````

````markdown
```{.bash filename="Terminal"}
quarto render document.qmd
```
````

### Default to front matter style

Most YAML can appear in either document front matter or `_quarto.yml`. Unless an example is explicitly about project-level configuration, write it as front matter—with `---` delimiters and `filename="document.qmd"`.

**For format-specific pages** (e.g., HTML Basics, PDF Basics), show the full hierarchy under `format`:

```{.markdown filename="document.qmd"}
---
format:
  html:
    toc: true
    toc-depth: 2
---
```

**For general pages** where an option applies across formats, you may omit the `format` hierarchy:

```{.markdown filename="document.qmd"}
---
toc: true
toc-depth: 2
---
```

### Be consistent within a page

Writers may deviate from these defaults for specific pages, but examples on a page should follow the same conventions throughout. If a page uses `---` delimiters, all YAML examples should. If a page includes `format: html:` in the hierarchy, all format-specific examples should.

### Match language to filename

Use a language consistent with the `filename`:

- `yaml` for `_quarto.yml`
- `markdown` for `.qmd` files

````markdown
```{.yaml filename="_quarto.yml"}
project:
  type: website
```
````

````markdown
```{.markdown filename="document.qmd"}
---
title: "My Document"
format: pdf
---
```
````

This applies even when a `.qmd` example contains only YAML front matter.

### Terminology: code cells vs code blocks

**Executable code cell:** Code that Quarto runs via Jupyter, Knitr, or another engine. Uses double braces in the docs to show the raw syntax:

````markdown
```{{python}}
import pandas as pd
```
````

**Code block:** Non-executable, display-only code:

````markdown
``` python
import pandas as pd
```
````

Avoid the term "code chunk" (a knitr-ism).

### Don't include shell prompts

Omit prompt characters (`$`, `>`, `%`) from terminal and console examples. They make copying harder and add no information.

**Do:**

```{.bash filename="Terminal"}
quarto render document.qmd
```

**Don't:**

```{.bash filename="Terminal"}
$ quarto render document.qmd
```

## Page Structure

### Start major pages with an "Overview" section

The Overview provides context and orients the reader before diving into specifics.

### Use descriptive section headers

Headers should tell readers what they'll learn, not just label topics.

**Do:** "Figure Sizing", "Customizing Appearance", "Multiple Rows"

**Don't:** "More Options", "Additional Information"

### Use tables for reference information

When documenting multiple options with descriptions, present them in a table rather than prose.

**Pipe tables** for simple content (text and inline code):

| Option       | Description                                                      |
|--------------|------------------------------------------------------------------|
| `toc`        | Include a table of contents (true or false).                     |
| `toc-depth`  | Number of section levels to include (default: 3).                |

**List tables** for complex content (code blocks, lists, or other block elements):

``` markdown
:::{.list-table}
- - Option
  - Description

- - `fig-pos`
  - Placement specifier for LaTeX figures. For example:

    ``` yaml
    fig-pos: 'h'
    ```

- - `fig-env`
  - LaTeX environment for figures (e.g., `figure*` for two-column spanning).
:::
```

**Avoid grid tables.** Historically used for complex content, but list tables are now preferred.

### Use callouts sparingly

Reserve callouts for limitations, requirements, or potential problems—situations where the reader genuinely needs to stop and take notice. Routine information belongs in regular prose.

- **Note:** Format-specific behavior or important caveats
- **Tip:** Workarounds or non-obvious solutions
- **Warning/Caution:** Actions that could cause problems
- **Important:** Requirements or prerequisites

**Do:** Use a callout to warn that a feature doesn't work in a specific format.

**Don't:** Use a callout to mention a related feature or provide general context.

## Word Choices

### Introduce options with "Use"

**Do:** "Use the `css` option to add a stylesheet."

**Don't:** "The `css` option allows you to add a stylesheet."

### Use "specify" for setting values

**Do:** "Specify the title using the `title` attribute."

### Use "include" when adding content

**Do:** "Include a search box by setting `search: true`."

### Say "For example" not "e.g." in prose

Reserve "e.g." for parenthetical notes or tables.

## What to Avoid

### No exclamation points

The docs maintain a calm, professional tone.

### No emojis

Keep the documentation clean and universally accessible.

### Avoid "simply" and "just"

What's simple to one reader isn't simple to another. These words can make struggling readers feel inadequate.

**Do:** "Add the `.lightbox` class to an image."

**Don't:** "Simply add the `.lightbox` class to an image."

### Avoid "we"

The documentation speaks directly to the reader, not as a team narrating their work.

**Do:** "You can customize this behavior..."

**Don't:** "We provide several ways to customize this behavior..."

### Avoid "allows you to"

This phrasing is wordy. Describe what happens directly.

**Do:** "Use `embed-resources: true` to create a self-contained HTML file."

**Don't:** "The `embed-resources` option allows you to create a self-contained HTML file."

### Avoid time estimates

Don't say things like "this takes just a minute" or "quick setup."

### Reduce "Note that..."

This phrase is overused. Often the information can stand on its own, or belongs in a callout if it's truly important.

**Do:** "Figure captions are left aligned to accommodate longer caption text."

**Don't:** "Note that figure captions are left aligned to accommodate longer caption text."

If the information is critical enough to warrant "Note that," consider whether it should be a callout instead.

## Cross-References and Links

### Link to related documentation

When mentioning a feature covered elsewhere, link to it:

> See the article on [Cross References](cross-references.qmd) for additional details.

### Use descriptive link text

**Do:** "See the [HTML Themes documentation](html-themes.qmd) for details."

**Don't:** "Click [here](html-themes.qmd) for more."

### Use `.qmd` extensions, not `.html`

Link to source files, not rendered output.

**Do:** `[Cross References](cross-references.qmd)`

**Don't:** `[Cross References](cross-references.html)`

This includes links with anchors: use `content.qmd#editing-tables`, not `content.html#editing-tables`.

Exception: Links in blog posts may use `.html`.

### Never use absolute URLs for internal links

**Do:** `[HTML Themes](/docs/output-formats/html-themes.qmd)`

**Don't:** `[HTML Themes](https://quarto.org/docs/output-formats/html-themes.html)`

### Use relative paths for siblings and children

For files in the same directory or subdirectories, use relative paths.

**Do:** `[PDF Basics](pdf-basics.qmd)` or `![Figure](images/fig-1.png)`

### Use absolute paths to avoid `../`

For files outside the current directory, prefer absolute paths from the project root over relative paths with `../`.

**Do:** `/docs/output-formats/html-themes.qmd`

**Don't:** `../output-formats/html-themes.qmd`

Exception: Links from a subdirectory to its parent section root may use `../`. For example, from `docs/manuscripts/authoring/jupyterlab.qmd`, you may link to `../index.qmd` to reach `docs/manuscripts/index.qmd`.

## Notes for Specific Contexts

### Documenting options

When documenting an option:
1. State what it does
2. Note the default if relevant
3. Show an example
4. Mention any caveats or format-specific behavior

### Documenting procedures

When explaining how to do something:
1. State the goal
2. Provide the steps or code
3. Show what the result looks like (screenshot or rendered output)
4. Note any variations or alternatives

---

## Terminology

### Prefer "option" for YAML settings

Use **option** as the default term:

> Use the `toc` option to include a table of contents.

When discussing hierarchy, say "under `X`" or "within `X`"—no need to add "option" or "key":

> Specify sidebar options under `website` in `_quarto.yml`.

> These fields are specified within `crossref` in the document metadata.

### Classes: include the dot

When referring to CSS classes, include the dot to match markdown syntax:

**Do:** "Add the class `.lightbox` to an image."

**Don't:** "Add the class `lightbox` to an image."

This applies to all class references: `.panel-tabset`, `.smaller`, `.columns`, etc.

