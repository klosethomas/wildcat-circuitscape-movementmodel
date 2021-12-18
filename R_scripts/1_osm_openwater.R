# openwater -----------------------------
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






openwater_list1 <- vector('list', length(9))
openwater_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature (bbx, key = "water") %>% 
    osmdata_sf()
  
  # only_ploygons
  m1 <- m1z$osm_polygons 
  
  
  if(is.null(m1z$osm_polygons) == FALSE){
  openwater_list1[[i]] <- assign(paste0("openwatera", i), m1)
  
    openwater_list1[[i]] <- subset(openwater_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multipolygons) == FALSE){
    m1a <- m1z$osm_multipolygons 
    openwater_list2[[i]] <- assign(paste0("openwaterb", i), m1a)
    
    openwater_list2[[i]] <- subset(openwater_list2[[i]], select = "geometry")
    
  }
  
}


openwater_list1 <- openwater_list1[!sapply(openwater_list1,is.null)]
openwater1 <- do.call(rbind, openwater_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

openwater_list2 <- openwater_list2[!sapply(openwater_list2,is.null)]

if(installr::is.empty(openwater_list2) == FALSE){
  openwater2 <- do.call(rbind, openwater_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("POLYGON")
  
  openwater_landuse <- rbind(openwater1, openwater2)} else{
    openwater_landuse <- openwater1
  }
save(openwater_landuse,
     file = here("data/workspace/openwater_landuse.rds"))
#--------------------------------------------------------------------------------------
openwater_list1 <- vector('list', length(9))
openwater_list2 <- vector('list', length(9))
for ( i in 5:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature (bbx, key = "natural", value = "water") %>% 
    osmdata_sf()
  
  # only_ploygons
  m1 <- m1z$osm_polygons 
  
  if(is.null(m1z$osm_polygons) == FALSE){
    openwater_list1[[i]] <- assign(paste0("openwatera", i), m1)
    
    openwater_list1[[i]] <- subset(openwater_list1[[i]], select = "geometry")
  }
  
  if(is.null(m1z$osm_multipolygons) == FALSE){
    m1a <- m1z$osm_multipolygons 
    openwater_list2[[i]] <- assign(paste0("openwaterb", i), m1a)
    
    openwater_list2[[i]] <- subset(openwater_list2[[i]], select = "geometry")
    
  }
  
}
openwater_list1 <- openwater_list1[!sapply(openwater_list1,is.null)]

openwater1 <- do.call(rbind, openwater_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")


openwater_list2 <- openwater_list2[!sapply(openwater_list2,is.null)]

if(installr::is.empty(openwater_list2) == FALSE){
  openwater2 <- do.call(rbind, openwater_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("POLYGON")
  
  openwater_natural <- rbind(openwater1, openwater2)} else{
    openwater_natural <- openwater1
  }

#--------------------------------------------------------------------------------------
openwater <- rbind(openwater_natural, openwater_landuse)
st_write(openwater, here("data/output/landuse_shape/openwater.shp"), append = T)


