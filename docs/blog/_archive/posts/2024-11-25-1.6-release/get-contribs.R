# Run using `quarto run get-contribs.R`

library(tidyverse)
library(gh)
library(glue)

last_release <- "2024-07-01T00:00:00Z"
milestone <- "v1.6"

quarto_staff_vec <-
  c("allenmanning", "cderv", "cscheid", "cwickham", "dragonstyle",
    "jjallaire", "jooyoungseo", "kevinushey", "mcanouil",
    "rich-iannone", "gordonwoodhull", "tarleb", "mine-cetinkaya-rundel")

# Get milestone number -----

milestones <- gh("/repos/{owner}/{repo}/milestones",
  owner = "quarto-dev",
  repo = "quarto-cli")

milestone_number <- map_int(milestones, "number")[map_chr(milestones, "title") == milestone]

# Get cli issues tagged with current milestone -----

quarto_issues <-
  gh(
    endpoint = "/repos/quarto-dev/quarto-cli/issues",
    .limit = 2000,
    .progress = FALSE,
    .params = list(
      state = "all",
      milestone = milestone_number
    )
  )

quarto_issues_tbl <- map(quarto_issues, \(x) data.frame(login = x$user$login, html_url = x$user$html_url)) |> 
  list_rbind() 
  
# Get web issues since last release -----

quarto_web_issues <-
  gh(
    endpoint = "/repos/quarto-dev/quarto-web/issues",
    .limit = 1500,
    .progress = FALSE,
    .params = list(
      state = "all",
      since = last_release
    )
  )

quarto_web_issues_tbl <- map(quarto_web_issues, \(x) data.frame(login = x$user$login, html_url = x$user$html_url)) |> 
  list_rbind() 

# Put together, exclude staff and write to file -----

cli_and_web_users <- bind_rows(quarto_web_issues_tbl, quarto_issues_tbl) |> 
  filter(!(login %in% quarto_staff_vec)) |> 
  arrange(login) |> 
  distinct() 

strings <- cli_and_web_users |> 
  glue_data("[{login}]({html_url}), ") 

strings[length(strings)] <- str_c(str_sub(strings[length(strings)], 1, -3), ".")
  
strings |> write_lines("_contribs.md")
  
