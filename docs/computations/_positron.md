The [Quarto Extension](https://open-vsx.org/extension/quarto/quarto) is bundled with Positron, and provides a variety of tools for working with `.qmd` files. The extension integrates directly with {{< meta positron-extension>}} to provide code completion, cell execution and side-by-side preview of Quarto documents.

![]({{< meta positron-screenshot >}}){.include-dark .border fig-alt="Screen shot of qmd file open in Positron with source markdown shown in Editor pane and a rendered document shown in the Viewer Pane."}

The extension includes a **Quarto: Preview** command that can be accessed via the Command Palette, the keyboard shortcut {{< kbd mac=Command-Shift-K win=Control-Shift-K linux=Control-Shift-K >}}, or a **Preview** button (![](/docs/tools/images/vscode-preview-icon.svg){.light-content fig-alt="Preview icon"}![](/docs/tools/images/vscode-preview-icon-white.svg){.dark-content fig-alt="Preview icon"}) in the editor toolbar. 
After rendering, a preview is displayed in the Viewer pane within Positron. 

You can read more about using Positron in [Tools: Positron](/docs/tools/positron/index.qmd).

::: {.content-visible unless-meta="is_r"}
You can also use the Positron notebook editor to create `.ipynb` notebooks that you will render with Quarto. The [Jupyter Lab](#jupyter-lab) section discusses using notebooks with Quarto in the context of Jupyter Lab, but the same concepts apply to Positron.
::: 