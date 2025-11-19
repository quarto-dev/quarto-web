# Reorder gallery YAML file -----------------------------------
## Example command
##    quarto run .\tools\sort-gallery.R docs\extensions\listings\journal-articles.yml  


args <- commandArgs(trailingOnly = TRUE)

yaml_file <- args[1]

yaml <- yaml::read_yaml(yaml_file)

yaml_ordered <- yaml[order(purrr::map_chr(yaml, "name"))]

yaml::write_yaml(yaml_ordered, yaml_file)

xfun::file_string(yaml_file) |> 
  # Add back spaces
  gsub(pattern = "\n- name:", replacement = "\n\n- name:") |> 
  # replace | by >
  gsub(pattern = " \\|", replacement = " \\>") |> 
  xfun::write_utf8(con = yaml_file)

## TODO: make a TS or Python script for a new parser / writer
## Then run this at each PR of a YAML file for gallery
rlang::warn("Please do check source control from reformatting problem (like newlines `\\n` and quotes `\"` not removed.")