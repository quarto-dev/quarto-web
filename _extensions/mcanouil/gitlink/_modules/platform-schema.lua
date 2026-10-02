--- MC Platform Schema - Validator for gitlink platform configurations (platforms.yml)
--- @module "platform-schema"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

local platform_schema = {}

-- ============================================================================
-- CONSTANTS
-- ============================================================================

--- Required pattern types that must exist in every platform configuration
--- @type table<integer, string>
local REQUIRED_PATTERN_TYPES = { 'issue', 'merge_request', 'commit', 'user' }

--- Required URL format types for platform configurations
--- @type table<integer, string>
local REQUIRED_URL_FORMAT_TYPES = { 'issue', 'merge_request', 'pull', 'commit', 'user' }

--- Validation error severity levels
--- @type table<string, integer>
local ERROR_LEVELS = {
  ERROR = 1,
  WARNING = 2,
  INFO = 3
}

-- ============================================================================
-- VALIDATION RESULT CLASS
-- ============================================================================

--- Validation result object containing errors, warnings, and metadata
--- @class ValidationResult
--- @field valid boolean Whether validation passed without errors
--- @field errors table<integer, string> List of error messages
--- @field warnings table<integer, string> List of warning messages
--- @field info table<integer, string> List of informational messages

--- Create a new validation result
--- @return ValidationResult
local function create_validation_result()
  return {
    valid = true,
    errors = {},
    warnings = {},
    info = {}
  }
end

--- Add an error to the validation result
--- @param result ValidationResult The validation result to update
--- @param message string The error message
--- @return nil
local function add_error(result, message)
  table.insert(result.errors, message)
  result.valid = false
end

--- Add a warning to the validation result
--- @param result ValidationResult The validation result to update
--- @param message string The warning message
--- @return nil
local function add_warning(result, message)
  table.insert(result.warnings, message)
end

--- Add an informational message to the validation result
--- @param result ValidationResult The validation result to update
--- @param message string The informational message
--- @return nil
local function add_info(result, message)
  table.insert(result.info, message)
end

-- ============================================================================
-- TYPE VALIDATION HELPERS
-- ============================================================================

--- Check if a value is a string
--- @param val any The value to check
--- @return boolean
local function is_string(val)
  return type(val) == 'string'
end

--- Check if a value is a table
--- @param val any The value to check
--- @return boolean
local function is_table(val)
  return type(val) == 'table'
end

--- Check if a value is an array (table with numeric keys)
--- @param val any The value to check
--- @return boolean
local function is_array(val)
  if not is_table(val) then
    return false
  end
  for k, _ in pairs(val) do
    if not (type(k) == 'number' and k > 0 and k == math.floor(k)) then
      return false
    end
  end
  return true
end

--- Check if a Lua regex pattern is valid
--- @param pattern string The pattern to validate
--- @return boolean, string|nil Whether valid, and error message if invalid
local function is_valid_lua_pattern(pattern)
  if not is_string(pattern) then
    return false, 'Pattern must be a string'
  end

  local success, err = pcall(function()
    _ = string.find('test', pattern)
  end)

  if not success then
    return false, tostring(err)
  end

  return true, nil
end

--- Check if a URL format template is valid
--- @param url_format string The URL format string to validate
--- @return boolean, string|nil Whether valid, and error message if invalid
local function is_valid_url_format(url_format)
  if not is_string(url_format) then
    return false, 'URL format must be a string'
  end

  if not url_format:find('/', 1, true) then
    return false, 'URL format must start with a forward slash (e.g., "/{repo}/issues/{number}")'
  end

  if not url_format:match('{') then
    return false, 'URL format must contain at least one placeholder (e.g., {repo}, {number})'
  end

  return true, nil
end

--- Check if a URL is valid format
--- @param url string The URL to validate
--- @return boolean, string|nil Whether valid, and error message if invalid
local function is_valid_base_url(url)
  if not is_string(url) then
    return false, 'Base URL must be a string'
  end

  if url:find('^https?://', 1) == nil then
    return false, 'Base URL must start with http:// or https://'
  end

  return true, nil
