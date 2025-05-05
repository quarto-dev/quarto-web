## {{< meta tool.name >}} Editors

Depending on your preference and the task at hand, you can author documents for rendering by Quarto using three different editors within {{< meta tool.name >}}:

1. The source code editor for editing `.qmd` documents as text.

2. The [Visual Editor](/docs/tools/{{< meta tool.prefix >}}/visual-editor.qmd) for WYSIWYG editing of `.qmd` documents.

3. The [Notebook Editor](/docs/tools/{{< meta tool.prefix >}}/notebook.qmd) for editing `.ipynb` notebooks.

We'll cover the source code editor below, however you might also want to consult the documentation for the [Visual Editor](/docs/tools/{{< meta tool.prefix >}}/visual-editor.qmd) or [Notebook Editor](/docs/tools/{{< meta tool.prefix >}}/notebook.qmd) after you've become familiar with the basics.

## Render and Preview

The Quarto VS Code extension includes commands and keyboard shortcuts for rendering Quarto documents (both standalone and within websites or books). After rendering, `quarto preview` is used behind the scenes to provide a [preview pane]{
  .content-hidden unless-meta="tool.is_vscode"}[preview in the Viewer Pane]{.content-hidden unless-meta="tool.is_positron"} within {{< meta tool.name >}} alongside your document:

![](/docs/tools/images/{{< meta tool.prefix >}}-render.png){.border fig-alt='Two windows arranged side by side. The window on the left is a qmd file opened in {{< meta tool.name >}}. The contents of this document are the same as the first part of the Getting Started: Welcome section of this website. The contents of this document are rendered by Quarto in the window on the right.'}

To render and preview, execute the **Quarto: Preview** command. You can alternatively use the <kbd>Ctrl+Shift+K</kbd> keyboard shortcut, or the **Preview** button (![](/docs/tools/images/vscode-preview-icon.svg){fig-alt="Preview icon"}) at the top right of the editor:

![](/docs/tools/images/{{< meta tool.prefix >}}-preview-button.png){.border fig-alt='The top of the {{< meta tool.name >}} editor. The right side of the editor tab area includes a Preview button.'}

::: {.callout-note appearance="simple"}
Note that on the Mac you should use `Cmd` rather than `Ctrl` as the prefix for all Quarto keyboard shortcuts.
:::

### Other Formats

The **Quarto: Preview** command renders the default format of the currently active document. If you want to preview a different format, use the **Quarto: Preview Format** command:

![](/docs/tools/images/vscode-preview-format-menu.png){.border fig-alt="The top of the Visual Studio code editor. The editor title menu is expanded and the Preview Format command is available on the menu."}

When you execute **Preview Format**, you'll see a quick pick list of formats to choose from (any formats declared in the document as well as some standard formats like PDF and MS Word):

![](/docs/tools/images/vscode-preview-format.png){.border fig-alt="The top of the Visual Studio code editor. The command pallette shows a quick pick list of available formats to preview."}

After previewing a different format, the **Quarto: Preview** command and <kbd>Ctrl+Shift+K</kbd> keyboard shortcut will be automatically rebound to the newly selected format for the duration of the current preview. To switch back to previewing the original format, use  **Quarto: Preview Format** command again.

::: {.callout-note appearance="simple"}
Embedded preview is currently supported for HTML and PDF based formats (including `revealjs` and `beamer` slideshows). However, for Word and other formats you need to use an appropriate external program to preview the output.
:::

### Render Command

The **Quarto: Preview** command is what you will most commonly use while authoring documents. If you have a single format (e.g. HTML or PDF) then previewing also renders your document so it's ready for distribution once you are happy with the output. However, if you have multiple formats will need to explicitly render them (as preview only renders a single format at a time). You can do this with the **Quarto: Render Document** command:

![](/docs/tools/images/vscode-render-command.png){.border fig-alt="The top of the Visual Studio code editor. The command pallette shows a quick pick list of available formats to render."}

If you have multiple declared formats you can render all of them. You can also selectively render any of the declared formats or other standard formats like PDF and MS Word.

## Render on Save

By default Quarto does not automatically render `.qmd` or `.ipynb` files when you save them. This is because rendering might be very time consuming (e.g. it could include long running computations) and it's good to have the option to save periodically without doing a full render.

However, you can configure the Quarto extension to automatically render whenever you save. You can do this either within {{< meta tool.name >}} settings or within the YAML options for your project or document. To configure the {{< meta tool.name >}} setting, search for `quarto.render` in settings and you'll find the **Render on Save** option:

