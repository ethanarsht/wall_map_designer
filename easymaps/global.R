library(leaflet)
library(shiny)
library(tidygeocoder)
library(osmdata)
library(raster)
library(rgeos)
library(mapview)
library(shinyWidgets)
library(sf)
library(shinyjs)
library(tidyverse)
library(geojsonsf)
library(jsonlite)

tile_list <- list(
  "Minimalist Light" = 'https://api.mapbox.com/styles/v1/ethanarsht/ckzh1dxab009h14l85ghq6ccm/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXRoYW5hcnNodCIsImEiOiJja3p4emVycHgwNmpuMnBwY296emJkdG5nIn0.WH_aegqXnpfsAQ-OrdIJeA',
  "Minimalist Dark"= 'https://api.mapbox.com/styles/v1/ethanarsht/ckzfu0dww001u14mz9crqmw71/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXRoYW5hcnNodCIsImEiOiJja3p4emVycHgwNmpuMnBwY296emJkdG5nIn0.WH_aegqXnpfsAQ-OrdIJeA'
)


get_city_boundaries <- function(address_str) {
  
  address_str <- "Bologna"
  outline_geo <- geo(address_str,
                     method = "osm", full_results = TRUE
  )
  
  r <- httr::GET(str_c(
    "https://global.mapit.mysociety.org/point/4326/", outline_geo[[1, "long"]], ",", outline_geo[[1, "lat"]]
    )
  )
  
  data <- fromJSON(rawToChar(r$content))
  
  for (n in names(data)) {
    print(n)
    if (data[[n]]$type_name == "OSM Administrative Boundary Level 8") {
      print(data[[n]])
      lookup_id <- n
    }
  }
  
  if (!exists('lookup_id')) {
    for (n in names(data)) {
      print(n)
      if (data[[n]]$type_name == "OSM Administrative Boundary Level 6") {
        print(data[[n]])
        lookup_id <- n
        print(lookup_id)
      }
    }
  }
  
  if (exists('lookup_id')) {
    mapit_lookup <- httr::GET(str_c("https://global.mapit.mysociety.org/area/", lookup_id, ".geojson"))
    sf <- geojson_sf(rawToChar(mapit_lookup$content))
    return(sf)
  } else {
    return(NA)
  }
  
  
}

get_city_boundaries_old <- function(address_str) {
  
  boundaries <- opq(bbox = address_str) %>%
    add_osm_feature(key = 'admin_level', value = 8) %>%
    osmdata_sf

  municipalities <- boundaries$osm_multipolygons %>%
    st_make_valid() %>%
    summarize()
}

pif <- function(x, p, true, false = identity){
  if(!requireNamespace("purrr")) 
    stop("Package 'purrr' needs to be installed to use function 'pif'")
  
  if(inherits(p,     "formula"))
    p     <- purrr::as_mapper(
      if(!is.list(x)) p else update(p,~with(...,.)))
  if(inherits(true,  "formula"))
    true  <- purrr::as_mapper(
      if(!is.list(x)) true else update(true,~with(...,.)))
  if(inherits(false, "formula"))
    false <- purrr::as_mapper(
      if(!is.list(x)) false else update(false,~with(...,.)))
  
  if ( (is.function(p) && p(x)) || (!is.function(p) && p)){
    if(is.function(true)) true(x) else true
  }  else {
    if(is.function(false)) false(x) else false
  }
}



