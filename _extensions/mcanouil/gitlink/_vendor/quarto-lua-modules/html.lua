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
  local name = filename:gsub('%.lua$', '')
  if not (debug and debug.getinfo) then
    -- q2 has no `debug` library, and its `require` looks in the directory of
    -- the module being loaded first.
    return require(name)
  end
  local source = debug.getinfo(1, 'S').source:sub(2)
  local dir = source:match('(.*[/\\])') or ''
  return require(dir .. name)
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

--- Extension versions already read, keyed by the directory of the entry point.
--- @type table<string, string>
local version_cache = {}

--- Read the top-level `version:` value of one `_extension.yml`.
--- @param path string Path of the manifest
--- @return boolean True if the file exists
--- @return string|nil The version, or nil if the file or the key is missing
local function read_manifest_version(path)
  local handle = io.open(path, 'r')
  if not handle then
    return false, nil
  end
  local version
  for line in handle:lines() do
    version = line:match('^version:%s*["\']?([^"\'%s]+)')
    if version then
      break
    end
  end
  handle:close()
  return true, version
end

--- Get the version of the extension that is running, from its `_extension.yml`.
--- The search starts in the directory of the running entry point and goes up.
--- It stops at the first `_extension.yml` it finds, with or without a version,
--- and never leaves the `_extensions` folder. An entry point outside
--- `_extensions` has only its own directory searched.
---
--- @return string The version
--- @usage local version = M.get_extension_version()
function M.get_extension_version()
  local start = pandoc.path.directory(quarto.utils.resolve_path('_extension.yml'))
  if version_cache[start] then
    return version_cache[start]
  end
  local in_extensions = false
  for _, part in ipairs(pandoc.path.split(start)) do
    in_extensions = in_extensions or part == '_extensions'
  end
  local searched = {}
  local dir = start
  while true do
    local path = pandoc.path.join({ dir, '_extension.yml' })
    searched[#searched + 1] = path
    local found, version = read_manifest_version(path)
    if version then
      version_cache[start] = version
      return version
    end
    local parent = pandoc.path.directory(dir)
    if found or not in_extensions or parent == dir or pandoc.path.filename(dir) == '_extensions'
        or pandoc.path.filename(parent) == '_extensions' then
      break
    end
    dir = parent
  end
  error(string.format(
    'No extension version found in %s. Pass `version` explicitly or add `version:` to `_extension.yml`.',
    table.concat(searched, ', ')))
end

--- Ensure HTML dependency is added only once per document.
--- Prevents duplicate dependency injection by tracking dependencies by name.
--- Returns true if dependency was added, false if already present.
--- Without a `version`, the version of the running extension is used, so the
--- dependency folder changes with each release. A caller whose entry point is
--- not inside `_extensions` must pass `version`.
---
--- @param config table Dependency configuration with fields: name (required), version, scripts, stylesheets, head
--- @return boolean True if dependency was added, false if already added
--- @usage M.ensure_html_dependency({name = 'my-lib', scripts = {'lib.js'}})
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
  config.version = config.version or M.get_extension_version()
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
