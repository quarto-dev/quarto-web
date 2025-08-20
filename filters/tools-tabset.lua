

local kTabsetIcons = {
  ["Positron"] = "positron-logo.svg",
  ["VS Code"] = "vscode-logo.png",
  ["RStudio"] = "rstudio-logo.png",
  ["Terminal"] = "text-editor-logo.png"
}

local injected = false
local function injectChooseYourTool()
  if not injected then
    injected = true
    quarto.doc.include_text('after-body', [[
      <script type="text/javascript">
        for (const navTab of document.querySelectorAll(".panel-tabset[data-group='tools-tabset'] ul")) {
          const choose = document.createElement("h3");
          choose.classList.add("no-anchor");
          choose.classList.add("choose-your-tool");
          choose.innerText = "Choose your tool";
          navTab.prepend(choose);
        }       
      </script>
    ]])
  end
end

function Tabset(el)
  if el.attr.attributes["group"] == "tools-tabset" then
    injectChooseYourTool()
    for i, tab in ipairs(el.tabs) do
      local text = pandoc.utils.stringify(tab.title)
      local icon = kTabsetIcons[text]
      if icon then
        tab.title.content:insert(1, pandoc.Image("", "/docs/get-started/images/" .. icon))
      end
    end
  end
  return el
end