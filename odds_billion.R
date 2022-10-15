library(tidyverse)
library(raster)
library(sf)
library(stars)

tifpath = system.file("C:\\Users\\Ethan\\Downloads\\ppp_2020_1km_Aggregated.tif", package = 'stars')

tif = read_stars('C:\\Users\\Ethan\\Downloads\\ppp_2020_1km_Aggregated.tif')

sf = st_as_sf(tif)
