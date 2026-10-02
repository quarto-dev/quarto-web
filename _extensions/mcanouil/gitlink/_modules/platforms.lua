--- Platform Configuration Module
--- @module "platforms"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

local platforms_module = {}

-- Load platform schema validation module
local platform_schema = require(quarto.utils.resolve_path('_modules/platform-schema.lua'):gsub('%.lua$', ''))

-- ============================================================================
-- CONFIGURATION STORAGE
-- ============================================================================

--- @type table<string, table> Platform configurations cache
local platform_configs = nil

--- @type table<string, table> Custom platform configurations
local custom_platforms = {}

--- @type table<string, table> Validation results for last loaded platforms
local validation_results = {}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

--- Check if a value is empty or nil
--- @param val any The value to check
--- @return boolean True if the value is nil or empty, false otherwise
local function is_empty(val)
  return val == nil or val == ''
end

--- Convert YAML value to Lua table structure
--- @param yaml_value any The YAML value to convert
--- @return any The converted value
local function convert_yaml_value(yaml_value)
  local yaml_type = pandoc.utils.type(yaml_value)

  if yaml_type == 'Inlines' or yaml_type == 'Blocks' then
    return pandoc.utils.stringify(yaml_value)
  elseif yaml_type == 'List' then
    local result = {}
    for i = 1, #yaml_value do
      result[i] = convert_yaml_value(yaml_value[i])
    end
    return result
  elseif type(yaml_value) == 'table' then
    local result = {}
    for key, value in pairs(yaml_value) do
      local converted_key = key:gsub('-', '_')
      result[converted_key] = convert_yaml_value(value)
    end
    return result
  else
    return yaml_value
  end
end

-- ============================================================================
-- CONFIGURATION LOADING
-- ============================================================================

--- Load platform configurations from YAML file
--- @param yaml_path string|nil Optional path to custom YAML file
--- @return table<string, table>|nil The platform configurations or nil on error
--- @usage local configs = platforms_module.load_platforms('custom-platforms.yml')
local function load_platforms(yaml_path)
  local config_path = yaml_path or quarto.utils.resolve_path('platforms.yml')

  local file = io.open(config_path, 'r')
  if not file then
    return nil
  end
  local content = file:read('*all')
  file:close()

  local success, result = pcall(function()
    local meta = pandoc.read('---\n' .. content .. '\n---', 'markdown').meta
    if meta and meta.platforms then
      return convert_yaml_value(meta.platforms)
    end
    return nil
  end)

  if success and result then
    return result
  end

  return nil
end

--- Initialise platform configurations
--- Loads platforms from YAML and validates them
--- @param yaml_path string|nil Optional path to custom YAML file
--- @return boolean, string|nil True if initialisation was successful, error message if failed
--- @usage local ok, err = platforms_module.initialise('custom-platforms.yml')
function platforms_module.initialise(yaml_path)
  if platform_configs and not yaml_path then
    return true, nil
  end

  local loaded_configs = load_platforms(yaml_path)

  if not loaded_configs then
    if not platform_configs then
      platform_configs = {}
    end
    local msg = yaml_path and ('Failed to load platforms from ' .. yaml_path) or 'Failed to load built-in platforms'
    return false, msg
  end

  local validation_results_all = platform_schema.validate_all_platforms(loaded_configs)
  local has_errors = false
  local error_messages = {}

  for platform_name, result in pairs(validation_results_all) do
    if not result.valid then
      has_errors = true
      local platform_errors = {}
      for _, err in ipairs(result.errors) do
        table.insert(platform_errors, '  - ' .. err)
      end
      table.insert(error_messages, platform_name .. ':\n' .. table.concat(platform_errors, '\n'))
    end
  end

  if has_errors then
    local msg = table.concat(error_messages, '\n')
    return false, msg
  end

  if platform_configs and yaml_path then
    for name, config in pairs(loaded_configs) do
      custom_platforms[name] = config
      validation_results[name] = validation_results_all[name]
    end
  else
    platform_configs = loaded_configs
  end

  return true, nil
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

--- Get platform configuration by name
--- @param platform_name string The platform name
--- @return table|nil The platform configuration or nil if not found
--- @usage local config = platforms_module.get_platform_config('github')
function platforms_module.get_platform_config(platform_name)
  if not platform_configs then
    platforms_module.initialise()
  end

  local name_lower = platform_name:lower()

  if custom_platforms[name_lower] then
    return custom_platforms[name_lower]
  end

  if platform_configs and platform_configs[name_lower] then
    return platform_configs[name_lower]
  end

  return nil
end

