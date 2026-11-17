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

--- @type string|nil Badge text colour (hex or colour name), nil to pick black or white
local badge_text_colour = nil

--- @type boolean Whether this document has already warned about a faint badge background
local badge_contrast_warned = false

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

--- @type string Class Quarto puts on the markdown-pipeline envelope elements
local MARKDOWN_ENVELOPE_CLASS = 'quarto-markdown-envelope-contents'

--- @type table<integer, boolean> Digit counts of a valid hex colour: #rgb, #rgba, #rrggbb, #rrggbbaa
local HEX_COLOUR_DIGIT_COUNTS = { [3] = true, [4] = true, [6] = true, [8] = true }

--- @type number WCAG AA minimum contrast ratio for normal text
local WCAG_AA_CONTRAST = 4.5

--- @type number[] Page colours behind an HTML badge: white for a light theme, black for a dark one
local HTML_PAGES = { 1, 0 }

--- @type number[] Page colour behind a Typst badge: white
local TYPST_PAGES = { 1 }

--- Check whether a value is a hex colour with 3, 4, 6, or 8 digits after the #.
--- @param value string The candidate colour value
--- @return boolean True if the value is a hex colour
local function is_hex_colour(value)
  return value:match('^#%x+$') ~= nil and HEX_COLOUR_DIGIT_COUNTS[#value - 1] == true
end

--- Validate a colour value as a hex code or CSS named colour.
--- Returns the original value if valid, or nil if invalid.
--- A value that is not a string returns nil without a warning, because the
--- schema check has already reported its type.
--- @param value any The candidate colour value
--- @param option_label string The metadata option name (for warnings)
--- @return string|nil The validated colour value, or nil if invalid
local function validate_colour(value, option_label)
  if type(value) ~= 'string' or str.is_empty(value) then
    return nil
  end
  local s = value --[[@as string]]
  if is_hex_colour(s) or colour.is_named_colour(s) then
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
  if is_hex_colour(value) then
    return value
  end
  return colour.named_to_HTML(value)
end

--- Split a validated colour value into its channels, each from 0 to 1.
--- @param value string The colour value (hex code or CSS named colour)
--- @return number[] The red, green, and blue channels
--- @return number The alpha channel, 1 when the colour has no alpha digits
local function colour_channels(value)
  local digits = colour_to_hex(value):sub(2)
  if #digits <= 4 then
    digits = digits:gsub('%x', '%0%0')
  end
  local channels = {}
  for i = 1, 3 do
    channels[i] = tonumber(digits:sub(2 * i - 1, 2 * i), 16) / 255
  end
  local alpha = #digits == 8 and tonumber(digits:sub(7, 8), 16) / 255 or 1
  return channels, alpha
end

--- Compute the WCAG relative luminance of sRGB channels.
--- @param channels number[] The red, green, and blue channels, each from 0 to 1
--- @return number The relative luminance, from 0 (black) to 1 (white)
local function relative_luminance(channels)
  local luminance = 0
  local weights = { 0.2126, 0.7152, 0.0722 }
  for i, weight in ipairs(weights) do
    local channel = channels[i]
    if channel <= 0.04045 then
      channel = channel / 12.92
    else
      channel = ((channel + 0.055) / 1.055) ^ 2.4
    end
    luminance = luminance + weight * channel
  end
  return luminance
end

--- Compute the WCAG contrast ratio between two relative luminances.
--- @param a number A relative luminance
--- @param b number Another relative luminance
--- @return number The contrast ratio, from 1 to 21
local function contrast_ratio(a, b)
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
end

--- Pick black or white text for a background colour.
--- A translucent background is blended over each page colour it can sit on.
--- The text colour with the higher worst-case contrast wins.
--- @param background string The background colour (hex code or CSS named colour)
--- @param pages number[] The grey levels of the possible pages, from 0 (black) to 1 (white)
--- @return string '#000000' or '#ffffff'
--- @return number The worst-case contrast ratio of that text colour
local function contrasting_text_colour(background, pages)
  local channels, alpha = colour_channels(background)
  local worst_black, worst_white = math.huge, math.huge
  for _, page in ipairs(pages) do
    local blended = {}
    for i, channel in ipairs(channels) do
      blended[i] = channel * alpha + page * (1 - alpha)
    end
    local luminance = relative_luminance(blended)
    worst_black = math.min(worst_black, contrast_ratio(luminance, 0))
    worst_white = math.min(worst_white, contrast_ratio(luminance, 1))
  end
  local text, worst = '#000000', worst_black
  if worst_white > worst_black then
    text, worst = '#ffffff', worst_white
  end
  return text, worst
end

--- Resolve the badge text colour for the pages of the current output format.
--- Returns the configured text colour when there is one.
--- Otherwise picks black or white, and warns once per document when neither
--- reaches WCAG AA on every page.
--- @param pages number[] The grey levels of the possible pages, from 0 (black) to 1 (white)
--- @return string The text colour (hex code or CSS named colour)
local function resolve_badge_text_colour(pages)
  if badge_text_colour then
    return badge_text_colour
  end
  local text, worst = contrasting_text_colour(badge_background_colour, pages)
  if worst < WCAG_AA_CONTRAST and not badge_contrast_warned then
    badge_contrast_warned = true
    log.log_warning(
      EXTENSION_NAME,
      "'badge-background-colour' value '" .. badge_background_colour .. "' is too transparent for readable text " ..
      "(" .. string.format('%.1f', worst) .. ':1 at worst, below ' .. WCAG_AA_CONTRAST .. ':1). ' ..
      "Use a more opaque colour or a valid 'badge-text-colour'."
    )
  end
  return text
end

--- Reset module-level state to defaults.
--- Quarto can render multiple documents in one process, so module-level state
--- from a previous document must be cleared at the start of each Meta pass.
--- `references_ids_set` is rebuilt by `get_references` in its own pass.
local function reset_state()
  platform = 'github'
  repository_name = nil
  base_url = 'https://github.com'
  force_mentions_set = {}
  is_enabled = true
  show_platform_badge = true
  badge_position = 'after'
  badge_background_colour = '#c3c3c3'
  badge_text_colour = nil
  badge_contrast_warned = false
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
        stylesheets = { css_path }
      })

      local badge_attr = pandoc.Attr(
        '',
        { 'gitlink-badge', 'badge' },
        {
          title = platform_label,
          ['aria-label'] = platform_label .. ' platform',
          style = 'background-color: ' .. badge_background_colour ..
              '; color: ' .. resolve_badge_text_colour(HTML_PAGES) .. ';'
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
      local text_hex = colour_to_hex(resolve_badge_text_colour(TYPST_PAGES))
      local badge_raw = '#box(fill: rgb("' ..
          bg_hex ..
          '"), inset: 2pt, outset: 0pt, radius: 3pt, baseline: -0.3em, text(size: 0.45em, fill: rgb("' ..
          text_hex .. '"), [' .. platform_label .. ']))'
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
        "Failed to load custom platforms from '" .. original_path .. "':\n" ..
        (err or 'unknown error') .. '\nUsing the built-in platforms only.'
      )
      meta_custom_platforms = nil
    end
  end
  if str.is_empty(meta_custom_platforms) then
    local ok, err = platforms.initialise()
    if not ok then
      log.log_error(EXTENSION_NAME, "Failed to load built-in platforms:\n" .. (err or 'unknown error'))
      return meta
    end
  end

  -- Parse repo-url from project metadata (website/book). That configuration
  -- is not in the document metadata, so read it once and share it with the
  -- widget.
  local project_meta, project_meta_error, project_meta_path = meta_mod.get_project_metadata()
  if project_meta_error then
    log.log_warning(
      EXTENSION_NAME,
      "Could not read the project metadata (" .. project_meta_error .. ") from '" ..
      project_meta_path .. "'. " ..
      "'website.repo-url' and 'book.repo-url' are ignored, " ..
      "and the widget placeholder check is skipped."
    )
  end
  local project_repo_url = project_meta and meta_mod.get_project_repo_url(project_meta)
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

  -- Read through the schema, which applies the defaults and resolves the
  -- `-color` spelling aliases.
  badge_position = checker:option('badge-position') or badge_position
  badge_background_colour = validate_colour(checker:option('badge-background-colour'), 'badge-background-colour')
      or badge_background_colour
  badge_text_colour = validate_colour(checker:option('badge-text-colour'), 'badge-text-colour')

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
      format_meta = project_meta,
      display_name = platforms.get_platform_display_name(platform),
    })
  end

  return meta
