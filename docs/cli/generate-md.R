library(jsonlite)
library(knitr)
library(dplyr)
library(tidyr)

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
  tibble(commands = commands) |>
    unnest_wider(commands) |>
    mutate(name = paste0("`", name, "`")) |>
    select(name, description) |>
    knitr::kable(
      col.names = c("Command", "Description"),
    ) |>
    paste(collapse = "\n")
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
    pull(text)
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
    heading("Commands"),
    commands_table,
    "\n",
    examples_text,
    sep = "\n",
    collapse = "\n"
  )
}

cli_json <- read_json("cli-info.json")
commands <- cli_json$commands

commands_content <- tibble(commands) |>
  unnest_wider(commands) |>
  rowwise() |>
  mutate(
    filename = paste0("_", name, ".md"),
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
