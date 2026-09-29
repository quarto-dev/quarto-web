-- Shift heading levels inside a marked div, e.g. to nest an include
-- under the current section:
--
-- ::: {.shift-headings by=1}
-- {{< include _file.md >}}
-- :::
--
-- `by` defaults to 1 and may be negative. The div is unwrapped, so only
-- its (shifted) contents reach the output.
--
-- Adapted from @jjallaire's filter in
-- https://github.com/quarto-dev/quarto-cli/discussions/6695#discussioncomment-15611429

function Div(el)
  if not el.classes:includes("shift-headings") then
    return nil
  end
  local by = tonumber(el.attributes["by"]) or 1
  return el:walk({
    Header = function(h)
      h.level = h.level + by
      return h
    end
  }).content
end
