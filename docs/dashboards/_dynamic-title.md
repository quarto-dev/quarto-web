::: {.panel-tabset}

## Python

```` {.python .pymd}
```{{python}}
from ipyleaflet import Map, basemaps, basemap_to_tiles

lat = 48
long = 350

print("title=", f"World Map at {lat}, {long}")

Map(basemap=basemap_to_tiles(basemaps.OpenStreetMap.Mapnik),
    center=(lat, long), zoom=2)
```
````

## R

````{.markdown}
```{{r}}
library(leaflet)

lat <- 48
long <- 350

cat("title=", "World Map at", lat, long)

leaflet() |> addTiles() |> 
  setView(long, lat, zoom = 2)
```
````

:::
