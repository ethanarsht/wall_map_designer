


shinyServer(function(input, output, server) {
  
  source('map_script.R')
  
  background_color <- reactive(
    input$background
  )
  
  output$tile_functionality <- renderUI({
    selectInput('tile', 'Select style', choices = tile_list)
  })
  
  output$mapjs_width <- renderUI({
    tags$script(HTML(paste0(
      'document.getElementById("map").style.width="', input$map_width, 'px";'
    )))
  })
  
  output$mapjs_height <- renderUI({
    tags$script(HTML(paste0(
      'document.getElementById("map").style.height="', input$map_height, 'px";'
    )))
  })
  
  lng_reactive <- reactive({
    input$lng_user
  })
  
  lat_reactive <- reactive({
    input$lat_user
  })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      pif(input$tile == 'watercolor', addProviderTiles(., providers$Stamen.Watercolor)) %>%
      pif(input$tile != 'watercolor', addTiles(., urlTemplate = input$tile)) %>%
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
                 
                 req(input$outline_selection)
                 city_bounds <- lookupid_to_sf(df_osm_levels, input$outline_selection)
                 if (!is.na(city_bounds)) {
                   outline <<- as_Spatial(city_bounds)
                   
                   wld <- raster::rasterToPolygons(raster::raster(ncol = 1, nrow = 1, crs = proj4string(outline)))
                   
                   msk <- gDifference(wld, outline)
                   
                   
                   leafletProxy('map') %>%
                     clearGroup('city_outline') %>%
                     addPolygons(
                       data = msk,
                       fillOpacity = 1,
                       color = 'white',
                       group = 'city_outline'
                     )
                   outline_binary <<- TRUE
                 }
               })
  
  observeEvent(input$submit_coords, {
    leafletProxy('map') %>%
      setView(
        lng = input$lng_user, lat = input$lat_user, zoom = current_zoom()
      )
    
    outline_binary <<- FALSE
    
  })
  
  observeEvent(input$submit_address, {
    geo_address <<- paste0(input$address_user, ", ", input$city_user, ", ", 
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
      ) %>%
      clearGroup('city_outline')
    
    outline_binary <<- FALSE
    output$outline_functionality <- renderUI({
      actionButton('add_outline', "Show only city")
    })
    
    output$outline_dropdown <- NULL
  })
  
  
  current_zoom <- reactive({
    input$map_zoom
  })
  
  current_center <- reactive({
    input$map_center
  })
  
  observeEvent(input$submit_address, {
    if (input$city_user != "") {
      output$outline_functionality <- renderUI({
        actionButton('add_outline', "Add area outline")
      })
    }
  })
  
  
  
  observeEvent(input$add_outline, {
    
    df_osm_levels <<- get_city_boundaries(address_str = geo_address)
    
    output$outline_dropdown <- renderUI({
      tagList(
        fluidRow(
          column(width = 3,
                 selectInput('outline_selection',
                             label = "Select outline level",
                             choices = df_osm_levels$level)
          ),
          column(width = 3,
                 h5(paste0("Use the dropdown to select an area outline. Each number represents an OpenStreetMap",
                             " outline level. Lower numbers are larger areas such as countries. Higher numbers are",
                             " smaller areas such as cities or neighborhoods.")))
        )
      )
    })
  })
  
  observeEvent(input$outline_selection, {
    city_bounds <- lookupid_to_sf(df_osm_levels, input$outline_selection)
    if (!is.na(city_bounds)) {
      outline <<- as_Spatial(city_bounds)

      wld <- raster::rasterToPolygons(raster::raster(ncol = 1, nrow = 1, crs = proj4string(outline)))

      msk <- gDifference(wld, outline)

      print(background_color())
      leafletProxy('map') %>%
        clearGroup('city_outline') %>%
        addPolygons(
          data = msk,
          fillOpacity = 1,
          fillColor = background_color(),
          color = 'white',
          group = 'city_outline'
        )
      outline_binary <<- TRUE
    }
    
    output$outline_functionality <- renderUI(
      tagList(
        actionButton('remove_outline', 'Remove outline')
        # actionButton('backup_outline', 'Backup method')
      )
    )
  })
  
  observeEvent(input$backup_outline, {
    outline <<- as_Spatial(get_city_boundaries_old(address_str = geo_address))
    
    wld <- raster::rasterToPolygons(raster::raster(ncol = 1, nrow = 1, crs = proj4string(outline)))
    
    msk <- gDifference(wld, outline)
    
    
    leafletProxy('map') %>%
      clearGroup('city_outline') %>%
      addPolygons(
        data = msk,
        fillOpacity = 1,
        color = background_color(),
        group = 'city_outline'
      )
  })
  
  observeEvent(input$remove_outline, {
    
    outline_binary <<- FALSE
    leafletProxy('map') %>%
      clearGroup('city_outline')
    
    output$outline_functionality <- renderUI({
      actionButton('add_outline', "Show only city")
    })
    
    output$outline_dropdown <- NULL
    
    print(input$add_outline)
  })
  
  observeEvent(input$create, {
    print(input$use_city_boundaries)
    print(geo_address)
    output$statusmessage <- renderText("Rendering...")
    Sys.sleep(1)
    print_m <<- make_map(current_center()$lng[1], current_center()$lat[1],
                         zoom = input$map_zoom,
                         title = input$title,
                         tile = input$tile,
                         location = input$subtitle,
                         width = input$map_width,
                         height = input$map_height,
                         outline_ind = outline_binary,
                         boundary_input = outline)
    # } else {
    #   print_m <<- make_map(current_center()$lng[1], current_center()$lat[1],
    #                        zoom = input$map_zoom,
    #                        title = input$title,
    #                        tile = input$tile,
    #                        location = input$subtitle,
    #                        width = input$map_width,
    #                        height = input$map_height,
    #                        outline_ind = outline_binary)
    # }
    
    
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
