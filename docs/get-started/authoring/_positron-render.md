When you preview a document with the **Quarto: Preview** command, the Preview button in the toolbar, or the keyboard shortcut {{< kbd mac=Command-Shift-K win=Ctrl+Shift+K linux=Ctrl+Shift+K >}}
the first format specified in the document header is rendered and previewed.
In this case, the file `authoring.pdf` will be created, and opened in the Viewer pane.

To preview a specific format use the **Quarto: Preview Format...** command and select a different format.
The selected format will then be used whenever you preview. 
To return to the default format, or a different format, run  **Quarto: Preview Format...** again.

To render all formats specified in the document header, run the command **Quarto: Render Document**. 
Then the following files would be created.

-   `authoring.pdf`
-   `authoring.html`
-   `authoring.docx`