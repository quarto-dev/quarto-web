library(gt)
temps <- data.frame(
  year = c(1920:1924),
  Jan = c(40.6, 44.2, 37.5, 41.8, 39.3), 
  Jun = c(58.5, 58.7, 57.8, 52.7, 57.7)
)
temps |>
  gt() |> 
  data_color(
    columns = c(-year),
    fn = scales::col_numeric(
      colorspace::diverge_hcl(n = 9,
        palette = "Green-Orange"),
      domain = c(35, 62))
  )