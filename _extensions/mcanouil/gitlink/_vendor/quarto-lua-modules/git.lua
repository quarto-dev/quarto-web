--- MC Git - Git repository utilities for Quarto Lua filters and shortcodes
--- @module "git"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

local M = {}

-- ============================================================================
-- GIT REPOSITORY UTILITIES
-- ============================================================================

--- Check if a string is empty or nil
--- @param s string|nil The string to check
--- @return boolean true if the string is nil or empty
local function is_empty(s)
  return s == nil or s == ''
end

--- Get repository name from git remote origin URL
--- Executes shell command to extract repository name from git remote
--- @return string|nil The repository name (e.g., "owner/repo") or nil if not found
--- @usage local repo = M.get_repository()
function M.get_repository()
  local is_windows = package.config:sub(1, 1) == '\\'
  local remote_repository_command

  if is_windows then
    remote_repository_command = "(git remote get-url origin) -replace '.*[:/](.+?)(\\.git)?$', '$1'"
  else
    remote_repository_command = "git remote get-url origin 2>/dev/null | sed -E 's|.*[:/]([^/]+/[^/.]+)(\\.git)?$|\\1|'"
  end

  local handle = io.popen(remote_repository_command)
  if handle then
    local git_repo = handle:read('*a'):gsub('%s+$', '')
    handle:close()
    if not is_empty(git_repo) then
      return git_repo
    end
  end

  return nil
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return M
