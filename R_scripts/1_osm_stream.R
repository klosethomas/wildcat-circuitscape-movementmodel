# stream -----------------------------
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

grid <- st_make_grid(study,  n= 3)
st_write(grid, here("data/shapes/grid.shp"),
         delete_dsn = TRUE)

grid   <-read_sf(here("data/shapes/grid.shp"))
grid$POLY_ID <- seq.int(nrow(grid)) 
grid <-  st_transform(grid, "+proj=longlat +ellps=WGS84 +datum=WGS84")

#---------------------------------------------------------------------

stream_list1 <- vector('list', length(9))
stream_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature(bbx, key = "waterway") %>%
    osmdata_sf
  

  m1 <- m1z$osm_lines
  
  if(is.null(m1z$osm_lines) == FALSE){
  stream_list1[[i]] <- assign(paste0("streama", i), m1)
    stream_list1[[i]] <- subset(stream_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multilines) == FALSE){
    m1a <- m1z$osm_multilines 
    stream_list2[[i]] <- assign(paste0("streamb", i), m1a)
    
    stream_list2[[i]] <- subset(stream_list2[[i]], select = "geometry")
    
  }
  
}
stream_list1 <- stream_list1[!sapply(stream_list1,is.null)]
stream1 <- do.call(rbind, stream_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

stream_list2 <- stream_list2[!sapply(stream_list2,is.null)]

if(installr::is.empty(stream_list2) == FALSE){
  stream2 <- do.call(rbind, stream_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("LINESTRING")
  
  stream <- rbind(stream1, stream2)} else{
    stream <- stream1
  }

#stream <- st_intersects(study, stream)
st_write(stream, here("data/output/landuse_shape/stream.shp"), append = T)




#-----------------------------------------------------------------------


river_list1 <- vector('list', length(9))
river_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature(bbx, key = "waterway", value = c("canal","river"),) %>%
    osmdata_sf
  
  
  m1 <- m1z$osm_lines
  
  if(is.null(m1z$osm_lines) == FALSE){
    river_list1[[i]] <- assign(paste0("rivera", i), m1)
    river_list1[[i]] <- subset(river_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multilines) == FALSE){
    m1a <- m1z$osm_multilines 
    river_list2[[i]] <- assign(paste0("riverb", i), m1a)
    
    river_list2[[i]] <- subset(river_list2[[i]], select = "geometry")
    
  }
  
}
river_list1 <- river_list1[!sapply(river_list1,is.null)]
river1 <- do.call(rbind, river_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

river_list2 <- river_list2[!sapply(river_list2,is.null)]

if(installr::is.empty(river_list2) == FALSE){
  river2 <- do.call(rbind, river_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("LINESTRING")
  
  river <- rbind(river1, river2)} else{
    river <- river1
  }

#river <- st_intersects(study, river)
st_write(river, here("data/output/landuse_shape/river_canal.shp"), append = T)






















# study   <-read_sf( here("data/shapes/studyarea_rect_big.shp"))
# study <- st_transform(study, "+proj=longlat +ellps=WGS84 +datum=WGS84")
# bb <- opq(st_bbox(study), timeout = 3600,  nodes_only = FALSE)
# 
# # bigger streams and canals for mapping ------------
# ## ---- load_osm ------  
# river <- add_osm_feature(bb, key = "waterway", value = c("canal","river"),) %>%
#   osmdata_sf
# ## ---- only_ploygons -------
# river1 <- river$osm_multilines %>% st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>% st_cast("LINESTRING")
# river2 <- river$osm_lines %>% st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")
# ## ---- write shapes --------
# st_write(river1, here("data/output/landuse_shape/workmemory/river1.shp"), append = F)
# st_write(river2, here("data/output/landuse_shape/workmemory/river2.shp"), append = F)
# 
# river1 <- read_sf(here("data/output/landuse_shape/workmemory/river1.shp")) 
# river2 <- read_sf(here("data/output/landuse_shape/workmemory/river2.shp"))
# ## ---- final landuse file ------
# river <- rbind(river1,river2)
# st_write(river, here("data/output/landuse_shape/river_canal.shp"),append = FALSE)







