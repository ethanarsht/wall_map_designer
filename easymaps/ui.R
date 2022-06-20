library(leaflet)

library(shiny)


shinyUI(fluidPage(

  titlePanel('Make your own wall map'),
  mainPanel(
    selectInput('tile', 'Select style', choices = tile_list),
    leafletOutput(
      'map'
    ),
    textInput('title', 'Title'),
    textInput('subtitle', 'Subtitle'),
    textOutput("lng"),
    textOutput("lat"),
    textOutput('zoom'),
    actionButton('create', 'Create map'),
    textOutput('statusmessage'),
    downloadButton('download', 'Download')
  )
))
