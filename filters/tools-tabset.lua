

local kTabsetIcons = {
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

function Div(el)
  if el.classes:includes("panel-tabset") then
    if el.attributes["group"] == "tools-tabset" then
      injectChooseYourTool()
      return el:walk({
        Header = function(headingEl)
          local text = pandoc.utils.stringify(headingEl.content)
          local icon = kTabsetIcons[text]
          if icon then
            headingEl.content:insert(1, pandoc.Image("", "/docs/get-started/images/" .. icon))
            return headingEl
          end
        end
      })
    end
  end

end