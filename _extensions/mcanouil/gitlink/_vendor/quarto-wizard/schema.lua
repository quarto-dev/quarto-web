--- MC Schema - Reference validator for Quarto extension schemas (`_schema.yml`)
--- @module "schema"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @version 2.2.0
---
--- Implements the v2 extension schema vocabulary published at
--- <https://m.canouil.dev/quarto-wizard/assets/schema/v2/extension-schema.json>.
--- The v1 dual-key vocabulary (`min`, `max`, `enum-case-insensitive`,
--- `element-attributes`, `pattern-exact`) is not accepted.
---
--- The module is standalone: it requires no sibling module, and it reaches
--- `pandoc` and `quarto` only through the `M._env` table, so it can be
--- exercised outside a Quarto render with stubs in place.

local M = {}

--- Meta-schema this module implements.
M.SCHEMA_VERSION = 'https://m.canouil.dev/quarto-wizard/assets/schema/v2/extension-schema.json'

-- ============================================================================
-- ENVIRONMENT SEAM
-- ============================================================================

--- Indirection over the two host globals, resolved at call time so a test
--- harness can install stubs before the first call.
local _env = {}

--- Render a Pandoc value as plain text.
--- @param value any Pandoc value
--- @return string Plain text
function _env.stringify(value)
  return pandoc.utils.stringify(value)
end

--- Report the Pandoc type of a value.
--- @param value any Pandoc value
--- @return string Pandoc type name
function _env.pandoc_type(value)
  return pandoc.utils.type(value)
end

--- Emit a warning through the host logger.
--- @param message string Message to emit
--- @return nil
function _env.warn(message)
  if quarto and quarto.log and quarto.log.warning then
    quarto.log.warning(message)
  else
    io.stderr:write(message .. '\n')
  end
end

--- Emit an error through the host logger.
--- @param message string Message to emit
--- @return nil
function _env.report_error(message)
  if quarto and quarto.log and quarto.log.error then
    quarto.log.error(message)
  else
    io.stderr:write(message .. '\n')
  end
end

M._env = _env

-- ============================================================================
-- CONSTANTS
-- ============================================================================

--- Maximum nesting depth accepted when converting a parsed schema.
local MAX_DEPTH = 16

--- Maximum number of Lua patterns one regex may expand into.
local MAX_PATTERN_BRANCHES = 64

--- Descriptor keywords holding a numeric bound.
local NUMERIC_KEYWORDS = {
  'minimum', 'maximum', 'exclusiveMinimum', 'exclusiveMaximum', 'multipleOf',
  'minLength', 'maxLength', 'minItems', 'maxItems',
}

--- Every keyword the v2 field descriptor may carry, mapped to whether this
--- module enforces it. Annotations are carried through untouched for tooling.
M.KEYWORDS = {
  type = true,
  required = true,
  default = true,
  const = true,
  enum = true,
  enumCaseInsensitive = true,
  pattern = true,
  minimum = true,
  maximum = true,
  exclusiveMinimum = true,
  exclusiveMaximum = true,
  multipleOf = true,
  minLength = true,
  maxLength = true,
  minItems = true,
  maxItems = true,
  uniqueItems = true,
  items = true,
  properties = true,
  additionalProperties = true,
  propertyNames = true,
  dependentRequired = true,
  aliases = true,
  deprecated = true,
  name = true,
  description = false,
  title = false,
  examples = false,
  format = false,
  completion = false,
  contentEncoding = false,
  contentMediaType = false,
}

-- ============================================================================
-- PRIVATE HELPERS
-- ============================================================================

--- Report whether a table is a dense array.
--- @param value any Value to inspect
--- @return boolean True when the table has only keys 1..n
local function _is_array(value)
  if type(value) ~= 'table' then
    return false
  end
  local count = 0
  for _ in pairs(value) do
    count = count + 1
  end
  return count == #value
end

--- Read a key from a map, accepting the hyphen and underscore spellings.
--- Keys are never rewritten, so a schema keeps the names its author wrote.
--- @param map table|nil Map to read
--- @param key string|nil Key to read
--- @return any value The stored value, or nil
--- @return string|nil found_key The spelling that matched
local function _lookup(map, key)
  if type(map) ~= 'table' or type(key) ~= 'string' then
    return nil, nil
  end
  if map[key] ~= nil then
    return map[key], key
  end
  local underscored = (key:gsub('%-', '_'))
  if underscored ~= key and map[underscored] ~= nil then
    return map[underscored], underscored
  end
  local hyphenated = (key:gsub('_', '-'))
  if hyphenated ~= key and map[hyphenated] ~= nil then
    return map[hyphenated], hyphenated
  end
  return nil, nil
end

--- Render any value for an error message, including mixed-type arrays.
--- Replaces `table.concat`, which throws on a boolean entry.
--- @param value any Value to render
--- @return string Readable representation
local function _format_value(value)
  local kind = type(value)
  if kind == 'string' then
    if value == '' then
      return '""'
    end
    return value
  elseif kind == 'number' or kind == 'boolean' then
    return tostring(value)
  elseif kind == 'nil' then
    return 'null'
  elseif kind == 'table' then
    if _is_array(value) then
      local parts = {}
      for index = 1, #value do
        parts[index] = _format_value(value[index])
      end
      return '[' .. table.concat(parts, ', ') .. ']'
    end
    return '{object}'
  end
  return tostring(value)
end

--- Render a list of values as a comma-separated string.
--- @param values table Array of values
--- @return string Readable list
local function _format_list(values)
  local parts = {}
  for index = 1, #values do
    parts[index] = _format_value(values[index])
  end
  return table.concat(parts, ', ')
end

--- Normalise a type spec to an array of type names.
--- @param type_spec string|table|nil Declared type
--- @return table|nil Array of type names, or nil when no type is declared
local function _type_names(type_spec)
  if type_spec == nil then
    return nil
  end
  if type(type_spec) == 'table' then
    return type_spec
  end
  return { type_spec }
end

--- Render a type spec for an error message.
--- @param type_spec string|table Declared type
--- @return string Readable type
local function _format_type(type_spec)
  if type(type_spec) == 'table' then
    return table.concat(type_spec, ' | ')
  end
  return tostring(type_spec)
end

--- Report the type name of a value, distinguishing arrays from objects.
--- @param value any Value to inspect
--- @return string Type name
local function _actual_type(value)
  local kind = type(value)
  if kind == 'table' then
    return _is_array(value) and 'array' or 'object'
  end
  if kind == 'nil' then
    return 'null'
  end
  return kind
end

--- Report whether a value satisfies a single type name.
--- @param value any Value to check
--- @param name string Type name
--- @return boolean True when the value matches
local function _matches_type(value, name)
  if name == 'content' then
    return value ~= nil
  end
  if name == 'null' then
    return value == nil
  end
  if name == 'integer' then
    return type(value) == 'number'
      and value == value
      and value ~= math.huge
      and value ~= -math.huge
      and value == math.floor(value)
  end
  if name == 'number' then
    return type(value) == 'number'
  end
  if name == 'boolean' then
    return type(value) == 'boolean'
  end
  if name == 'string' then
    return type(value) == 'string'
  end
  if name == 'array' then
    return type(value) == 'table' and _is_array(value)
  end
  if name == 'object' then
    -- An array is not an object. An empty table is both, and Lua cannot tell
    -- the two apart, so it satisfies either.
    return type(value) == 'table' and (next(value) == nil or not _is_array(value))
  end
  return false
end

--- Report whether a value satisfies any declared type.
--- @param value any Value to check
--- @param type_spec string|table|nil Declared type
--- @return boolean True when the value matches, or no type is declared
local function _matches_type_spec(value, type_spec)
  local names = _type_names(type_spec)
  if names == nil then
    return true
  end
  for _, name in ipairs(names) do
    if _matches_type(value, name) then
      return true
    end
  end
  return false
end

--- Coerce a string toward a single scalar type.
--- Pandoc renders every YAML number as a string, so the incoming value and
--- the schema's own literals both need this before any comparison.
--- @param value any Value to coerce
--- @param name string Target type name
--- @return any coerced Coerced value, or nil
--- @return boolean ok True when the coercion applied
local function _coerce_scalar(value, name)
  if type(value) ~= 'string' then
    return nil, false
  end
  if name == 'number' then
    local number = tonumber(value)
    if number then
      return number, true
    end
  elseif name == 'integer' then
    local number = tonumber(value)
    if number and number == math.floor(number) then
      return number, true
    end
  elseif name == 'boolean' then
    -- Only `true` and `false`, which is what YAML 1.2 calls a boolean and what
    -- Pandoc reads. `yes` and `no` are booleans in YAML 1.1 alone, and Pandoc
    -- hands them over as strings, so accepting them here made this validator
    -- disagree with the YAML the documents are written in.
    --
    -- The coercion is still needed for the words that do name a boolean,
    -- because an attribute and a shortcode argument always arrive as strings.
    local lowered = value:lower()
    if lowered == 'true' then
      return true, true
    end
    if lowered == 'false' then
      return false, true
    end
  end
  return nil, false
end

--- Coerce a value toward its declared type.
--- A value already matching one declared type is returned untouched, so
--- `type: [boolean, string]` keeps the string "fenced" a string.
--- @param value any Value to coerce
--- @param type_spec string|table|nil Declared type
--- @return any Coerced value
local function _coerce(value, type_spec)
  local names = _type_names(type_spec)
  if names == nil or value == nil then
    return value
  end
  for _, name in ipairs(names) do
    if _matches_type(value, name) then
      return value
    end
  end
  for _, name in ipairs(names) do
    local coerced, ok = _coerce_scalar(value, name)
    if ok then
      return coerced
    end
  end
  return value
end

