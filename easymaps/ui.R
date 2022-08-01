


shinyUI(fluidPage(
  useShinyjs(),
  shinyWidgets::setBackgroundColor("#f3f4f5"),

  titlePanel('Make your own wall map'),
  mainPanel(
    selectInput('tile', 'Select style', choices = tile_list),
    fluidRow(
      column(width = 3,
             numericInput('map_width', 'Map width in pixels', value = 600, min = 200, max = 1000)
          ),
      column(width = 3,
             numericInput('map_height', label = "Map height in pixels", value = 400, min = 200, max = 1000))
    ),
    uiOutput(
      'map_display'
    ),
    column(width = 6,
           fluidRow(
             column(width = 3,
                    numericInput('lng_user', 'Longitude', value = 0)
             ),
             column(width = 3,
                    numericInput('lat_user', 'Latitude', value = 0)
             )
           ),
           actionButton('submit_coords', 'Submit coordinates'),
          ),
    column(width = 6,
           fluidRow(
             textInput('country_user', 'Country'),
             textInput('province_user', 'Province/State/Region'),
             textInput('city_user', 'City'),
             textInput('address_user', 'Street address')
           ),
           actionButton('submit_address', 'Submit address'),
           uiOutput('outline_functionality'),
           uiOutput('outline_dropdown')
           ),
    
    textInput('title', 'Title'),
    textInput('subtitle', 'Subtitle'),
    textOutput("lng"),
    textOutput("lat"),
    textOutput('zoom'),
    actionButton('create', 'Create map'),
    
    fluidRow(
      imageOutput('preview_map')
      ),
    
    br(),
    
    fluidRow(
      column(width = 3,
             textOutput('statusmessage')
      ),

      column(width = 3,
             uiOutput('download_display')
      )
    )
)))
