--- MC Bitbucket - Bitbucket-specific functionality for gitlink extension
--- @module "bitbucket"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

local str = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/string.lua'):gsub('%.lua$', ''))

local bitbucket_module = {}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

--- Create a Bitbucket link with platform label
--- @param text string The link text
--- @param uri string The URI
--- @param create_link_fn function The link creation function from main filter
--- @return pandoc.Link A Pandoc Link element with platform label
local function create_bitbucket_link(text, uri, create_link_fn)
  return create_link_fn(text, uri, "bitbucket")
end

--- Try matching a Str element's text against a pattern, with stripping fallback.
--- @param elem_text string The text to match
--- @param pattern string The Lua pattern (anchored with ^ and $)
--- @return string|nil prefix Stripped prefix (empty if direct match)
--- @return string|nil ... Captures from the pattern match
--- @return string|nil suffix Stripped suffix (empty if direct match)
local function match_with_stripping(elem_text, pattern)
  local captures = { elem_text:match("^" .. pattern .. "$") }
  if #captures > 0 then
    return "", captures, ""
  end

  local prefix, inner, suffix = str.strip_surrounding(elem_text)
  if (prefix ~= "" or suffix ~= "") and inner ~= "" then
    captures = { inner:match("^" .. pattern .. "$") }
    if #captures > 0 then
      return prefix, captures, suffix
    end
  end

  local search_pos = 1
  while true do
    local b_prefix, b_content, b_suffix, open_pos = str.find_bracketed_content(elem_text, search_pos)
    if not b_content then
      break
    end
    captures = { b_content:match("^" .. pattern .. "$") }
    if #captures > 0 then
      return b_prefix, captures, b_suffix
    end
    search_pos = open_pos + 1
  end

  return nil, nil, nil
end

-- ============================================================================
-- BITBUCKET MULTI-WORD PATTERN PROCESSING
-- ============================================================================

--- Process Bitbucket-style multi-word patterns in inline sequences
--- This function handles patterns like "issue #123" and "pull request #456"
--- according to https://support.atlassian.com/bitbucket-cloud/docs/markup-comments/
--- @param inlines table List of inline elements
--- @param base_url string The base URL for the Bitbucket instance
--- @param repository_name string|nil The repository name (e.g., "owner/repo")
--- @param create_link_fn function The link creation function from main filter
--- @return table Modified list of inline elements
--- @usage local result = bitbucket_module.process_inlines(inlines, "https://bitbucket.org", "owner/repo", create_platform_link)
function bitbucket_module.process_inlines(inlines, base_url, repository_name, create_link_fn)
  local result = {}
  local i = 1

  while i <= #inlines do
    local matched = false

    -- Try to match "issue #123" pattern
    if i + 2 <= #inlines then
      local elem1, elem2, elem3 = inlines[i], inlines[i + 1], inlines[i + 2]
      if elem1.t == "Str" and elem1.text == "issue" and
          elem2.t == "Space" and
          elem3.t == "Str" then
        local prefix, captures, suffix = match_with_stripping(elem3.text, "#(%d+)")
        if captures then
          local number = captures[1]
          local uri
          if repository_name then
            uri = base_url .. "/" .. repository_name .. "/issues/" .. number
          else
            return inlines
          end
          local link = create_bitbucket_link("issue #" .. number, uri, create_link_fn)
          if link then
            if prefix ~= "" then table.insert(result, pandoc.Str(prefix)) end
            table.insert(result, link)
            if suffix ~= "" then table.insert(result, pandoc.Str(suffix)) end
            i = i + 3
            matched = true
          end
        end
      end
    end

    -- Try to match "issue owner/repo#123" pattern
    if not matched and i + 2 <= #inlines then
      local elem1, elem2, elem3 = inlines[i], inlines[i + 1], inlines[i + 2]
      if elem1.t == "Str" and elem1.text == "issue" and
          elem2.t == "Space" and
          elem3.t == "Str" then
        local prefix, captures, suffix = match_with_stripping(elem3.text, "([^/]+/[^/#]+)#(%d+)")
        if captures then
          local repo, number = captures[1], captures[2]
          local uri = base_url .. "/" .. repo .. "/issues/" .. number
          local link = create_bitbucket_link("issue " .. repo .. "#" .. number, uri, create_link_fn)
          if link then
            if prefix ~= "" then table.insert(result, pandoc.Str(prefix)) end
            table.insert(result, link)
            if suffix ~= "" then table.insert(result, pandoc.Str(suffix)) end
            i = i + 3
            matched = true
          end
        end
      end
    end

    -- Try to match "pull request #456" pattern
    if not matched and i + 4 <= #inlines then
      local elem1, elem2, elem3, elem4, elem5 = inlines[i], inlines[i + 1], inlines[i + 2], inlines[i + 3], inlines[i + 4]
      if elem1.t == "Str" and elem1.text == "pull" and
          elem2.t == "Space" and
          elem3.t == "Str" and elem3.text == "request" and
          elem4.t == "Space" and
          elem5.t == "Str" then
        local prefix, captures, suffix = match_with_stripping(elem5.text, "#(%d+)")
        if captures then
          local number = captures[1]
          local uri
          if repository_name then
            uri = base_url .. "/" .. repository_name .. "/pull-requests/" .. number
          else
            return inlines
          end
          local link = create_bitbucket_link("pull request #" .. number, uri, create_link_fn)
          if link then
            if prefix ~= "" then table.insert(result, pandoc.Str(prefix)) end
            table.insert(result, link)
            if suffix ~= "" then table.insert(result, pandoc.Str(suffix)) end
            i = i + 5
            matched = true
          end
        end
      end
    end

    -- Try to match "pull request owner/repo#456" pattern
    if not matched and i + 4 <= #inlines then
      local elem1, elem2, elem3, elem4, elem5 = inlines[i], inlines[i + 1], inlines[i + 2], inlines[i + 3], inlines[i + 4]
      if elem1.t == "Str" and elem1.text == "pull" and
          elem2.t == "Space" and
          elem3.t == "Str" and elem3.text == "request" and
          elem4.t == "Space" and
          elem5.t == "Str" then
        local prefix, captures, suffix = match_with_stripping(elem5.text, "([^/]+/[^/#]+)#(%d+)")
        if captures then
          local repo, number = captures[1], captures[2]
          local uri = base_url .. "/" .. repo .. "/pull-requests/" .. number
          local link = create_bitbucket_link("pull request " .. repo .. "#" .. number, uri, create_link_fn)
          if link then
            if prefix ~= "" then table.insert(result, pandoc.Str(prefix)) end
            table.insert(result, link)
            if suffix ~= "" then table.insert(result, pandoc.Str(suffix)) end
            i = i + 5
            matched = true
          end
        end
      end
    end

    if not matched then
      table.insert(result, inlines[i])
      i = i + 1
    end
  end

  return result
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return bitbucket_module