![](/docs/tools/images/vscode-render-on-save.png){.border fig-alt="The Visual Studio Code Quarto render settings. The Render on Save option is checked."}

You might also want to control this behavior on a per-document or per-project basis. If you include the `editor: render-on-save` option in your document or project YAML it will supersede whatever your {{< meta tool.name >}} setting is. For example:

``` yaml
editor:
  render-on-save: true
```

## External Preview

If you prefer to use an external browser for preview (or have no preview triggered at all by rendering) you can use the **Preview Type** option to specify an alternate behavior:

![](/docs/tools/images/vscode-preview-settings.png){.border fig-alt='{{< meta tool.name >}} settings interface with \'quarto preview type\' entered into the search bar. User settings reveals Quarto > Render: Preview Type, with a dropdown to select location for document preview after render. The default, internal, is selected, which previews using a side-by-side panel in {{< meta tool.name >}}. The other two options in the dropdown are external and none.'}

## Code Cells

There are a variety of tools that make it easier to edit and execute code cells. Editing tools include syntax highlighting, code folding, code completion, and signature tips:

![](/docs/tools/images/{{< meta tool.prefix >}}-code-cell.png){.border fig-alt='A Quarto document in {{< meta tool.name >}} with a python code cell. There is a code completion helper active in the python cell.'}

For Python, R, and Julia cells, commands are available to execute the current cell, previous cells, or the currently selected line(s). 
[Cell output is shown side by side in the Jupyter interactive console:]{.content-hidden unless-meta="tool.is_vscode"}
[R and Python cells are executed in the appropriate Console, and output is shown in the pane:]{.content-hidden unless-meta="tool.is_vscode"}

![](/docs/tools/images/{{< meta tool.prefix >}}-execute-cell.png){.border fig-alt='{{< meta tool.name >}} with two panes open, source code on the right, and the interactive output of that code shown in a second pane on the left.'}

Here are all of the commands and keyboard shortcuts available for executing cells:

| Quarto Command       | Keyboard Shortcut   |
|----------------------|---------------------|
| Run Current Cell     | <kbd>⇧⌘ Enter</kbd> |
| Run Selected Line(s) | <kbd>⌘ Enter</kbd>  |
| Run Next Cell        | <kbd>⌥⌘ N</kbd>     |
| Run Previous Cell    | <kbd>⌥⌘ P</kbd>     |
| Run All Cells        | <kbd>⌥⌘ R</kbd>     |
| Run Cells Above      | <kbd>⇧⌥⌘ P</kbd>    |
| Run Cells Below      | <kbd>⇧⌥⌘ N</kbd>    |

You can quickly insert a new code cell using the <kbd>Ctrl+Shift+I</kbd> keyboard shortcut.

::: {.content-hidden unless-meta="tool.is_vscode"}
Enhanced features for embedded languages (e.g. completion, code execution) can be enabled by installing the most recent version(s) of these extensions:

-   [Python Extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python) and [Jupyter Extension](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
-   [R Extension](https://marketplace.visualstudio.com/items?itemName=REditorSupport.r)
-   [Julia Extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia)
:::

::: {.content-hidden unless-meta="tool.is_positron"}
Positron includes enhanced features for R and Python code cells (e.g. completion, code execution).
To get enhanced features for Julia, install the [Julia Extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia).
:::

### Execution Directory

::: {.content-hidden unless-meta="tool.is_vscode"}
Embedded language extensions handle the working directory for execution in distinct ways:

1. The Python Extension runs code within the directory of the source file from which code is executed. You can customize this behavior using the `jupyter.notebookFileRoot` option.

2. The R Extension runs code within the working directory of the R session running in the **R Interactive** terminal. You can change this directory manually using `setwd()`.

3. The Julia Extension runs code within the working directory of the Julia session running in the **Julia REPL** terminal. You can change this directory manually using `cd()`.
:::

::: {.content-hidden unless-meta="tool.is_positron"}
The execution directory for code cells in Positron depends on the language of the code cell:

1. **R and Python** cells will be executed in the appropriate Console in Positron.
The default execution directory for the Console is folder that was opened as the workspace.

2. **Julia** cells require the Julia Extension which runs code within the working directory of the Julia session running in the **Julia REPL** terminal. You can change this directory manually using `cd()`.
:::

## Contextual Assistance

Execute the **Quarto: Show Assist Panel** command to show a panel in the sidebar that shows contextual assistance depending on the current cursor location:

1)  Help/documentation is shown when editing code
2)  A realtime preview of equations is shown when editing LaTeX math
3)  Thumbnail previews are shown when your cursor is located on a markdown image.

