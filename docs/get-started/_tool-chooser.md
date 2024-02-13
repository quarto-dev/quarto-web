```{=html}
<ul id="choose-your-tool" class="nav nav-tabs" role="tablist">
  <h3 class="no-anchor">Choose your tool</h3>
  <li class="nav-item" role="presentation">
    <a class="nav-link" href="vscode.html">
      <img src="../images/vscode-logo.png">VS Code
    </a>
  </li>
  <li class="nav-item" role="presentation">
    <a class="nav-link" href="jupyter.html">
      <img src="../images/jupyter-logo.png">Jupyter
    </a>
  </li>
  <li class="nav-item" role="presentation">
    <a class="nav-link" href="rstudio.html">
      <img src="../images/rstudio-logo.png">RStudio
    </a>
  </li>
  <li class="nav-item" role="presentation">
    <a class="nav-link" href="neovim.html">
      <img src="../images/neovim-logo.svg">Neovim
    </a>
  </li>
  <li class="nav-item" role="presentation">
    <a class="nav-link" href="text-editor.html">
      <img src="../images/text-editor-logo.png" id="text-editor-logo">Editor
    </a>
  </li>
</ul>

<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function() {
  // get file name
  const filename = window.location.pathname.split("/").slice(-1)[0];
  
  // latch active
  const toolLinks = window.document.querySelectorAll("#choose-your-tool a");
  for (const tool of toolLinks) {
    if (tool.href.endsWith(filename)) {
      tool.classList.add("active");
      break;
    }
  }
  
   // save in local storage
  window.localStorage.setItem("tutorialTool", filename);
});

</script>
```