end

--- Turn a Typst bibliography entry into a path that Pandoc can read.
--- Quarto stores it as raw Typst, which `str.stringify` drops, and Typst reads
--- a leading `/` from the project root.
--- Remove when https://github.com/quarto-dev/quarto-cli/issues/11552 and
--- https://github.com/quarto-dev/quarto-cli/issues/12553 are fixed.
--- @param entry pandoc.MetaValue A bibliography entry
--- @return string The bibliography path
local function typst_bibliography_path(entry)
  if pandoc.utils.type(entry) == 'Inlines' then
    entry = entry:walk({
      RawInline = function(raw) return pandoc.Str(raw.text) end
    })
  end
  return paths.resolve_project_path(str.stringify(entry))
end

--- Extract and store reference IDs from the document
--- This function collects all reference IDs from the document to distinguish
--- between actual citations and Git hosting mentions
--- @param doc pandoc.Pandoc The Pandoc document
--- @return pandoc.Pandoc The document (unchanged)
local function get_references(doc)
  references_ids_set = {}
  if not is_enabled then
    return doc
  end
  local source = doc
  local bibliography = doc.meta.bibliography
  if bibliography and quarto.doc.is_format('typst') then
    local meta = {}
    for key, value in pairs(doc.meta) do
      meta[key] = value
    end
    local entries = pandoc.utils.type(bibliography) == 'List' and bibliography or { bibliography }
    meta.bibliography = pandoc.List.map(entries, typst_bibliography_path)
    source = pandoc.Pandoc(doc.blocks, meta)
  end
  for _, reference in ipairs(pandoc.utils.references(source)) do
    if reference.id then
      references_ids_set[reference.id] = true
    end
  end
  return doc