For example, below help on the matplotlib `plot()` function is shown automatically when the cursor is located on the function:

::: {.content-hidden unless-meta="tool.is_vscode"}
![](/docs/computations/images/python-vscode.png){.border fig-alt='Screenshot of {{< meta tool.name >}} editor with three vertical sections. The leftmost includes the file explorer, and quarto help. The second pane is the source code for a quarto file with python code. The third is interactive with Python running and output of the code cells shown.'}
:::

::: {.content-hidden unless-meta="tool.is_positron"}
![](/docs/tools/images/positron-python.png){.border .preview-image fig-alt="Screen shot of Positron editor with three vertical sections. The leftmost includes the file explorer, and quarto help. The second pane is the source code for a quarto file with python code, and the active Python Console. The third shows the Environment and Plots for the active console populated with the output of the code cells."}
:::

## Live Preview

While editing LaTeX math or Mermaid and Graphviz diagrams, click the **Preview** button above the code (or use the <kbd>Ctrl+Shift+L</kbd> keyboard shortcut) to open a live preview which will update automatically as you edit.

Here we see a preview of the currently edited LaTeX equation displayed in the Quarto assist panel:

![](/docs/tools/images/vscode-equation.png){.border fig-alt='Quarto document open in {{< meta tool.name >}} with a LaTeX equation shown in the \'Quarto Equation\' section of the panel to the left of the document.'}

Here we see a Graphviz diagram preview automatically updated as we edit:

![](/docs/authoring/images/vscode-graphviz.gif){.border fig-alt="A Quarto document being edited in Visual Studio Code, with a live preview of the currently edited diagram shown in a pane to the right"}

## YAML Intelligence

YAML code completion is available for project files, YAML front matter, and executable cell options:

![](/docs/tools/images/vscode-yaml-completion.png){.border fig-alt="Quarto document with YAML being edited. Next to the cursor code completion helper is open showing YAML options beginning with the letters preceding the cursor ('co')."}

If you have incorrect YAML it will also be highlighted when documents are saved:

![](/docs/tools/images/vscode-yaml-diagnostics.png){.border fig-alt="Quarto document YAML metadata with an incorrect option underlined in red."}

## Code Snippets

Code snippets are templates that make it easier to enter repeating code patterns (e.g. code blocks, callouts, divs, etc.). Execute the **Insert Snippet** command within a Quarto document to insert a markdown snippet:

![](/docs/tools/images/vscode-snippets.png){.border fig-alt="Quarto document with dropdown 'Select a snippet' dropdown, the first item (bold - insert bold text) is selected."}

### IntelliSense

VSCode uses IntelliSense to suggest snippets or possible values for a specific function while typing. This is turned off by default for snippets, but not for values. To enable snippet suggestions in IntelliSense while typing or when selecting a text snippet and pressing `ctrl+space`, the setting `editor.snippetSuggestions` needs to be set to a value other than `none` (for example to `inline`).

-   Press `F1` and search for `Preferences: Open Settings (UI)` or `File` \> `Preferences` \> `Settings`
-   Search for following term `@lang:quarto editor.snippetSuggestions`. `Editor: Snippet Suggestions` should show up.
-   Change value to a not-`none` value.

## Document Navigation

If you have a large document use the outline view for quick navigation between sections:

![](/docs/tools/images/vscode-outline.png){.border fig-alt="Quarto document with outline view shown in left-hand panel. The outline shows the section headers of the quarto documents."}

You can also use the **Go to Symbol in Editor** command or keyboard shortcut <kbd>Ctrl+Shift+O</kbd> for type-ahead navigation of the current document's outline.

Use the **Go to File** command <kbd>Ctrl+P</kbd> to navigate to other files and the **Go to Symbol in Workspace** command <kbd>Ctrl+T</kbd> for type-ahead navigation to all headings in the workspace:

![](/docs/tools/images/vscode-workspace-symbols.png){.border fig-alt='Quarto document in {{< meta tool.name >}} with command palette open showing the files in the project with the entered term, \'margin\'.'}

## Learning More

Besides the traditional source editor described above, you can also use one of the following other editors depending on your preferences and task at hand:

1. The [Visual Editor](/docs/tools/{{< meta tool.prefix >}}/visual-editor.qmd) for WYSIWYG editing of `.qmd` documents.

2. The [Notebook Editor](/docs/tools/{{< meta tool.prefix >}}/notebook.qmd) for editing `.ipynb` notebooks.
