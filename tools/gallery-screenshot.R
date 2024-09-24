
# Screenshot example for Gallery Image -----------------------------------

## Example: Run this command from root repo
##     quarto run .\tools\gallery-screenshot.R .\docs\gallery\dashboards\dashing-through-snow.png  https://mine.quarto.pub/dashing-through-snow-py/

args <- commandArgs(trailingOnly = TRUE)

# Check if the correct number of arguments are provided
if (length(args) < 2) {
  stop("Please provide both the image path and URL.")
}

# Set variables from command line arguments
image_path <- args[1]
if (xfun::file_ext(image_path) != "png") {
  stop("First argument must be a .png image path to create.")
}
url <- args[2]

# taking the size from previous image
infos <- magick::image_read("docs/gallery/dashboards/housing-market-dashboard.png")  |> magick::image_info()
webshot2::webshot(url, image_path, vwidth = infos$width, vheight = infos$height)
