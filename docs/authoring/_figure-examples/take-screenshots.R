# Generate screenshots of HTML outputs

library(webshot2)
library(fs) 

webshot("_examples.html", "../images/elephant-subfigures.png",
  selector = "#fig-elephants", zoom = 2, vwidth = 1200)

shoot_figure_id <- function(id){
  webshot("_examples.html", 
    file = fs::path("..", "images", id, ext = "png"),
    selector = paste0("#", id), 
    zoom = 2, vwidth = 1200)
}

shoot_figure_id("elephant-figures-no-subcaption")
shoot_figure_id("elephant-rows")
shoot_figure_id("layout-attrib")
shoot_figure_id("layout-attrib-negative")
shoot_figure_id("valign")