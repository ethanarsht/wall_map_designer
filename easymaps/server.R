

library(shiny)

shinyServer(function(input, output, server) {
  
  source('map_script.R')
  
  output$tile_functionality <- renderUI({
    selectInput('tile', 'Select style', choices = tile_list)
  })
  
  output$map_display <- renderUI({
    leafletOutput('map', width = input$map_width, height = input$map_height)
  })
  
  lng_reactive <- reactive({
    input$lng_user
  })
  
  lat_reactive <- reactive({
    input$lat_user
  })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(urlTemplate = input$tile) %>%
      setView(lng = 0, lat = 0, zoom = 1)
  })
  
  observeEvent(input$tile,
               {
                 leafletProxy('map') %>%
                   addTiles(urlTemplate = input$tile) %>%
                   setView(lng = current_center()$lng[1],
                           lat = current_center()$lat[1],
                           zoom = current_zoom()
                   )
               })
  
  observeEvent(input$submit_coords, {
    leafletProxy('map') %>%
      setView(
        lng = input$lng_user, lat = input$lat_user, zoom = current_zoom()
      )
  })
  
  observeEvent(input$submit_address, {
    geo_address <- paste0(input$address_user, ", ", input$city_user, ", ", 
                          input$province_user, ", ", input$country_user)
    
    df_address <- data.frame(
      address = c(geo_address)
    )
    print(geo_address)
    
    reverse <- geocode(
      df_address, address, method = 'osm'
    )
    print(reverse)
    
    leafletProxy('map') %>%
      setView(
        lng = reverse[[1, 'long']], lat = reverse[[1, 'lat']], zoom = 12
      )
  })
  
  
  current_zoom <- reactive({
    input$map_zoom
  })
  
  current_center <- reactive({
    input$map_center
  })
  
  output$lng <- renderText(current_center()$lng[1])
  output$lat <- renderText(current_center()$lat[1])
  output$zoom <- renderText(current_zoom())
  
  observeEvent(input$create, {
    output$statusmessage <- renderText("Rendering...")
    Sys.sleep(1)
    print_m <<- make_map(current_center()$lng[1], current_center()$lat[1],
                        zoom = input$map_zoom,
                        title = input$title,
                        tile = input$tile,
                        location = input$subtitle,
                        width = input$map_width,
                        height = input$map_height)
    
    output$statusmessage <- renderText('Ready for download')

    output$preview_map <- renderImage({
      tmpfile <- print_m %>% image_write(tempfile(fileext = 'jpg'), format = 'jpg')
      list(src = tmpfile, contentType = "image/jpeg",
           width = input$map_width + 100, height = input$map_height + 100)
    },
    deleteFile = T)
    
    output$download_display <- renderUI({
      downloadButton('download', 'Download')
    })
  })
  
  output$download <- downloadHandler(
    filename = function() {
      str_c(input$title, "_", input$subtitle, ".png")
    },
    content = function(file) {
      image_write(print_m, file)
    }
  )
  
  observeEvent(input$download, {
    output$statusmessage <- NULL
  })

})