--- Get platform display name
--- Returns the display name from the platform configuration or a capitalised default
--- @param platform_name string The platform name
--- @return string The platform display name
--- @usage local name = platforms_module.get_platform_display_name('github')
function platforms_module.get_platform_display_name(platform_name)
  local config = platforms_module.get_platform_config(platform_name)
  if config and config.display_name then
    return config.display_name
  end
  local name_str = tostring(platform_name)
  return name_str:sub(1, 1):upper() .. name_str:sub(2)
end

--- Get all available platform names
--- @return table<integer, string> List of available platform names
--- @usage local platforms = platforms_module.get_all_platform_names()
function platforms_module.get_all_platform_names()
  if not platform_configs then
    platforms_module.initialise()
  end

  local names = {}

  if platform_configs then
    for name, _ in pairs(platform_configs) do
      table.insert(names, name)
    end
  end

  for name, _ in pairs(custom_platforms) do
    if not platform_configs or not platform_configs[name] then
      table.insert(names, name)
    end
  end

  table.sort(names)
  return names
end

--- Register a custom platform configuration
--- Validates the configuration against the schema before registration
--- @param platform_name string The platform name
--- @param config table The platform configuration
--- @return boolean, string|nil True if registration was successful, error message if failed
--- @usage local ok, err = platforms_module.register_custom_platform('forgejo', {...})
function platforms_module.register_custom_platform(platform_name, config)
  if not platform_name or not config then
    return false, 'Platform name and configuration are required'
  end

  local result = platform_schema.validate_platform(platform_name, config)

  if not result.valid then
    local error_lines = {}
    for _, err in ipairs(result.errors) do
      table.insert(error_lines, '  - ' .. err)
    end
    local error_msg = 'Invalid platform configuration "' .. platform_name .. '":\n' .. table.concat(error_lines, '\n')
    return false, error_msg
  end

  local name_lower = platform_name:lower()
  custom_platforms[name_lower] = config
  validation_results[name_lower] = result

  return true, nil
end

--- Load custom platform from YAML string
--- Parses YAML and registers the platform with full validation
--- @param yaml_string string The YAML string containing platform configuration
--- @param platform_name string The platform name to register
--- @return boolean, string|nil True if registration was successful, error message if failed
--- @usage local ok, err = platforms_module.load_custom_platform_from_yaml(yaml_str, 'forgejo')
function platforms_module.load_custom_platform_from_yaml(yaml_string, platform_name)
  if is_empty(yaml_string) or is_empty(platform_name) then
    return false, 'YAML string and platform name are required'
  end

  local success, result = pcall(function()
    local meta = pandoc.read('---\n' .. yaml_string .. '\n---', 'markdown').meta
    if meta and meta.platforms and meta.platforms[platform_name] then
      return convert_yaml_value(meta.platforms[platform_name])
    end
    return nil
  end)

  if not success then
    return false, 'Failed to parse YAML: ' .. tostring(result)
  end

  if not result then
    return false, 'No platform configuration found for "' .. platform_name .. '" in YAML'
  end

  return platforms_module.register_custom_platform(platform_name, result)
end

--- Clear all custom platform configurations
--- @return nil
--- @usage platforms_module.clear_custom_platforms()
function platforms_module.clear_custom_platforms()
  custom_platforms = {}
end

--- Check if a platform is available
--- @param platform_name string The platform name
--- @return boolean True if the platform is available, false otherwise
--- @usage local available = platforms_module.is_platform_available('github')
function platforms_module.is_platform_available(platform_name)
  local name_lower = platform_name:lower()
  return platforms_module.get_platform_config(name_lower) ~= nil
end

--- Get the validation result for a platform
--- @param platform_name string The platform name
--- @return table|nil The validation result or nil if not found
--- @usage local result = platforms_module.get_validation_result('forgejo')
function platforms_module.get_validation_result(platform_name)
  local name_lower = platform_name:lower()
  return validation_results[name_lower]
end

--- Validate a platform configuration against the schema
--- Useful for testing custom platforms before registering them
--- @param platform_name string The platform name
--- @param config table The platform configuration to validate
--- @return table ValidationResult with valid, errors, warnings, and info fields
--- @usage
---   local result = platforms_module.validate_platform_config('forgejo', config)
---   if result.valid then print('OK') else print(table.concat(result.errors, ', ')) end
function platforms_module.validate_platform_config(platform_name, config)
  return platform_schema.validate_platform(platform_name, config)
end

--- Validate all platforms in a configuration table
--- Useful for validating entire custom platform files
--- @param platforms table Table of platform configurations
--- @return table<string, table> ValidationResult for each platform
--- @usage
---   local results = platforms_module.validate_all_platforms(platforms_config)
function platforms_module.validate_all_platforms(platforms)
  return platform_schema.validate_all_platforms(platforms)
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return platforms_module
