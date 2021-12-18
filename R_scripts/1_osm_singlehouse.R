# singlehouse -----------------------------
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
study   <-read_sf( here("data/shapes/studyarea.shp"))

grid <- st_make_grid(study,  n= 4)
st_write(grid, here("data/shapes/grid.shp"),
         delete_dsn = TRUE)

grid   <-read_sf(here("data/shapes/grid.shp"))
grid$POLY_ID <- seq.int(nrow(grid)) 
grid <-  st_transform(grid, "+proj=longlat +ellps=WGS84 +datum=WGS84")

#---------------------------------------------------------------------

singlehouse_list1 <- vector('list', length(16))
singlehouse_list2 <- vector('list', length(16))
for ( i in 2:16){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- osmdata::add_osm_feature(bbx, key = "building")%>%
    osmdata::osmdata_sf()
  
  
  # only_ploygons
  m1 <- m1z$osm_polygons 
  
  
  if(is.null(m1z$osm_polygons) == FALSE){
  singlehouse_list1[[i]] <- assign(paste0("singlehousea", i), m1)
  
    singlehouse_list1[[i]] <- subset(singlehouse_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multipolygons) == FALSE){
    m1a <- m1z$osm_multipolygons 
    singlehouse_list2[[i]] <- assign(paste0("singlehouseb", i), m1a)
    
    singlehouse_list2[[i]] <- subset(singlehouse_list2[[i]], select = "geometry")
    
  }
  
}
singlehouse_list1 <- singlehouse_list1[!sapply(singlehouse_list1,is.null)]
singlehouse1 <- do.call(rbind, singlehouse_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

singlehouse_list2 <- singlehouse_list2[!sapply(singlehouse_list2,is.null)]

if(installr::is.empty(singlehouse_list2) == FALSE){
  singlehouse2 <- do.call(rbind, singlehouse_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("POLYGON")
  
  singlehouse <- rbind(singlehouse1, singlehouse2)} else{
    singlehouse <- singlehouse1
  }


st_write(singlehouse, here("data/output/landuse_shape/singlehouse.shp"), delete_dsn = TRUE)




# in case the download is not working and you got the data by downloading the singlehouses 
# other sources you can load them here, so they are in the same format like the other landuse files.
# singlehouse -----------------------------

singlehouse <- read_sf(here("data/output/landuse_shape/singlehouse.shp"))%>% 
  subset(select= "geometry") %>% 
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>% 
  st_cast("POLYGON")
st_write(singlehouse, here("data/output/landuse_shape/singlehouse.shp"), delete_dsn = TRUE)