end

--- Remove the anchors a custom pattern may already carry.
--- @param pattern string A `user`, `issue`, `merge-request` or `commit` pattern of a platform
--- @return string The pattern without a leading `^` or a trailing unescaped `$`
local function strip_anchors(pattern)
  local stripped = pattern:gsub('^%^', '')
  if stripped:sub(-1) == '$' and stripped:sub(-2, -2) ~= '%' then
    stripped = stripped:sub(1, -2)
  end
  return stripped
end

--- Match a whole `@username` against the `user` pattern of a platform.
--- A partial match does not count, and the username must end with a letter or digit.
--- @param config table The platform configuration
--- @param text string The text to match, such as `@mcanouil`
--- @return string|nil The username, or nil if the text is not a valid mention
local function match_username(config, text)
  if not config.patterns.user then
    return nil
  end
  local username = text:match('^' .. strip_anchors(config.patterns.user) .. '$')
  if username and username:match('%w$') then
    return username
  end
  return nil
end

--- Find the username a citation id stands for.
--- An id listed in `gitlink.mentions` is used as is; an id in the bibliography is not a mention.
--- @param config table The platform configuration
--- @param id string The citation id
--- @return string|nil The username, or nil if the citation is not a mention
local function mention_username(config, id)
  if force_mentions_set[id] then
    return id
  end
  if references_ids_set[id] then
    return nil
  end
  return match_username(config, '@' .. id)
end

--- Build the inlines for one mention: prefix, link, suffix.
--- @param config table The platform configuration
--- @param citation pandoc.Citation The citation
--- @param username string The username
--- @return pandoc.Inlines The prefix, the mention link, and the suffix
local function mention_inlines(config, citation, username)
  local uri = base_url .. config.url_formats.user:gsub('{username}', username)
  local inlines = pandoc.Inlines({})
  if #citation.prefix > 0 then
    inlines:extend(citation.prefix)
    inlines:insert(pandoc.Space())
  end
  inlines:insert(create_platform_link('@' .. username, uri, platform))
  local suffix = citation.suffix
  if #suffix > 0 then
    local first = suffix[1]
    local hugs_link = first.t == 'Space' or (first.t == 'Str' and first.text:match('^[,;:.%)%]]') ~= nil)
    if not hugs_link then
      inlines:insert(pandoc.Space())
    end
    inlines:extend(suffix)
  end
  return inlines
end

