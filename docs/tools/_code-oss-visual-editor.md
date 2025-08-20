## Overview

The [Quarto VS Code Extension](https://open-vsx.org/extension/quarto/quarto) includes a visual markdown editor that supports all of Quarto's markdown syntax including tables, citations, cross-references, footnotes, divs/spans, definition lists, attributes, raw HTML/TeX, and more:

![](/docs/tools/images/{{< meta tool.prefix >}}-visual-editor.png){.border .light-content fig-alt='{{< meta tool.name >}} with a document called `libraries.qmd` open in visual editing mode. The subtitle and list of items are typeset. The visual editing toolbar is visible at the top of the document.' }

![](/docs/tools/images/{{< meta tool.prefix >}}-visual-editor-dark.png){.border .dark-content fig-alt='Positron with a document called `libraries.qmd` open in visual editing mode. The subtitle and list of items are typeset. The visual editing toolbar is visible at the top of the document.' }


You can switch between visual and source mode at any time and can even edit documents concurrently in both modes. To switch between visual and source mode:

1.  Use the <kbd>⇧⌘ F4</kbd> keyboard shortcut.

2.  Use the context menu from anywhere in a document:

    ![](/docs/tools/images/{{< meta tool.prefix >}}-visual-editor-context-menu.png){.border .light-content fig-alt='The context menu in with the Edit in Visual Mode command highlighted.' width="609"}

    ![](/docs/tools/images/{{< meta tool.prefix >}}-visual-editor-context-menu-dark.png){.border .dark-content fig-alt='The context menu in with the Edit in Visual Mode command highlighted.' width="609"}

3.  Use the **Edit in Visual Mode** and **Edit in Source Mode** commands:

    ![](/docs/tools/images/{{< meta tool.prefix >}}-visual-mode-command.png){.border .light-content fig-alt='The command palette with the Edit in Visual Mode command highlighted.' width="609"}

    ![](/docs/tools/images/{{< meta tool.prefix >}}-visual-mode-command-dark.png){.border .dark-content fig-alt='The command palette with the Edit in Visual Mode command highlighted.' width="609"}

4.  Use the editor menu:

    ![](/docs/tools/images/{{< meta tool.prefix >}}-visual-mode-menu.png){.border .light-content width="609" fig-alt='The editor menu with the Edit in Visual Mode command highlighted.'}

    ![](/docs/tools/images/{{< meta tool.prefix >}}-visual-mode-menu-dark.png){.border .dark-content width="609" fig-alt='The editor menu with the Edit in Visual Mode command highlighted.'}
    

:::{.content-hidden unless-meta="tool.is_positron"}
5.  Using the **Source**/**Visual** buttons in the toolbar:

    ![](/docs/tools/images/positron-visual-editor-toolbar-toggle.png){.border .light-content fig-alt="The toolbar in Positron with the Source and Visual buttons highlighted." width="609"}

    ![](/docs/tools/images/positron-visual-editor-toolbar-toggle-dark.png){.border .dark-content fig-alt="The toolbar in Positron with the Source and Visual buttons highlighted." width="609"}
:::

You can also right click a `.qmd` document in the file explorer and select the **Open With...** command, which will prompt you for the editor to open the file with:

![](/docs/tools/images/{{< meta tool.prefix >}}-visual-editor-default-mode.png){.border .light-content width="609"}


![](/docs/tools/images/{{< meta tool.prefix >}}-visual-editor-default-mode-dark.png){.border .dark-content width="609"}

Note that this menu also provides an option to configure the default editor for `.qmd` files: use this if you want to primarily edit in visual mode and occasionally switch to source mode.

## Keyboard Shortcuts

Visual mode supports both traditional keyboard shortcuts (e.g. <kbd>⌘ B</kbd> for bold) as well as markdown shortcuts (using markdown syntax directly). For example, enclose `**bold**` text in asterisks or type `##` and press space to create a second level heading.

Here are the available keyboard and markdown shortcuts:

| Command            | Keyboard Shortcut  |   Markdown Shortcut   |
|--------------------|:------------------:|:---------------------:|
| Bold               |   <kbd>⌘ B</kbd>   |      `**bold**`       |
| Italic             |   <kbd>⌘ I</kbd>   |      `*italic*`       |
| Code               |   <kbd>⌘ D</kbd>   |     `` `code` ``      |
| Strikeout          |                    |     `~~strike~~`      |
| Subscript          |                    |        `~sub~`        |
| Superscript        |                    |       `^super^`       |
| Heading 1          |  <kbd>⌥⌘ 1</kbd>   |          `#`          |
| Heading 2          |  <kbd>⌥⌘ 2</kbd>   |         `##`          |
| Heading 3          |  <kbd>⌥⌘ 3</kbd>   |         `###`         |
| Heading Attributes |                    |    `{#id .class}`     |
| Link               |   <kbd>⌘ K</kbd>   |       `<href>`        |
| Blockquote         |                    |          `>`          |
| Code Block         |  <kbd>⇧⌘ \\</kbd>  |     ```` ``` ````     |
| Code Cell          |  <kbd>⌥⌘ I</kbd>   | ```` ```{python} ```` |
| Raw Block          |                    | ```` ```{=html} ````  |
| Div                |                    |         `:::`         |
| Bullet List        |                    |          `-`          |
| Ordered List       |                    |         `1.`          |
| Tight List         |  <kbd>⌥⌘ 9</kbd>   |                       |
| List Check         |                    |         `[x]`         |
| Emoji              |                    |       `:smile:`       |
| Definition         |                    |          `:`          |
| Non-Breaking Space | <kbd>⌃ Space</kbd> |                       |
| Hard Line Break    | <kbd>⇧ Enter</kbd> |                       |
| Paragraph          |  <kbd>⌥⌘ 0</kbd>   |                       |
| Image              |  <kbd>⇧⌘ I</kbd>   |                       |
| Footnote           |  <kbd>⇧⌘ F7</kbd>  |                       |
| Citation           |  <kbd>⇧⌘ F8</kbd>  |         `[@`          |
| Table              |  <kbd>⌥⌘ T</kbd>   |                       |
| Editing Comment    |  <kbd>⇧⌘ C</kbd>   |                       |
| Select All         |   <kbd>⌘ A</kbd>   |                       |
| Clear Formatting   |  <kbd>⌘ \\</kbd>   |                       |
| Edit Attributes    |   <kbd>F4</kbd>    |                       |

::: {.callout-tip appearance="simple"}
For markdown shortcuts, if you didn't intend to use a shortcut and want to reverse its effect, just press the backspace key.
:::

## Insert Anything

You can also use the catch-all <kbd>⌘ /</kbd> shortcut to insert just about anything. Just execute the shortcut then type what you want to insert. For example:

::: {layout-ncol="2"}
![](/docs/visual-editor/images/visual-editing-omni-list.png){fig-alt="There is a line of text (with a cursor at the end) where someone has typed '/lis'. There is a drop-down menu underneath this with options for 'Bullet List', 'Numbered List', and 'Definition List' arranged vertically. The title of each item is bolded, has a small icon to the left, and a small description in lighter gray text underneath it." width="400"}

![](/docs/visual-editor/images/visual-editing-omni-math.png){fig-alt="There is a line of text (with a cursor at the end) where someone has typed '/ma'. There is a drop-down menu underneath this with options for 'Inline Math', 'Display Math', and 'Image...' arranged vertically. The title of each item is bolded, has a small icon to the left, and a small description in lighter gray text underneath it." width="400"}
:::

If you are at the beginning of a line (as displayed above), you can also enter plain `/` to invoke the shortcut.

## Editor Toolbar

The editor toolbar includes buttons for the most commonly used formatting commands:

![](/docs/tools/images/{{< meta tool.prefix >}}-visual-editor-toolbar.png){.border width="609"}

Additional commands are available on the **Format**, **Insert**, and **Table** menus:

| Format                                                                                                            | Insert                                                                                                            | Table                                                                                                           |
|------------------------|------------------------|------------------------|
| ![](/docs/tools/images/vscode-visual-editor-format-menu.png){.border fig-alt="The contents of the Format drop down menu."} | ![](/docs/tools/images/vscode-visual-editor-insert-menu.png){.border fig-alt="The contents of the Insert drop down menu."} | ![](/docs/tools/images/vscode-visual-editor-table-menu.png){.border fig-alt="The contents of the Table drop down menu."} |

## Editor Options

There are a variety of {{< meta tool.name >}} options available to configure the behavior of the visual editor. You can locate these options by filtering on `quarto.visualEditor` in the settings pane:

![](/docs/tools/images/vscode-visual-editor-options.png){.border width="609"}

Options enable configuration of appearance (font size, content width, etc.), markdown output (e.g. column wrapping), spell checking, and default spacing for lists.

## Zotero Citations

[Zotero](https://zotero.org) is a popular free and open source reference manager. The Quarto visual editor integrates directly with Zotero, enabling you to use the **Insert Citation** command to use references from your Zotero libraries:

![](/docs/visual-editor/images/visual-editing-citations-zotero-browse.png){.illustration fig-alt="The 'Insert Citation' dialog. The 'My Library' option is selected. The search bar at the top of the right section is empty, but the search results section is filled with the contents of a Zotero reference manager library. Each of the search result icons has a small 'Z' on the bottom right to indicate that the result comes from a Zotero library."}

Zotero references will also show up automatically in visual editor completions:

<img src="/docs/visual-editor/images/visual-editing-citation-completions.png" width="426" fig-alt="Someone has typed &apos;@&apos; in the Visual Editor. In light gray to the right of the &apos;@&apos; is a magnifying glass followed by the text &apos;or DOI&apos;. Underneath this is a pop-up menu showing available citations. Each citation has a title of the form &apos;@citation&apos; in black, the title of the cited material in gray underneath it, an icon to the left, and the reference to the right in gray. Some of the icons have a small red &apos;Z&apos; on the bottom right corner, indicating that the corresponding reference comes from a Zotero library."/>

Items from Zotero will appear alongside items from your bibliography with a small "Z" logo juxtaposed over them. If you insert a citation from Zotero that isn't already in your bibliography then it will be automatically added to the bibliography.

If you are running both {{< meta tool.name >}} and Zotero on your desktop, then no additional configuration is required for connecting to your Zotero library. If however you [are using VS Code in a web browser and/or]{.content-hidden unless-meta="tool.is_vscode"} want to access your Zotero library over the web, then a few more steps are required (see the [Zotero Web API](#zotero-web-api) section for details).

### Group Libraries {#group-libraries}

[Zotero Groups](https://www.zotero.org/support/groups) provide a powerful way to share collections with a class or work closely with colleagues on a project. By default, Zotero Group Libraries are not included in the **Insert Citation** dialog or citation completions. However, you can use the *Quarto \> Zotero: Group Libraries* option to activate one or more group libraries (either globally, or per-workspace):

![](/docs/visual-editor/images/visual-editing-vscode-zotero-libraries.png){.illustration width="563"}

After you've added a group library to the list, a sync will be performed and you should see the library in the **Insert Citation** dialog. If you don't, double check the exact spelling of the group library name you are configuring (you may even want to copy and paste it from Zotero so you are certain to get it right).

### Zotero Web API {#zotero-web-api}

If you [are using VS Code in a web browser and/or]{.content-hidden unless-meta="tool.is_vscode"} don't have Zotero installed locally, you can still access your Zotero library using the Zotero Web API (assuming you have a Zotero web account and have synced your libraries to your account).

::: {.callout-tip appearance="simple"}
If you are running {{< meta tool.name >}} on your desktop it's generally easier to also run Zotero on your desktop and access your library locally. That said, it is possible to access Zotero web libraries from {{< meta tool.name >}} on the desktop if you prefer that configuration.
:::

#### API Access Key

Zotero integration uses the Zotero Web API, so the first step is to [create a Zotero account](https://www.zotero.org/user/register) and then configure Zotero to sync its data to your account. You can do this using the **Sync** tab of the Zotero preferences:

![](/docs/visual-editor/images/visual-editing-citations-zotero-sync.png){.illustration fig-alt="The Sync tab of Zotero preferences." width="675"}

Once you've configured your library to sync, you need to [create a Zotero API Key](https://www.zotero.org/settings/keys/new):

![](/docs/visual-editor/images/visual-editing-citations-zotero-keygen.png){.illustration fig-alt="The 'New Private Key' section of Zotero. The 'Allow library access' option is selected." width="675"}

Follow the instructions to create a new access key. Note that if you want to use [Group Libraries](#group-libraries), you should change the default to provide read-only access to groups (as illustrated above).

Be sure to **record your key** after generating it (i.e. copy it to the clipboard and/or save it somewhere more permanent) as you won't be able to view it again after you navigate away.

#### Library Configuration

Finally, go to Zotero settings and specify that you'd like to use your `web` Zotero library rather than a local one:

![](/docs/visual-editor/images/vscode-zotero-web-config.png){.border}

You'll then be promoted to enter your Zotero Web API Key:

![](/docs/visual-editor/images/visual-editing-zotero-vscode-setup.png){.illustration width="601"}

After you provide your API key and it is validated, an initial sync of your Zotero libraries is performed. After this, you are ready to start inserting citations from Zotero.

::: callout-note
If you need to change your Zotero API key, you can always execute the **Quarto: Zotero - Connect Web Library** command. To force a sync of your web library, execute the **Quarto: Zotero - Sync Web Library** command (note that your web library is synced automatically so it is unlikely you'll need to use this command explicitly).
:::

## Markdown Output

The Quarto visual editor generates markdown using Pandoc. This means that in some cases your markdown will be *rewritten* to conform to standard Pandoc idioms. For example, Pandoc inserts 3 spaces after list bullets and automatically escapes characters that might be used for markdown syntax.

Here is a list of conventions for Pandoc generated markdown that might differ from your own markdown writing style:

-   `*text*` is used in preference to `_text_`
-   Backtick code blocks are written as ```` ``` {.md} ```` rather than ```` ```md ````
-   Backtick code blocks with no attributes are rendered as 4-space indented code blocks
-   Horizontal rules are written as dashes spanning the full width of the document
-   Plain links are written as `<https://yihui.org>` rather than `https://yihui.org`
-   Bullet and numbered lists use additional leading spaces before list item content
-   The blockquote character (`>`) is included on each new line of a blockquote
-   Table captions are written below rather than above tables
-   Multiline HTML and TeX blocks use the explicit raw attribute (e.g. ```` ```{=tex} ````)
-   Inline footnotes are replaced with footnotes immediately below the paragraph
-   Nested divs use `:::` at all levels so long as their attributes are distinct
-   Unnumbered sections are designated with `{.unnumbered}` rather than `{-}`
-   Characters used for markdown syntax (e.g. `*`, `_`, or `#`) are always escaped

While some of this behavior might be bothersome at first, if you decide that visual editing mode is useful for your workflow it's probably best to just adapt to writing your own markdown the same way that Pandoc does.

### Writer Options

Some aspects of markdown output can be customized via global, project, or file-level options, including:

-   How to wrap / break lines (fixed column, sentence-per-line, etc.).
-   Where to write footnotes (below the current paragraph or section, or at the end of the document).
-   Whether to write inline or reference style links.

You can specify these options in one of two ways:

1.  As a global or per-workspace {{< meta tool.name >}} option (you can find the options that affect markdown output by filtering on `quarto.visualEditor.markdown`).

2.  Specifying them within document or project level YAML (described below).

#### Line Wrapping

By default, the visual editor writes Markdown with no line wrapping (paragraphs all occupy a single line). However, if you prefer to insert line breaks at a particular column (e.g. 72 or 80), or to insert a line break after each sentence, you can use the `quarto.visualEditor.markdownWrap` and `quarto.visualEditor.markdownWrapColumn` options accessible from the settings editor in {{< meta tool.name >}}.

You can also set this behavior on a per-document or per-project basis via the `wrap` option. For example, to wrap lines after 72 characters you would use this:

``` yaml
---
editor:
  markdown:
    wrap: 72
---
```

To insert a line break after each sentence, use `wrap: sentence`. For example:

``` yaml
---
editor:
  markdown:
    wrap: sentence
---
```

::: {.callout-note appearance="simple"}
The algorithm used for sentence wrapping will handle English and Japanese text well, but may not detect the end of sentences accurately for other languages.
:::

If you have enabled a global line wrapping option and want to turn off wrapping for a given document, use `wrap: none`.

#### References

By default, references (footnotes and reference links) are written at the end of the block where their corresponding footnote appears. You can override this behavior using the `quarto.visualEditor.markdownReferences` {{< meta tool.name >}} setting or by using the `references` option within document or project YAML.

For example, to write references at the end of sections rather than blocks you would use:

``` yaml
---
title: "My Document"
editor:
  markdown:
    references: 
      location: block
---
```

Valid values for the `references` option are `block`, `section`, and `document`.

If you are aggregating a set of markdown documents into a larger work, you may want to make sure that reference identifiers are unique across all of your documents (e.g. you don't want to have `[^1]` appear multiple times). You can ensure uniqueness via the `prefix` option. For example:

``` yaml
---
title: "My Document"
editor:
  markdown:
    references: 
      location: block
      prefix: "mydoc"
---
```

This will result in footnotes in this document using the specified prefix (e.g. `[^mydoc-1]`), ensuring they are globally unique across the manuscript.

::: {.callout-note appearance="simple"}
Note that if you are within a Quarto [book](/docs/books/book-basics.qmd) project then a references `prefix` is applied automatically so no changes to `editor` options are required.
:::

#### Links

Links are written inline by default, however they can be written as reference links (below content as with footnotes) by adding the `links: true` option to the `references` section of document or project YAML. For example:

``` yaml
---
title: "My Document"
editor:
  markdown:
    references: 
      location: block
      links: true
---
```

You can alternatively enable reference links using the {{< meta tool.name >}} `quarto.visualEditor.markdownReferenceLinks` option.

### Known Limitations

There are a handful of Pandoc markdown extensions not currently supported by visual editing. These are infrequently used extensions, so in all likelihood they won't affect documents you edit, but are still worth noting.

| Extension(s)             | Example            | Behavior                                 |
|---------------------|-------------------|--------------------------------|
| Inline footnotes         | \^\[inline\]       | Converted to numeric footnote.           |
| Footnote identifiers     | \[\^longnote\]     | Converted to numeric footnote.           |
| Example lists            | (\@) First example | Read/written as ordinary numbered lists. |
| Auto-list numbers        | #\. First item     | Read/written as ordinary numbered lists. |
| Reference links          | This is a \[link\] | Converted to ordinary links.             |
| MultiMarkdown attributes | \# Heading \[id\]  | Converted to Pandoc attributes.          |

The visual editor is unable to parse non-YAML title blocks (e.g. old-style % titles or MultiMarkdown titles) and also unable to parse non top-level YAML metadata blocks. If these forms of metadata are encountered, visual mode will fail to load with a warning.

Note that support for reference links can be enabled via the `editor: markdown: references: links` option in document or project YAML, or the {{< meta tool.name >}} `quarto.visualEditor.markdownReferenceLinks` option. Reference links will be written according the reference location option (either the `block` or `section` in which they appear, or alternatively at the end of the `document`).
