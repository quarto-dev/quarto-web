Span = function(s)
  if not quarto.format.isHtmlOutput() then
    return nil
  end
  if s.classes:includes('color-box') then
    local color
    if  s.attributes['color'] then
      quarto.log.output("HERE")
      color = s.attributes['color']
      s.attributes.color = nil
    elseif #s.content == 1 and s.content[1] and s.content[1].t == "Code" and s.content[1].text and s.content[1].text:sub(1, 1) == '#' then
      color = s.content[1].text
    end
    if color then
      s.content:insert(1, pandoc.Span('', pandoc.Attr('', { 'color-box' }, { style ="background-color:" .. color .. ";"})))
      return pandoc.Span( s.content , { "", { "color-box-container" } })
    end
  end
end