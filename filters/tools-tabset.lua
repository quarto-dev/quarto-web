

local kTabsetIcons = {
  ["VS Code"] = "vscode-logo.png",
  ["RStudio"] = "rstudio-logo.png",
  ["Terminal"] = "text-editor-logo.png"
}

function Div(el)
  if el.classes:includes("panel-tabset") then
    if el.attributes["group"] == "tools-tabset" then
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