end

-- ============================================================================
-- SCHEMA VALIDATORS
-- ============================================================================

--- Validate a pattern object (array of patterns or single string for user)
--- @param patterns any The patterns to validate
--- @param pattern_type string The type of pattern (for error messages)
--- @param result ValidationResult The validation result to update
--- @return nil
local function validate_patterns(patterns, pattern_type, result)
  if not patterns then
    local hint = 'Expected: patterns:\n      ' .. pattern_type:gsub('_', '-') .. ': [\'pattern1\', \'pattern2\']'
    add_error(result, string.format('Missing required pattern type: "%s" (%s)', pattern_type:gsub('_', '-'), hint))
    return
  end

  if pattern_type == 'user' and is_string(patterns) then
    local valid, err = is_valid_lua_pattern(patterns)
    if not valid then
      add_error(result, string.format('Invalid Lua regex in user: %s (e.g., "@([%%w%%-%%%%]+)")', err))
    end
    return
  end

  if not is_array(patterns) then
    add_error(
      result,
      string.format(
        'Pattern type "%s" must be an array of patterns, got %s (e.g., [\'#(%%d+)\', \'owner/repo#(%%d+)\'])',
        pattern_type:gsub('_', '-'), type(patterns))
    )
    return
  end

  if #patterns == 0 then
    add_warning(result,
      string.format('Pattern type "%s" is empty (add at least one pattern)', pattern_type:gsub('_', '-')))
    return
  end

  for i, pattern in ipairs(patterns) do
    local valid, err = is_valid_lua_pattern(pattern)
    if not valid then
      add_error(result, string.format('Invalid Lua regex in %s[%d]: %s', pattern_type:gsub('_', '-'), i, err))
    end
  end
end

--- Validate the patterns section of a platform configuration
--- @param patterns any The patterns object to validate
--- @param result ValidationResult The validation result to update
--- @return nil
local function validate_patterns_section(patterns, result)
  if not patterns then
    add_error(result,
      'Missing required field: "patterns" (add patterns section with: issue, merge-request, commit, user)')
    return
  end

  if not is_table(patterns) then
    add_error(result, string.format('Field "patterns" must be a table, got %s', type(patterns)))
    return
  end

  for _, pattern_type in ipairs(REQUIRED_PATTERN_TYPES) do
    validate_patterns(patterns[pattern_type], pattern_type, result)
  end

  for key, _ in pairs(patterns) do
    local found = false
    for _, pattern_type in ipairs(REQUIRED_PATTERN_TYPES) do
      if key == pattern_type then
        found = true
        break
      end
    end
    if not found then
      add_warning(result, string.format('Unknown pattern type: "%s" (not recognised)', key:gsub('_', '-')))
    end
  end
end

--- Validate the url-formats section of a platform configuration
--- @param url_formats any The url-formats object to validate
--- @param result ValidationResult The validation result to update
--- @return nil
local function validate_url_formats_section(url_formats, result)
  if not url_formats then
    add_error(result,
      'Missing required field: "url-formats" (add url-formats section with: issue, pull, merge-request, commit, user)')
    return
  end

  if not is_table(url_formats) then
    add_error(result, string.format('Field "url-formats" must be a table, got %s', type(url_formats)))
    return
  end

  for _, format_type in ipairs(REQUIRED_URL_FORMAT_TYPES) do
    local format = url_formats[format_type]
    if not format then
      local hint = format_type == 'issue' and '/{repo}/issues/{number}' or
          format_type == 'pull' and '/{repo}/pull/{number}' or
          format_type == 'merge_request' and '/{repo}/pull/{number}' or
          format_type == 'commit' and '/{repo}/commit/{sha}' or
          format_type == 'user' and '/{username}' or '/{path}'
      add_error(result, string.format('Missing required URL format: "%s" (e.g., "%s")', format_type:gsub('_', '-'), hint))
    else
      local valid, err = is_valid_url_format(format)
      if not valid then
        add_error(result, string.format('Invalid url-formats.%s: %s', format_type:gsub('_', '-'), err))
      end
    end
  end

  for key, _ in pairs(url_formats) do
    local found = false
    for _, format_type in ipairs(REQUIRED_URL_FORMAT_TYPES) do
      if key == format_type then
        found = true
        break
      end
    end
    if not found then
      add_warning(result, string.format('Unknown URL format type: "%s" (not recognised)', key:gsub('_', '-')))
    end
  end
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

