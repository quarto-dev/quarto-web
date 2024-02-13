RStudio {{< var rstudio.min_version >}} and later includes support for editing and preview of Quarto documents (the documentation below assumes you are using this build or a later version). 

If you are using Quarto within RStudio it is **strongly** recommended that you use the [latest release](https://posit.co/download/rstudio-desktop/) of RStudio ({{< var rstudio.current_release >}}).

You can download RStudio {{< var rstudio.current_release >}} from <https://posit.co/download/rstudio-desktop/>.

### Creating Documents

Use the **File :** **New File : Quarto Document...** command to create new Quarto documents:

![](/docs/tools/images/new-quarto-doc.png){.border width="529" fig-alt="The 'New Quarto Document' dialog menu in RStudio."}

### Render and Preview

Use the **Render** button to preview documents as you edit them:

![](/docs/tools/images/rstudio-render.png){.border-bottom width="612" fig-alt="The top section of a qmd file as displayed in RStudio. There is a toolbar right above the document containing various options, including 'Render.' There is a stylized, segmented blue arrow pointing at the word."}

If you prefer to automatically render whenever you save you can check the **Render on Save** option on the editor toolbar.

The preview will appear alongside the editor:

![](/docs/tools/images/rstudio-preview.png){.border fig-alt="An RStudio window. On the left half of the page is a Quarto document and the 'Jobs' pane open underneath that. There is messages in green text in the 'Jobs' pane that say: 'Watching files for changes. Browse at http://localhost:4064'. On the right half of the window is the Quarto output of the document on the left, as rendered by Knitr."}

The preview will update whenever you re-render the document. Side-by-side preview works for both HTML and PDF output.

### Projects

If you want to create a new project for a Quarto document or set of documents, use the **File : New Project...** command, specify **New Directory**, then choose **Quarto Project**:

![](/docs/tools/images/rstudio-new-knitr-project.png){.border width="533" fig-alt="A section of the 'New Project Wizard' menu from Rstudio. This section is titled 'Create Quarto Project'. The Quarto logo is displayed on the left. ON the right are fields for 'Type', 'Directory name', and 'Create project as subdirectory of:'. Underneath that are options for 'Engine', 'Create a git repository', and 'Use renv with this project'. The option for 'Engine' is set to 'Knitr'. There are buttons for 'Create Project' and 'Cancel' arranged side-by-side in the bottom right of the window. There is an option to 'Open in new session' in the button left corner."}

You can use this UI to create both vanilla projects as well as [websites](../websites/website-basics.qmd) and [books](../books/book-basics.qmd). Options are also provided for creating a [git](https://git-scm.com/) repository and initializing an [renv](https://rstudio.github.io/renv/) environment for the project.
