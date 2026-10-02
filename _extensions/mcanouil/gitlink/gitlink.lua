--- @module "gitlink"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

--- Extension name constant
local EXTENSION_NAME = 'gitlink'

--- Load modules
local str = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/string.lua'):gsub('%.lua$', ''))
local log = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/logging.lua'):gsub('%.lua$', ''))
local meta_mod = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/metadata.lua'):gsub('%.lua$', ''))
local html_mod = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/html.lua'):gsub('%.lua$', ''))
local paths = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/paths.lua'):gsub('%.lua$', ''))
local git = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/git.lua'):gsub('%.lua$', ''))
local bitbucket = require(quarto.utils.resolve_path('_modules/bitbucket.lua'):gsub('%.lua$', ''))
local platforms = require(quarto.utils.resolve_path('_modules/platforms.lua'):gsub('%.lua$', ''))
local colour = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/colour.lua'):gsub('%.lua$', ''))
local widget = require(quarto.utils.resolve_path('_modules/widget.lua'):gsub('%.lua$', ''))
local schema = require(quarto.utils.resolve_path('_vendor/quarto-wizard/schema.lua'):gsub('%.lua$', ''))
local check = require(quarto.utils.resolve_path('_vendor/quarto-lua-modules/schema-check.lua'):gsub('%.lua$', ''))

--- Checks the document configuration against `_schema.yml` and reports what the
--- extension cannot use.
--- The validator is injected rather than required by the checker, so the two
--- vendored sources stay independent of each other.
--- The schema is read once here, at file scope, rather than once per document.
--- An unreadable schema is reported and never stops a render, because a fault
--- in the configuration must not remove the document.
local checker = check.new(schema, EXTENSION_NAME)

--- @type string The platform type (github, gitlab, codeberg, gitea, bitbucket)
local platform = 'github'

--- @type string|nil The repository name (e.g., "owner/repo")
local repository_name = nil

--- @type string The base URL for the Git hosting platform
local base_url = 'https://github.com'

--- @type table<string, boolean> Set of reference IDs from the document
local references_ids_set = {}

--- @type table<string, boolean> Set of citation IDs forced to be treated as mentions
local force_mentions_set = {}

--- @type boolean Whether the filter is enabled for this document
local is_enabled = true

--- @type boolean Whether to show visible platform badges
local show_platform_badge = true

--- @type string Badge position: "after" or "before"
local badge_position = 'after'

--- @type string Badge background colour (hex or colour name)
local badge_background_colour = '#c3c3c3'

--- @type string|nil Badge text colour (hex or colour name)
local badge_text_colour = nil

--- @type boolean Whether to shorten link text matching platform URLs
local normalize_links = true

--- @type boolean Whether to fetch issue/PR/commit titles for link text
local fetch_titles = false

--- @type table<string, string> Cache of fetched titles by URL
local title_cache = {}

--- @type table<string, table|false> Cached platform configurations by name (per render); false means "looked up and not found"
local platform_config_cache = {}

--- @type table<integer, string>|nil Cached list of all known platform names (per render)
local all_platform_names_cache = nil

--- @type integer Full length of a git commit SHA
local COMMIT_SHA_FULL_LENGTH = 40

--- @type integer Short length for displaying commit SHA
local COMMIT_SHA_SHORT_LENGTH = 7

--- @type integer Minimum length for a valid git commit SHA
local COMMIT_SHA_MIN_LENGTH = 7

--- @type string Lua pattern matching a 3-, 4-, 6-, or 8-character hex colour with leading #
local HEX_COLOUR_PATTERN = '^#%x%x%x%x?%x?%x?%x?%x?$'

--- @type string Class Quarto puts on the markdown-pipeline envelope elements
local MARKDOWN_ENVELOPE_CLASS = 'quarto-markdown-envelope-contents'

--- Validate a colour value as a hex code or CSS named colour.
--- Returns the original value if valid, or nil if invalid.
--- @param value string|nil The candidate colour value
--- @param option_label string The metadata option name (for warnings)
--- @return string|nil The validated colour value, or nil if invalid
local function validate_colour(value, option_label)
  if str.is_empty(value) then
    return nil
  end
  local s = value --[[@as string]]
  if s:match(HEX_COLOUR_PATTERN) or colour.is_named_colour(s) then
    return s
  end
  log.log_warning(
    EXTENSION_NAME,
    "Ignoring invalid '" .. option_label .. "' value '" .. s ..
    "': expected a hex colour (e.g. '#c3c3c3') or a CSS named colour."
  )
  return nil
end

--- Convert a validated colour value to its hex form for Typst rgb().
--- Hex codes are returned unchanged; CSS named colours are resolved via
--- the colour module. Assumes the value has already been validated.
--- @param value string The colour value (hex code or CSS named colour)
--- @return string The hex form
local function colour_to_hex(value)
  if value:match(HEX_COLOUR_PATTERN) then
    return value
  end
  return colour.named_to_HTML(value)
