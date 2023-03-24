## Workflow

You can author Quarto documents that include {{< meta jupyter-language >}} code using any text or notebook editor. No matter what editing tool you use, you'll always run `quarto preview` first to setup a live preview of changes in your document. Live preview is available for both HTML and PDF output. For example:

```{.bash filename="Terminal"}
# preview as html
quarto preview document.qmd

# preview as pdf
quarto preview document.qmd --to pdf

# preview a jupyter notebook
quarto preview document.ipynb
```

{{< include _jupyter-execute.md >}}

## Embed Notebooks

In addition to including executable {{< meta jupyter-language >}} code chunks in a Quarto document, you can also embed cells from an external Jupyter Notebook (`.ipynb`). See [Embedding Jupyter Notebook Cells](/docs/authoring/notebook-embed.qmd) for more details.

## VS Code

The [Quarto Extension](https://marketplace.visualstudio.com/items?itemName=quarto.quarto) for VS Code provides a variety of tools for working with `.qmd` files in VS Code. The extension integrates directly with the {{< meta vscode-extension >}} to provide the following {{< meta jupyter-language >}}-specific capabilities:

1)  Code completion
2)  Cell execution
3)  Contextual help

{{< meta vscode-screenshot >}}

You can install the VS Code extension by searching for 'quarto' in the extensions panel or from the [extension marketplace](https://marketplace.visualstudio.com/items?itemName=quarto.quarto).

You can also use the VS Code notebook editor to create {{< meta jupyter-language >}} notebooks that you will render with Quarto. The next section discusses using notebooks with Quarto in the context of Jupyter Lab, but the same concepts apply to VS Code.

## Jupyter Lab

We could convert the simple `document.qmd` we used as an example above to a Jupyter notebook using the `quarto convert` command. For example:

```{.bash filename="Terminal"}
quarto convert document.qmd
```

If we open this notebook in Jupyter Lab and execute the cells, here is what we see:

{{< meta jupyter-screenshot >}}

Note that there are three different types of cell here:

1)  The YAML document options at the top are in a **Raw** cell.
2)  The heading and explanation are in a **Markdown** cell.
3)  The {{< meta jupyter-language >}} code and its output are in a **Code** cell.

When working in a Jupyter notebook, you can use `quarto preview` to provide a live preview of your rendered document:

```{.bash filename="Terminal"}
quarto preview document.ipynb
```

The preview will be updated every time you save the notebook in Jupyter Lab.
