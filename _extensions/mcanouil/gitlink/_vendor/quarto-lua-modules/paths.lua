--- MC Paths - Path resolution and file type checks for Quarto Lua filters and shortcodes
--- @module "paths"
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

--- Load string module for is_empty
local str = load_sibling('string.lua')

-- ============================================================================
-- PATH UTILITIES
-- ============================================================================

--- Resolve a path relative to the project directory.
--- If the path starts with `/`, it is treated as relative to the project directory.
--- If `quarto.project.directory` is available, it is prepended to the path.
--- If `quarto.project.directory` is nil, the leading `/` is removed.
--- @param path string The path to resolve (may start with `/`)
--- @return string The resolved path
--- @usage local resolved = M.resolve_project_path("/config.yml")
--- @usage local resolved = M.resolve_project_path("config.yml")
function M.resolve_project_path(path)
  if str.is_empty(path) then
    return path
  end

  if path:sub(1, 1) == '/' then
    if quarto.project.directory then
      return pandoc.path.join({ quarto.project.directory, path:sub(2) })
    else
      return path:sub(2)
    end
  else
    return path
  end
end

-- ============================================================================
-- FILE TYPE CHECKS
-- ============================================================================

--- Check if URI has one of the specified extensions.
--- Performs case-insensitive extension matching by default.
--- Extensions can be provided with or without leading dot.
---
--- @param uri string|nil File URI to check
--- @param extensions table<integer, string> Array of extensions (e.g., {".md", "qmd", ".txt"})
--- @param case_sensitive boolean|nil Whether to match case-sensitively (default: false)
--- @return boolean True if URI ends with one of the extensions, false otherwise
--- @usage local is_md = M.has_extension("file.md", {".md", ".markdown"}) -- returns true
--- @usage local is_md = M.has_extension("file.MD", {".md"}, true) -- returns false (case-sensitive)
function M.has_extension(uri, extensions, case_sensitive)
  if uri == nil or uri == '' or extensions == nil then
    return false
  end

  --- @type string URI for matching (lowercase if case-insensitive)
  local match_uri = case_sensitive and uri or uri:lower()

  for _, ext in ipairs(extensions) do
    --- @type string Extension to match (ensure it starts with dot)
    local match_ext = ext
    if not match_ext:match('^%.') then
      match_ext = '.' .. match_ext
    end

    --- @type string Extension for matching (lowercase if case-insensitive)
    if not case_sensitive then
      match_ext = match_ext:lower()
    end

    -- Check if URI ends with this extension
    if match_uri:match('%' .. match_ext .. '$') then
      return true
    end
  end

  return false
end

--- Check if URI is a markdown file.
--- Convenience function to check for markdown extensions: .md, .markdown, .qmd
---
--- @param uri string|nil File URI to check
--- @return boolean True if markdown file, false otherwise
--- @usage local is_markdown = M.is_markdown("doc.qmd") -- returns true
function M.is_markdown(uri)
  return M.has_extension(uri, { '.md', '.markdown', '.qmd' })
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return M
