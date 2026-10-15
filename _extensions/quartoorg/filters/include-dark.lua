local function dark_path(src)
  local path = {pandoc.path.split_extension(src)}
  return path[1] .. "-dark" .. path[2]
end

local function new_image(img, src, class) 
  local new_classes = pandoc.List.filter(img.classes, function(c)
    return c ~= "include-dark"
  end)
  new_classes:insert(class)
  local new_attr = pandoc.Attr(img.attr.identifier, new_classes, img.attr.attributes)
  local new_img = pandoc.Image(img.caption, src, img.title, new_attr)
  return new_img
end

function Image(img)
  if img.classes:includes("include-dark") then
    local dark_img = new_image(img, dark_path(img.src), "dark-content")
    local light_img = new_image(img, img.src, "light-content")
    return {dark_img, light_img}
  end
  return img
end

