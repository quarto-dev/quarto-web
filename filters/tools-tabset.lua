

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
        for (const navTab of document.querySelectorAll(".panel-tabset[data-group='tools-tabset'] ul[role='tablist']")) {
          navTab.setAttribute("aria-label", "Choose your tool");
          const row = document.createElement("div");
          row.classList.add("choose-your-tool-row");
          const choose = document.createElement("p");
          choose.classList.add("choose-your-tool");
          choose.setAttribute("aria-hidden", "true");
          choose.innerText = "Choose your tool";
          navTab.before(row);
          row.append(choose, navTab);
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
        tab.title.content:insert(1, pandoc.Image("", "/docs/get-started/images/" .. icon, "", pandoc.Attr("", {}, {{"alt", ""}})))
      end
    end
  end
  return el
end