--- MC String - String manipulation and escaping for Quarto Lua filters and shortcodes
--- @module "string"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

local M = {}

-- ============================================================================
-- STRING UTILITIES
-- ============================================================================

--- Pandoc utility function for converting values to strings
--- @type function
M.stringify = pandoc.utils.stringify

--- Check if a string is empty or nil.
--- Utility function to determine if a value is empty or nil,
--- which is useful for parameter validation throughout the module.
--- @param s string|nil|table The value to check for emptiness
--- @return boolean True if the value is nil or empty, false otherwise
--- @usage local result = M.is_empty("") -- returns true
--- @usage local result = M.is_empty(nil) -- returns true
--- @usage local result = M.is_empty("hello") -- returns false
function M.is_empty(s)
  return s == nil or s == ''
end

--- Escape special pattern characters in a string for Lua pattern matching
--- @param s string The string to escape
--- @return string The escaped string
--- @usage local escaped = M.escape_pattern("user/repo#123")
function M.escape_pattern(s)
  local escaped = s:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1')
  return escaped
end

--- Split a string by a separator
--- @param str string The string to split
--- @param sep string The separator pattern
--- @return table Array of string fields
--- @usage local parts = M.split("a.b.c", ".")
function M.split(str, sep)
  local fields = {}
  local pattern = string.format('([^%s]+)', sep)
  str:gsub(pattern, function(c) fields[#fields + 1] = c end)
  return fields
end

--- Trim leading and trailing whitespace from a string
--- @param str string The string to trim
--- @return string The trimmed string
--- @usage local trimmed = M.trim("  hello world  ") -- returns "hello world"
function M.trim(str)
  if str == nil then return '' end
  return str:match('^%s*(.-)%s*$')
end

--- Convert any value to a string, handling Pandoc objects and empty values.
--- Returns nil for empty or nil values, otherwise returns a string representation.
--- @param val any The value to convert
--- @return string|nil The string value or nil if empty
--- @usage local str = M.to_string(kwargs.value)
function M.to_string(val)
  if not val then return nil end
  if type(val) == 'string' then
    return val ~= '' and val or nil
  end
  -- Handle Pandoc objects
  if pandoc and pandoc.utils and pandoc.utils.stringify then
    local str = pandoc.utils.stringify(val)
    return str ~= '' and str or nil
  end
  local str = tostring(val)
  return str ~= '' and str or nil
end

--- Strip one layer of surrounding bracket or punctuation characters.
--- Handles balanced pairs: () [] {} "" '' `` «»
--- Handles trailing-only punctuation: , . ; : ! ?
--- @param text string The input text
--- @return string prefix Characters stripped from the start (may be empty)
--- @return string inner The inner text after stripping
--- @return string suffix Characters stripped from the end (may be empty)
function M.strip_surrounding(text)
  if not text or #text < 2 then
    return '', text or '', ''
  end

  local balanced = {
    ['('] = ')', ['['] = ']', ['{'] = '}',
    ['"'] = '"', ["'"] = "'", ['`'] = '`',
  }
  -- UTF-8 guillemets
  local first_two = text:sub(1, 2)
  local last_two = text:sub(-2)
  if first_two == '\xC2\xAB' and last_two == '\xC2\xBB' then
    return first_two, text:sub(3, -3), last_two
  end

  local first = text:sub(1, 1)
  local last = text:sub(-1)

  if balanced[first] and last == balanced[first] then
    return first, text:sub(2, -2), last
  end

  local trailing = {
    [','] = true, ['.'] = true, [';'] = true,
    [':'] = true, ['!'] = true, ['?'] = true,
  }
  if trailing[last] then
    return '', text:sub(1, -2), last
  end

  return '', text, ''
end

--- Peel unbalanced surrounding brackets and trailing punctuation from a token.
--- Unlike `strip_surrounding`, this does not require a balanced pair: it removes
--- any run of leading opening-bracket characters and any run of trailing
--- closing-bracket or punctuation characters. This handles bracket groups that
--- Pandoc split across whitespace, e.g. "(#2," and "#3)" from "(#2, #3)".
--- Leading set: ( [ { " ' ` and the 2-byte UTF-8 « (\xC2\xAB).
--- Trailing set: ) ] } " ' ` , . ; : ! ? and the 2-byte UTF-8 » (\xC2\xBB).
--- @param text string The input text
--- @return string prefix Characters peeled from the start (may be empty)
--- @return string inner The inner text after peeling
--- @return string suffix Characters peeled from the end (may be empty)
function M.strip_edges(text)
  if not text or text == '' then
    return '', text or '', ''
  end

  local leading = {
    ['('] = true, ['['] = true, ['{'] = true,
    ['"'] = true, ["'"] = true, ['`'] = true,
  }
  local trailing = {
    [')'] = true, [']'] = true, ['}'] = true,
    ['"'] = true, ["'"] = true, ['`'] = true,
    [','] = true, ['.'] = true, [';'] = true,
    [':'] = true, ['!'] = true, ['?'] = true,
  }

  local first = 1
  local last = #text
  local prefix = ''
  local suffix = ''

  while first <= last do
    if text:sub(first, first + 1) == '\xC2\xAB' then
      prefix = prefix .. '\xC2\xAB'
      first = first + 2
    elseif leading[text:sub(first, first)] then
      prefix = prefix .. text:sub(first, first)
      first = first + 1
    else
      break
    end
  end

  while last >= first do
    -- The two-byte window can only match a real «/» pair: the leading loop
    -- never leaves \xC2 at first - 1 (openers are ASCII or the \xAB of a peeled
    -- «), so the guillemet check cannot straddle the already-peeled prefix.
    if last >= 2 and text:sub(last - 1, last) == '\xC2\xBB' then
      suffix = '\xC2\xBB' .. suffix
      last = last - 2
    elseif trailing[text:sub(last, last)] then
      suffix = text:sub(last, last) .. suffix
      last = last - 1
    else
      break
    end
  end

  return prefix, text:sub(first, last), suffix
end

--- Find a balanced bracket pair anywhere in the text and split around it.
--- Walks the text from `start_pos` looking for an opening bracket whose matching
--- closing bracket appears later in the string. Returns the text split into
--- a prefix (up to and including the opening bracket), the inner content, and
--- a suffix (closing bracket and everything after).
--- Supports the same bracket pairs as `strip_surrounding`:
--- () [] {} "" '' `` and the 2-byte UTF-8 guillemets «».
--- @param text string The input text
--- @param start_pos integer|nil Byte position to start searching from (default 1)
--- @return string|nil prefix Text up to and including the opening bracket
--- @return string|nil content Non-empty text between the brackets
--- @return string|nil suffix Closing bracket and trailing text
--- @return integer|nil open_pos Byte position of the opening bracket
function M.find_bracketed_content(text, start_pos)
  if not text or #text < 2 then
    return nil, nil, nil, nil
  end
  start_pos = start_pos or 1

  local balanced = {
    ['('] = ')', ['['] = ']', ['{'] = '}',
    ['"'] = '"', ["'"] = "'", ['`'] = '`',
  }

  local i = start_pos
  while i <= #text do
    -- UTF-8 guillemet «…»
    if text:sub(i, i + 1) == '\xC2\xAB' then
      local close_pos = text:find('\xC2\xBB', i + 2, true)
      if close_pos and close_pos > i + 2 then
        return text:sub(1, i + 1), text:sub(i + 2, close_pos - 1), text:sub(close_pos), i
      end
      i = i + 2
    else
      local c = text:sub(i, i)
      local close_char = balanced[c]
      if close_char then
        local close_pos = text:find(close_char, i + 1, true)
        if close_pos and close_pos > i + 1 then
          return text:sub(1, i), text:sub(i + 1, close_pos - 1), text:sub(close_pos), i
        end
      end
      i = i + 1
    end
  end

  return nil, nil, nil, nil
end

-- ============================================================================
-- ESCAPE UTILITIES
-- ============================================================================

--- Escape special LaTeX characters in text.
--- @param text string The text to escape
--- @return string The escaped text safe for LaTeX
function M.escape_latex(text)
  text = string.gsub(text, '\\', '\\textbackslash{}')
  text = string.gsub(text, '%{', '\\{')
  text = string.gsub(text, '%}', '\\}')
  text = string.gsub(text, '%$', '\\$')
  text = string.gsub(text, '%&', '\\&')
  text = string.gsub(text, '%%', '\\%%')
  text = string.gsub(text, '%#', '\\#')
  text = string.gsub(text, '%^', '\\textasciicircum{}')
  text = string.gsub(text, '%_', '\\_')
  text = string.gsub(text, '~', '\\textasciitilde{}')
  return text
end

--- Escape special Typst characters in text.
--- @param text string The text to escape
--- @return string The escaped text safe for Typst
function M.escape_typst(text)
  text = string.gsub(text, '%#', '\\#')
  return text
end

--- Escape characters for Typst string literals (inside `"..."`).
--- Handles backslash, double quote, newline, carriage return, and tab.
--- @param text string The text to escape
--- @return string The escaped text safe for Typst string literals
function M.escape_typst_string(text)
  return (text
    :gsub('\\', '\\\\')
    :gsub('"', '\\"')
    :gsub('\n', '\\n')
    :gsub('\r', '\\r')
    :gsub('\t', '\\t'))
end

--- Escape characters for JavaScript string literals (inside `"..."` or `'...'`).
--- Handles backslash, both quote styles, newlines, carriage returns, tabs,
--- form feeds, and the `</` sequence so payloads cannot break out of a
--- surrounding inline `<script>` block.
--- @param text string|nil The text to escape
--- @return string The escaped text safe for JavaScript string literals
--- @usage local safe = M.escape_js_string([[a "b" </script>]])
function M.escape_js_string(text)
  if text == nil then return '' end
  if type(text) ~= 'string' then text = tostring(text) end
  return (text
    :gsub('\\', '\\\\')
    :gsub('"', '\\"')
    :gsub("'", "\\'")
    :gsub('\n', '\\n')
    :gsub('\r', '\\r')
    :gsub('\t', '\\t')
    :gsub('\f', '\\f')
    :gsub('</', '<\\/'))
end

--- Escape special Lua pattern characters for use in string.gsub.
--- @param text string The text containing characters to escape
--- @return string The escaped text safe for Lua patterns
function M.escape_lua_pattern(text)
  text = string.gsub(text, '%%', '%%%%')
  text = string.gsub(text, '%^', '%%^')
  text = string.gsub(text, '%$', '%%$')
  text = string.gsub(text, '%(', '%%(')
  text = string.gsub(text, '%)', '%%)')
  text = string.gsub(text, '%.', '%%.')
  text = string.gsub(text, '%[', '%%[')
  text = string.gsub(text, '%]', '%%]')
  text = string.gsub(text, '%*', '%%*')
  text = string.gsub(text, '%+', '%%+')
  text = string.gsub(text, '%-', '%%-')
  text = string.gsub(text, '%?', '%%?')
  return text
end

--- Escape special HTML characters in text.
--- Escapes &, <, >, ", and ' to prevent XSS and ensure valid HTML.
--- @param text string The text to escape
--- @return string Escaped text safe for use in HTML
--- @usage local escaped = M.escape_html('Hello <World>')
function M.escape_html(text)
  if text == nil then return '' end
  if type(text) ~= 'string' then text = tostring(text) end
  local result = text
      :gsub('&', '&amp;')
      :gsub('<', '&lt;')
      :gsub('>', '&gt;')
      :gsub('"', '&quot;')
      :gsub("'", '&#39;')
  return result
end

--- Escape special HTML attribute characters.
--- Escapes characters that could break attribute values.
--- @param value string The attribute value to escape
--- @return string Escaped value safe for use in HTML attributes
--- @usage local escaped = M.escape_attribute('Hello "World"')
function M.escape_attribute(value)
  if value == nil then return '' end
  if type(value) ~= 'string' then value = tostring(value) end
  local result = value
      :gsub('&', '&amp;')
      :gsub('"', '&quot;')
      :gsub('<', '&lt;')
      :gsub('>', '&gt;')
  return result
end

--- Escape text for different formats.
--- @param text string The text to escape
--- @param format string The format to escape for (e.g., "latex", "typst", "lua")
--- @return string The escaped text
function M.escape_text(text, format)
  local escape_functions = {
    latex = M.escape_latex,
    typst = M.escape_typst,
    lua = M.escape_lua_pattern
  }

  local escape = escape_functions[format]
  if escape then
    return escape(text)
  else
    error('Unsupported escape format: ' .. format)
  end
end

--- Converts a string to a valid HTML id by lowercasing and replacing spaces.
--- @param text string The text to convert
--- @return string The HTML id
function M.ascii_id(text)
  local id = text:lower():gsub('[^a-z0-9 ]', ''):gsub(' +', '-')
  return id
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return M
