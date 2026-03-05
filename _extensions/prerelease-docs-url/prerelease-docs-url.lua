-- Version-aware shortcode for linking to prerelease docs.
--
-- Usage: {{< prerelease-docs-url 1.9 >}}
--
-- Returns "prerelease." when the referenced version's docs live on
-- prerelease.quarto.org, or "" when they're on quarto.org.

local function handler(args, kwargs, meta)
  local ref_version = quarto.shortcode.read_arg(args, 1)
  if ref_version == nil then
    quarto.log.error("prerelease-docs-url requires a version argument, e.g. {{< prerelease-docs-url \"1.9\" >}}")
    return pandoc.Str("")
  end
  -- Strip surrounding quotes that may be preserved in text contexts
  ref_version = ref_version:gsub('^"(.*)"$', '%1'):gsub("^'(.*)'$", '%1')

  -- On the prerelease site, always link to prerelease
  if quarto.project.profile:includes("prerelease-docs") then
    return pandoc.Str("prerelease.")
  end

  -- Compare referenced version to this branch's version
  local branch_version = pandoc.utils.stringify(meta["version"])

  if ref_version == branch_version then
    return pandoc.Str("")
  else
    return pandoc.Str("prerelease.")
  end
end

return {["prerelease-docs-url"] = handler}
