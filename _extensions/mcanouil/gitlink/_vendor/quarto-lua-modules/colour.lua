--- MC Colour - Colour conversion utilities for Quarto Lua filters and shortcodes
--- @module "colour"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

local M = {}

-- ============================================================================
-- CSS NAMED COLOURS
-- ============================================================================

--- CSS named colours lookup table.
--- Maps lowercase colour names to uppercase 6-character hex codes.
--- Contains all 148 standard CSS named colours.
--- @type table<string, string>
local CSS_NAMED_COLOURS = {
  aliceblue = '#F0F8FF',
  antiquewhite = '#FAEBD7',
  aqua = '#00FFFF',
  aquamarine = '#7FFFD4',
  azure = '#F0FFFF',
  beige = '#F5F5DC',
  bisque = '#FFE4C4',
  black = '#000000',
  blanchedalmond = '#FFEBCD',
  blue = '#0000FF',
  blueviolet = '#8A2BE2',
  brown = '#A52A2A',
  burlywood = '#DEB887',
  cadetblue = '#5F9EA0',
  chartreuse = '#7FFF00',
  chocolate = '#D2691E',
  coral = '#FF7F50',
  cornflowerblue = '#6495ED',
  cornsilk = '#FFF8DC',
  crimson = '#DC143C',
  cyan = '#00FFFF',
  darkblue = '#00008B',
  darkcyan = '#008B8B',
  darkgoldenrod = '#B8860B',
  darkgray = '#A9A9A9',
  darkgreen = '#006400',
  darkgrey = '#A9A9A9',
  darkkhaki = '#BDB76B',
  darkmagenta = '#8B008B',
  darkolivegreen = '#556B2F',
  darkorange = '#FF8C00',
  darkorchid = '#9932CC',
  darkred = '#8B0000',
  darksalmon = '#E9967A',
  darkseagreen = '#8FBC8F',
  darkslateblue = '#483D8B',
  darkslategray = '#2F4F4F',
  darkslategrey = '#2F4F4F',
  darkturquoise = '#00CED1',
  darkviolet = '#9400D3',
  deeppink = '#FF1493',
  deepskyblue = '#00BFFF',
  dimgray = '#696969',
  dimgrey = '#696969',
  dodgerblue = '#1E90FF',
  firebrick = '#B22222',
  floralwhite = '#FFFAF0',
  forestgreen = '#228B22',
  fuchsia = '#FF00FF',
  gainsboro = '#DCDCDC',
  ghostwhite = '#F8F8FF',
  gold = '#FFD700',
  goldenrod = '#DAA520',
  gray = '#808080',
  green = '#008000',
  greenyellow = '#ADFF2F',
  grey = '#808080',
  honeydew = '#F0FFF0',
  hotpink = '#FF69B4',
  indianred = '#CD5C5C',
  indigo = '#4B0082',
  ivory = '#FFFFF0',
  khaki = '#F0E68C',
  lavender = '#E6E6FA',
  lavenderblush = '#FFF0F5',
  lawngreen = '#7CFC00',
  lemonchiffon = '#FFFACD',
  lightblue = '#ADD8E6',
  lightcoral = '#F08080',
  lightcyan = '#E0FFFF',
  lightgoldenrodyellow = '#FAFAD2',
  lightgray = '#D3D3D3',
  lightgreen = '#90EE90',
  lightgrey = '#D3D3D3',
  lightpink = '#FFB6C1',
  lightsalmon = '#FFA07A',
  lightseagreen = '#20B2AA',
  lightskyblue = '#87CEFA',
  lightslategray = '#778899',
  lightslategrey = '#778899',
  lightsteelblue = '#B0C4DE',
  lightyellow = '#FFFFE0',
  lime = '#00FF00',
  limegreen = '#32CD32',
  linen = '#FAF0E6',
  magenta = '#FF00FF',
  maroon = '#800000',
  mediumaquamarine = '#66CDAA',
  mediumblue = '#0000CD',
  mediumorchid = '#BA55D3',
  mediumpurple = '#9370DB',
  mediumseagreen = '#3CB371',
  mediumslateblue = '#7B68EE',
  mediumspringgreen = '#00FA9A',
  mediumturquoise = '#48D1CC',
  mediumvioletred = '#C71585',
  midnightblue = '#191970',
  mintcream = '#F5FFFA',
  mistyrose = '#FFE4E1',
  moccasin = '#FFE4B5',
  navajowhite = '#FFDEAD',
  navy = '#000080',
  oldlace = '#FDF5E6',
  olive = '#808000',
  olivedrab = '#6B8E23',
  orange = '#FFA500',
  orangered = '#FF4500',
  orchid = '#DA70D6',
  palegoldenrod = '#EEE8AA',
  palegreen = '#98FB98',
  paleturquoise = '#AFEEEE',
  palevioletred = '#DB7093',
  papayawhip = '#FFEFD5',
  peachpuff = '#FFDAB9',
  peru = '#CD853F',
  pink = '#FFC0CB',
  plum = '#DDA0DD',
  powderblue = '#B0E0E6',
  purple = '#800080',
  rebeccapurple = '#663399',
  red = '#FF0000',
  rosybrown = '#BC8F8F',
  royalblue = '#4169E1',
  saddlebrown = '#8B4513',
  salmon = '#FA8072',
  sandybrown = '#F4A460',
  seagreen = '#2E8B57',
  seashell = '#FFF5EE',
  sienna = '#A0522D',
  silver = '#C0C0C0',
  skyblue = '#87CEEB',
  slateblue = '#6A5ACD',
  slategray = '#708090',
  slategrey = '#708090',
  snow = '#FFFAFA',
  springgreen = '#00FF7F',
  steelblue = '#4682B4',
  tan = '#D2B48C',
  teal = '#008080',
  thistle = '#D8BFD8',
  tomato = '#FF6347',
  turquoise = '#40E0D0',
  violet = '#EE82EE',
  wheat = '#F5DEB3',
  white = '#FFFFFF',
  whitesmoke = '#F5F5F5',
  yellow = '#FFFF00',
  yellowgreen = '#9ACD32'
}