--- Validate a complete platform configuration
--- Checks schema, types, patterns, and URLs
--- @param platform_name string The name of the platform being validated
--- @param config table The platform configuration to validate
--- @return ValidationResult
--- @usage
---   local result = platform_schema.validate_platform('github', config)
---   if not result.valid then
---     for _, err in ipairs(result.errors) do
---       print('ERROR: ' .. err)
---     end
---   end
function platform_schema.validate_platform(platform_name, config)
  local result = create_validation_result()

  if not is_string(platform_name) or platform_name == '' then
    add_error(result, 'Platform name must be a non-empty string')
    return result
  end

  if not is_table(config) then
    add_error(result, string.format('Platform configuration must be a table, got %s', type(config)))
    return result
  end

  if not config.base_url then
    add_error(result, 'Missing required field: "base-url" (e.g., https://github.com)')
  else
    local valid, err = is_valid_base_url(config.base_url)
    if not valid then
      add_error(result, string.format('Invalid base-url: %s (e.g., https://git.example.com)', err))
    end
  end

  validate_patterns_section(config.patterns, result)

  validate_url_formats_section(config.url_formats, result)

  return result
end

--- Validate all platforms in a configuration table
--- @param platforms table Table of platform configurations keyed by name
--- @return table<string, ValidationResult> Validation results for each platform
--- @usage
---   local results = platform_schema.validate_all_platforms(platforms_config)
function platform_schema.validate_all_platforms(platforms)
  local results = {}

  if not is_table(platforms) then
    results['__global__'] = create_validation_result()
    add_error(results['__global__'], 'Platforms configuration must be a table')
    return results
  end

  for platform_name, config in pairs(platforms) do
    results[platform_name] = platform_schema.validate_platform(platform_name, config)
  end

  return results
end

--- Format validation results as human-readable strings
--- @param result ValidationResult The validation result to format
--- @return string, string|nil Formatted message, and platform_name if provided
--- @usage
---   local msg = platform_schema.format_result(result)
---   print(msg)
function platform_schema.format_result(result)
  local lines = {}

  if result.valid then
    table.insert(lines, 'Validation passed.')
  else
    table.insert(lines, 'Validation failed with ' .. #result.errors .. ' error(s):')
    for i, err in ipairs(result.errors) do
      table.insert(lines, string.format('  [Error %d] %s', i, err))
    end
  end

  if #result.warnings > 0 then
    table.insert(lines, '')
    table.insert(lines, #result.warnings .. ' warning(s):')
    for i, warn in ipairs(result.warnings) do
      table.insert(lines, string.format('  [Warning %d] %s', i, warn))
    end
  end

  if #result.info > 0 then
    table.insert(lines, '')
    table.insert(lines, #result.info .. ' info message(s):')
    for i, info in ipairs(result.info) do
      table.insert(lines, string.format('  [Info %d] %s', i, info))
    end
  end

  return table.concat(lines, '\n')
end

--- Get a summary of validation errors and warnings
--- @param result ValidationResult The validation result
--- @return string Summary string
--- @usage
---   local summary = platform_schema.get_summary(result)
function platform_schema.get_summary(result)
  return string.format(
    'Status: %s | Errors: %d | Warnings: %d',
    result.valid and 'PASSED' or 'FAILED',
    #result.errors,
    #result.warnings
  )
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return platform_schema