end

--- Reset all module-level state to defaults.
--- Quarto can render multiple documents in one process, so module-level state
--- from a previous document must be cleared at the start of each Meta pass.
local function reset_state()
  platform = 'github'
  repository_name = nil
  base_url = 'https://github.com'
  references_ids_set = {}
  force_mentions_set = {}
  is_enabled = true
  show_platform_badge = true
  badge_position = 'after'
  badge_background_colour = '#c3c3c3'
  badge_text_colour = nil
  normalize_links = true
  fetch_titles = false
  title_cache = {}
  platform_config_cache = {}
  all_platform_names_cache = nil
  if platforms.clear_custom_platforms then
    platforms.clear_custom_platforms()
  end
  -- Dependency tracking is per document; without a reset, dependencies added
  -- for a previous document in the same process would be skipped here.
  html_mod.reset_dependencies()
end

--- Get the cached list of all known platform names.
--- @return table<integer, string> List of platform names
local function get_all_platform_names()
  if not all_platform_names_cache then
    all_platform_names_cache = platforms.get_all_platform_names()
  end
  return all_platform_names_cache
end

--- Get platform configuration (cached per render).
--- Memoises lookups against `platform_config_cache` to avoid repeated calls
--- to the platforms module for every Str element in the document.
--- The cache stores `false` for "looked up and not found" so repeated misses
--- skip the underlying lookup.
--- @param platform_name string The platform name
--- @return table|nil The platform configuration or nil if not found
local function get_platform_config(platform_name)
  if not platform_name then
    return nil
  end
  local key = platform_name:lower()
  local cached = platform_config_cache[key]
  if cached ~= nil then
    return cached or nil
  end
  local config = platforms.get_platform_config(key)
  platform_config_cache[key] = config or false
  return config
end

--- Parse a full repository URL to extract platform, base-url, and owner/repo.
--- Matches the URL against all known platform base URLs.
--- @param url string The full repository URL (e.g., "https://github.com/owner/repo")
--- @return string|nil platform_name The matched platform name
--- @return string|nil matched_base_url The base URL portion
--- @return string|nil repo_path The owner/repo portion
local function parse_repo_url(url)
  local all_names = get_all_platform_names()
  for _, name in ipairs(all_names) do
    local config = get_platform_config(name)
    if config and config.base_url then
      local escaped = str.escape_pattern(config.base_url)
      local repo_path = url:match('^' .. escaped .. '/(.+)$')
      if repo_path then
        repo_path = repo_path:match('^([^%?#]+)') or repo_path
        repo_path = repo_path:gsub('%.git$', ''):gsub('/$', '')
        if not str.is_empty(repo_path) then
          return name, config.base_url, repo_path
        end
      end
    end
  end
  return nil, nil, nil
end

--- Create a link with platform label
--- @param text string|nil The link text
--- @param uri string|nil The URI
--- @param platform_name string|nil The platform name
--- @return pandoc.Link|pandoc.Span|nil A Pandoc Link element with platform label or Span containing link and badge
local function create_platform_link(text, uri, platform_name)
  if str.is_empty(uri) or str.is_empty(text) or str.is_empty(platform_name) then
    return nil
  end

  local platform_label = platforms.get_platform_display_name(platform_name --[[@as string]])

  local link_content = { pandoc.Str(text --[[@as string]]) }
  local link_attr = pandoc.Attr('', {}, {})

  if quarto.doc.is_format("html:js") or quarto.doc.is_format("html") then
    link_attr = pandoc.Attr('', {}, { title = platform_label })
    local link = pandoc.Link(link_content, uri --[[@as string]], '', link_attr)

    if show_platform_badge then
      local css_path = quarto.utils.resolve_path("gitlink.css")
      html_mod.ensure_html_dependency({
        name = 'quarto-gitlink',
        version = '1.0.0',
        stylesheets = { css_path }
      })

      local badge_classes = { 'gitlink-badge', 'badge', 'text-bg-secondary' }
      local badge_style = {}
      if not str.is_empty(badge_background_colour) then
        table.insert(badge_style, 'background-color: ' .. badge_background_colour .. ';')
      end
      if not str.is_empty(badge_text_colour) then
        table.insert(badge_style, 'color: ' .. badge_text_colour .. ';')
      end

      local badge_attr = pandoc.Attr(
        '',
        badge_classes,
        {
          title = platform_label,
          ['aria-label'] = platform_label .. ' platform',
          style = table.concat(badge_style, ' ')
        }
      )
      local badge = pandoc.Span({ pandoc.Str(platform_label) }, badge_attr)

      local inlines = {}
      if badge_position == "before" then
        inlines = { badge, pandoc.Space(), link }
      else
        inlines = { link, badge }
      end

      return pandoc.Span(inlines)
    else
      return link
    end
  elseif quarto.doc.is_format("typst") then
    local link = pandoc.Link(link_content, uri --[[@as string]], '', link_attr)

    if show_platform_badge then
      -- Typst rgb() only accepts hex strings, so convert any CSS-named colour
      -- (already validated at Meta time) to its hex equivalent.
      local bg_hex = colour_to_hex(badge_background_colour)
      local text_colour_opt = ''
      if not str.is_empty(badge_text_colour) then
        text_colour_opt = ', fill: rgb("' .. colour_to_hex(badge_text_colour --[[@as string]]) .. '")'
      end
      local badge_raw = '#box(fill: rgb("' ..
          bg_hex ..
          '"), inset: 2pt, outset: 0pt, radius: 3pt, baseline: -0.3em, text(size: 0.45em' ..
          text_colour_opt .. ', [' .. platform_label .. ']))'
      local badge = pandoc.RawInline('typst', ' ' .. badge_raw)

      local inlines = {}
      if badge_position == "before" then
        inlines = { badge, pandoc.Space(), link }
      else
        inlines = { link, badge }
      end

      return pandoc.Span(inlines)
    else
      return link
    end
  else
    table.insert(link_content, pandoc.Space())
    table.insert(link_content, pandoc.Str("(" .. platform_label .. ")"))
    return pandoc.Link(link_content, uri --[[@as string]], '', link_attr)
  end