--- Check if a value is a CSS named colour.
--- Performs case-insensitive matching against the 148 standard CSS named colours.
--- @param value string|nil The colour value to check
--- @return boolean True if the value is a recognised CSS named colour
--- @usage local result = M.is_named_colour('rebeccapurple') -- returns true
function M.is_named_colour(value)
  if not value then return false end
  return CSS_NAMED_COLOURS[value:lower()] ~= nil
end

-- ============================================================================
-- COLOUR CONVERSION UTILITIES
-- ============================================================================

--- Expand 3-character hex colour to 6-character format.
--- @param hex string Hex colour code (either #123 or #123456 format)
--- @return string 6-character hex colour code (e.g., #123 becomes #112233)
function M.expand_hex_colour(hex)
  if string.len(hex) == 4 then
    return (string.gsub(hex, '#(%x)(%x)(%x)', '#%1%1%2%2%3%3'))
  end
  return hex
end

--- Convert RGB colour notation to HTML hex format.
--- @param rgb string RGB colour string in format "rgb(r, g, b)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function M.RGB_to_HTML(rgb)
  local r, g, b = rgb:match('rgb%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)')
  r = tonumber(r)
  g = tonumber(g)
  b = tonumber(b)
  return string.upper(string.format('#%02x%02x%02x', r, g, b))
end

--- Convert RGB percentage notation to HTML hex format.
--- @param rgb string RGB colour string in format "rgb(r%, g%, b%)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function M.RGBPercent_to_HTML(rgb)
  local r, g, b = rgb:match('rgb%((%d+)%s*%%%s*,%s*(%d+)%s*%%%s*,%s*(%d+)%s*%%%s*%)')
  r = math.floor(tonumber(r) * 255 / 100 + 0.5)
  g = math.floor(tonumber(g) * 255 / 100 + 0.5)
  b = math.floor(tonumber(b) * 255 / 100 + 0.5)
  return string.upper(string.format('#%02x%02x%02x', r, g, b))
end

--- Helper function to convert hue to RGB component.
--- @param p number
--- @param q number
--- @param t number
--- @return number RGB component value
function M.hue_to_rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1 / 6 then return p + (q - p) * 6 * t end
  if t < 1 / 2 then return q end
  if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
  return p
end

--- Convert HSL colour notation to HTML hex format.
--- @param hsl string HSL colour string in format "hsl(h, s%, l%)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function M.HSL_to_HTML(hsl)
  local h, s, l = hsl:match('hsl%((%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)')
  h = tonumber(h) / 360
  s = tonumber(s) / 100
  l = tonumber(l) / 100

  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = M.hue_to_rgb(p, q, h + 1 / 3)
    g = M.hue_to_rgb(p, q, h)
    b = M.hue_to_rgb(p, q, h - 1 / 3)
  end

  r = math.floor(r * 255 + 0.5)
  g = math.floor(g * 255 + 0.5)
  b = math.floor(b * 255 + 0.5)

  return string.upper(string.format('#%02x%02x%02x', r, g, b))
end

--- Convert HWB colour notation to HTML hex format.
--- @param hwb string HWB colour string in format "hwb(h w% b%)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function M.HWB_to_HTML(hwb)
  local h, w, b = hwb:match('hwb%((%d+)%s+(%d+)%%%s+(%d+)%%%s*%)')
  h = tonumber(h)
  w = tonumber(w) / 100
  b = tonumber(b) / 100

  local sum = w + b
  if sum > 1 then
    w = w / sum
    b = b / sum
  end

  h = h / 360

  local r, g, b_colour
  local q = 1
  local p = 0
  r = M.hue_to_rgb(p, q, h + 1 / 3)
  g = M.hue_to_rgb(p, q, h)
  b_colour = M.hue_to_rgb(p, q, h - 1 / 3)

  r = r * (1 - w - b) + w
  g = g * (1 - w - b) + w
  b_colour = b_colour * (1 - w - b) + w

  r = math.floor(r * 255 + 0.5)
  g = math.floor(g * 255 + 0.5)
  b_colour = math.floor(b_colour * 255 + 0.5)

  return string.upper(string.format('#%02x%02x%02x', r, g, b_colour))
end

--- Convert a CSS named colour to HTML hex format.
--- @param name string CSS colour name (case-insensitive)
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function M.named_to_HTML(name)
  local hex = CSS_NAMED_COLOURS[name:lower()]
  if not hex then
    error('Unknown CSS named colour: ' .. tostring(name))
  end
  return hex
end

--- Convert a colour code to HTML format based on its format type.
--- @param code string The colour code to convert
--- @param format string The colour format (e.g., "hwb", "hsl", "rgb", "rgb_percent", "hex", "named")
--- @return string HTML hex colour code
function M.to_html(code, format)
  local converters = {
    hwb = M.HWB_to_HTML,
    hsl = M.HSL_to_HTML,
    rgb = M.RGB_to_HTML,
    rgb_percent = M.RGBPercent_to_HTML,
    hex = M.expand_hex_colour,
    hex3 = M.expand_hex_colour,
    hex6 = M.expand_hex_colour,
    named = M.named_to_HTML
  }

  local converter = converters[format]
  if converter then
    return converter(code)
  else
    error('Unsupported colour format: ' .. format)
  end
end

-- ============================================================================
-- COLOUR ATTRIBUTE UTILITIES
-- ============================================================================

--- Get colour value from attributes table, accepting both British and American spellings.
--- Checks for 'colour' first (British, primary), then falls back to 'color' (American).
--- @param attrs table Attributes table (kwargs or element.attributes)
--- @param default string|nil Default value if neither spelling is found
--- @return string|nil Colour value or default
--- @usage local colour = M.get_colour(kwargs, 'info')
function M.get_colour(attrs, default)
  if attrs == nil then
    return default
  end
  local value = attrs.colour or attrs.color
  if value == nil then
    return default
  end
  local str_value = pandoc.utils.stringify(value)
  if str_value == '' then
    return default
  end
  return str_value
end

--- Check if a colour value is a custom colour (hex, rgb, hsl, hwb, etc.).
--- Used to determine whether to apply a semantic class or inline style.
--- Named CSS colours are not custom colours; they are standard/semantic values.
--- @param colour string|nil The colour value to check
--- @return boolean True if it's a custom colour value
--- @usage local is_custom = M.is_custom_colour('#ff6600') -- returns true
--- @usage local is_custom = M.is_custom_colour('red') -- returns false
function M.is_custom_colour(colour)
  if not colour then return false end
  if M.is_named_colour(colour) then return false end
  local lower = colour:lower()
  return lower:match('^#') or lower:match('^rgb') or lower:match('^hsl') or lower:match('^hwb')
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return M
