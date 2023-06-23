```{=html}
<ul id="choose-your-tool" class="nav nav-tabs" role="tablist">
  <li class="nav-item" role="presentation">
    <a class="nav-link" href="jupyterlab.html">
      <img src="../images/jupyter-logo.png">Jupyter
    </a>
  </li>
  <li class="nav-item" role="presentation">
    <a class="nav-link" href="vscode.html">
      <img src="../images/vscode-logo.png">VS Code
    </a>
  </li>
  <li class="nav-item" role="presentation">
    <a class="nav-link" href="rstudio.html">
      <img src="../images/rstudio-logo.png">RStudio
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