end

--- Get repository name from metadata or git remote.
--- This function extracts the repository name either from document metadata
--- or by querying the git remote origin URL.
--- @param meta table The document metadata table.
--- @return table The metadata table (unchanged).
local function get_repository(meta)
  -- Reset module-level state at the start of every document so a previous
  -- render in a batch does not bleed into this one.
  reset_state()

  -- After the reset and before the first option read, so that every option this
  -- pass goes on to read has already been reported on.
  checker:options(meta)

  -- Allow opt-out at the document level for drafts, templates, or any
  -- document where automatic link rewriting is undesirable. The navbar
  -- widget is gated independently so a site can run widget-only with
  -- `enabled: false` and `widget.enabled: true`.
  local extensions_meta = meta and meta['extensions']
  local gitlink_meta = extensions_meta and extensions_meta['gitlink']
  local widget_meta = gitlink_meta and gitlink_meta['widget']
  local widget_enabled = widget.is_enabled(widget_meta)
  -- The schema decides each of these, so `enabled: no` turns the filter off.
  -- Reading the document itself treated every spelling but `false` as true,
  -- and treated every spelling but `true` as false one flag over.
  is_enabled = checker:option('enabled') ~= false
  if not is_enabled and not widget_enabled then
    return meta
  end

  local meta_platform = meta_mod.get_metadata_value(meta, 'gitlink', 'platform')
  local meta_base_url = meta_mod.get_metadata_value(meta, 'gitlink', 'base-url')
  local meta_repository = meta_mod.get_metadata_value(meta, 'gitlink', 'repository-name')
  local meta_custom_platforms = meta_mod.get_metadata_value(meta, 'gitlink', 'custom-platforms-file')

  if not str.is_empty(meta_custom_platforms) then
    local original_path = meta_custom_platforms --[[@as string]]
    local custom_file_path = paths.resolve_project_path(original_path)
    local ok, err = platforms.initialise(custom_file_path)
    if not ok then
      log.log_error(
        EXTENSION_NAME,
        "Failed to load custom platforms from '" .. original_path .. "':\n" .. (err or 'unknown error')
      )
      return meta
    end
  else
    local ok, err = platforms.initialise()
    if not ok then
      log.log_error(EXTENSION_NAME, "Failed to load built-in platforms:\n" .. (err or 'unknown error'))
      return meta
    end
  end

  -- Parse repo-url from project metadata (website/book)
  local project_repo_url = meta_mod.get_project_repo_url()
  local parsed_platform, parsed_base_url, parsed_repo_name = nil, nil, nil
  if project_repo_url then
    parsed_platform, parsed_base_url, parsed_repo_name = parse_repo_url(project_repo_url)
    if not parsed_platform then
      log.log_warning(
        EXTENSION_NAME,
        "Could not match project repo-url '" .. project_repo_url ..
        "' to any known platform. Falling back to default resolution."
      )
    end
  end

  -- Resolve platform: explicit metadata > repo-url detection > default 'github'
  if not str.is_empty(meta_platform) then
    platform = (meta_platform --[[@as string]]):lower()
  elseif parsed_platform then
    platform = parsed_platform
  else
    platform = 'github'
  end

  local config = get_platform_config(platform)
  if not config then
    local available_platforms = table.concat(get_all_platform_names(), ', ')
    log.log_error(
      EXTENSION_NAME,
      "Unsupported platform: '" .. platform ..
      "'. Supported platforms are: " .. available_platforms .. '.'
    )
    return meta
  end

  -- Resolve base-url: explicit metadata > repo-url detection > platform default
  if not str.is_empty(meta_base_url) then
    base_url = meta_base_url --[[@as string]]
  elseif parsed_base_url then
    base_url = parsed_base_url
  else
    base_url = config.base_url
  end

  -- Resolve repository-name: explicit metadata > repo-url path > git remote
  if not str.is_empty(meta_repository) then
    repository_name = meta_repository
  elseif parsed_repo_name then
    repository_name = parsed_repo_name
  else
    repository_name = git.get_repository()
  end

  show_platform_badge = checker:option('show-platform-badge') ~= false

  local badge_pos_meta = meta_mod.get_metadata_value(meta, 'gitlink', 'badge-position')
  if badge_pos_meta ~= nil then
    badge_position = badge_pos_meta --[[@as string]]
  end

  local badge_bg_colour_meta = meta_mod.get_metadata_value(meta, 'gitlink', 'badge-background-colour')
  if not str.is_empty(badge_bg_colour_meta) then
    local validated_bg = validate_colour(badge_bg_colour_meta --[[@as string]], 'badge-background-colour')
    if validated_bg then
      badge_background_colour = validated_bg
    end
  end

  local badge_text_colour_meta = meta_mod.get_metadata_value(meta, 'gitlink', 'badge-text-colour')
  if not str.is_empty(badge_text_colour_meta) then
    local validated_text = validate_colour(badge_text_colour_meta --[[@as string]], 'badge-text-colour')
    if validated_text then
      badge_text_colour = validated_text
    end
  end

  normalize_links = checker:option('normalize-links') ~= false

  fetch_titles = checker:option('fetch-titles') == true

  -- Read the optional `mentions` list (citation IDs to force-treat as mentions).
  -- Direct table access because get_metadata_value flattens lists via stringify.
  local mentions_meta = gitlink_meta and gitlink_meta['mentions']
  if mentions_meta then
    if type(mentions_meta) == 'table' then
      for _, mention in ipairs(mentions_meta) do
        local id = str.stringify(mention)
        if not str.is_empty(id) then
          force_mentions_set[id] = true
        end
      end
    else
      local id = str.stringify(mentions_meta)
      if not str.is_empty(id) then
        force_mentions_set[id] = true
      end
    end
  end

  if widget_enabled then
    widget.setup({
      extension_name = EXTENSION_NAME,
      widget_meta = widget_meta,
      platform = platform,
      platform_config = config,
      base_url = base_url,
      repository_name = repository_name,
      display_name = platforms.get_platform_display_name(platform),
    })
  end

  return meta
