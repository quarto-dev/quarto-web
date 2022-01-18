
function Table(tbl)
  tbl = pandoc.utils.to_simple_table(tbl)
  tbl.widths = { 0.3, 0.7 }
  return pandoc.utils.from_simple_table(tbl)
end