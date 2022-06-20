library(leaflet)
library(shiny)

tile_list <- list(
  "Minimalist Light" = 'https://api.mapbox.com/styles/v1/ethanarsht/ckzh1dxab009h14l85ghq6ccm/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXRoYW5hcnNodCIsImEiOiJja3p4emVycHgwNmpuMnBwY296emJkdG5nIn0.WH_aegqXnpfsAQ-OrdIJeA',
  "Minimalist Dark"= 'https://api.mapbox.com/styles/v1/ethanarsht/ckzfu0dww001u14mz9crqmw71/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXRoYW5hcnNodCIsImEiOiJja3p4emVycHgwNmpuMnBwY296emJkdG5nIn0.WH_aegqXnpfsAQ-OrdIJeA'
)