end

--- Extract and store reference IDs from the document
--- This function collects all reference IDs from the document to distinguish
--- between actual citations and Git hosting mentions
--- @param doc pandoc.Pandoc The Pandoc document
--- @return pandoc.Pandoc The document (unchanged)
local function get_references(doc)
  local references = pandoc.utils.references(doc)
  for _, reference in ipairs(references) do
    if reference.id then
      references_ids_set[reference.id] = true
    end
  end
  return doc
end

--- Process Git hosting mentions in citations.
--- Distinguishes between actual bibliography citations and Git hosting @mentions.
--- When the citation id appears in `gitlink.mentions`, the citation is forced
--- to be treated as a mention even if a reference with that id exists.
--- @param cite pandoc.Cite The citation element
--- @return pandoc.Cite|pandoc.Link The original citation or a Git hosting mention link
local function process_mentions(cite)
  if not is_enabled then
    return cite
  end
  local cite_id = cite.citations[1] and cite.citations[1].id
  if cite_id and not force_mentions_set[cite_id] and references_ids_set[cite_id] then
    return cite
  end
  local mention_text = str.stringify(cite.content)
  local config = get_platform_config(platform)
  if config and config.patterns.user then
    local username = mention_text:match(config.patterns.user)
    if username then
      local url_format = config.url_formats.user
      local uri = base_url .. url_format:gsub("{username}", username)
      local link = create_platform_link(mention_text, uri, platform)
      return link or cite
    end
  end
  return cite
end


