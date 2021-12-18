# Village -----------------------------


# Load the required packages
library("here")                 # used for relative paths
library("sf") 
library("osmdata")
library("raster")
library("sp") 
library("dplyr")
library("qgisprocess") # remotes::install_github("paleolimbot/qgisprocess")

## ---- qgisprocess --------
options(qgisprocess.path = "C:/Programme/QGIS 3.16/bin/qgis_process-qgis-ltr.bat")
qgis_configure()

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







village_list1 <- vector('list', length(9))
village_list2 <- vector('list', length(9))
for ( i in 1:9){
  bbx <- opq(st_bbox(grid[grid$POLY_ID==i,]), timeout = 3600,  nodes_only = FALSE)
  
  m1z <- add_osm_feature(bbx,
                         key = "landuse",
                         value = c("residential", "industrial","retail","commercial","allotments","port","cemetery","construction")
  ) %>%
    osmdata_sf()
  
  # only_ploygons
  m1 <- m1z$osm_polygons 
  
  if(is.null(m1z$osm_polygons) == FALSE){
    village_list1[[i]] <- assign(paste0("villagea", i), m1)
    village_list1[[i]] <- subset(village_list1[[i]], select = "geometry")
  } 
  
  if(is.null(m1z$osm_multipolygons) == FALSE){
    m1a <- m1z$osm_multipolygons 
    village_list2[[i]] <- assign(paste0("villageb", i), m1a)
    
    village_list2[[i]] <- subset(village_list2[[i]], select = "geometry")
    
  }
  
}
village_list1 <- village_list1[!sapply(village_list1,is.null)]
village1 <- do.call(rbind, village_list1)%>%
  st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")

village_list2 <- village_list2[!sapply(village_list2,is.null)]

if(installr::is.empty(village_list2) == FALSE){
  village2 <- do.call(rbind, village_list2)%>%
    st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
    st_cast("POLYGON")
  
  village <- rbind(village1, village2)} else{
    village <- village1
  }


village <- st_transform(village, crs = 32632)



# buffer village shapes  ----
village_qgis <- qgisprocess::qgis_run_algorithm(
  "native:buffer",
  INPUT = village,
  DISTANCE = 16,
  DISSOLVE = 1
)
village_qgis <- sf::read_sf(qgis_output(village_qgis, "OUTPUT"))

# multipart to singlepart shapes  ----
village_qgis <- qgisprocess::qgis_run_algorithm(
  "native:multiparttosingleparts",
  INPUT = village_qgis,

)
village_qgis <- sf::read_sf(qgis_output(village_qgis, "OUTPUT"))

# create area
village_qgis$size <- as.numeric(st_area(village_qgis) / 10000)
st_write(village_qgis,
         here("data/output/landuse_shape/village_all.shp"),
         delete_dsn = TRUE)

# filter by size
village_filter <- village_qgis[village_qgis$size >= 10, ]
st_write(village_filter,
         here("data/output/landuse_shape/village_shp.shp"),
         delete_dsn = TRUE)    

















# # fix geometries
# village_qgis <- qgisprocess::qgis_run_algorithm(
#   "grass7:v.clean",
#   input = village_qgis,
#   threshold = 0.01
# )
# village_qgis <- sf::read_sf(qgis_output(village_qgis, "output"))
# 
# # dissolve
# village_qgis <- qgisprocess::qgis_run_algorithm(
#   "native:dissolve",
#   INPUT = village_qgis,
#   
# )
# village_qgis <- sf::read_sf(qgis_output(village_qgis, "OUTPUT"))



# v1 <- v1z$osm_polygons %>%
#   subset(select = "geometry") %>%
#   st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ")
# v2 <- v1z$osm_multipolygons %>%
#   subset(select = "geometry") %>%
#   st_transform("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs ") %>%
#   st_cast("POLYGON")
# # merge the two datasets
# st_write(v1,
#   here("data/output/landuse_shape/workmemory/v1.shp"),
#   append = FALSE
# )
# st_write(v2,
#   here("data/output/landuse_shape/workmemory/v2.shp"),
#   append = FALSE
# )
# village <- rbind(v1, v2)
# # delete villages <= 10 ha
# village <- st_transform(village, crs = 32632)
# village$size <- as.numeric(st_area(village) / 10000)
# village <- village[village$size >= 10, ]
# st_write(village,
#          here("data/output/landuse_shape/village_map.shp"), delete_dsn = TRUE)    
# 
# study   <-read_sf( here("data/shapes/studyarea.shp"))
# village <- st_intersects(study, meadow_map)
# st_write(village, here("data/output/landuse_shape/village.shp"), append = T)