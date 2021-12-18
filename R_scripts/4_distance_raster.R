# 4_distance_raster
## ---- distance-a ---------
# This script will calculate the distance raster. Each raster cell will get 
# the distance to the next specific feature in meters.
# The needed raster layers are loaded singular in each step to save memory.
# within forest= Distance equals 0
# Load the required packages
library("here")                 # used for relative paths
library("sf")                   # used to handle spatial data
library("raster")               # used to handle raster data
library("qgisprocess")

## ---- qgisprocess --------
options(qgisprocess.path = 'C:/Program Files/QGIS 3.16/bin/qgis_process-qgis-ltr.bat')
qgis_configure()

# CREATE DISTANCE RASTER ------------------------------------------------------
## ---- distance-b ---------
# 1 distance meadow ----
   meadow_dist <- qgisprocess::qgis_run_algorithm(
      "gdal:proximity",
      INPUT = here::here("data/output/landuse_raster/meadow_r.tif"),
      BAND = 1,
      DATA_TYPE = 5,
      VALUES = 1,
      UNITS = 0,
      MAX_DISTANCE = 0,
      NODATA = 0,
      REPLACE = 0,
      OUTPUT = here::here("data/output/distance_raster/meadow_dist.tif")
   ) 
meadow_dist <- raster(here("data/output/distance_raster/meadow_dist.tif")) %>%
   mask(studyarea)
writeRaster(meadow_dist, here("data/output/distance_raster/meadow_dist.tif"), overwrite =TRUE)
## ---- distance-c ---------
# 2 distance village ----
   village_dist_max900 <- qgisprocess::qgis_run_algorithm(
      "gdal:proximity",
      INPUT = here::here("data/output/landuse_raster/village_r.tif"),
      BAND = 1,
      DATA_TYPE = 5,
      VALUES = 1,
      UNITS = 0,
      MAX_DISTANCE = 900,
      NODATA = 900,
      REPLACE = 0,
      OUTPUT = here("data/output/distance_raster/village_dist_max900.tif")
   ) 
village_dist_max900 <- raster(here("data/output/distance_raster/village_dist_max900.tif")) %>%
   mask(studyarea)
writeRaster(village_dist_max900, here("data/output/distance_raster/village_dist_max900.tif"), overwrite =TRUE) 
## ---- distance-d ---------
# 3 distance singlehouse ----
   singlehouse_dist_max200 <- qgis_run_algorithm(
      "gdal:proximity",
      INPUT = here::here("data/output/landuse_raster/singlehouse_r.tif"),
      BAND = 1,
      DATA_TYPE = 5,
      VALUES = 1,
      UNITS = 0,
      MAX_DISTANCE = 200,
      NODATA = 200,
      REPLACE = 0,
      OUTPUT = here::here("data/output/distance_raster/singlehouse_dist_max200.tif")
   ) 
singlehouse_dist_max200 <- raster(here("data/output/distance_raster/singlehouse_dist_max200.tif")) %>%
   mask(studyarea)
writeRaster(singlehouse_dist_max200, here("data/output/distance_raster/singlehouse_dist_max200.tif"), overwrite =TRUE) 

## ---- distance-e ---------
# 4 distance wood ----
   wood_dist <- qgis_run_algorithm(
      "gdal:proximity",
      INPUT = here("data/output/landuse_raster/wood_r.tif"),
      BAND = 1,
      DATA_TYPE = 5,
      VALUES = 1,
      UNITS = 0,
      MAX_DISTANCE = 0,
      NODATA = 0,
      REPLACE = 0,
      OUTPUT = here::here("data/output/distance_raster/wood_dist.tif")
   ) 
wood_dist <- raster(here("data/output/distance_raster/wood_dist.tif")) %>%
   mask(studyarea)
writeRaster(wood_dist, here("data/output/distance_raster/wood_dist.tif"), overwrite =TRUE)  
## ---- distance-f ---------
# 5 distance  street ----
   street_dist_max200 <- qgis_run_algorithm(
      "gdal:proximity",
      INPUT = here::here("data/output/landuse_raster/street_r.tif"),
      BAND = 1,
      DATA_TYPE = 5,
      VALUES = 1,
      UNITS = 0,
      MAX_DISTANCE = 200,
      NODATA = 200,
      REPLACE = 0,
      OUTPUT = here::here("data/output/distance_raster/street_dist_max200.tif")
   ) 
street_dist_max200 <- raster(here("data/output/distance_raster/street_dist_max200.tif")) %>%
   mask(studyarea)
writeRaster(street_dist_max200, here("data/output/distance_raster/street_dist_max200.tif"), overwrite =TRUE)  
## ---- distance-g ---------
# 6 distance stream ----
   stream_dist <- qgis_run_algorithm(
      "gdal:proximity",
      INPUT = here::here("data/output/landuse_raster/stream_r.tif"),
      BAND = 1,
      DATA_TYPE = 5,
      VALUES = 1,
      UNITS = 0,
      MAX_DISTANCE = 0,
      NODATA = 0,
      REPLACE = 0,
      OUTPUT = here::here("data/output/distance_raster/stream_dist.tif")
   )
stream_dist <- raster(here("data/output/distance_raster/stream_dist.tif")) %>%
   mask(studyarea)
writeRaster(stream_dist, here("data/output/distance_raster/stream_dist.tif"), overwrite =TRUE)
## ---- distance-h ---------