--- Process issues and merge requests
--- @param elem pandoc.Str The string element to process
--- @param current_platform string The current platform name
--- @param current_base_url string The current base URL
--- @return pandoc.Link|nil A link or nil if no valid pattern found
--- @return string|nil The platform name used for this match
--- @return string|nil The base URL used for this match
local function process_issues_and_mrs(elem, current_platform, current_base_url)
  local config = get_platform_config(current_platform)
  if not config then
    return nil, nil, nil
  end

  local text = elem.text
  local repo = nil
  local number = nil
  local ref_type = nil
  local short_link = nil
  local matched_platform = current_platform
  local matched_base_url = current_base_url

  for _, pattern in ipairs(config.patterns.issue) do
    if pattern == "#(%d+)" and text:match("^#(%d+)$") then
      number = text:match("^#(%d+)$")
      repo = repository_name
      ref_type = "issue"
      short_link = "#" .. number
      break
    elseif pattern == "([^/]+/[^/#]+)#(%d+)" and text:match("^([^/]+/[^/#]+)#(%d+)$") then
      repo, number = text:match("^([^/]+/[^/#]+)#(%d+)$")
      ref_type = "issue"
      short_link = repo .. "#" .. number
      break
    elseif pattern == "GH%-(%d+)" and text:match("^GH%-(%d+)$") then
      number = text:match("^GH%-(%d+)$")
      repo = repository_name
      ref_type = "issue"
      short_link = "#" .. number
      break
    end
  end

  if not number and config.patterns.merge_request then
    for _, pattern in ipairs(config.patterns.merge_request) do
      if pattern == "!(%d+)" and text:match("^!(%d+)$") then
        number = text:match("^!(%d+)$")
        repo = repository_name
        ref_type = "merge_request"
        short_link = "!" .. number
        break
      elseif pattern == "([^/]+/[^/#]+)!(%d+)" and text:match("^([^/]+/[^/#]+)!(%d+)$") then
        repo, number = text:match("^([^/]+/[^/#]+)!(%d+)$")
        ref_type = "merge_request"
        short_link = repo .. "!" .. number
        break
      end
    end
  end

  if not number then
    local all_platform_names = get_all_platform_names()
    for _, platform_name in ipairs(all_platform_names) do
      local platform_config = get_platform_config(platform_name)
      if platform_config then
        local platform_base_url = platform_config.base_url
        local escaped_platform_url = str.escape_pattern(platform_base_url)
        local url_pattern_issue = '^' .. escaped_platform_url .. '/([^/]+/[^/]+)/%-?/?issues?/(%d+)'
        local url_pattern_mr = '^' .. escaped_platform_url .. '/([^/]+/[^/]+)/%-?/?merge[_%-]requests/(%d+)'
        local url_pattern_pull_requests = '^' .. escaped_platform_url .. '/([^/]+/[^/]+)/%-?/?pull%-requests/(%d+)'
        local url_pattern_pull = '^' .. escaped_platform_url .. '/([^/]+/[^/]+)/%-?/?pulls?/(%d+)'

        if text:match(url_pattern_issue) then
          repo, number = text:match(url_pattern_issue)
          ref_type = 'issue'
          if repo == repository_name then
            short_link = '#' .. number
          else
            short_link = repo .. '#' .. number
          end
          matched_platform = platform_name
          matched_base_url = platform_base_url
          config = platform_config
          break
        elseif text:match(url_pattern_mr) then
          repo, number = text:match(url_pattern_mr)
          ref_type = 'merge_request'
          if repo == repository_name then
            short_link = '!' .. number
          else
            short_link = repo .. '!' .. number
          end
          matched_platform = platform_name
          matched_base_url = platform_base_url
          config = platform_config
          break
        elseif text:match(url_pattern_pull_requests) then
          repo, number = text:match(url_pattern_pull_requests)
          ref_type = 'pull'
          if repo == repository_name then
            short_link = '#' .. number
          else
            short_link = repo .. '#' .. number
          end
          matched_platform = platform_name
          matched_base_url = platform_base_url
          config = platform_config
          break
        elseif text:match(url_pattern_pull) then
          repo, number = text:match(url_pattern_pull)
          ref_type = 'pull'
          if repo == repository_name then
            short_link = '#' .. number
          else
            short_link = repo .. '#' .. number
          end
          matched_platform = platform_name
          matched_base_url = platform_base_url
          config = platform_config
          break
        end
      end
    end
  end

  if number and repo and ref_type then
    local url_format
    if ref_type == "issue" then
      url_format = config.url_formats.issue
    elseif ref_type == "merge_request" then
      url_format = config.url_formats.merge_request
    elseif ref_type == "pull" then
      url_format = config.url_formats.pull
    end

    if url_format then
      local uri = matched_base_url .. url_format:gsub("{repo}", repo):gsub("{number}", number)
      return create_platform_link(short_link, uri, matched_platform), matched_platform, matched_base_url
    end
  end

  return nil, nil, nil
end

--- Process user/organisation references
--- @param elem pandoc.Str The string element to process
--- @param current_platform string The current platform name
--- @return pandoc.Link|nil A user link or nil if no valid pattern found
--- @return string|nil The platform name used for this match
--- @return string|nil The base URL used for this match
local function process_users(elem, current_platform)
  local config = get_platform_config(current_platform)
  if not config then
    return nil, nil, nil
  end

  local text = elem.text
  local username = nil

  local all_platform_names = get_all_platform_names()
  for _, platform_name in ipairs(all_platform_names) do
    local platform_config = get_platform_config(platform_name)
    if platform_config then
      local platform_base_url = platform_config.base_url
      local escaped_platform_url = str.escape_pattern(platform_base_url)
      local url_pattern = '^' .. escaped_platform_url .. '/([%w%-%.]+)$'

      if text:match(url_pattern) then
        username = text:match(url_pattern)
        if username then
          local url_format = platform_config.url_formats.user
          local uri = platform_base_url .. url_format:gsub('{username}', username)
          return create_platform_link('@' .. username, uri, platform_name), platform_name, platform_base_url
        end
      end
    end
  end

  return nil, nil, nil
