library(fs)
library(stringr)
library(glue)

# Version numbers
old_release <- "v1.5.57"
new_release_major <- "1.6"
new_prerelease_major <- "1.7"

major_version <- str_extract(old_release, "(\\d+)\\.(\\d+)")

downloads <- path("docs", "download")

# Create new changelog content -------------------------------------------

changelog_url <- paste0("https://github.com/quarto-dev/quarto-cli/releases/download/", 
  old_release, "/changelog.md")
changelog_dir <- dir_create(path(downloads, "changelog", major_version))

download_status <- download.file(changelog_url, path(changelog_dir, 
  "_changelog", ext = "md"))
stopifnot(!download_status)

glue("
---
title: {major_version} Release Notes
format: html
---

{{{{< include _changelog.md >}}}}
") |> 
  writeLines(path(changelog_dir, "index", ext = "qmd"))

# Increment versions of aliases ------------------------------------------

release_page <- path(downloads, "release", ext = "qmd")
prerelease_page <- path(downloads, "prerelease", ext = "qmd")

aliases <- paste0("changelog/", 
  c(major_version, new_release_major, new_prerelease_major), 
  "/") 

readLines(release_page) |> 
  str_replace(aliases[1], aliases[2]) |> 
  writeLines(release_page)

readLines(prerelease_page) |> 
  str_replace(aliases[2], aliases[3]) |> 
  writeLines(prerelease_page)

# MANUALLY update listing ------------------------------------------------

old_abbr <- str_split(major_version, "\\.")[[1]] |> paste0(collapse = "")

# Add new item to download-older listing in docs/download/index.qmd

cat("Please manually add a new item to the `download-older` listing in `docs/download/index.qmd`:\n")
glue('
- id: version{ old_abbr }
  title: { old_release }
  date: <RELEASE DATE>
  path: https://github.com/quarto-dev/quarto-cli/releases/tag/{ old_release }
  changelog: "[Release Notes](changelog/{ major_version }/)"
')

