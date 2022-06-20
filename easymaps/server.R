

library(shiny)

shinyServer(function(input, output, server) {
  
  source('map_script.R')
  
  output$tile_functionality <- renderUI({
    selectInput('tile', 'Select style', choices = tile_list)
  })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(urlTemplate = input$tile) %>%
      setView(lng = 0, lat = 0, zoom = 1)
  })
  
  current_zoom <- reactive({
    input$map_zoom
  })
  
  current_center <- reactive({
    input$map_center
  })
  
  output$lng <- renderText({
    current_center()$lng[1]
    })
  output$lat <- renderText(current_center()$lat[1])
  output$zoom <- renderText(current_zoom())
  
  observeEvent(input$create, {
    print_m <<- make_map(current_center()$lng[1], current_center()$lat[1],
                        zoom = input$map_zoom,
                        title = input$title,
                        tile = input$tile,
                        location = input$subtitle)
    
    output$statusmessage <- renderText('Map complete')
  })
  
  output$download <- downloadHandler(
    filename = function() {
      str_c(input$title, "_", input$subtitle, ".png")
    },
    content = function(file) {
      image_write(print_m, file)
    }
  )

})