end

--- Process commit references
--- @param elem pandoc.Str The string element to process
--- @param current_platform string The current platform name
--- @param current_base_url string The current base URL
--- @return pandoc.Link|nil A commit link or nil if no valid pattern found
--- @return string|nil The platform name used for this match
--- @return string|nil The base URL used for this match
local function process_commits(elem, current_platform, current_base_url)
  local config = get_platform_config(current_platform)
  if not config then
    return nil, nil, nil
  end

  local text = elem.text
  local repo = nil
  local commit_sha = nil
  local short_link = nil
  local matched_platform = current_platform
  local matched_base_url = current_base_url

  for _, pattern in ipairs(config.patterns.commit) do
    if pattern == "^(%x+)$" and text:match("^(%x+)$") and text:len() >= COMMIT_SHA_MIN_LENGTH and text:len() <= COMMIT_SHA_FULL_LENGTH then
      commit_sha = text:match("^(%x+)$")
      repo = repository_name
      short_link = commit_sha:sub(1, COMMIT_SHA_SHORT_LENGTH)
      break
    elseif pattern == "([^/]+/[^/@]+)@(%x+)" and text:match("^([^/]+/[^/@]+)@(%x+)$") then
      local r, sha = text:match("^([^/]+/[^/@]+)@(%x+)$")
      if sha:len() >= COMMIT_SHA_MIN_LENGTH and sha:len() <= COMMIT_SHA_FULL_LENGTH then
        repo = r
        commit_sha = sha
        short_link = repo .. "@" .. commit_sha:sub(1, COMMIT_SHA_SHORT_LENGTH)
        break
      end
    elseif pattern == "(%w+)@(%x+)" and text:match("^(%w+)@(%x+)$") then
      local user, sha = text:match("^(%w+)@(%x+)$")
      if repository_name and sha:len() >= COMMIT_SHA_MIN_LENGTH and sha:len() <= COMMIT_SHA_FULL_LENGTH then
        local repo_part = repository_name:match("/(.+)")
        if repo_part then
          repo = user .. "/" .. repo_part
          commit_sha = sha
          short_link = user .. "@" .. sha:sub(1, COMMIT_SHA_SHORT_LENGTH)
          break
        end
      end
    end
  end

  if not commit_sha then
    local all_platform_names = get_all_platform_names()
    for _, platform_name in ipairs(all_platform_names) do
      local platform_config = get_platform_config(platform_name)
      if platform_config then
        local platform_base_url = platform_config.base_url
        local escaped_platform_url = str.escape_pattern(platform_base_url)
        local url_pattern = '^' .. escaped_platform_url .. '/([^/]+/[^/]+)/%-?/?commits?/(%x+)$'
        if text:match(url_pattern) then
          local r, sha = text:match(url_pattern)
          if sha:len() >= COMMIT_SHA_MIN_LENGTH and sha:len() <= COMMIT_SHA_FULL_LENGTH then
            repo = r
            commit_sha = sha
            if repo == repository_name then
              short_link = commit_sha:sub(1, COMMIT_SHA_SHORT_LENGTH)
            else
              short_link = repo .. '@' .. commit_sha:sub(1, COMMIT_SHA_SHORT_LENGTH)
            end
            matched_platform = platform_name
            matched_base_url = platform_base_url
            config = platform_config
            break
          end
        end
      end
    end
  end

  if commit_sha and repo
      and commit_sha:len() >= COMMIT_SHA_MIN_LENGTH
      and commit_sha:len() <= COMMIT_SHA_FULL_LENGTH then
    local url_format = config.url_formats.commit
    local uri = matched_base_url .. url_format:gsub("{repo}", repo):gsub("{sha}", commit_sha)
    return create_platform_link(short_link, uri, matched_platform), matched_platform, matched_base_url
  end

  return nil, nil, nil
end

--- Try the issue/MR, commit, and user matchers on a single token's text.
--- @param text string The token text to match
--- @return pandoc.Link|pandoc.Span|nil A link, a badge span, or nil
local function match_single(text)
  local elem = pandoc.Str(text)
  return process_issues_and_mrs(elem, platform, base_url)
    or process_commits(elem, platform, base_url)
    or process_users(elem, platform)
end

