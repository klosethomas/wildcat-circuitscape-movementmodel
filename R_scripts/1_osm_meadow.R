# Meadow -----------------------------
# load_osm

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

grid <- st_make_grid(study,  n= 3)
st_write(grid, here("data/shapes/grid.shp"),
         delete_dsn = TRUE)

grid   <-read_sf(here("data/shapes/grid.shp"))
grid$POLY_ID <- seq.int(nrow(grid)) 
grid <-  st_transform(grid, "+proj=longlat +ellps=WGS84 +datum=WGS84")






meadow_list1 <- vector('list', length(9))
meadow_list2 <- vector('list', length(9))
for ( i in 1:9){
bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)

m1z <- osmdata::add_osm_feature(bbx, key = "landuse", value = c("meadow", "grass")) %>%
  osmdata::osmdata_sf()

# only_ploygons
m1 <- m1z$osm_polygons 



meadow_list1[[i]] <- assign(paste0("meadowa", i), m1)
if(meadow_list1[i] != "NULL" ){
meadow_list1[[i]] <- subset(meadow_list1[[i]], select = "geometry")
} 

if(is.null(m1z$osm_multipolygons) == FALSE){
m1a <- m1z$osm_multipolygons 
meadow_list2[[i]] <- assign(paste0("meadowb", i), m1a)

meadow_list2[[i]] <- subset(meadow_list2[[i]], select = "geometry")
 
}

}
meadow_list1 <- meadow_list1[!sapply(meadow_list1,is.null)]
meadow1 <- do.call(rbind, meadow_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

meadow_list2 <- meadow_list2[!sapply(meadow_list2,is.null)]

if(installr::is.empty(meadow_list2) == FALSE){
meadow2 <- do.call(rbind, meadow_list2)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
  st_cast("POLYGON")

meadow_landuse <- rbind(meadow1, meadow2)} else{
  meadow_landuse <- meadow1
}

#--------------------------------------------------------------------------------------
meadow_list1 <- vector('list', length(9))
meadow_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- osmdata::add_osm_feature(bbx, key = "natural", 
                                  value = c("grassland", "heath", "scrub", "wetland")) %>%
    osmdata_sf()
  
  # only_ploygons
  m1 <- m1z$osm_polygons 
  
  if(is.null(m1z$osm_polygons) == FALSE){
  meadow_list1[[i]] <- assign(paste0("meadowa", i), m1)

    meadow_list1[[i]] <- subset(meadow_list1[[i]], select = "geometry")
  }
  
  if(is.null(m1z$osm_multipolygons) == FALSE){
    m1a <- m1z$osm_multipolygons 
    meadow_list2[[i]] <- assign(paste0("meadowb", i), m1a)
    
    meadow_list2[[i]] <- subset(meadow_list2[[i]], select = "geometry")
    
  }
  
}
meadow_list1 <- meadow_list1[!sapply(meadow_list1,is.null)]

meadow1 <- do.call(rbind, meadow_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")


meadow_list2 <- meadow_list2[!sapply(meadow_list2,is.null)]

if(installr::is.empty(meadow_list2) == FALSE){
  meadow2 <- do.call(rbind, meadow_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("POLYGON")
  
  meadow_natural <- rbind(meadow1, meadow2)} else{
    meadow_natural <- meadow1
  }

#--------------------------------------------------------------------------------------
meadow <- rbind(meadow_natural, meadow_landuse)
st_write(meadow, here("data/output/landuse_shape/meadow.shp"), append = T)

# study   <-read_sf( here("data/shapes/studyarea.shp"))
# meadow <- st_intersects(study, meadow_map)
# st_write(meadow, here("data/output/landuse_shape/meadow.shp"), append = T)




###################################################################################
#in case of the download is not working and you got the data from other sources:
#extract landuse from OSM-Datasets


library("here")                 # used for relative paths
library("sf")
library("dplyr")
library("tidyverse")
library("ggplot2")
library("raster")


meadow1 <- read_sf(here("data/output/landuse_shape/workingspace/wetland.shp"))%>%
  subset(select = "geometry") %>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
  st_cast("POLYGON")
meadow2 <- read_sf(here("data/output/landuse_shape/workingspace/meadow.shp"))%>%
  subset(select = "geometry") %>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
  st_cast("POLYGON")
meadow3 <- read_sf(here("data/output/landuse_shape/workingspace/scrub.shp"))%>%
  subset(select = "geometry") %>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
  st_cast("POLYGON")
meadow4 <- read_sf(here("data/output/landuse_shape/workingspace/heath.shp"))%>%
  subset(select = "geometry") %>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
  st_cast("POLYGON")
meadow5 <- read_sf(here("data/output/landuse_shape/workingspace/grass.shp"))%>%
  subset(select = "geometry") %>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
  st_cast("POLYGON")
meadow6 <- read_sf(here("data/output/landuse_shape/workingspace/grassland.shp"))%>%
  subset(select = "geometry") %>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
  st_cast("POLYGON")

meadow <- rbind(meadow1,
                meadow2,
                meadow3,
                meadow4,
                meadow5,
                meadow6)

st_write(meadow, here("data/output/landuse_shape/meadow.shp"), delete_dsn = T)

