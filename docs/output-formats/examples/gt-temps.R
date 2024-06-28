library(dplyr)
library(gt)

temps <- data.frame(
  year = c(1920:1924),
  Jan = c(40.6, 44.2, 37.5, 41.8, 39.3), 
  Jun = c(58.5, 58.7, 57.8, 52.7, 57.7)
)

temps %>% 
  gt() %>% 
  data_color(
    columns = c(-year),
    colors = scales::col_numeric(
      colorspace::diverge_hcl(n = 9, palette = "Green-Orange"), # colorblind safe and topical
      domain = c(35, 62)) # original c(31.3, 66.6)
  )
