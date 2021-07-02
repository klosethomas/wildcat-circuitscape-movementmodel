# get_osm.r

## ---- osm-a  --------
# This script will load the data from osm.
# Download Date: 30.3.21

# Load the required packages
library("here")                 # used for relative paths
library("sf") 
library("osmdata")
library("raster")
library("sp") 
library("dplyr")

## ---- osm-b  --------
## ---- load_data --------   
# will download the Data for the BB of the Studyarea and a buffer 
study   <-read_sf( here("data/shapes/studyarea_rect_big.shp"))

grid <- st_make_grid(study,  n= 5)
st_write(grid, here("data/shapes/grid.shp"),
         delete_dsn = TRUE)

grid   <-read_sf(here("data/shapes/grid.shp"))
grid$POLY_ID <- seq.int(nrow(grid)) 
grid <-  st_transform(grid, "+proj=longlat +ellps=WGS84 +datum=WGS84")

study <- st_transform(study, "+proj=longlat +ellps=WGS84 +datum=WGS84")
#study <- st_transform(study, crs = 32632)
bb <- opq(st_bbox(study), timeout = 3600,  nodes_only = FALSE)

## ---- osm-c  --------
# wildlife_crossing -----------------------------
#load_osm 
cr <- osmdata::add_osm_feature(bb, key = "man_made", value = "wildlife_crossing") %>%
  osmdata_sf()
#only_ploygons
cr1 <- cr$osm_polygons %>%
  subset(select = "osm_id") %>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")
cr1         <- st_buffer(cr1, 5)
st_write(cr1, here("data/output/landuse_shape/crossing.shp"), append = T)

## ---- osm_d  --------
# motorway_underpass -----------------------------
# load_osm 
 mb <- osmdata::add_osm_feature(bb, key = "highway", value = "motorway") %>%
   add_osm_feature(key = "bridge", value = "yes", value_exact = FALSE) %>%
  osmdata::osmdata_sf()
# only_ploygons
 mb1 <- mb$osm_lines %>%
   subset(select = "osm_id") %>%
   st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")
 mb1 <- st_transform(mb1, crs = 32632)
 mb1$lengths <- as.numeric(st_length(mb1))
 mb1 <- mb1[mb1$lengths >= 25, ]
 mb1 <- st_buffer(mb1, 12.5)
 st_write(mb1, here("data/output/landuse_shape/underpass.shp"), append = T)

## ---- osm_e  --------