--- Match a token's text as a single reference or a comma-separated group.
--- First tries a whole-text match. If that fails and the text is a
--- comma-separated group (two or more segments), matches every segment; the
--- group is recognised only when *all* segments are valid references, so mixed
--- text such as "1,000" or "#1,note" is left untouched. Comma separators are
--- preserved as literal `Str` inlines.
--- @param text string The token text (already stripped of surrounding brackets)
--- @return pandoc.Link|pandoc.Span|pandoc.List|nil A link, a badge span, a list of inlines, or nil
local function match_reference_group(text)
  local link = match_single(text)
  if link then
    return link
  end

  if not text:find(",", 1, true) then
    return nil
  end

  local links = {}
  local count = 0
  for segment in (text .. ","):gmatch("([^,]*),") do
    if segment == "" then
      return nil
    end
    local seg_link = match_single(segment)
    if not seg_link then
      return nil
    end
    count = count + 1
    links[count] = seg_link
  end

  if count < 2 then
    return nil
  end

  local result = pandoc.List({})
  for i = 1, count do
    if i > 1 then
      result:insert(pandoc.Str(","))
    end
    result:insert(links[i])
  end
  return result
end

--- Main Git hosting processing function
--- Attempts to convert string elements into Git hosting links by trying different patterns
--- @param elem pandoc.Str The string element to process
--- @return pandoc.Str|pandoc.Link|pandoc.List The original element, a link, or a list of inlines
local function process_gitlink(elem)
  if not is_enabled then
    return elem
  end
  if not platform or not base_url or str.is_empty(platform) then
    return elem
  end
  -- When link normalisation is disabled, leave bare URL tokens alone.
  -- Pandoc represents the visible text of an autolink as a Str inside the
  -- Link element, so skipping URL-shaped tokens preserves the URL text.
  if not normalize_links then
    local t = elem.text
    if t and (t:sub(1, 7) == 'http://' or t:sub(1, 8) == 'https://') then
      return elem
    end
  end

  -- Fast path: match the raw text directly, including bare comma-separated
  -- groups such as "#2,#3".
  local link = match_reference_group(elem.text)
  if link then
    return link
  end

  -- Slow path: peel unbalanced surrounding brackets and trailing punctuation
  -- and retry. This also handles bracket groups that Pandoc split across
  -- whitespace, e.g. "(#2," and "#3)" from "(#2, #3)", and single-token groups
  -- such as "(#2,#3)".
  local prefix, inner, suffix = str.strip_edges(elem.text)
  if prefix ~= "" or suffix ~= "" then
    if inner ~= "" then
      link = match_reference_group(inner)
      if link then
        local result = pandoc.List({})
        if prefix ~= "" then
          result:insert(pandoc.Str(prefix))
        end
        if pandoc.utils.type(link) == "List" then
          result:extend(link)
        else
          result:insert(link)
        end
        if suffix ~= "" then
          result:insert(pandoc.Str(suffix))
        end
        return result
      end
    end
  end

  -- Embedded path: scan for a bracket pair anywhere inside the token and
  -- retry the matchers on the bracket content. Handles cases where the
  -- bracket is surrounded by additional text or punctuation, e.g.
  -- "something(#1)", "(#1).", ".(#1).", "(#1)something", "something(#1,#2)".
  local search_pos = 1
  while true do
    local b_prefix, b_content, b_suffix, open_pos = str.find_bracketed_content(elem.text, search_pos)
    if not b_content then
      break
    end

    local content_link = match_reference_group(b_content)
    if content_link then
      local result = pandoc.List({})
      if b_prefix ~= "" then
        result:insert(pandoc.Str(b_prefix))
      end
      if pandoc.utils.type(content_link) == "List" then
        result:extend(content_link)
      else
        result:insert(content_link)
      end
      if b_suffix ~= "" then
        result:insert(pandoc.Str(b_suffix))
      end
      return result
    end

    search_pos = open_pos + 1
  end

  return elem
end

--- Process inline elements for Bitbucket multi-word patterns
--- @param elem table Block element containing inline content
--- @return table The modified element
local function process_inlines(elem)
  if not is_enabled then
    return elem
  end
  if elem.content and platform == "bitbucket" then
    elem.content = bitbucket.process_inlines(elem.content, base_url, repository_name, create_platform_link)
  end
  return elem
end

--- Fetch the HTML <title> of a URL via curl (best-effort, cached per render).
--- Returns nil when fetching is disabled, the URL cannot be reached, or curl
--- is not available. Failures log a warning but never abort the render.
--- @param uri string The URL to fetch
--- @return string|nil The page title, or nil if unavailable
local function fetch_title_for(uri)
  if not fetch_titles then
    return nil
  end
  local cached = title_cache[uri]
  if cached ~= nil then
    return cached or nil
  end
  if uri:find('"', 1, true) or uri:find("'", 1, true) then
    title_cache[uri] = false
    return nil
  end
  local handle = io.popen(
    'curl -fsSL --max-time 5 -A "quarto-gitlink" "' .. uri .. '" 2>/dev/null', 'r'
  )
  if not handle then
    log.log_warning(EXTENSION_NAME, "Title fetch unavailable (could not start curl).")
    title_cache[uri] = false
    return nil
  end
  local body = handle:read('*a') or ''
  handle:close()
  local raw_title = body:match('<title[^>]*>(.-)</title>')
  if not raw_title or raw_title == '' then
    title_cache[uri] = false
    return nil
  end
  local decoded = raw_title
      :gsub('&amp;', '&')
      :gsub('&lt;', '<')
      :gsub('&gt;', '>')
      :gsub('&quot;', '"')
      :gsub('&#39;', "'")
  local trimmed = str.trim(decoded)
  if trimmed == '' then
    title_cache[uri] = false
    return nil
  end
  title_cache[uri] = trimmed
  return trimmed
