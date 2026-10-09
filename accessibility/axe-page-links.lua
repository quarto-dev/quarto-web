-- Link the page paths in an axe report's tables to the live site.
--
-- `quarto call axe` writes each page as a plain site path, such as
-- `docs/authoring/markdown-basics.html`, in the first column of tables whose
-- first header is "page". This makes each one a root-relative link.

local function first_header_text(tbl)
  local row = tbl.head.rows[1]
  if not row or not row.cells[1] then
    return nil
  end
  return pandoc.utils.stringify(row.cells[1].contents)
end

function Table(tbl)
  if first_header_text(tbl) ~= "page" then
    return nil
  end
  for _, body in ipairs(tbl.bodies) do
    for _, row in ipairs(body.body) do
      local cell = row.cells[1]
      local path = cell and pandoc.utils.stringify(cell.contents)
      if path and path:match("^[%w%-_./]+%.html$") then
        cell.contents = { pandoc.Plain({ pandoc.Link(path, "/" .. path) }) }
      end
    end
  end
  return tbl
end
