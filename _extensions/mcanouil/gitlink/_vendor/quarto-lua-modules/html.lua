--- MC HTML - HTML generation and dependency management for Quarto Lua filters and shortcodes
--- @module "html"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

local M = {}

--- Load a sibling module from the same directory as this file.
--- @param filename string The sibling module filename (e.g., 'string.lua')
--- @return table The loaded module
local function load_sibling(filename)
  local source = debug.getinfo(1, 'S').source:sub(2)
  local dir = source:match('(.*[/\\])') or ''
  return require((dir .. filename):gsub('%.lua$', ''))
end

--- Load string module for escape_html and escape_attribute
local str = load_sibling('string.lua')

-- ============================================================================
-- HTML RAW GENERATION UTILITIES
-- ============================================================================

--- Generates a raw HTML header element.
--- @param level integer The header level (e.g., 2 for <h2>)
--- @param text string|nil The header text
--- @param id string The id attribute for the header
--- @param classes table List of classes for the header
--- @param attributes table|nil Additional HTML attributes
--- @return string Raw HTML string for the header
function M.raw_header(level, text, id, classes, attributes)
  local attr_str = ''
  if id and id ~= '' then
    attr_str = attr_str .. ' id="' .. str.escape_attribute(id) .. '"'
  end
  if classes and #classes > 0 then
    local escaped_classes = {}
    for i, cls in ipairs(classes) do
      escaped_classes[i] = str.escape_attribute(cls)
    end
    attr_str = attr_str .. ' class="' .. table.concat(escaped_classes, ' ') .. '"'
  end
  if attributes then
    for k, v in pairs(attributes) do
      attr_str = attr_str .. ' ' .. str.escape_attribute(k) .. '="' .. str.escape_attribute(v) .. '"'
    end
  end
  return string.format('<h%d%s>%s</h%d>', level, attr_str, str.escape_html(text or ''), level)
end

-- ============================================================================
-- HTML DEPENDENCY UTILITIES
-- ============================================================================

--- Managed HTML dependency tracker
--- Tracks which dependencies have been added to prevent duplication
--- @type table<string, boolean>
local dependency_tracker = {}

--- Ensure HTML dependency is added only once per document.
--- Prevents duplicate dependency injection by tracking dependencies by name.
--- Returns true if dependency was added, false if already present.
---
--- @param config table Dependency configuration with fields: name (required), version, scripts, stylesheets, head
--- @return boolean True if dependency was added, false if already added
--- @usage M.ensure_html_dependency({name = 'my-lib', version = '1.0.0', scripts = {'lib.js'}})
function M.ensure_html_dependency(config)
  if not config or not config.name then
    error("HTML dependency configuration must include a 'name' field")
  end

  --- @type string Unique key for this dependency
  local dep_key = config.name

  -- Check if already added
  if dependency_tracker[dep_key] then
    return false
  end

  -- Add the dependency
  quarto.doc.add_html_dependency(config)

  -- Mark as added
  dependency_tracker[dep_key] = true
  return true
end

--- Reset dependency tracker.
--- Useful for testing or when processing multiple independent documents.
--- In normal usage, this should not be called as dependencies persist per document.
---
--- @return nil
function M.reset_dependencies()
  dependency_tracker = {}
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return M
