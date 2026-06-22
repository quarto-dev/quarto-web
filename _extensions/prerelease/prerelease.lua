-- Version-aware shortcodes for prerelease content.
--
-- prerelease-docs-url:
--   {{< prerelease-docs-url 1.9 >}}
--   Returns "prerelease." when the referenced version's docs live on
--   prerelease.quarto.org, or "" when they're on quarto.org.
--
-- prerelease-callout:
--   {{< prerelease-callout 1.9 >}}
--   Shows a "Pre-release Feature" callout when the referenced version is
--   unreleased. Shows nothing once the version is released.
--
--   {{< prerelease-callout 1.9 type="blog" >}}
--   Blog mode: shows "Pre-release Feature" callout when unreleased,
--   switches to "Quarto X.Y Feature" callout once released.
--
-- Both shortcodes use the `version` key from _quarto.yml metadata and
-- the `prerelease-docs` profile to determine whether a version is released.

--- Strip surrounding quotes from a shortcode argument.
local function strip_quotes(s)
  return s:gsub('^"(.*)"$', '%1'):gsub("^'(.*)'$", '%1')
end

--- Parse the version argument and site version metadata.
-- Returns ref_version, branch_version (as pandoc.types.Version), or
-- nil plus an error Blocks/Inlines on failure.
local function parse_versions(shortcode_name, args, meta, context)
  local ref_str = quarto.shortcode.read_arg(args, 1)
  if ref_str == nil then
    return nil, nil, quarto.shortcode.error_output(
      shortcode_name,
      "requires a version argument, e.g. {{< " .. shortcode_name .. " 1.9 >}}",
      context
    )
  end
  ref_str = strip_quotes(ref_str)

  local version_str = meta["version"] and pandoc.utils.stringify(meta["version"]) or nil
  if not version_str or version_str == "" then
    return nil, nil, quarto.shortcode.error_output(
      shortcode_name,
      "missing 'version' in document metadata",
      context
    )
  end

  local ok_branch, branch_version = pcall(pandoc.types.Version, version_str)
  if not ok_branch then
    return nil, nil, quarto.shortcode.error_output(
      shortcode_name,
      "invalid metadata version '" .. version_str .. "'",
      context
    )
  end

  local ok_ref, ref_version = pcall(pandoc.types.Version, ref_str)
  if not ok_ref then
    return nil, nil, quarto.shortcode.error_output(
      shortcode_name,
      "invalid version argument '" .. ref_str .. "'",
      context
    )
  end

  return ref_version, branch_version, nil
end

--- Check whether a referenced version is unreleased.
-- On prerelease site (profile prerelease-docs): ref >= site version
-- On main site: ref > site version
local function is_unreleased(ref_version, branch_version)
  if quarto.project.profile:includes("prerelease-docs") then
    return ref_version >= branch_version
  else
    return ref_version > branch_version
  end
end

--- Parse a markdown string into pandoc Blocks.
local function md_to_blocks(md)
  return pandoc.read(md, "markdown").blocks
end

-- Shortcode: prerelease-docs-url
local function docs_url_handler(args, kwargs, meta, raw_args, context)
  local ref_version, branch_version, err = parse_versions(
    "prerelease-docs-url", args, meta, context
  )
  if err then return err end

  -- On the prerelease site, always link to prerelease
  if quarto.project.profile:includes("prerelease-docs") then
    return pandoc.Str("prerelease.")
  end

  if ref_version <= branch_version then
    return pandoc.Str("")
  else
    return pandoc.Str("prerelease.")
  end
end

-- Shortcode: prerelease-callout
local function callout_handler(args, kwargs, meta, raw_args, context)
  local ref_version, branch_version, err = parse_versions(
    "prerelease-callout", args, meta, context
  )
  if err then return err end

  local ref_str = strip_quotes(quarto.shortcode.read_arg(args, 1))
  local callout_type = kwargs["type"] or ""
  local is_blog = callout_type == "blog"
  local unreleased = is_unreleased(ref_version, branch_version)

  if unreleased then
    -- Pre-release callout (both feature docs and blog)
    local content = md_to_blocks(
      "This feature is new in the upcoming Quarto " .. ref_str .. " release. " ..
      "To use the feature now, you'll need to " ..
      "[download and install](/docs/download/prerelease.qmd) " ..
      "the Quarto pre-release."
    )
    return quarto.Callout({
      type = "note",
      title = "Pre-release Feature",
      content = content,
    })
  end

  if is_blog then
    -- Released blog callout
    local content = md_to_blocks(
      "This post is part of a series highlighting new features in the " ..
      ref_str .. " release of Quarto. Get the latest release on the " ..
      "[download page](/docs/download/index.qmd)."
    )
    return quarto.Callout({
      type = "note",
      title = "Quarto " .. ref_str .. " Feature",
      content = content,
    })
  end

  -- Feature docs, already released: show nothing
  return pandoc.Blocks({})
end

return {
  ["prerelease-docs-url"] = docs_url_handler,
  ["prerelease-callout"] = callout_handler,
}