--- Process Git hosting mentions in citations.
--- Distinguishes between actual bibliography citations and Git hosting @mentions.
--- When the citation id appears in `gitlink.mentions`, the citation is forced
--- to be treated as a mention even if a reference with that id exists.
--- A citation with several ids becomes links only when every id is a mention.
--- @param cite pandoc.Cite The citation element
--- @return pandoc.Cite|pandoc.Inlines The original citation or the mention inlines
local function process_mentions(cite)
  if not is_enabled then
    return cite
  end
  local config = get_platform_config(platform)
  if not config then
    return cite
  end
  local inlines = pandoc.Inlines({})
  for i, citation in ipairs(cite.citations) do
    local username = mention_username(config, citation.id)
    if not username then
      return cite
    end
    if i > 1 then
      inlines:extend({ pandoc.Str(';'), pandoc.Space() })
    end
    inlines:extend(mention_inlines(config, citation, username))
  end
  return inlines
end


--- Match a whole token against a list of issue or merge request patterns.
--- One capture is a number in the configured repository; two captures are a repository and a number.
--- @param patterns table|nil The patterns, tried in order
--- @param text string The token text
--- @param separator string The character shown between repository and number (`#` or `!`)
--- @return string|nil repo The repository
--- @return string|nil number The issue or merge request number
--- @return string|nil short_link The link text
local function match_numbered_reference(patterns, text, separator)
  for _, pattern in ipairs(patterns or {}) do
    local first, second = text:match('^' .. strip_anchors(pattern) .. '$')
    if second then
      return first, second, first .. separator .. second
    elseif first then
      return repository_name, first, separator .. first
    end
  end
  return nil, nil, nil
end

--- Match a whole token against the commit patterns of a platform.
--- One capture is a SHA in the configured repository.
--- Two captures are a repository (`owner/repo`) or a user (their fork), then a SHA.
--- @param config table The platform configuration
--- @param text string The token text
--- @return string|nil repo The repository
--- @return string|nil sha The commit SHA
--- @return string|nil short_link The link text
local function match_commit_reference(config, text)
  for _, pattern in ipairs(config.patterns.commit) do
    local first, second = text:match('^' .. strip_anchors(pattern) .. '$')
    local sha = second or first
    local valid_sha = sha and sha:match('^%x+$')
      and #sha >= COMMIT_SHA_MIN_LENGTH and #sha <= COMMIT_SHA_FULL_LENGTH
    if valid_sha then
      local short_sha = sha:sub(1, COMMIT_SHA_SHORT_LENGTH)
      if not second then
        return repository_name, sha, short_sha
      elseif first:find('/', 1, true) then
        return first, sha, first .. '@' .. short_sha
      else
        local user = match_username(config, '@' .. first)
        local repo_part = repository_name and repository_name:match('/(.+)')
        if user and repo_part then
          return user .. '/' .. repo_part, sha, user .. '@' .. short_sha
        end
      end
    end
  end
  return nil, nil, nil
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

  repo, number, short_link = match_numbered_reference(config.patterns.issue, text, '#')
  if number then
    ref_type = 'issue'
  else
    repo, number, short_link = match_numbered_reference(config.patterns.merge_request, text, '!')
    if number then
      ref_type = 'merge_request'
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

  local all_platform_names = get_all_platform_names()
  for _, platform_name in ipairs(all_platform_names) do
    local platform_config = get_platform_config(platform_name)
    if platform_config then
      local platform_base_url = platform_config.base_url
      local escaped_platform_url = str.escape_pattern(platform_base_url)
      local path = text:match('^' .. escaped_platform_url .. '/([^/]+)$')
      local username = path and match_username(platform_config, '@' .. path)
      if username then
        local url_format = platform_config.url_formats.user
        local uri = platform_base_url .. url_format:gsub('{username}', username)
        return create_platform_link('@' .. username, uri, platform_name), platform_name, platform_base_url
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

  repo, commit_sha, short_link = match_commit_reference(config, text)

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
--- 1. Get repository information from metadata
--- 2. Extract references from the document, once `enabled` is known
--- 3. Process inline containers for Bitbucket multi-word patterns
--- 4. Process link elements to shorten URLs used as link text
--- 5. Process string elements for Git hosting patterns
--- 6. Process citations for Git hosting mentions
return {
  { Meta = get_repository },
  { Pandoc = get_references },
  { Plain = process_inlines, Para = process_inlines },
  envelope_safe_pass({ Link = process_link }),
  envelope_safe_pass({ Str = process_gitlink_topdown }),
  envelope_safe_pass({ Cite = process_mentions })
}
