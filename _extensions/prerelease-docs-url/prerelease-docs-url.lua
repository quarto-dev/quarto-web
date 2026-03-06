-- Version-aware shortcode for linking to prerelease docs.
--
-- Usage: {{< prerelease-docs-url 1.9 >}}
--
-- Returns "prerelease." when the referenced version's docs live on
-- prerelease.quarto.org, or "" when they're on quarto.org.

local function handler(args, kwargs, meta, raw_args, context)
  local ref_version = quarto.shortcode.read_arg(args, 1)
  if ref_version == nil then
    return quarto.shortcode.error_output(
      "prerelease-docs-url",
      "requires a version argument, e.g. {{< prerelease-docs-url 1.9 >}}",
      context
    )
  end
  -- Strip surrounding quotes that may be preserved in text contexts
  ref_version = ref_version:gsub('^"(.*)"$', '%1'):gsub("^'(.*)'$", '%1')

  -- On the prerelease site, always link to prerelease
  if quarto.project.profile:includes("prerelease-docs") then
    return pandoc.Str("prerelease.")
  end

  -- Guard against missing or invalid version metadata
  local version_str = meta["version"] and pandoc.utils.stringify(meta["version"]) or nil
  if not version_str or version_str == "" then
    return quarto.shortcode.error_output(
      "prerelease-docs-url",
      "missing 'version' in document metadata",
      context
    )
  end

  -- Compare referenced version to this branch's version using
  -- pandoc.types.Version for correct element-wise comparison (1.12 > 1.9)
  local ok_branch, branch_version = pcall(pandoc.types.Version, version_str)
  local ok_ref, ref = pcall(pandoc.types.Version, ref_version)

  if not ok_branch then
    return quarto.shortcode.error_output(
      "prerelease-docs-url",
      "invalid metadata version '" .. version_str .. "'",
      context
    )
  end
  if not ok_ref then
    return quarto.shortcode.error_output(
      "prerelease-docs-url",
      "invalid version argument '" .. ref_version .. "'",
      context
    )
  end

  if ref <= branch_version then
    return pandoc.Str("")
  else
    return pandoc.Str("prerelease.")
  end
end

return {["prerelease-docs-url"] = handler}
