


shinyUI(fluidPage(
  useShinyjs(),
  shinyWidgets::setBackgroundColor("#f3f4f5"),

  titlePanel('Make your own wall map'),
  
  
  mainPanel(
    fluidRow(
      column(width = 6,
             fluidRow(
               h3('1. Where would you like to map?')
             ),
             fluidRow(
               textInput('country_user', 'Country'),
               textInput('province_user', 'Province/State/Region'),
               textInput('city_user', 'City'),
               textInput('address_user', 'Street address'),
               actionButton('submit_address', 'Submit address')
             )
      ),
      column(width = 6,
             div(
               leafletOutput('map'),
               style = "position:fixed; width:inherit;")
      ),
    ),
   
    
    fluidRow(
      h3("2. What style should your map have?")
    ),
    selectInput('tile', 'Select style', choices = tile_list),
    
    fluidRow(
      h3("3. What dimensions should your map have?")
    ),
    fluidRow(
      column(width = 3,
             numericInput('map_width', 'Map width in pixels', value = 600, min = 200, max = 1000)
          ),
      column(width = 3,
             numericInput('map_height', label = "Map height in pixels", value = 400, min = 200, max = 1000))
    ),
    uiOutput('mapjs_width'),
    uiOutput('mapjs_height'),
    
    fluidRow(
      h3("4. Optional: Add an outline and background to your map")
    ),
    
    fluidRow(
      uiOutput('outline_functionality'),
      uiOutput('outline_dropdown')
    ),
    
    fluidRow(
      colourInput("background", "Background color", "white")
    ),
    
    fluidRow(
      h3("5. Add a title and subtitle")
    ),
    
    textInput('title', 'Title'),
    textInput('subtitle', 'Subtitle'),
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
