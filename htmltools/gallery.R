library(htmltools)

# gallery is a list file()ories
gallery <- function(file) {
  gallery <- yaml::yaml.load_file(file)
  tagList(lapply(gallery, category))
}

# category is a list of items with a header
category <- function(category) {
  withTags(tagList(
    h2(category$category),
    p(category$description),
    div(class = "gallery-category grid",
        lapply(category$items, item)
    )
  ))
}

# item is a bootstrap card with a thumbnail
item <- function(item) {
  withTags({
    div(class = "card border-2 rounded-3 g-col-12 g-col-sm-6 g-col-md-4 mb-2",
        div(class = "card-header py-1 px-2 border-bottom border-1",
            small(class = "card-text text-nowrap inline-block",
                  a(href = item$href, item$title), 
                  span(" "),
                  span(class = "fw-light", item$subtitle)
            ),
            a(class = "source-code card-text float-end inline-block", 
              href = item$code,
              title = "View source code",
              i(class="bi-code-slash")
            )
        ),
        a(href = item$href,
          img(
            class = "card-img-top",
            src = item$thumbnail,
            alt = item$description
          )
        )
    )
  })
}

