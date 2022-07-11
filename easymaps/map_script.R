library(tidyverse)
library(leaflet)
library(magick)
library(mapview)
library(htmlwidgets)

mapviewOptions(platform = "leaflet", mapview.maxpixels = Inf, plainview.maxpixels = Inf, raster.size = Inf)

make_map <- function(lng, lat, zoom, title, location, tile, width, height) {
  # lng = 5.1225301
  # lat = 52.0734346
  # zoom = 16
  # title = 'Miami'
  # location = 'Florida'
  
  # tile <- 'https://api.mapbox.com/styles/v1/ethanarsht/ckzh1dxab009h14l85ghq6ccm/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXRoYW5hcnNodCIsImEiOiJja3p4emVycHgwNmpuMnBwY296emJkdG5nIn0.WH_aegqXnpfsAQ-OrdIJeA'
  m <- leaflet() %>%
    addTiles(urlTemplate = tile) %>%
    # addProviderTiles(providers$Stamen.Watercolor) %>%
    # addCircleMarkers(
    #   lng = 5.1225301,
    #   lat = 52.0734346,
    #   color = "orange",
    #   fillColor = "orange",
    #   opacity = 0,
    #   fillOpacity = .75,
    #   radius = 12
    # ) %>%
    setView(lng = lng, lat = lat, zoom = zoom)
  
  mapshot(m, file = "temp.png", selfcontained = FALSE, zoom = 2,
          vwidth = width, vheight = height
          )

  i <- image_read('temp.png')
  
  i_crop <- i %>%
    # image_crop('1400X800', gravity = 'center') %>%
    image_border('gray', '10x10') %>%
    image_border('white', '200x200+100+100') %>%
    # image_crop('800x950', gravity = 'south') %>%
    image_annotate(toupper(title), size = 50, gravity = "south",
                   location = '+0+110',
                   weight = 700) %>%
    image_annotate(location,
                   size = 30,
                   gravity = 'south',
                   location = '+0+70',
                   style = 'italic') %>%
    # image_annotate('Ethan Arsht',
    #                size = 15,
    #                gravity = 'south',
    #                location = "+300+25",
    #                font = "Mistral",
    #                color = "blue") %>%
    # image_scale('875x875!') %>%
    image_border('white', '50x50')
  return(i_crop)
}

# s <- make_map(lng = 88.4522, lat = 22.57849, zoom = 13, title = 'Bidhannagar', location = 'West Bengal')


# image_write(s, 'bidhannagar.png')
# 
# m <- leaflet() %>%
#   addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
#   setView(lng = -111.4185629, lat = 40.6469941, zoom = 16)
# 
# mapshot(m, file = 'temp.png')
# 
# i <- image_read('temp.png')
# 
# i_crop <- i %>%
#   image_crop('992x700+0+20', gravity = 'south') %>%
#   image_border('gray', '10x10') %>%
#   image_border('white', '200x200') %>%
#   image_annotate('KIPS HOUSE', size = 70, gravity = "south",
#                  location = '+0+100',
#                  weight = 700) %>%
#   image_annotate('Brussels, Belgium',
#                  size = 30,
#                  gravity = 'south',
#                  location = '+0+50',
#                  style = 'italic')
