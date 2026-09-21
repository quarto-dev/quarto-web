```{=html}
<h3 class="no-anchor" id="choose-your-tool-heading">Choose your tool</h3>
<nav aria-labelledby="choose-your-tool-heading">
<ul id="choose-your-tool" class="nav nav-tabs">
  <li class="nav-item">
    <a class="nav-link" href="positron.html">
      <img src="../images/positron-logo.svg" alt="">Positron
    </a>
  </li>
  <li class="nav-item">
    <a class="nav-link" href="vscode.html">
      <img src="../images/vscode-logo.png" alt="">VS Code
    </a>
  </li>
  <li class="nav-item">
    <a class="nav-link" href="jupyter.html">
      <img src="../images/jupyter-logo.png" alt="">Jupyter
    </a>
  </li>
  <li class="nav-item">
    <a class="nav-link" href="rstudio.html">
      <img src="../images/rstudio-logo.png" alt="">RStudio
    </a>
  </li>
  <li class="nav-item">
    <a class="nav-link" href="neovim.html">
      <img src="../images/neovim-logo.svg" alt="">Neovim
    </a>
  </li>
  <li class="nav-item">
    <a class="nav-link" href="text-editor.html">
      <img src="../images/text-editor-logo.png" id="text-editor-logo" alt="">Editor
    </a>
  </li>
</ul>
</nav>

<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function() {
  // get file name
  const filename = window.location.pathname.split("/").slice(-1)[0];
  
  // latch active
  const toolLinks = window.document.querySelectorAll("#choose-your-tool a");
  for (const tool of toolLinks) {
    if (tool.href.endsWith(filename)) {
      tool.classList.add("active");
      tool.setAttribute("aria-current", "page");
      break;
    }
  }
  
   // save in local storage
  window.localStorage.setItem("tutorialToolGetStarted", filename);
});

</script>
```
