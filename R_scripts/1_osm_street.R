# street -----------------------------
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
study <- st_transform(study, "+proj=longlat +ellps=WGS84 +datum=WGS84")
#---------------------------------------------------------------------

street_list1 <- vector('list', length(9))
street_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature (bbx, key = "highway", value = c ("motorway", "motorway_link","trunk","trunk_link","primary","primary_link","secondary","secondary_link","tertiary","tertiary_link","residential","unclassified","living_street","service","road")) %>% osmdata_sf()
  
  
  m1 <- m1z$osm_lines
  
  if(is.null(m1z$osm_lines) == FALSE){
    street_list1[[i]] <- assign(paste0("streeta", i), m1)
    street_list1[[i]] <- subset(street_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multilines) == FALSE){
    m1a <- m1z$osm_multilines 
    street_list2[[i]] <- assign(paste0("streetb", i), m1a)
    
    street_list2[[i]] <- subset(street_list2[[i]], select = "geometry")
    
  }
  
}
street_list1 <- street_list1[!sapply(street_list1,is.null)]
street1 <- do.call(rbind, street_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

street_list2 <- street_list2[!sapply(street_list2,is.null)]

if(installr::is.empty(street_list2) == FALSE){
  street2 <- do.call(rbind, street_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("LINESTRING")
  
  street <- rbind(street1, street2)} else{
    street <- street1
  }

street <- st_intersects(study, street)
st_write(street, here("data/output/landuse_shape/street.shp"), append = T)




#-----------------------------------------------------------------------
bb <- opq(st_bbox(study), timeout = 3600,  nodes_only = FALSE)
# junction -----------------------------
## ---- load_osm ------  
jz <- add_osm_feature (bb, key = "highway", value = c ("motorway_link", "trunk_link","primary_link")) %>% 
  osmdata_sf() %>% 
  osm_poly2line()
## ---- only_lines -------
j1 <- jz$osm_lines %>% subset(select= "geometry") %>% st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>% st_cast("LINESTRING")
j1 <- st_transform(j1, crs = 32632)
j1         <- st_buffer(j1, 20) # buffer with 20 m
## ---- final landuse file ------
st_write(j1, here("data/output/landuse_shape/junction.shp"), append = T)
#----------------------------------------------------------------------

study   <-read_sf( here("data/shapes/studyarea_rect_big.shp"))
study <- st_transform(study, "+proj=longlat +ellps=WGS84 +datum=WGS84")
bb <- opq(st_bbox(study), timeout = 3600,  nodes_only = FALSE)



# federal road

fr <-  add_osm_feature (bb, key = "highway", value = c ("trunk","trunk_link","primary","primary_link")) %>% osmdata_sf() 
fr2 <- fr$osm_lines %>% subset(select= "geometry") %>% st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")
st_write(fr2, here("data/output/landuse_shape/federalroad.shp"), append = T)

#---------------------------------------------------------------------

# motorz <- add_osm_feature (bb, key = "highway", value = c ("motorway")) %>% 
#   osmdata_sf() %>% 
#   osm_poly2line()
# ## ---- only_lines -------
# motor1 <- motorz$osm_lines %>% subset(select= "osm_id") %>% st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>% st_cast("LINESTRING")
# motor1 <- st_transform(motor1, crs = 32632)
# 
# ## ---- final landuse file ------
# st_write(motor1, here("data/output/landuse_shape/motorway_map.shp"), append = T)
# 
# motor1 <- st_intersects(motor1, study)
# motor_buf         <- st_buffer(motor1, 20) # buffer with 20 m
# st_write(motor_buf, here("data/output/landuse_shape/motorway_buf.shp"), append = T)

grid <- st_make_grid(study,  n= 3)
st_write(grid, here("data/shapes/grid.shp"),
         delete_dsn = TRUE)

grid   <-read_sf(here("data/shapes/grid.shp"))
grid$POLY_ID <- seq.int(nrow(grid)) 
grid <-  st_transform(grid, "+proj=longlat +ellps=WGS84 +datum=WGS84")

motor_list1 <- vector('list', length(9))
motor_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature (bb, key = "highway", value = c ("motorway")) %>% 
    osmdata_sf() %>% 
    osm_poly2line()
  
  
  m1 <- m1z$osm_lines
  
  if(is.null(m1z$osm_lines) == FALSE){
    motor_list1[[i]] <- assign(paste0("motora", i), m1)
    motor_list1[[i]] <- subset(motor_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multilines) == FALSE){
    m1a <- m1z$osm_multilines 
    motor_list2[[i]] <- assign(paste0("motorb", i), m1a)
    
    motor_list2[[i]] <- subset(motor_list2[[i]], select = "geometry")
    
  }
  
}
motor_list1 <- motor_list1[!sapply(motor_list1,is.null)]
motor1 <- do.call(rbind, motor_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

motor_list2 <- motor_list2[!sapply(motor_list2,is.null)]

if(installr::is.empty(motor_list2) == FALSE){
  motor2 <- do.call(rbind, motor_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("LINESTRING")
  
  motor <- rbind(motor1, motor2)} else{
    motor <- motor1
  }

motor1 <- st_transform(motor1, crs = 32632)

## ---- final landuse file ------
st_write(motor1, here("data/output/landuse_shape/motorway_map.shp"), append = T)

#motor1 <- st_intersects(motor1, study)
motor_buf         <- st_buffer(motor1, 20) # buffer with 20 m
st_write(motor_buf, here("data/output/landuse_shape/motorway_buf.shp"), append = T)

st_write(motor, here("data/output/landuse_shape/motorway.shp"), append = T)



