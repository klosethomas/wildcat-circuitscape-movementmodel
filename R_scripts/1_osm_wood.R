# wood -----------------------------
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






wood_list1 <- vector('list', length(9))
wood_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature(bbx, key = "landuse", value = "forest" ) %>%
    osmdata_sf
  
  # only_ploygons
  m1 <- m1z$osm_polygons 
  
  if(is.null(m1z$osm_polygons) == FALSE){
  wood_list1[[i]] <- assign(paste0("wooda", i), m1)
    wood_list1[[i]] <- subset(wood_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multipolygons) == FALSE){
    m1a <- m1z$osm_multipolygons 
    wood_list2[[i]] <- assign(paste0("woodb", i), m1a)
    wood_list2[[i]] <- subset(wood_list2[[i]], select = "geometry")
    
  }
  
}
wood_list1 <- wood_list1[!sapply(wood_list1,is.null)]
wood1 <- do.call(rbind, wood_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

wood_list2 <- wood_list2[!sapply(wood_list2,is.null)]

if(installr::is.empty(wood_list2) == FALSE){
  wood2 <- do.call(rbind, wood_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("POLYGON")
  
  wood_landuse <- rbind(wood1, wood2)} else{
    wood_landuse <- wood1
  }

#--------------------------------------------------------------------------------------
wood_list1 <- vector('list', length(9))
wood_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature(bbx, key = "natural", value = "wood") %>%
    osmdata_sf
  
  # only_ploygons
  m1 <- m1z$osm_polygons 
  
  if(is.null(m1z$osm_polygons) == FALSE){
  wood_list1[[i]] <- assign(paste0("wooda", i), m1)
    wood_list1[[i]] <- subset(wood_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multipolygons) == FALSE){
    m1a <- m1z$osm_multipolygons 
    wood_list2[[i]] <- assign(paste0("woodb", i), m1a)
    
    wood_list2[[i]] <- subset(wood_list2[[i]], select = "geometry")
    
  }
  
}
wood_list1 <- wood_list1[!sapply(wood_list1,is.null)]
wood1 <- do.call(rbind, wood_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

wood_list2 <- wood_list2[!sapply(wood_list2,is.null)]

if(installr::is.empty(wood_list2) == FALSE){
  wood2 <- do.call(rbind, wood_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("POLYGON")
  
  wood_natural <- rbind(wood1, wood2)} else{
    wood_natural <- wood1
  }

#--------------------------------------------------------------------------------------
wood_map <- rbind(wood_natural, wood_landuse)
st_write(wood_map, here("data/output/landuse_shape/wood_map.shp"), append = T)

study   <-read_sf( here("data/shapes/studyarea.shp"))
wood <- st_intersects(study, wood_map)
st_write(wood, here("data/output/landuse_shape/wood.shp"), append = T)
