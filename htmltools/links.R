library(htmltools)

card <- function(x) {
  div(class = "card",
      div(class = "card-body",
          div(class = "card-title", tags$h4(x$title)),
          ifelse(!is.null(x$subtitle),
                 tagList(div(class = "card-subtitle text-muted", tags$h6(HTML(x$subtitle)))),
                 tagList()),
          tags$ul(tagList(lapply(x$links, function(link) { 
            tags$li(tags$a(href = link[[2]], link[[1]]))
          })))
      )    
  )
}

link_cards <- function(file) {
  cards <- yaml::yaml.load_file(file)
  div(class = "link-cards", tagList(lapply(cards, card)))
}