-- ============================================================================
-- PATTERN COMPILATION
-- ============================================================================

--- Lua replacements for JS shorthand classes, outside a character class.
local ESCAPE_OUTSIDE = {
  d = '%d', D = '%D', w = '[%w_]', W = '[^%w_]', s = '%s', S = '%S',
}

--- Lua replacements for JS shorthand classes, inside a character class.
--- `\W` has no in-class form, because the underscore cannot be excluded there.
local ESCAPE_INSIDE = {
  d = '%d', D = '%D', w = '%w_', s = '%s', S = '%S',
}

--- Escapes with a real Lua equivalent. Anything else alphanumeric is refused,
--- because compiling it to the bare letter would accept the wrong values.
local CONTROL_ESCAPES = {
  n = '\n',
  t = '\t',
  r = '\r',
  f = '\f',
  v = '\v',
}

--- Characters Lua treats as magic outside a character class.
local LUA_MAGIC = '^$()%.[]*+-?'

--- Escape one literal character for use in a Lua pattern.
--- @param char string Single character
--- @return string Escaped character
local function _escape_literal(char)
  if LUA_MAGIC:find(char, 1, true) then
    return '%' .. char
  end
  return char
end

--- Compile a JS regular expression into a list of equivalent Lua patterns.
--- Alternation is expanded into one pattern per branch, which is how Lua,
--- lacking alternation, can honour the commonest JSON Schema idiom.
--- Anything that cannot be expressed is reported rather than accepted.
--- @param regex string JS regular expression
--- @return table|nil branches Array of Lua patterns, or nil on failure
--- @return string|nil reason Why compilation failed
local function _compile_pattern(regex)
  local position = 1
  local length = #regex
  local anchor_start = false
  local anchor_end = false
  local has_top_level_alternation = false
  local parse_alternation

  --- Combine a set of prefixes with a set of continuations.
  local function cross(prefixes, continuations)
    local out = {}
    for _, prefix in ipairs(prefixes) do
      for _, continuation in ipairs(continuations) do
        if #out >= MAX_PATTERN_BRANCHES then
          return nil, 'alternation expands past ' .. MAX_PATTERN_BRANCHES .. ' branches'
        end
        out[#out + 1] = prefix .. continuation
      end
    end
    return out
  end

  --- Parse a bracketed character class starting at the current position.
  local function parse_class()
    local out = { '[' }
    position = position + 1
    if regex:sub(position, position) == '^' then
      out[#out + 1] = '^'
      position = position + 1
    end
    if regex:sub(position, position) == ']' then
      out[#out + 1] = '%]'
      position = position + 1
    end
    while position <= length do
      local char = regex:sub(position, position)
      if char == ']' then
        position = position + 1
        out[#out + 1] = ']'
        return table.concat(out)
      elseif char == '\\' then
        local next_char = regex:sub(position + 1, position + 1)
        if next_char == '' then
          return nil, 'trailing backslash'
        end
        if next_char == 'W' then
          return nil, 'unsupported "\\W" inside a character class'
        end
        local mapped = ESCAPE_INSIDE[next_char]
        if mapped then
          out[#out + 1] = mapped
        elseif next_char:match('[1-9]') then
          return nil, 'unsupported backreference "\\' .. next_char .. '"'
        elseif next_char == '%' then
          out[#out + 1] = '%%'
        elseif CONTROL_ESCAPES[next_char] then
          out[#out + 1] = CONTROL_ESCAPES[next_char]
        elseif next_char:match('%w') then
          return nil, 'unsupported escape "\\' .. next_char .. '"'
        else
          out[#out + 1] = '%' .. next_char
        end
        position = position + 2
      elseif char == '%' then
        out[#out + 1] = '%%'
        position = position + 1
      else
        out[#out + 1] = char
        position = position + 1
      end
    end
    return nil, 'unterminated character class'
  end

  --- Read a trailing quantifier, rejecting the forms Lua cannot express.
  local function parse_quantifier()
    local char = regex:sub(position, position)
    if char ~= '*' and char ~= '+' and char ~= '?' then
      return ''
    end
    if regex:sub(position + 1, position + 1) == '?' then
      return nil, 'unsupported non-greedy quantifier "' .. char .. '?"'
    end
    position = position + 1
    return char
  end

  --- Parse a single atom and return the branches it contributes.
  local function parse_atom(depth, at_sequence_start)
    local char = regex:sub(position, position)

    if char == '(' then
      if regex:sub(position + 1, position + 1) == '?' then
        local marker = regex:sub(position + 2, position + 2)
        if marker == '=' or marker == '!' or marker == '<' then
          return nil, 'unsupported lookahead or lookbehind'
        end
        if marker ~= ':' then
          return nil, 'unsupported group modifier "(?' .. marker .. '"'
        end
        position = position + 3
      else
        position = position + 1
      end
      local branches, reason = parse_alternation(depth + 1)
      if not branches then
        return nil, reason
      end
      if regex:sub(position, position) ~= ')' then
        return nil, 'unterminated group'
      end
      position = position + 1
      local quantifier = regex:sub(position, position)
      if quantifier == '*' or quantifier == '+' or quantifier == '?' then
        return nil, 'unsupported quantifier applied to a group'
      end
      return branches
    end

    if char == '[' then
      local class, reason = parse_class()
      if not class then
        return nil, reason
      end
      local quantifier, quantifier_reason = parse_quantifier()
      if not quantifier then
        return nil, quantifier_reason
      end
      return { class .. quantifier }
    end

    if char == '\\' then
      local next_char = regex:sub(position + 1, position + 1)
      if next_char == '' then
        return nil, 'trailing backslash'
      end
      if next_char:match('[1-9]') then
        return nil, 'unsupported backreference "\\' .. next_char .. '"'
      end
      position = position + 2
      local mapped = ESCAPE_OUTSIDE[next_char]
      local atom
      if mapped then
        atom = mapped
      elseif CONTROL_ESCAPES[next_char] then
        atom = CONTROL_ESCAPES[next_char]
      elseif next_char:match('%w') then
        return nil, 'unsupported escape "\\' .. next_char .. '"'
      else
        atom = _escape_literal(next_char)
      end
      local quantifier, quantifier_reason = parse_quantifier()
      if not quantifier then
        return nil, quantifier_reason
      end
      return { atom .. quantifier }
    end

    if char == '^' then
      if depth ~= 0 or not at_sequence_start or position ~= 1 then
        return nil, 'unsupported anchor "^" away from the start of the pattern'
      end
      position = position + 1
      anchor_start = true
      return { '' }
    end

    if char == '$' then
      if depth ~= 0 or position ~= length then
        return nil, 'unsupported anchor "$" away from the end of the pattern'
      end
      position = position + 1
      anchor_end = true
      return { '' }
    end

    if char == '{' then
      return nil, 'unsupported counted quantifier "{n,m}"'
    end

    if char == '*' or char == '+' or char == '?' then
      return nil, 'quantifier "' .. char .. '" with nothing to repeat'
    end

    if char == '.' then
      position = position + 1
      local quantifier, quantifier_reason = parse_quantifier()
      if not quantifier then
        return nil, quantifier_reason
      end
      return { '.' .. quantifier }
    end

    position = position + 1
    local atom = _escape_literal(char)
    local quantifier, quantifier_reason = parse_quantifier()
    if not quantifier then
      return nil, quantifier_reason
    end
    return { atom .. quantifier }
  end

  --- Parse one alternative: a run of atoms up to `|`, `)` or the end.
  local function parse_sequence(depth)
    local branches = { '' }
    local first = true
    while position <= length do
      local char = regex:sub(position, position)
      if char == '|' or char == ')' then
        break
      end
      local atom_branches, reason = parse_atom(depth, first)
      if not atom_branches then
        return nil, reason
      end
      first = false
      local crossed, cross_reason = cross(branches, atom_branches)
      if not crossed then
        return nil, cross_reason
      end
      branches = crossed
    end
    return branches
  end

  parse_alternation = function(depth)
    local all = {}
    local iterations = 0
    while true do
      iterations = iterations + 1
      local branches, reason = parse_sequence(depth)
      if not branches then
        return nil, reason
      end
      for _, branch in ipairs(branches) do
        if #all >= MAX_PATTERN_BRANCHES then
          return nil, 'alternation expands past ' .. MAX_PATTERN_BRANCHES .. ' branches'
        end
        all[#all + 1] = branch
      end
      if regex:sub(position, position) == '|' then
        position = position + 1
      else
        break
      end
    end
    if depth == 0 and iterations > 1 then
      has_top_level_alternation = true
    end
    return all
  end

  local branches, reason = parse_alternation(0)
  if not branches then
    return nil, reason
  end
  if position <= length then
    return nil, 'unbalanced ")" in pattern'
  end

  -- The anchors are collected for the expression as a whole, so applying them
  -- to multiple top-level branches would anchor branches the author did not anchor.
  if has_top_level_alternation and (anchor_start or anchor_end) then
    return nil, 'unsupported anchor in a top-level alternation'
  end

  local prefix = anchor_start and '^' or ''
  local suffix = anchor_end and '$' or ''
  local out = {}
  for index, branch in ipairs(branches) do
    out[index] = prefix .. branch .. suffix
  end
  return out
end

M._compile_pattern = _compile_pattern

--- Report whether a string satisfies any compiled branch.
--- @param value string Value to test
--- @param branches table Array of Lua patterns
--- @return boolean True when a branch matches
local function _pattern_matches(value, branches)
  for _, branch in ipairs(branches) do
    local ok, matched = pcall(string.match, value, branch)
    if ok and matched ~= nil then
      return true
    end
  end
  return false
end

-- ============================================================================
-- PANDOC VALUE CONVERSION
-- ============================================================================

--- Convert a Pandoc metadata value to a native Lua value.
--- Pandoc's Lua objects carry no `t` field, so the kind has to come from
--- `pandoc.utils.type`; testing `value.t` silently turns every string option
--- into a list of its inline elements.
--- @param value any Pandoc metadata value
--- @return any Native Lua value
local function _convert_pandoc_value(value)
  local kind = _env.pandoc_type(value)

  -- A bare key, `null` and `~` all arrive as an empty Pandoc `string`, which
  -- is how Pandoc collapses YAML null. An explicit `""` arrives as an empty
  -- `Inlines` instead, so the two are told apart before either is unwrapped.
  if kind == 'string' and value == '' then
    return nil
  end

  if type(value) ~= 'table' then
    return value
  end

  if kind == 'Inlines' or kind == 'Blocks' or kind == 'Inline' or kind == 'Block' then
    return _env.stringify(value)
  end

  if kind == 'List' then
    -- A null element is absent, the same rule this module applies to a null
    -- key. Writing it into a running count rather than the source index
    -- keeps the result a proper sequence instead of leaving a gap.
    local result = {}
    for index = 1, #value do
      local converted = _convert_pandoc_value(value[index])
      if converted ~= nil then
        result[#result + 1] = converted
      end
    end
    return result
  end

  if _is_array(value) and #value > 0 then
    -- A null element is absent, the same rule this module applies to a null
    -- key. Writing it into a running count rather than the source index
    -- keeps the result a proper sequence instead of leaving a gap.
    local result = {}
    for index = 1, #value do
      local converted = _convert_pandoc_value(value[index])
      if converted ~= nil then
        result[#result + 1] = converted
      end
    end
    return result
  end

  local result = {}
  for key, item in pairs(value) do
    result[tostring(key)] = _convert_pandoc_value(item)
  end
  return result
end

-- ============================================================================
-- YAML PARSING
-- ============================================================================

--- Pandoc parses YAML string scalars as Markdown, which rewrites a schema in
--- place: `^[a-z]+$` arrives as `+$`, and `^\d+\.?\d*m?s$` arrives as
--- `^.??s$`. The schema file is therefore parsed here instead.
---
--- The subset covers what an extension schema needs: block maps and
--- sequences, plain and quoted scalars, folded and literal block scalars,
--- flow sequences and flow maps (including ones spanning several lines), and
--- `#` comments. Anchors, aliases, tags, multiple documents and complex keys
--- are not supported and are reported rather than misread.
---
--- Every function here reports a failure by returning a message rather than
--- by calling `error`. Quarto replaces `error` with a logger that returns
--- instead of unwinding, so a module that trusts `error` to stop execution
--- carries on with invalid state and fails later somewhere unrelated.
---
--- One deliberate deviation from YAML: a block scalar is always stripped of
--- its trailing newline unless it is chomped with `+`. Schema text is
--- annotation, and a trailing newline there is noise rather than meaning.

--- Build a parse error message carrying the offending line number.
--- @param line_number number Line number
--- @param message string Explanation
--- @return string Formatted message
local function _yaml_error(line_number, message)
  return string.format('line %d: %s', line_number, message)
end

--- Remove a trailing `#` comment, respecting quoted spans.
--- @param text string Line content
--- @return string Content without its comment
local function _strip_comment(text)
  local out = {}
  local quote = nil
  local index = 1
  while index <= #text do
    local char = text:sub(index, index)
    if quote then
      out[#out + 1] = char
      if char == '\\' and quote == '"' then
        index = index + 1
        out[#out + 1] = text:sub(index, index)
      elseif char == quote then
        quote = nil
      end
    elseif char == '"' or char == "'" then
      quote = char
      out[#out + 1] = char
    elseif char == '#' and (index == 1 or text:sub(index - 1, index - 1):match('%s')) then
      break
    else
      out[#out + 1] = char
    end
    index = index + 1
  end
  return (table.concat(out):gsub('%s+$', ''))
end

--- Trim leading and trailing whitespace.
--- @param text string Text to trim
--- @return string Trimmed text
local function _trim(text)
  return (text:gsub('^%s+', ''):gsub('%s+$', ''))
end

--- Parse a scalar, giving numbers and booleans their real Lua types.
--- @param text string Scalar text
--- @param line_number number Line number for errors
--- @return any value Parsed value, nil for an explicit null
--- @return string|nil err
local function _parse_scalar(text, line_number)
  text = _trim(text)

  if text == '' or text == '~' or text == 'null' or text == 'Null' or text == 'NULL' then
    return nil, nil
  end

  local first = text:sub(1, 1)

  if first == '"' then
    if #text < 2 or text:sub(-1) ~= '"' then
      return nil, _yaml_error(line_number, 'unterminated double-quoted scalar')
    end
    return (text:sub(2, -2):gsub('\\(.)', function(escaped)
      if escaped == 'n' then return '\n' end
      if escaped == 't' then return '\t' end
      if escaped == 'r' then return '\r' end
      return escaped
    end)), nil
  end

  if first == "'" then
    if #text < 2 or text:sub(-1) ~= "'" then
      return nil, _yaml_error(line_number, 'unterminated single-quoted scalar')
    end
    return (text:sub(2, -2):gsub("''", "'")), nil
  end

  if first == '&' or first == '*' or first == '!' then
    return nil, _yaml_error(line_number, 'anchors, aliases and tags are not supported')
  end

  if text == 'true' or text == 'True' or text == 'TRUE' or text == 'yes' or text == 'Yes' then
    return true, nil
  end
  if text == 'false' or text == 'False' or text == 'FALSE' or text == 'no' or text == 'No' then
    return false, nil
  end

  local number = tonumber(text)
  if number ~= nil and text:match('^[%-+]?[%d%.eE%+%-]+$') then
    return number, nil
  end

  return text, nil
end

--- Split a flow collection body on its top-level commas.
--- @param body string Text between the brackets
--- @return table Array of raw item strings
local function _split_flow(body)
  local items = {}
  local depth = 0
  local quote = nil
  local start = 1
  local index = 1
  while index <= #body do
    local char = body:sub(index, index)
    if quote then
      if char == '\\' and quote == '"' then
        index = index + 1
      elseif char == quote then
        quote = nil
      end
    elseif char == '"' or char == "'" then
      quote = char
    elseif char == '[' or char == '{' then
      depth = depth + 1
    elseif char == ']' or char == '}' then
      depth = depth - 1
    elseif char == ',' and depth == 0 then
      items[#items + 1] = body:sub(start, index - 1)
      start = index + 1
    end
    index = index + 1
  end
  local tail = body:sub(start)
  if tail:match('%S') then
    items[#items + 1] = tail
  end
  return items
end

--- Strip the quotes from a mapping key.
--- @param key string Raw key text
--- @param line_number number Line number for errors
--- @return string|nil key
--- @return string|nil err
local function _unquote_key(key, line_number)
  key = _trim(key)
  local first = key:sub(1, 1)
  if first == '"' or first == "'" then
    local parsed, err = _parse_scalar(key, line_number)
    if err then
      return nil, err
    end
    return tostring(parsed), nil
  end
  return key, nil
end

local _parse_flow

--- Parse a value written in flow style, or a plain scalar.
--- @param text string Value text
--- @param line_number number Line number for errors
--- @param depth number|nil Current nesting depth
--- @return any value
--- @return string|nil err
_parse_flow = function(text, line_number, depth)
  depth = depth or 0
  if depth > MAX_DEPTH then
    return nil, _yaml_error(line_number, 'value nests deeper than ' .. MAX_DEPTH .. ' levels')
  end

  text = _trim(text)
  local first = text:sub(1, 1)

  if first == '[' then
    if text:sub(-1) ~= ']' then
      return nil, _yaml_error(line_number, 'unterminated flow sequence')
    end
    local out = {}
    for index, item in ipairs(_split_flow(text:sub(2, -2))) do
      local value, err = _parse_flow(item, line_number, depth + 1)
      if err then
        return nil, err
      end
      out[index] = value
    end
    return out, nil
  end

  if first == '{' then
    if text:sub(-1) ~= '}' then
      return nil, _yaml_error(line_number, 'unterminated flow mapping')
    end
    local out = {}
    for _, item in ipairs(_split_flow(text:sub(2, -2))) do
      local key, rest = item:match('^%s*(.-)%s*:%s*(.*)$')
      if not key or key == '' then
        return nil, _yaml_error(line_number, 'expected "key: value" inside a flow mapping')
      end
      local name, key_err = _unquote_key(key, line_number)
      if key_err then
        return nil, key_err
      end
      local value, err = _parse_flow(rest, line_number, depth + 1)
      if err then
        return nil, err
      end
      out[name] = value
    end
    return out, nil
  end

  return _parse_scalar(text, line_number)
end

--- Split a mapping line into its key and the rest of the line.
--- The separator is the first unquoted colon followed by a space or the end
--- of the line, so a URL value such as `https://...` is not split.
--- @param text string Line content
--- @return string|nil key
--- @return string|nil rest
local function _split_key(text)
  local quote = nil
  local index = 1
  while index <= #text do
    local char = text:sub(index, index)
    if quote then
      if char == '\\' and quote == '"' then
        index = index + 1
      elseif char == quote then
        quote = nil
      end
    elseif char == '"' or char == "'" then
      quote = char
    elseif char == ':' then
      local following = text:sub(index + 1, index + 1)
      if following == '' or following == ' ' then
        return text:sub(1, index - 1), _trim(text:sub(index + 2))
      end
    end
    index = index + 1
  end
  return nil, nil
end

--- Break the source into classified lines.
--- @param source string YAML text
--- @return table|nil lines Array of {raw, indent, number, blank, comment}
--- @return string|nil err
local function _scan_lines(source)
  local lines = {}
  local number = 0
  for raw in (source .. '\n'):gmatch('([^\n]*)\n') do
    number = number + 1
    if raw:find('\t') then
      return nil, _yaml_error(number, 'tabs are not valid YAML indentation')
    end
    local indent = #(raw:match('^ *') or '')
    local body = raw:sub(indent + 1)
    lines[#lines + 1] = {
      raw = raw,
      indent = indent,
      number = number,
      blank = body == '',
      comment = body:sub(1, 1) == '#',
    }
  end
  return lines, nil
end

--- Advance past blank and comment lines.
--- @param lines table Scanned lines
--- @param index number Starting index
--- @return number Index of the next significant line
local function _skip_insignificant(lines, index)
  while index <= #lines and (lines[index].blank or lines[index].comment) do
    index = index + 1
  end
  return index
end

--- Read the comment-stripped content of a line.
--- @param line table Scanned line
--- @return string Content
local function _content(line)
  return _strip_comment(line.raw:sub(line.indent + 1))
end

--- Track bracket depth across one line, ignoring quoted spans.
--- @param text string Line content
--- @param depth number Depth carried in
--- @param quote string|nil Open quote carried in
--- @return number depth
--- @return string|nil quote
local function _scan_flow_depth(text, depth, quote)
  local index = 1
  while index <= #text do
    local char = text:sub(index, index)
    if quote then
      if char == '\\' and quote == '"' then
        index = index + 1
      elseif char == quote then
        quote = nil
      end
    elseif char == '"' or char == "'" then
      quote = char
    elseif char == '[' or char == '{' then
      depth = depth + 1
    elseif char == ']' or char == '}' then
      depth = depth - 1
    end
    index = index + 1
  end
  return depth, quote
end

--- Collect a flow collection that may run across several lines.
--- @param lines table Scanned lines
--- @param start number Index of the line holding the opening bracket
--- @param initial string Flow text already read from that line
--- @param line_number number Line number for errors
--- @return string|nil text The whole flow collection on one line
--- @return number next_index Index of the first line after it
--- @return string|nil err
local function _gather_flow(lines, start, initial, line_number)
  local pieces = { initial }
  local depth, quote = _scan_flow_depth(initial, 0, nil)
  local index = start

  while depth > 0 do
    index = index + 1
    if index > #lines then
      return nil, index, _yaml_error(line_number, 'unterminated flow collection')
    end
    local content = _content(lines[index])
    pieces[#pieces + 1] = content
    depth, quote = _scan_flow_depth(content, depth, quote)
  end

  return table.concat(pieces, ' '), index + 1, nil
end

--- Read a folded or literal block scalar.
--- @param lines table Scanned lines
--- @param start number First candidate line
--- @param parent_indent number Indentation of the owning key
--- @param style string Block style, such as '>', '>-' or '|'
--- @return string text
--- @return number next_index
local function _read_block_scalar(lines, start, parent_indent, style)
  local kind = style:sub(1, 1)
  local chomp = style:sub(2, 2)

  local collected = {}
  local block_indent = nil
  local index = start

  while index <= #lines do
    local line = lines[index]
    if line.blank then
      collected[#collected + 1] = ''
      index = index + 1
    elseif line.indent > parent_indent then
      block_indent = block_indent or line.indent
      collected[#collected + 1] = line.raw:sub(block_indent + 1)
      index = index + 1
    else
      break
    end
  end

  while #collected > 0 and collected[#collected] == '' do
    table.remove(collected)
  end

  local text
  if kind == '>' then
    local parts = {}
    local buffer = {}
    for _, line in ipairs(collected) do
      if line == '' then
        if #buffer > 0 then
          parts[#parts + 1] = table.concat(buffer, ' ')
          buffer = {}
        end
        parts[#parts + 1] = '\n'
      else
        buffer[#buffer + 1] = (line:gsub('%s+$', ''))
      end
    end
    if #buffer > 0 then
      parts[#parts + 1] = table.concat(buffer, ' ')
    end
    text = table.concat(parts)
  else
    text = table.concat(collected, '\n')
  end

  if chomp == '+' then
    text = text .. '\n'
  end

  return text, index
end

local _parse_block
local _parse_sequence

--- The order in which each parsed mapping declared its keys.
--- Lua tables have no key order, but a schema is authored in a meaningful one,
--- and a generator that turns a schema into documentation needs it. The order
--- is kept beside the data rather than inside it, so it cannot be mistaken for
--- a key of the mapping. Weak keys let a discarded mapping take its order with
--- it.
local _key_order = setmetatable({}, { __mode = 'k' })

--- Parse a block mapping at a known indentation.
--- @return table|nil map
--- @return number next_index
--- @return string|nil err
local function _parse_map(lines, start, indent, depth)
  local map = {}
  local order = {}
  local index = start

  while index <= #lines do
    local line = lines[index]
    if line.blank or line.comment then
      index = index + 1
    elseif line.indent < indent then
      break
    else
      if line.indent > indent then
        return nil, index, _yaml_error(line.number, 'unexpected indentation inside a mapping')
      end

      local content = _content(line)
      if content == '' then
        index = index + 1
      else
        if content == '---' or content == '...' then
          return nil, index,
            _yaml_error(line.number, 'multiple YAML documents are not supported')
        end

        if content:sub(1, 1) == '-' then
          return nil, index,
            _yaml_error(line.number, 'a sequence item cannot appear inside a mapping here')
        end

        local raw_key, rest = _split_key(content)
        if raw_key == nil or _trim(raw_key) == '' then
          return nil, index, _yaml_error(line.number, 'expected "key: value"')
        end

        local key, key_err = _unquote_key(raw_key, line.number)
        if key_err then
          return nil, index, key_err
        end
        if map[key] == nil then
          order[#order + 1] = key
        end
        index = index + 1

        -- An explicit indentation indicator (`|2`, `>2-`) is reported rather
        -- than misread: without this the whole block is stored as the string
        -- "|2" and its body is then parsed as further mapping lines.
        if rest:match('^[|>]%d') or rest:match('^[|>][+%-]%d') then
          return nil, index, _yaml_error(
            line.number,
            'a block scalar indentation indicator is not supported: ' .. rest
          )
        end

        local block_style = rest:match('^([|>][+%-]?)$')
        if block_style then
          local text, next_index = _read_block_scalar(lines, index, indent, block_style)
          map[key] = text
          index = next_index
        elseif rest == '' then
          local value, next_index, err = _parse_block(lines, index, indent, depth + 1)
          if err then
            return nil, next_index, err
          end

          -- A block sequence may sit at the column of its own key, which
          -- `_parse_block` declines because its guard wants a deeper line.
          -- Nothing was consumed in that case, so read the sequence here.
          if value == nil and next_index == index then
            local peek = _skip_insignificant(lines, index)
            if peek <= #lines and lines[peek].indent == indent then
              local ahead = _content(lines[peek])
              if ahead == '-' or ahead:sub(1, 2) == '- ' then
                value, next_index, err = _parse_sequence(lines, peek, indent, depth + 1)
                if err then
                  return nil, next_index, err
                end
              end
            end
          end

          map[key] = value
          index = next_index
        elseif rest:sub(1, 1) == '[' or rest:sub(1, 1) == '{' then
          local text, next_index, err = _gather_flow(lines, index - 1, rest, line.number)
          if err then
            return nil, next_index, err
          end
          local value, value_err = _parse_flow(text, line.number, depth)
          if value_err then
            return nil, next_index, value_err
          end
          map[key] = value
          index = next_index
        else
          local value, err = _parse_flow(rest, line.number, depth)
          if err then
            return nil, index, err
          end
          map[key] = value
        end
      end
    end
  end

  _key_order[map] = order
  return map, index, nil
end

--- Parse a block sequence at a known indentation.
--- @return table|nil sequence
--- @return number next_index
--- @return string|nil err
_parse_sequence = function(lines, start, indent, depth)
  local sequence = {}
  local index = start

  while index <= #lines do
    local line = lines[index]
    if line.blank or line.comment then
      index = index + 1
    elseif line.indent < indent then
      break
    else
      if line.indent > indent then
        return nil, index, _yaml_error(line.number, 'unexpected indentation inside a sequence')
      end

      local content = _content(line)
      local rest = content:match('^%-%s*(.*)$')
      if rest == nil then
        break
      end

      if rest == '' then
        local value, next_index, err = _parse_block(lines, index + 1, indent, depth + 1)
        if err then
          return nil, next_index, err
        end
        -- A Lua array cannot hold an interior nil, so an empty item would be
        -- dropped and every later item would shift down one index, moving the
        -- element that `minItems` and an `items` path such as `preload[2]`
        -- refer to. Report it instead.
        if value == nil then
          return nil, index, _yaml_error(line.number, 'an empty sequence item is not supported')
        end
        sequence[#sequence + 1] = value
        index = next_index
      elseif _split_key(rest) == nil then
        -- A plain or flow scalar item, such as `- password` or `- [a, b]`.
        if rest:sub(1, 1) == '[' or rest:sub(1, 1) == '{' then
          local text, next_index, err = _gather_flow(lines, index, rest, line.number)
          if err then
            return nil, next_index, err
          end
          local value, value_err = _parse_flow(text, line.number, depth)
          if value_err then
            return nil, next_index, value_err
          end
          sequence[#sequence + 1] = value
          index = next_index
        else
          local value, err = _parse_flow(rest, line.number, depth)
          if err then
            return nil, index, err
          end
          sequence[#sequence + 1] = value
          index = index + 1
        end
      else
        -- The remainder of the dash line is the first line of the item, and it
        -- sits at the column where that remainder begins.
        local offset = #content - #rest
        local synthetic = {
          raw = string.rep(' ', indent + offset) .. rest,
          indent = indent + offset,
          number = line.number,
          blank = false,
          comment = false,
        }
        local saved = lines[index]
        lines[index] = synthetic
        local value, next_index, err = _parse_block(lines, index, indent, depth + 1)
        lines[index] = saved
        if err then
          return nil, next_index, err
        end
        sequence[#sequence + 1] = value
        index = next_index
      end
    end
  end

  return sequence, index, nil
end

--- Parse whichever block collection begins at `start`.
--- @param lines table Scanned lines
--- @param start number Index to start from
--- @param parent_indent number|nil Indentation that the block must exceed
--- @param depth number Current nesting depth
--- @return any value
--- @return number next_index
--- @return string|nil err
_parse_block = function(lines, start, parent_indent, depth)
  depth = depth or 0
  local index = _skip_insignificant(lines, start)
  if index > #lines then
    return nil, index, nil
  end

  local line = lines[index]
  if parent_indent ~= nil and line.indent <= parent_indent then
    return nil, start, nil
  end

  if depth > MAX_DEPTH then
    return nil, index, _yaml_error(line.number, 'schema nests deeper than ' .. MAX_DEPTH .. ' levels')
  end

  local indent = line.indent
  local content = _content(line)

  if content:sub(1, 1) == '[' or content:sub(1, 1) == '{' then
    local text, next_index, err = _gather_flow(lines, index, content, line.number)
    if err then
      return nil, next_index, err
    end
    local value, value_err = _parse_flow(text, line.number, depth)
    if value_err then
      return nil, next_index, value_err
    end
    return value, next_index, nil
  end

  if content == '-' or content:sub(1, 2) == '- ' then
    return _parse_sequence(lines, index, indent, depth)
  end
  return _parse_map(lines, index, indent, depth)
end

--- Parse YAML text into a native Lua table.
--- @param source string YAML text
--- @return table|nil tree
--- @return string|nil err
local function _parse_yaml_text(source)
  local lines, scan_err = _scan_lines(source)
  if scan_err then
    return nil, scan_err
  end

  -- A single leading `---` opens one document, which is valid and common.
  -- A later one opens a second document, which `_parse_map` reports. Testing
  -- the raw text instead would also reject a `---` inside a block scalar.
  local first = _skip_insignificant(lines, 1)
  if first <= #lines and _content(lines[first]) == '---' then
    lines[first].blank = true
  end

  local value, _, err = _parse_block(lines, 1, nil, 0)
  if err then
    return nil, err
  end
  if value == nil then
    return {}, nil
  end
  if type(value) ~= 'table' or (_is_array(value) and #value > 0) then
    return nil, 'the file must contain a mapping at its top level'
  end
  return value, nil
end

M._parse_yaml_text = _parse_yaml_text

--- Read and parse a YAML schema file.
--- @param filename string Path to the schema file
--- @return table|nil tree
--- @return string|nil err
local function _parse_yaml_file(filename)
  local handle = io.open(filename, 'r')
  if not handle then
    return nil, string.format('Could not open schema file: %s', filename)
  end

  local content = handle:read('*a')
  handle:close()

  local tree, err = _parse_yaml_text(content)
  if err then
    return nil, string.format('Could not parse schema file %s: %s', filename, err)
  end
  return tree, nil
end


-- ============================================================================
-- DESCRIPTOR COMPILATION
-- ============================================================================

local _compiled_cache = setmetatable({}, { __mode = 'k' })

local _compile

--- Compile a field descriptor: coerce its literals against its own declared
--- type, compile its patterns, and recurse into nested descriptors.
--- Returns a new table, so the caller's schema is never mutated.
--- @param spec table Raw field descriptor
--- @return table Compiled descriptor
_compile = function(spec)
  if type(spec) ~= 'table' then
    return spec
  end

  local cached = _compiled_cache[spec]
  if cached then
    return cached
  end

  local out = {}
  for key, value in pairs(spec) do
    out[key] = value
  end

  local type_spec = out.type

  if out.default ~= nil then
    out.default = _coerce(out.default, type_spec)
  end
  if out.const ~= nil then
    out.const = _coerce(out.const, type_spec)
  end
  if type(out.enum) == 'table' then
    local values = {}
    for index = 1, #out.enum do
      values[index] = _coerce(out.enum[index], type_spec)
    end
    out.enum = values
  end

  for _, keyword in ipairs(NUMERIC_KEYWORDS) do
    if out[keyword] ~= nil then
      out[keyword] = tonumber(out[keyword]) or out[keyword]
    end
  end

  if type(out.required) == 'string' then
    out.required = out.required:lower() == 'true' or out.required:lower() == 'yes'
  end
  if type(out.uniqueItems) == 'string' then
    out.uniqueItems = out.uniqueItems:lower() == 'true'
  end
  if type(out.enumCaseInsensitive) == 'string' then
    out.enumCaseInsensitive = out.enumCaseInsensitive:lower() == 'true'
  end
  if out.additionalProperties == 'false' then
    out.additionalProperties = false
  elseif out.additionalProperties == 'true' then
    out.additionalProperties = true
  end

  if type(out.pattern) == 'string' then
    out._pattern, out._pattern_error = _compile_pattern(out.pattern)
  end
  if type(out.propertyNames) == 'string' then
    out._property_names, out._property_names_error = _compile_pattern(out.propertyNames)
  end

  if type(out.items) == 'table' then
    out.items = _compile(out.items)
  end
  if type(out.properties) == 'table' then
    local properties = {}
    for key, value in pairs(out.properties) do
      properties[key] = _compile(value)
    end
    out.properties = properties
  end
  if type(out.additionalProperties) == 'table' then
    out.additionalProperties = _compile(out.additionalProperties)
  end

  _compiled_cache[spec] = out
  return out
end

-- ============================================================================
-- FINDINGS
-- ============================================================================

--- Record a finding against a path.
--- @param context table Validation context
--- @param severity string 'error' or 'warning'
--- @param path string Dotted path of the offending value
--- @param keyword string Keyword that produced the finding
--- @param message string Human-readable explanation
--- @return nil
local function _report(context, severity, path, keyword, message)
  table.insert(context.findings, {
    path = path,
    keyword = keyword,
    message = message,
    severity = severity,
  })
end

--- Split findings into the string arrays the public API returns.
--- @param findings table Array of findings
--- @return table errors Array of error strings
--- @return table warnings Array of warning strings
local function _split_findings(findings)
  local errors = {}
  local warnings = {}
  for _, finding in ipairs(findings) do
    local line = finding.path and (finding.path .. ': ' .. finding.message) or finding.message
    if finding.severity == 'warning' then
      table.insert(warnings, line)
    else
      table.insert(errors, line)
    end
  end
  return errors, warnings
end

-- ============================================================================
-- KEYWORD CHECKS
-- ============================================================================

local _validate_value
local _validate_map

--- Check `enum`, honouring `enumCaseInsensitive`.
local function _check_enum(value, spec, path, context)
  if type(spec.enum) ~= 'table' then
    return
  end
  local case_insensitive = spec.enumCaseInsensitive == true
  for _, allowed in ipairs(spec.enum) do
    if value == allowed then
      return
    end
    if case_insensitive and type(value) == 'string' and type(allowed) == 'string'
      and value:lower() == allowed:lower() then
      return
    end
  end
  _report(context, 'error', path, 'enum', string.format(
    'must be one of: %s, got %s.', _format_list(spec.enum), _format_value(value)
  ))
end

--- Check `pattern`, reporting a pattern the module cannot compile.
local function _check_pattern(value, spec, path, context)
  if spec.pattern == nil or type(value) ~= 'string' then
    return
  end
  if spec._pattern == nil then
    _report(context, 'error', path, 'pattern', string.format(
      'schema declares a pattern this validator cannot compile (%s): %s.',
      spec._pattern_error or 'unsupported construct', spec.pattern
    ))
    return
  end
  if not _pattern_matches(value, spec._pattern) then
    _report(context, 'error', path, 'pattern', string.format(
      'does not match required pattern: %s.', spec.pattern
    ))
  end
end

--- Check the numeric bounds.
local function _check_numeric(value, spec, path, context)
  if type(value) ~= 'number' then
    return
  end
  if type(spec.minimum) == 'number' and value < spec.minimum then
    _report(context, 'error', path, 'minimum', string.format(
      'must be at least %s, got %s.', _format_value(spec.minimum), _format_value(value)
    ))
  end
  if type(spec.maximum) == 'number' and value > spec.maximum then
    _report(context, 'error', path, 'maximum', string.format(
      'must be at most %s, got %s.', _format_value(spec.maximum), _format_value(value)
    ))
  end
  if type(spec.exclusiveMinimum) == 'number' and value <= spec.exclusiveMinimum then
    _report(context, 'error', path, 'exclusiveMinimum', string.format(
      'must be greater than %s, got %s.', _format_value(spec.exclusiveMinimum), _format_value(value)
    ))
  end
  if type(spec.exclusiveMaximum) == 'number' and value >= spec.exclusiveMaximum then
    _report(context, 'error', path, 'exclusiveMaximum', string.format(
      'must be less than %s, got %s.', _format_value(spec.exclusiveMaximum), _format_value(value)
    ))
  end
  if type(spec.multipleOf) == 'number' and spec.multipleOf ~= 0 then
    local quotient = value / spec.multipleOf
    if quotient ~= math.floor(quotient) then
      _report(context, 'error', path, 'multipleOf', string.format(
        'must be a multiple of %s, got %s.', _format_value(spec.multipleOf), _format_value(value)
      ))
    end
  end
end

--- Check string length.
local function _check_string_length(value, spec, path, context)
  if type(value) ~= 'string' then
    return
  end
  -- Count characters rather than bytes, so a multi-byte glyph counts as one.
  local length = utf8 and utf8.len(value) or nil
  if length == nil then
    length = #value
  end
  if type(spec.minLength) == 'number' and length < spec.minLength then
    _report(context, 'error', path, 'minLength', string.format(
      'must be at least %d characters, got %d.', spec.minLength, length
    ))
  end
  if type(spec.maxLength) == 'number' and length > spec.maxLength then
    _report(context, 'error', path, 'maxLength', string.format(
      'must be at most %d characters, got %d.', spec.maxLength, length
    ))
  end
end

--- Check array length and uniqueness.
local function _check_array(value, spec, path, context)
  if type(value) ~= 'table' then
    return
  end
  local length = #value
  if type(spec.minItems) == 'number' and length < spec.minItems then
    _report(context, 'error', path, 'minItems', string.format(
      'must have at least %d items, got %d.', spec.minItems, length
    ))
  end
  if type(spec.maxItems) == 'number' and length > spec.maxItems then
    _report(context, 'error', path, 'maxItems', string.format(
      'must have at most %d items, got %d.', spec.maxItems, length
    ))
  end
  if spec.uniqueItems == true then
    local seen = {}
    for index = 1, length do
      local element = value[index]
      local rendered = _format_value(element)
      -- The key carries the type so 1 and "1" are different items. A string
      -- keys on its own text rather than on the rendering, because
      -- `_format_value` renders an empty string as `""`, which would make it
      -- collide with the two-character string `""`. The message carries only
      -- the rendering, because the key is not the author's text.
      local raw = type(element) == 'string' and element or rendered
      local key = type(element) .. '\0' .. raw
      if seen[key] then
        _report(context, 'error', path, 'uniqueItems', string.format(
          'must not repeat items, but %s appears more than once.', rendered
        ))
        break
      end
      seen[key] = true
    end
  end
end

--- Validate array elements against `items`.
local function _check_items(value, spec, path, context)
  if type(spec.items) ~= 'table' or type(value) ~= 'table' then
    return
  end
  for index = 1, #value do
    local element = _coerce(value[index], spec.items.type)
    value[index] = element
    if element ~= nil then
      _validate_value(element, spec.items, string.format('%s[%d]', path, index), context)
    end
  end
end

--- Validate object members against `properties` and its companions.
local function _check_object(value, spec, path, context)
  if type(value) ~= 'table' then
    return
  end

  if spec._property_names ~= nil or spec._property_names_error ~= nil then
    if spec._property_names == nil then
      _report(context, 'error', path, 'propertyNames', string.format(
        'schema declares a propertyNames pattern this validator cannot compile (%s): %s.',
        spec._property_names_error or 'unsupported construct', spec.propertyNames
      ))
    else
      for key in pairs(value) do
        if type(key) == 'string' and not _pattern_matches(key, spec._property_names) then
          _report(context, 'error', path .. '.' .. key, 'propertyNames', string.format(
            'key does not match required pattern: %s.', spec.propertyNames
          ))
        end
      end
    end
  end

  local defaulted = {}

  if type(spec.properties) == 'table' then
    local sub, filled = _validate_map(value, spec.properties, path, context, {
      unknown = spec.additionalProperties == false and 'warn' or 'ignore',
      additional = type(spec.additionalProperties) == 'table' and spec.additionalProperties or nil,
    })

    -- `_validate_map` builds a new table, so its defaults, coercion and alias
    -- resolution have to be written back into the value the parent holds.
    -- Without this a nested `properties` contributes nothing to `merged`.
    local stale = {}
    for key in pairs(value) do
      if sub[key] == nil then
        stale[#stale + 1] = key
      end
    end
    for _, key in ipairs(stale) do
      value[key] = nil
    end
    for key, member in pairs(sub) do
      value[key] = member
    end
    defaulted = filled
  elseif type(spec.additionalProperties) == 'table' then
    for key, member in pairs(value) do
      local coerced = _coerce(member, spec.additionalProperties.type)
      value[key] = coerced
      if coerced ~= nil then
        _validate_value(coerced, spec.additionalProperties, path .. '.' .. tostring(key), context)
      end
    end
  end

  -- Runs after the properties block, which writes the resolved members back
  -- into `value`. Before that, a dependent supplied under an alias is not yet
  -- there to be found. A `default` is an annotation and does not change the
  -- instance, so a key that only holds one neither triggers a requirement nor
  -- satisfies it.
  if type(spec.dependentRequired) == 'table' then
    for key, dependents in pairs(spec.dependentRequired) do
      local trigger, trigger_key = _lookup(value, key)
      if trigger ~= nil and not defaulted[trigger_key] and type(dependents) == 'table' then
        for _, dependent in ipairs(dependents) do
          local supplied, dependent_key = _lookup(value, dependent)
          if supplied == nil or defaulted[dependent_key] then
            _report(context, 'error', path, 'dependentRequired', string.format(
              'requires "%s" when "%s" is present.', dependent, key
            ))
          end
        end
      end
    end
  end
end

--- Run every keyword check against one value.
--- A failed type check short-circuits, so one mistake yields one message.
--- @param value any Value to validate
--- @param spec table Compiled descriptor
--- @param path string Dotted path of the value
--- @param context table Validation context
--- @return nil
_validate_value = function(value, spec, path, context)
  local names = _type_names(spec.type)

  if names then
    for _, name in ipairs(names) do
      if name == 'content' then
        return
      end
    end
  end

  if not _matches_type_spec(value, spec.type) then
    _report(context, 'error', path, 'type', string.format(
      'must be of type "%s", got "%s".', _format_type(spec.type), _actual_type(value)
    ))
    return
  end

  if spec.const ~= nil and value ~= spec.const then
    _report(context, 'error', path, 'const', string.format(
      'must be %s, got %s.', _format_value(spec.const), _format_value(value)
    ))
  end

  _check_enum(value, spec, path, context)
  _check_pattern(value, spec, path, context)
  _check_numeric(value, spec, path, context)
  _check_string_length(value, spec, path, context)
  _check_array(value, spec, path, context)
  _check_items(value, spec, path, context)
  _check_object(value, spec, path, context)
end

-- ============================================================================
-- MAP VALIDATION
-- ============================================================================

--- Build the deprecation warning for a descriptor, and forward its value.
--- @param field string Field name
--- @param spec table Compiled descriptor
--- @param value any Current value
--- @param merged table Working values
--- @return string message Warning text
--- @return boolean cleared True when the deprecated key was removed
local function _apply_deprecation(field, spec, value, merged)
  local deprecated = spec.deprecated

  if type(deprecated) == 'string' then
    return string.format('option "%s" is deprecated. %s', field, deprecated), false
  end

  if type(deprecated) ~= 'table' then
    return string.format('option "%s" is deprecated.', field), false
  end

  local message
  if deprecated.since then
    message = string.format('option "%s" is deprecated since %s.', field, deprecated.since)
  else
    message = string.format('option "%s" is deprecated.', field)
  end
  if deprecated.message then
    message = message .. ' ' .. deprecated.message
  end

  -- A v1 schema writes `replace-with`, which this vocabulary does not accept.
  -- Say so, rather than dropping the forwarding without a word.
  local unrecognised = {}
  for key in pairs(deprecated) do
    if key ~= 'since' and key ~= 'message' and key ~= 'replaceWith' then
      unrecognised[#unrecognised + 1] = key
    end
  end
  if #unrecognised > 0 then
    table.sort(unrecognised)
    message = message .. string.format(
      ' The deprecation declares %s, which this vocabulary does not accept; use "replaceWith".',
      table.concat(unrecognised, ', ')
    )
  end

  local cleared = false
  if deprecated.replaceWith then
    local replacement = deprecated.replaceWith
    message = message .. string.format(' Use "%s" instead.', replacement)
    if _lookup(merged, replacement) == nil then
      merged[replacement] = value
    end
    merged[field] = nil
    cleared = true
  end

  return message, cleared
end

--- Record that a descriptor accepts a spelling, and report a contested one.
---
--- Two descriptors can name the same spelling, when one declares as an alias
--- what another declares as its own name, or when two of them declare the same
--- alias. `pairs` yields descriptors in no particular order, so which field a
--- contested spelling resolves to is not decidable from the schema. It is
--- reported rather than resolved in silence, because the schema is what is
--- wrong and only its author can settle it.
---
--- @param sources table Map of spelling to declared name
--- @param spelling string The spelling being declared
--- @param field string The declared name that accepts it
--- @param base_path string|nil Path prefix for findings
--- @param context table Validation context
local function _declare_spelling(sources, spelling, field, base_path, context)
  -- The owner is read through `_lookup`, like every other name comparison in
  -- this module, so a contest between the hyphen and the underscore spelling
  -- of one name is found as well. Those sit under different keys but reach the
  -- same document key at merge time, so they contest just as directly.
  local owner = _lookup(sources, spelling)
  if owner ~= nil and owner ~= field then
    _report(context, 'warning', base_path and (base_path .. '.' .. spelling) or spelling,
      'aliases', string.format(
        'is declared by both "%s" and "%s"; which one accepts it is not defined.',
        owner, field))
  end
  -- Stored under the literal spelling either way. The map is also the set of
  -- keys a descriptor claimed, and a contested spelling is still claimed: the
  -- schema is ambiguous, which the warning says, and treating the key as
  -- undeclared on top of that would report it as unknown as well.
  sources[spelling] = sources[spelling] or field
end


--- Validate a map of values against a map of field descriptors.
--- @param values table Values to validate
--- @param descriptors table Field descriptor map
--- @param base_path string|nil Path prefix for findings
--- @param context table Validation context
--- @param options table|nil {unknown = 'warn'|'error'|'ignore', additional = descriptor}
--- @return table merged Values with aliases, coercion and defaults applied
--- @return table defaulted Set of field names whose value came from `default`
--- @return table sources Map of every spelling the schema accepts to the
---   declared name it resolves to. A reader that has to answer a question
---   about a name the caller wrote asks this rather than walking the
---   descriptors again, because the merge has already decided the answer.
---   It doubles as the set of keys a descriptor claimed, which is what the
---   unknown key pass below reads.
_validate_map = function(values, descriptors, base_path, context, options)
  options = options or {}
  local unknown_policy = options.unknown or 'ignore'

  local merged = {}
  for key, value in pairs(values) do
    merged[key] = value
  end

  local defaulted = {}
  local sources = {}
  local fields = {}

  -- Three passes, because `pairs` yields descriptors in no particular order.
  -- Aliases must land before deprecation reads a value, and a `replaceWith`
  -- target must be populated before its own descriptor is validated.
  for field, raw_spec in pairs(descriptors) do
    local spec = _compile(raw_spec)
    fields[#fields + 1] = {
      name = field,
      spec = spec,
      path = base_path and (base_path .. '.' .. field) or field,
    }
    -- Two writes with different weight. Declaring a spelling fills an empty
    -- slot only, while claiming the value under one overwrites whatever was
    -- there. The value lands under whichever descriptor claimed it, so the
    -- claim is what the map has to follow: a declaration that outranked it
    -- would send a reader to a field the merge has already emptied.
    _declare_spelling(sources, field, field, base_path, context)

    -- A value found under an alias, or under the other spelling, moves to the
    -- name the schema declares. The key it came from is removed, so `merged`
    -- never carries the same value twice, once coerced and once raw.
    -- The declared name is read first, so it wins over any alias.
    local supplied_key
    local found, found_key = _lookup(merged, field)
    if found ~= nil then
      merged[field] = found
      sources[found_key] = field
      supplied_key = found_key
      if found_key ~= field then
        merged[found_key] = nil
      end
    end

    if type(spec.aliases) == 'table' then
      for _, alias in ipairs(spec.aliases) do
        _declare_spelling(sources, alias, field, base_path, context)
        local aliased, alias_key = _lookup(merged, alias)
        if aliased ~= nil then
          sources[alias_key] = field
          if merged[field] == nil then
            merged[field] = aliased
            supplied_key = alias_key
          elseif alias_key ~= field then
            -- Two spellings were supplied. The first one read wins, and the
            -- other is reported rather than left behind unvalidated. Both
            -- names come from the document, never from the schema.
            _report(context, 'warning',
              base_path and (base_path .. '.' .. field) or field,
              'aliases',
              string.format('was given as both "%s" and "%s"; "%s" was used.',
                supplied_key, alias_key, supplied_key))
          end
          if alias_key ~= field then
            merged[alias_key] = nil
          end
        end
      end
    end
  end

  for _, entry in ipairs(fields) do
    local value = merged[entry.name]
    if entry.spec.deprecated and value ~= nil then
      local message, cleared = _apply_deprecation(entry.name, entry.spec, value, merged)
      _report(context, 'warning', entry.path, 'deprecated', message)
      entry.cleared = cleared
    end
  end

  for _, entry in ipairs(fields) do
    local field, spec, path = entry.name, entry.spec, entry.path
    local value

    if entry.cleared then
      value = nil
    else
      value = _coerce(merged[field], spec.type)
      merged[field] = value

      if value == nil and spec.default ~= nil then
        value = spec.default
        merged[field] = value
        defaulted[field] = true
      end
    end

    -- An empty string is a value the author wrote. Only a missing key is
    -- absent, so `minLength`, `const` and `enum` can be tested against ''.
    if spec.required == true and value == nil then
      _report(context, 'error', path, 'required', 'is required but was not provided.')
    elseif value ~= nil then
      _validate_value(value, spec, path, context)
    end
  end

  if unknown_policy ~= 'ignore' or options.additional then
    for key, value in pairs(values) do
      if sources[key] == nil then
        local path = base_path and (base_path .. '.' .. tostring(key)) or tostring(key)
        if options.additional then
          local coerced = _coerce(value, options.additional.type)
          merged[key] = coerced
          if coerced ~= nil then
            _validate_value(coerced, options.additional, path, context)
          end
        elseif unknown_policy == 'error' then
          _report(context, 'error', path, 'additionalProperties', 'is not a recognised key.')
        else
          _report(context, 'warning', path, 'additionalProperties', 'is not a recognised key and was ignored.')
        end
      end
    end
  end

  return merged, defaulted, sources
end

--- Start a validation run.
--- @return table Fresh validation context
local function _new_context()
  return { findings = {} }
end

--- Close a validation run and shape the public return values.
--- @param context table Validation context
--- @param merged table Merged values
--- @return boolean valid
--- @return table errors
--- @return table warnings
--- @return table merged
--- @return table findings
local function _finish(context, merged)
  local errors, warnings = _split_findings(context.findings)
  return #errors == 0, errors, warnings, merged, context.findings
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

--- Load and parse a schema file.
--- Sections absent from the file default to an empty table.
---
--- A failure is returned, not raised. Quarto replaces `error` with a logger
--- that returns instead of unwinding, so raising here would let a caller
--- carry on with a nil schema and fail later somewhere unrelated.
---
--- @param filename string|nil Path to the schema file (defaults to '_schema.yml')
--- @return table|nil schema Schema with {['$schema'], options, shortcodes, formats, projects, attributes, classes}
--- @return string|nil err Why the schema could not be read
--- @usage local schema, err = M.load_schema('_schema.yml')
function M.load_schema(filename)
  local raw, err = _parse_yaml_file(filename or '_schema.yml')
  if err then
    return nil, err
  end

  return {
    ['$schema'] = raw['$schema'],
    options = raw.options or {},
    shortcodes = raw.shortcodes or {},
    formats = raw.formats or {},
    projects = raw.projects or {},
    attributes = raw.attributes or {},
    classes = raw.classes or {},
  }, nil
end

--- List the keys of a parsed mapping in the order the schema declared them.
--- A schema is authored in a meaningful order, and a generator that turns one
--- into documentation needs that order rather than an arbitrary one.
--- Falls back to sorted keys for a table this module did not parse.
--- @param map table A mapping from a loaded schema
--- @return table Array of keys
--- @usage for _, name in ipairs(schema.key_order(loaded.options)) do
function M.key_order(map)
  if type(map) ~= 'table' then
    return {}
  end

  local order = _key_order[map]
  if order ~= nil then
    local copy = {}
    for index, key in ipairs(order) do
      copy[index] = key
    end
    return copy
  end

  local keys = {}
  for key in pairs(map) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

--- Validate a map of values against a map of field descriptors.
--- @param values table Values to validate
--- @param descriptors table Field descriptor map
--- @param options table|nil {unknown = 'warn'|'error'|'ignore'}
--- @return boolean valid True when no error was reported
--- @return table errors Array of error strings
--- @return table warnings Array of warning strings
--- @return table merged Values with aliases, coercion and defaults applied
--- @return table findings Array of structured findings
--- @usage local valid, errors, warnings, merged = M.validate(options, schema.options)
function M.validate(values, descriptors, options)
  options = options or {}
  local context = _new_context()
  local merged = _validate_map(values or {}, descriptors or {}, nil, context, {
    unknown = options.unknown or 'warn',
  })
  return _finish(context, merged)
end

--- Validate positional shortcode arguments against an argument descriptor array.
--- Each descriptor should carry a `name`; the merged table is keyed by name.
--- @param args table Array of positional argument values
--- @param argument_specs table Array of argument descriptors
--- @param options table|nil {unknown = 'warn'|'ignore'}
--- @return boolean valid
--- @return table errors
--- @return table warnings
--- @return table merged Map keyed by argument name
--- @return table findings
--- @usage local valid, errors, warnings, merged = M.validate_arguments(args, specs)
function M.validate_arguments(args, argument_specs, options)
  options = options or {}
  args = args or {}
  argument_specs = argument_specs or {}

  local context = _new_context()
  local merged = {}

  for index, raw_spec in ipairs(argument_specs) do
    local spec = _compile(raw_spec)
    local name = spec.name or tostring(index)
    local path = string.format('argument %d ("%s")', index, name)

    local value = _coerce(args[index], spec.type)
    if value == nil and spec.default ~= nil then
      value = spec.default
    end
    merged[name] = value

    if spec.required == true and value == nil then
      _report(context, 'error', path, 'required', 'is required but was not provided.')
    elseif value ~= nil then
      _validate_value(value, spec, path, context)
    end
  end

  if (options.unknown or 'warn') ~= 'ignore' and #args > #argument_specs then
    _report(context, 'warning', nil, 'arguments', string.format(
      'Received %d arguments but only %d are defined. The extra arguments were ignored.',
      #args, #argument_specs
    ))
  end

  return _finish(context, merged)
end

--- Validate one shortcode call against its schema entry.
--- Covers the positional `arguments`, the named `attributes`, and the
--- parent-level `required` array of attribute names.
--- @param name string Shortcode name, used as the path prefix
--- @param args table Array of positional argument values
--- @param kwargs table Map of named attribute values
--- @param entry table Shortcode entry from `schema.shortcodes[name]`
--- @param options table|nil {unknown = 'warn'|'error'|'ignore'}
--- @return boolean valid
--- @return table errors
--- @return table warnings
--- @return table merged {arguments = ..., attributes = ...}
--- @return table findings
--- @usage local valid, errors, warnings, merged = M.validate_shortcode('iconify', args, kwargs, schema.shortcodes.iconify)
function M.validate_shortcode(name, args, kwargs, entry, options)
  options = options or {}
  entry = entry or {}

  local context = _new_context()
  local merged = { arguments = {}, attributes = {} }

  if type(entry.arguments) == 'table' then
    local _, errors, warnings, arguments = M.validate_arguments(args or {}, entry.arguments, options)
    merged.arguments = arguments
    for _, message in ipairs(errors) do
      _report(context, 'error', nil, 'arguments', name .. ' ' .. message)
    end
    for _, message in ipairs(warnings) do
      _report(context, 'warning', nil, 'arguments', name .. ' ' .. message)
    end
  end

  local declared = type(entry.attributes) == 'table'
  local spellings
  if declared then
    local attributes, _, resolved = _validate_map(kwargs or {}, entry.attributes, name, context, {
      unknown = options.unknown or 'warn',
    })
    merged.attributes = attributes
    spellings = resolved
  end

  if type(entry.required) == 'table' then
    -- `merged.attributes` is filled only when the entry declares `attributes`,
    -- and it is authoritative when it is: it keeps every unclaimed key and it
    -- drops a key that a deprecation cleared. The vocabulary allows `required`
    -- on its own, so fall back to what the caller supplied only when the
    -- entry declares no `attributes`. A name that names an alias is not
    -- missing either: `_validate_map` moves its value to the field that
    -- declares the alias and clears the alias spelling, the same way it
    -- clears a deprecated key, so look for the value under that field. The
    -- merge reports which declared name each spelling resolves to, so that
    -- is one lookup rather than a second walk over the descriptors. It goes
    -- through `_lookup`, the same as every other name comparison in this
    -- module, so a hyphen in one spelling and an underscore in the other
    -- still match.
    --
    -- This asks what the shortcode receives, not what the author wrote, so
    -- a `default` present in `merged.attributes` satisfies a name here.
    -- That is the opposite of `dependentRequired` above, which asks what
    -- the author wrote and treats a default as an annotation nobody
    -- supplied. Neither reading is a bug: they answer different questions
    -- about the same instance.
    local function _required_satisfied(required)
      local field = (spellings and _lookup(spellings, required)) or required
      if _lookup(merged.attributes, field) ~= nil then
        return true
      end
      if not declared then
        return _lookup(kwargs or {}, required) ~= nil
      end
      return false
    end

    for _, required in ipairs(entry.required) do
      if not _required_satisfied(required) then
        _report(context, 'error', name .. '.' .. required, 'required',
          'is required but was not provided.')
      end
    end
  end

  return _finish(context, merged)
end

--- Validate Pandoc element attributes against one group of the `attributes`
--- section. Undeclared attributes are ignored by default, because a Pandoc
--- element legitimately carries attributes from Quarto and other filters.
--- @param attributes table Map of attribute values
--- @param group string Group key, such as a class, identifier or element name
--- @param schema table Loaded schema
--- @param options table|nil {unknown = 'warn'|'error'|'ignore'}
--- @return boolean valid
--- @return table errors
--- @return table warnings
--- @return table merged
--- @return table findings
--- @usage local valid, errors, warnings, merged = M.validate_attributes(el.attributes, 'callout-note', schema)
function M.validate_attributes(attributes, group, schema, options)
  options = options or {}
  local descriptors = schema and schema.attributes and _lookup(schema.attributes, group) or nil

  local context = _new_context()
  if descriptors == nil then
    return _finish(context, attributes or {})
  end

  local merged = _validate_map(attributes or {}, descriptors, group, context, {
    unknown = options.unknown or 'ignore',
  })
  return _finish(context, merged)
end

--- Validate the options of one output format against the `formats` section.
--- Quarto merges the options of the selected format into the top level of the
--- metadata, so the values are read from there. The format name is never a key.
--- A value is collected only when a descriptor declares its name, which keeps
--- the document's own keys, such as `title`, out of the merge. The `unknown`
--- option therefore has nothing to report here, and is kept so that the entry
--- points keep one signature.
--- @param meta table Document metadata
--- @param format string Format name, such as 'html' or 'typst'
--- @param schema table Loaded schema
--- @param options table|nil {unknown = 'warn'|'error'|'ignore'}
--- @return boolean valid
--- @return table errors
--- @return table warnings
--- @return table merged
--- @return table findings
--- @usage local valid, errors, warnings, merged = M.validate_format(meta, 'typst', schema)
function M.validate_format(meta, format, schema, options)
  options = options or {}
  local descriptors = schema and schema.formats and _lookup(schema.formats, format) or nil

  local context = _new_context()
  if descriptors == nil then
    return _finish(context, {})
  end

  -- Each value is stored under the spelling the document wrote, never under the
  -- declared name. `_validate_map` is what moves an alias or the other spelling
  -- to the declared name, and it needs the original key to say which two
  -- spellings a document supplied for one field.
  --
  -- `_lookup` returns the first spelling it finds, so a document that wrote one
  -- name in both spellings loses the other. Every other entry point reports the
  -- loser through the `unknown` option, which has nothing to report here, so the
  -- collection reports it in the same words `_validate_map` uses.
  local values = {}
  for field, raw_spec in pairs(descriptors) do
    local spec = _compile(raw_spec)

    -- One entry per name, and not one per spelling. `_lookup` reads both
    -- spellings of whichever entry is kept, so an alias that is only the other
    -- spelling of a name already listed adds nothing. Probing it as well would
    -- collect the two spellings under separate keys, and one mistake would then
    -- be reported three times, once by each probe and once by `_validate_map`.
    local names = { field }
    local listed = { [(field:gsub('_', '-'))] = true }
    if type(spec) == 'table' and type(spec.aliases) == 'table' then
      for _, alias in ipairs(spec.aliases) do
        -- A schema file is not read against the meta-schema, so an unquoted
        -- `no` reaches here as a boolean. `_lookup` skips a key that is not a
        -- string everywhere else, and so does this.
        if type(alias) == 'string' then
          local normalised = (alias:gsub('_', '-'))
          if not listed[normalised] then
            listed[normalised] = true
            names[#names + 1] = alias
          end
        end
      end
    end

    for _, name in ipairs(names) do
      local value, found_key = _lookup(meta, name)
      if value ~= nil then
        values[found_key] = _convert_pandoc_value(value)

        for _, other in ipairs({ (name:gsub('%-', '_')), (name:gsub('_', '-')) }) do
          if other ~= found_key and meta[other] ~= nil then
            _report(context, 'warning', format .. '.' .. field, 'aliases',
              string.format('was given as both "%s" and "%s"; "%s" was used.',
                found_key, other, found_key))
          end
        end
      end
    end
  end

  local merged = _validate_map(values, descriptors, format, context, {
    unknown = options.unknown or 'ignore',
  })
  return _finish(context, merged)
end

--- Extract an extension's options from document metadata.
--- Reads `meta.extensions[extension_name]` and converts Pandoc values to
--- native Lua values, keeping every key exactly as the document wrote it.
--- @param meta table Document metadata
--- @param extension_name string Extension name
--- @return table Map of option values
--- @usage local options = M.extract_meta_options(meta, 'iconify')
function M.extract_meta_options(meta, extension_name)
  local extension_meta = meta and meta['extensions'] and meta['extensions'][extension_name]
  if not extension_meta then
    return {}
  end

  local options = {}
  for key, value in pairs(extension_meta) do
    options[tostring(key)] = _convert_pandoc_value(value)
  end
  return options
end

--- Load a schema, validate an extension's options, and log the outcome.
--- A schema that cannot be loaded is reported and the render continues with
--- no validated options, rather than aborting on a configuration file.
--- @param meta table Document metadata
--- @param extension_name string Extension name
--- @param schema_path string Path to the schema file, resolved by the caller
--- @param options table|nil {unknown = 'warn'|'error'|'ignore'}
--- @return table merged Validated options with defaults applied
--- @usage local options = M.validate_options(meta, 'iconify', quarto.utils.resolve_path('_schema.yml'))
function M.validate_options(meta, extension_name, schema_path, options)
  local schema, err = M.load_schema(schema_path)
  if err then
    _env.report_error(string.format('Extension "%s": %s', extension_name, err))
    return {}
  end

  if not schema.options or next(schema.options) == nil then
    return {}
  end

  local values = M.extract_meta_options(meta, extension_name)
  local valid, errors, warnings, merged = M.validate(values, schema.options, options)

  if #warnings > 0 then
    _env.warn(M.format_warnings(warnings, extension_name))
  end
  if not valid then
    _env.report_error(M.format_errors(errors, extension_name))
  end

  return merged
end

--- Format error messages as one readable block.
--- @param errors table Array of error strings
--- @param extension_name string|nil Extension name for context
--- @return string Formatted message, or an empty string
--- @usage local message = M.format_errors(errors, 'iconify')
function M.format_errors(errors, extension_name)
  if #errors == 0 then
    return ''
  end

  local prefix = extension_name and ('Extension "' .. extension_name .. '": ') or ''
  local lines = {}
  for index, message in ipairs(errors) do
    table.insert(lines, '  ' .. index .. '. ' .. message)
  end

  return prefix .. 'Configuration validation failed:\n' .. table.concat(lines, '\n')
end

--- Format warning messages as one readable block.
--- @param warnings table Array of warning strings
--- @param extension_name string|nil Extension name for context
--- @return string Formatted message, or an empty string
--- @usage local message = M.format_warnings(warnings, 'iconify')
function M.format_warnings(warnings, extension_name)
  if #warnings == 0 then
    return ''
  end

  local prefix = extension_name and ('Extension "' .. extension_name .. '": ') or ''
  local lines = {}
  for index, message in ipairs(warnings) do
    table.insert(lines, '  ' .. index .. '. ' .. message)
  end

  return prefix .. 'Configuration warnings:\n' .. table.concat(lines, '\n')
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return M
