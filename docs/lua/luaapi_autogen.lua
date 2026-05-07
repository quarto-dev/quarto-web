function Para(para)
    if #para.content == 1 and para.content[1].t == "Link" then
        local link = para.content[1]
        if link.target:match("^command:extension") then 
            return {} 
        end
    end
    if pandoc.utils.stringify(para):match("^Miss locale") then 
        return {} 
    end
end