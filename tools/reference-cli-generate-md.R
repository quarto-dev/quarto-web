# Generates .md files in docs/cli/includes/ from `cli-info.json` in docs/cli/
# 1. Update JSON:
# quarto dev-call cli-info > docs/cli/cli-info.json
# 2. Generate .md with:
# quarto run tools/reference-cli-generate-md.R

library(jsonlite)
library(knitr)
library(here)
library(tidyverse)
library(fansi)

options(knitr.table.format = "html")

# Helper Functions -------------------------------------------------------

heading <- function(text, level = 2) {
  paste0(strrep("#", level), " ", text, "\n")
}

process_usage <- function(name, usage) {
  xfun::fenced_block(
    paste("quarto", name, usage, sep = " "),
    attrs = ".bash"
  ) |>
    paste(collapse = "\n")
}

make_code <- function(x) {
  paste0("<code>", x, "</code>")
}

process_options <- function(options) {
  options_table <- tibble(options = options) |>
    unnest_wider(options) |>
    select(flags, typeDefinition, description) |>
    rowwise() |>
    mutate(
      flags = paste0(make_code(flags), collapse = ", "),
      typeDefinition = ifelse(
        typeDefinition == "",
        "",
        paste0(make_code(typeDefinition))
      )
    ) |>
    knitr::kable(
      col.names = c("Flags", "Arguments", "Description"),
      escape = FALSE
    ) |>
    paste(collapse = "\n")

  options_table |> raw_html()
}

process_commands <- function(commands) {
  if (length(commands) == 0) {
    return("")
  }
  commands_table <- tibble(commands = commands) |>
    unnest_wider(commands) |>
    mutate(name = make_code(name)) |>
    select(name, description) |>
    knitr::kable(
      col.names = c("Command", "Description"),
      escape = FALSE
    ) |>
    paste(collapse = "\n")
  paste(heading("Commands", 2), raw_html(commands_table), sep = "\n")
}

process_examples <- function(examples) {
  if (length(examples) == 0) {
    return("")
  }
  example_text <- examples |>
    tibble() |>
    unnest_wider(examples) |>
    rowwise() |>
    mutate(
      description = xfun::fenced_block(
        description,
        attrs = c(".bash", "filename='Terminal'")
      ) |>
        paste(collapse = "\n") |>
        paste0("\n"),
      name = heading(name, 3),
      text = paste0(name, description)
    ) |>
    pull(text) |>
    paste(collapse = "\n")
  paste0(heading("Examples", 2), example_text, collapse = "")
}

md_content <- function(name, description, usage, options, commands, examples) {
  usage_text <- process_usage(name, usage)
  options_table <- process_options(options)
  commands_table <- process_commands(commands)
  examples_text <- process_examples(examples)

  paste(
    description,
    usage_text,
    "\n",
    heading("Options"),
    options_table,
    "\n",
    commands_table,
    "\n",
    examples_text,
    sep = "\n",
    collapse = "\n"
  )
}


# Read and process JSON --------------------------------------------------

cli_json <- read_json(here("docs", "cli", "cli-info.json"))
cat("cli-info.json version: ", cli_json$version, "\n")
commands <- cli_json$commands

exclude <- c("create-project", "editor-support")
commands <- commands[!map_chr(commands, "name") %in% exclude]

# Recursively extract commands and subcommands
extract_commands <- function(commands, prefix = NULL) {
  result <- list()

  for (cmd in commands) {
    # Create full command name
    full_name <- str_c(prefix, cmd$name, sep = " ")

    # Add current command to results
    cmd$name <- full_name
    result[[length(result) + 1]] <- cmd

    # Recursively process nested commands if they exist
    if (!is.null(cmd$commands) && length(cmd$commands) > 0) {
      nested_commands <- extract_commands(cmd$commands, prefix = full_name)
      result <- c(result, nested_commands)
    }
  }

  return(result)
}

# Table for landing ------------------------------------------------------

tibble(commands = commands) |>
  unnest_wider(commands) |>
  select(name, description) |>
  mutate(
    name = paste("[", name, "](", name, ".qmd)", sep = ""),
    description = stringr::str_extract(description, "^[^\\n]+")
  ) |>
  knitr::kable() |>
  writeLines(here("docs", "cli", "includes", "_cli-commands.md"))


# Individual commands ----------------------------------------------------

all_commands <- extract_commands(commands)

commands_tbl <-
  tibble(commands = all_commands) |>
  unnest_wider(commands) |>
  filter(str_detect(name, "help", negate = TRUE)) |>
  rowwise()

commands_content <- commands_tbl |>
  mutate(
    filename = here(
      "docs",
      "cli",
      "includes",
      paste0("_", gsub(" ", "-", name), ".md")
    ),
    content = md_content(
      name,
      description,
      usage,
      options,
      commands,
      examples
    )
  )

commands_content |>
  group_walk(~ with(.x, writeLines(content, filename)))
