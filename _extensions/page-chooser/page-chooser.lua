-- page-chooser: a labelled row of links to sibling pages ("Choose your tool").
--
-- Usage:  {{< page-chooser tools >}}
--
-- Reads `page-choosers.<name>` from document metadata (usually a directory
-- _metadata.yml):
--
--   page-choosers:
--     tools:
--       label: Choose your tool          # visible label; also names the <nav>
--       storage-key: tutorialToolGetStarted  # optional: remember the last page
--       default: listing-filters.html    # optional: item marked current on index.html
--       item-width: 147px                # optional: tile width (default 102px)
--       items:
--         - text: Positron
--           href: positron.html
--           img: ../images/positron-logo.svg   # decorative logo, or
--           icon: gear                          # a Bootstrap icon name
--           icon-class: text-editor-logo        # optional extra class on the logo

local function str(v)
  if v == nil then return nil end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function attr(name, value)
  if value == nil or value == "" then return "" end
  return " " .. name .. '="' .. esc(value) .. '"'
end

return {
  ["page-chooser"] = function(args, kwargs, meta)
    if not quarto.doc.is_format("html") then
      return pandoc.Null()
    end

    local name = str(args[1])
    local choosers = meta["page-choosers"]
    local cfg = name and choosers and choosers[name]
    if cfg == nil then
      quarto.log.warning("page-chooser: no `page-choosers." .. tostring(name) .. "` in metadata")
      return pandoc.Null()
    end

    quarto.doc.add_html_dependency({
      name = "page-chooser",
      version = "1.0.0",
      stylesheets = { "page-chooser.css" },
      scripts = { { path = "page-chooser.js", afterBody = true } },
    })

    local label_id = name .. "-chooser-label"
    local width = str(cfg["item-width"])
    local style = width and ("--page-chooser-item-width: " .. width) or nil

    local out = {}
    table.insert(out, '<div class="page-chooser"' ..
      attr("data-storage-key", str(cfg["storage-key"])) ..
      attr("data-default", str(cfg["default"])) .. '>')
    table.insert(out, '<p class="page-chooser-label h3"' .. attr("id", label_id) .. '>' ..
      esc(str(cfg.label) or "") .. '</p>')
    table.insert(out, '<nav' .. attr("aria-labelledby", label_id) .. '>')
    table.insert(out, '<ul class="page-chooser-list"' .. attr("style", style) .. '>')
    for _, item in ipairs(cfg.items or {}) do
      local logo = ""
      if item.img then
        logo = '<img' .. attr("src", str(item.img)) .. ' alt=""' ..
          attr("class", str(item["icon-class"])) .. '>'
      elseif item.icon then
        logo = '<i class="bi bi-' .. esc(str(item.icon)) ..
          (item["icon-class"] and (" " .. esc(str(item["icon-class"]))) or "") ..
          '" aria-hidden="true"></i>'
      end
      table.insert(out, '<li><a' .. attr("href", str(item.href)) .. '>' ..
        logo .. esc(str(item.text) or "") .. '</a></li>')
    end
    table.insert(out, '</ul>')
    table.insert(out, '</nav>')
    table.insert(out, '</div>')

    return pandoc.RawBlock("html", table.concat(out, "\n"))
  end
}
