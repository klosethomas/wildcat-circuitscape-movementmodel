## ---- studyarea-a --------

# This script will generate the studyarea from the wildcat dataset.
#output:

# studyarea           shape
# studyarea_rect      rectangle
# studyarea_rect_big  rectangle with more space, for mapping



# Load the required packages
library("here")                 # used for relative paths
library("sf")
library("dplyr")
library("tidyverse")
library("ggplot2")
library("raster")
library("mapview")

## ---- studyarea-b --------
# load row data
lockstock_all <- read_sf(here("data/shapes/Lockstock2017bis18.shp"))

# delete points in Osnabrück and Süntel
lockstock_heide <-
  subset(lockstock_all, Gebiet != "HP" &
           Gebiet != "Sch" & Gebiet != "OS")
# tidy the data
lockstock_heide$Art_des_Na[lockstock_heide$Art_des_Na == "Felis sp"] <-
  "Felis spec"
lockstock_heide$Art_des_Na[lockstock_heide$Art_des_Na == "Felis sp."] <-
  "Felis spec"
lockstock_heide$Art_des_Na[lockstock_heide$Art_des_Na == "Canis spec."] <-
  "Canis spec"
lockstock_heide$Art_des_Na[lockstock_heide$Art_des_Na == "Baummader"] <-
  "Baummarder"
lockstock_heide$Art_des_Na[lockstock_heide$Art_des_Na == "Art nicht best"] <-
  "Art nicht best."
lockstock_heide$Art_des_Na[lockstock_heide$Art_des_Na == "Art n. best."] <-
  "Art nicht best."

# delete entry with corrupt geometry
lockstock_heide <- subset(lockstock_heide, YKor != "5799114")

# add new colums with the right lat & long values
lockstock_heide <- lockstock_heide %>%
  mutate(xcoord = unlist(map(lockstock_heide$geometry, 1)),
         ycoord = unlist(map(lockstock_heide$geometry, 2)))

# delete false X & Y colums
lockstock_heide <- subset(lockstock_heide, select = -c(XKord, YKor))
st_write(lockstock_heide,
         here("data/shapes/lockstock_heide.shp"),
         delete_dsn = TRUE)
## ---- studyarea-c --------
# create polygon by points
library("concaveman")
polygon <- concaveman(lockstock_heide, concavity = 520)

# buffer polygon to create studyarea
studyarea <- st_buffer(polygon, 30000)

st_write(studyarea, here("data/shapes/studyarea.shp"),
         delete_dsn = TRUE)
## ---- studyarea-d --------

bbox_new <- st_bbox(studyarea) # current bounding box

studyarea_rect <- bbox_new %>%  # take the bounding box ...
  st_as_sfc() %>%# ... and make it a sf polygon
  st_as_sf()

st_write(studyarea_rect, here("data/shapes/studyarea_rect.shp"),
         delete_dsn = TRUE)

xrange <- bbox_new$xmax - bbox_new$xmin # range of x values
yrange <- bbox_new$ymax - bbox_new$ymin # range of y values

bbox_new[1] <- bbox_new[1] - (0.07 * xrange) # xmin - left
bbox_new[3] <- bbox_new[3] + (0.07 * xrange) # xmax - right
bbox_new[2] <- bbox_new[2] - (0.1 * yrange) # ymin - bottom
bbox_new[4] <- bbox_new[4] + (0.1 * yrange) # ymax - top

studyarea_rect_big <- bbox_new %>%  # take the bounding box ...
  st_as_sfc() %>%# ... and make it a sf polygon
  st_as_sf()

st_write(studyarea_rect_big, here("data/shapes/studyarea_rect_big.shp"),
         delete_dsn = TRUE)




# statistics ################

#calculate portions of landuse share with studyarea polygon 

studyarea <- read_sf(here("data/shapes/studyarea.shp")) 


wood <- read_sf(here("data/output/landuse_shape/wood.shp"))%>%
  st_buffer(0)%>%
  st_transform(st_crs(studyarea))%>%
  st_intersection(studyarea)


meadow <- read_sf(here("data/output/landuse_shape/meadow.shp"))%>%
  st_buffer(0)%>%
  st_transform(st_crs(studyarea))%>%
  st_intersection(studyarea)


village <- read_sf(here("data/output/landuse_shape/village.shp"))%>%
  st_buffer(0)%>%
  st_set_crs(crs(studyarea))%>% 
  st_intersection(studyarea)



studyarea$area <- st_area(studyarea)/10000
wood$area <- st_area(wood)/10000
meadow$area <- st_area(meadow)/10000
village$area <- st_area(village)/10000

st_write(studyarea, here("data/output/test/studyarea.shp"))
st_write(wood, here("data/output/test/wood.shp"))
st_write(meadow, here("data/output/test/meadow.shp"))
st_write(village, here("data/output/test/village.shp"))

studayarea_km2 <- sum(studyarea$area)
wood_km2 <- sum(wood$area)
meadow_km2 <- sum(meadow$area)
village_km2 <- sum(village$area)

wood_km2/studayarea_km2

(wood_km2+meadow_km2+village_km2)/studayarea_km2


