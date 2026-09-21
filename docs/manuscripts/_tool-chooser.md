```{=html}
<nav aria-label="Choose your tool">
<ul id="choose-your-tool" class="nav nav-tabs">
  <li class="nav-item">
    <a class="nav-link" href="jupyterlab.html">
      <img src="../images/jupyter-logo.png" alt="">Jupyter
    </a>
  </li>
  <li class="nav-item">
    <a class="nav-link" href="vscode.html">
      <img src="../images/vscode-logo.png" alt="">VS Code
    </a>
  </li>
  <li class="nav-item">
    <a class="nav-link" href="rstudio.html">
      <img src="../images/rstudio-logo.png" alt="">RStudio
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
  window.localStorage.setItem("tutorialToolManuscript", filename);
});

</script>
```
