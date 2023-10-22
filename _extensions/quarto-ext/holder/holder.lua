


return {
  ['holder'] = function(args, kwargs) 

    quarto.doc.add_html_dependency({
      name = "holder", 
      version = "2.9.8",
      scripts = {'holder.min.js'},
    })

    local size = pandoc.utils.stringify(args[1])
    if #args > 1 then
      kwargs['text'] = pandoc.utils.stringify(args[2])
    end
 
    local query = '?'
    for k, v in pairs(kwargs) do
      query = query .. k .. '=' .. pandoc.utils.stringify(v) .. '&'
    end    
    
    return pandoc.RawInline('html', '<img data-src="holder.js/' .. size .. query .. '">')
  end
}
