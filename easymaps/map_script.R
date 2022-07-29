library(tidyverse)
library(leaflet)
library(magick)
library(mapview)
library(htmlwidgets)

mapviewOptions(platform = "leaflet", mapview.maxpixels = Inf, plainview.maxpixels = Inf, raster.size = Inf)

make_map <- function(lng, lat, zoom, title, location, tile, width, height, 
                      boundary_input = NULL, outline_ind) {
  
  # get outline of selected municipality
  
  # lng = 28.7319989
  # lat = 41.0049823
  # zoom = 11
  # title = 'Bidhannagar'
  # location = 'West Bengal'
  # tile <- 'https://api.mapbox.com/styles/v1/ethanarsht/ckzfu0dww001u14mz9crqmw71/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXRoYW5hcnNodCIsImEiOiJja3p4emVycHgwNmpuMnBwY296emJkdG5nIn0.WH_aegqXnpfsAQ-OrdIJeA'
  # width = 700
  # height = 700
  # geo_address = "Istanbul, Turkey"
  
  if (outline_ind == TRUE) {
    outline <- boundary_input
    
    wld <- raster::rasterToPolygons(raster::raster(ncol = 1, nrow = 1, crs = proj4string(outline)))
    
    msk <- gDifference(wld, outline)
    
    m <- msk %>% 
      leaflet() %>%
      addTiles(urlTemplate = tile) %>%
      addPolygons(
        
        fillOpacity = 1,
        color = 'white'
      ) %>%
      setView(lng = lng, lat = lat, zoom = zoom)
    
  } else {
    m <- leaflet() %>%
      addTiles(urlTemplate = tile) %>%
      setView(lng = lng, lat = lat, zoom = zoom)
  }
  
  
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
  
  
  
  
  mapshot(m, file = "temp.png", selfcontained = FALSE, zoom = 2,
          vwidth = width, vheight = height
          )

  i <- image_read('temp.png')
  
  ii <- image_info(i)
  
  outline_ind <- T
  
  i_crop <- i %>%
    image_crop(str_c(ii$width - 75, "x", ii$height - 75, "+0+0"), gravity = 'center') %>%
    pif(outline_ind == F, image_border(., "gray", "10x10")) %>%
    # image_border('gray', '10x10') %>%
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

# s <- make_map(lng = 4.35, lat = 50.8, zoom = 10, title = 'Bidhannagar', location = 'West Bengal',
#               tile <- 'https://api.mapbox.com/styles/v1/ethanarsht/ckzh1dxab009h14l85ghq6ccm/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXRoYW5hcnNodCIsImEiOiJja3p4emVycHgwNmpuMnBwY296emJkdG5nIn0.WH_aegqXnpfsAQ-OrdIJeA',
#               width = 400,
#               height = 400,
#               outline_city = ", Brussels, , "
# )


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
