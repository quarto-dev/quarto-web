library(fs)
library(stringr)
library(glue)
library(jsonlite)
library(gh)

downloads <- path("docs", "download")

# Current versions -------------------------------------------------------

# Based on updated download files
new_release <- read_json(path(downloads, "_download.json"))$version
new_prerelease <- read_json(path(downloads, "_prerelease.json"))$version

# Old version from Git history -------------------------------------------

# Need version at two commits ago
previous_commit <- gh("https://api.github.com/repos/:owner/:repo/commits",
  owner = "quarto-dev", repo = "quarto-web", 
  path = "docs/download/_download.json",
  per_page = 2)

previous_commit_ref <- previous_commit[[2]]$sha

previous_contents <- gh("/repos/{owner}/{repo}/contents/{path}", 
  owner = "quarto-dev", repo = "quarto-web", 
  path =  "docs/download/_download.json",
  ref = previous_commit_ref,
  .accept = "application/vnd.github.raw+json")
previous_contents_json <- parse_json(previous_contents$message)

old_release <- previous_contents_json$version
old_release_date <- previous_contents_json$created

# Version numbers
extract_major <- function(x){
  str_extract(x, "(\\d+)\\.(\\d+)")
}

new_release_major <-  extract_major(new_release)
new_prerelease_major <-  extract_major(new_prerelease)
major_version <- extract_major(old_release)

cat("Release:", old_release, "->", new_release, "\n")
cat("Prerelease:", new_release_major, "->", new_prerelease_major, "\n")

# Create new changelog content -------------------------------------------

changelog_url <- paste0("https://github.com/quarto-dev/quarto-cli/releases/download/v", 
  old_release, "/changelog.md")
changelog_dir <- dir_create(path(downloads, "changelog", major_version))
changelog_file <- path(changelog_dir, "_changelog", ext = "md")

download_status <- download.file(changelog_url, changelog_file)
stopifnot(!download_status)

# escape shortcodes on changelog files as we don't want them processed on website
# changelog.md is not supposed to have shortcodes that are meant to be resolved as they 
# are not .qmd files, but regular markdown files.
# # Pattern that matches {{< >}} but NOT {{{< >}}} (already escaped): "(?<!\\{)(\\{\\{<[^>]*>\\}\\})(?!\\})"
xfun::gsub_file(changelog_file, pattern = "(?<!\\{)(\\{\\{<[^>]*>\\}\\})(?!\\})", replacement = "{\\1}", perl = TRUE)

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

# Update listing ------------------------------------------------

old_abbr <- str_split(major_version, "\\.")[[1]] |> paste0(collapse = "")

# Add new item to download-older listing in docs/download/index.qmd

glue('
\n- id: version{ old_abbr }
  title: { old_release }
  date: { format(as.Date(old_release_date), "%Y-%m-%d") }
  path: https://github.com/quarto-dev/quarto-cli/releases/tag/v{ old_release }
  changelog: "[Release Notes](changelog/{ major_version }/)"
') |> 
  cat(file = path(downloads, "_download-older.yml"), append = TRUE)

