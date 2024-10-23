
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
width <-  if (is.na(args[3])) 1440 else as.numeric(args[3])
height <- if (is.na(args[4])) 900 else as.numeric(args[4])
message("==> Creating screenshot of ", url, " and saving to ", image_path)
png <- webshot2::webshot(url, image_path, vwidth = width, vheight = height)
if (Sys.which("optipng") != "") {
  message("==> Shrinking image with optipng")
  webshot2::shrink(png)
}

