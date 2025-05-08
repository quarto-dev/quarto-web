# Generates .md files in docs/cli/includes/ from `cli-info.json` in docs/cli/
# 1. Update JSON:
# quarto dev-call cli-info > docs/cli/cli-info.json
# 2. Generate .md with:
# quarto run tools/reference-cli-generate-md.R

library(jsonlite)
library(knitr)
library(dplyr)
library(tidyr)
library(here)

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

process_options <- function(options) {
  tibble(options = options) |>
    unnest_wider(options) |>
    select(flags, typeDefinition, description) |>
    rowwise() |>
    mutate(
      flags = paste0("`", flags, "`", collapse = ", "),
      typeDefinition = ifelse(
        typeDefinition == "",
        "",
        paste0("`", typeDefinition, "`")
      )
    ) |>
    knitr::kable(
      col.names = c("Flags", "Arguments", "Description"),
    ) |>
    paste(collapse = "\n")
}

process_commands <- function(commands) {
  if (length(commands) == 0) {
    return("")
  }
  commands_table <- tibble(commands = commands) |>
    unnest_wider(commands) |>
    mutate(name = paste0("`", name, "`")) |>
    select(name, description) |>
    knitr::kable(
      col.names = c("Command", "Description"),
    ) |>
    paste(collapse = "\n")
  paste(heading("Commands", 2), commands_table, sep = "\n")
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

commands_tbl <- tibble(commands) |>
  unnest_wider(commands) |>
  filter(!(name %in% exclude)) |>
  rowwise()

# Expand subcommands that arent "help"
subcommands <-
  commands_tbl |>
  filter(!(length(commands) == 1 & commands[[1]]["name"] == "help")) |>
  unnest(commands) |>
  unnest_wider(commands, names_sep = "_") |>
  filter(commands_name != "help") |>
  mutate(commands_name = paste(name, commands_name)) |>
  select(starts_with("commands_")) |>
  rename_with(~ gsub("commands_", "", .x))

commands_content <- commands_tbl |>
  bind_rows(subcommands) |>
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


# Table for landing ------------------------------------------------------

commands_tbl |>
  select(name, description) |>
  mutate(
    name = paste("[", name, "](", name, ".qmd)", sep = ""),
    description = stringr::str_extract(description, "^[^\\n]+")
  ) |>
  knitr::kable() |>
  writeLines(here("docs", "cli", "includes", "_cli-commands.md"))