end

--- Process Link elements to shorten platform URLs used as link text.
--- When `gitlink.normalize-links` is true (the default), an autolink whose text
--- equals its target (e.g. `<https://github.com/owner/repo/issues/1>`) is
--- unwrapped so the later `Str` pass converts the bare URL to its platform-style
--- form (e.g. `#1`). Unwrapping (rather than returning the converted link here)
--- avoids a doubly nested link, because the `Str` pass also descends into link
--- content and would re-process the shortened text.
--- When `gitlink.fetch-titles` is true, an autolink whose target points at a
--- known platform URL is given a title-derived link text (issue/PR/commit
--- title) instead of the URL when the fetch succeeds.
--- @param elem pandoc.Link The link element to process
--- @return pandoc.Link|pandoc.Str The original link, a retitled link, or the unwrapped URL
local function process_link(elem)
  if not is_enabled or not normalize_links then
    return elem
  end

  local link_text = str.stringify(elem.content)
  local link_target = elem.target

  if link_text == link_target then
    if fetch_titles then
      local title = fetch_title_for(link_target)
      if title then
        return pandoc.Link({ pandoc.Str(title) }, link_target, '', elem.attr)
      end
    end

    -- Only unwrap when the URL is a recognised platform reference; otherwise the
    -- autolink is left untouched so ordinary URLs keep their link.
    -- `process_gitlink` returns its argument unchanged when nothing matches, so
    -- an identity check reliably detects a conversion. `pandoc.utils.type`
    -- cannot be used here: it reports "Inline" for both `Str` and `Link`.
    local temp_str = pandoc.Str(link_text)
    if process_gitlink(temp_str) ~= temp_str then
      return temp_str
    end
  end

  return elem
end

--- Skip the content of an inline markdown-pipeline entry.
--- Quarto renders navigation hrefs and social metadata values as hidden inline
--- snippets in such a span, then reads the rendered fragment back with
--- `innerText` and puts the result in an attribute. A converted reference would
--- add its badge text to that value.
--- The same envelope also carries values that Quarto inserts with `innerHTML`,
--- such as a navbar or sidebar title, a navigation entry text, an `about` link
--- text, and a next or previous page title. A reference in those no longer
--- converts. The two kinds cannot be told apart, because a navigation entry
--- registers its text and its href under one identifier prefix, so the whole
--- envelope is skipped.
--- A `Div` with the same class is a block entry (page footer, margin and body
--- header and footer, announcement). Quarto inserts those with `innerHTML` as
--- well, and they are a separate envelope, so only spans are skipped.
--- @param span pandoc.Span The span element to inspect
--- @return pandoc.Span span The unchanged span
--- @return boolean|nil descend False to stop traversal of the subtree
local function skip_markdown_envelope(span)
  if span.classes:includes(MARKDOWN_ENVELOPE_CLASS) then
    return span, false
  end
  return span
end

--- Convert a string element and stop traversal of the result.
--- Top-down traversal descends into a returned element, so without this a
--- created link would have its own text converted a second time.
--- @param elem pandoc.Str The string element to process
--- @return pandoc.Str|pandoc.Link|pandoc.List The result of `process_gitlink`
--- @return boolean descend Always false
local function process_gitlink_topdown(elem)
  return process_gitlink(elem), false
end

--- Turn element handlers into a top-down pass that skips envelope spans.
--- Each pass needs its own prune point, because the passes that create links
--- stay separate walks: `process_link` unwraps an autolink into a `Str` that the
--- later `Str` pass has to convert.
--- @param handlers table The element handlers for the pass
--- @return table The filter table for the pass
local function envelope_safe_pass(handlers)
  handlers.traverse = 'topdown'
  handlers.Span = skip_markdown_envelope
  return handlers
end

--- Pandoc filter configuration
--- Defines the order of filter execution:
--- 1. Extract references from the document
--- 2. Get repository information from metadata
--- 3. Process inline containers for Bitbucket multi-word patterns
--- 4. Process link elements to shorten URLs used as link text
--- 5. Process string elements for Git hosting patterns
--- 6. Process citations for Git hosting mentions
return {
  { Pandoc = get_references },
  { Meta = get_repository },
  { Plain = process_inlines, Para = process_inlines },
  envelope_safe_pass({ Link = process_link }),
  envelope_safe_pass({ Str = process_gitlink_topdown }),
  envelope_safe_pass({ Cite = process_mentions })
}
