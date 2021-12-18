# 3_rasterize_data.R
## ---- raster-a  --------
# This script will create a rasterdummy with the wished resolution
# of 25 m and the extent of the studyarea.
# The landuse shapes will be rasterized. Features with a 1 and
# blank space ith a 0.
# In some landuse files higher values are written, these are
# later used as barrier values.

# Load the required packages
library("here") # used for relative paths
library("sf") # used to handle spatial data
library("raster") # used to handle raster data
library("qgisprocess") # remotes::install_github("paleolimbot/qgisprocess")

## ---- qgisprocess --------
# add your path to the install directorie of QGIS process file
options(qgisprocess.path = "C:/Program Files/QGIS 3.16/bin/qgis_process-qgis-ltr.bat")
qgis_configure()

# load land use cut data
studyarea <- read_sf(here("data/shapes/studyarea.shp")) 


## ---- dummy --------
# * Create Rasterdummy --------------------------------------------------------------------
studyarea_extent <- extent(studyarea)
rasterdummy <- raster(ext = studyarea_extent, res = 25) # create the rasterdummy with studyarea extent and resolution= 25
# last x,y cells are cut (note buffer and edge effects)
projection(rasterdummy) <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs " # define projection and unite = meter
writeRaster(rasterdummy, here("data/output/landuse_raster/rasterdummy.tif"), overwrite = T) # write rasterdummy in output folder


## ---- meadow  --------
# 1 rasterize meadow  ----

meadow_r <- qgisprocess::qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/meadow.shp"),
  BURN = 1,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/meadow_r.tif")
)
meadow_r <- raster(here("data/output/landuse_raster/meadow_r.tif")) %>%
  mask(studyarea)
writeRaster(meadow_r, here("data/output/landuse_raster/meadow_r.tif"), overwrite =TRUE)

## ---- wood  --------
# 2 rasterize wood ----
wood_r <- qgisprocess::qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/wood.shp"),
  BURN = 1,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/wood_r.tif")
)
wood_r <- raster(here("data/output/landuse_raster/wood_r.tif")) %>%
  mask(studyarea)
writeRaster(wood_r, here("data/output/landuse_raster/wood_r.tif"), overwrite =TRUE)
## ---- street  --------
# 3 rasterize  street ----
street_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/street.shp"),
  BURN = 1,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/street_r.tif")
)
street_r <- raster(here("data/output/landuse_raster/street_r.tif")) %>%
  mask(studyarea)
writeRaster(street_r, here("data/output/landuse_raster/street_r.tif"), overwrite =TRUE)
## ---- village  --------
# 4 rasterize  village ----
village_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/village_shp.shp"),
  BURN = 1,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/village_r.tif")
)
village_r <- raster(here("data/output/landuse_raster/village_r.tif")) %>%
  mask(studyarea)
writeRaster(village_r, here("data/output/landuse_raster/village_r.tif"), overwrite =TRUE)
## ---- singlehouse  --------
# 5 rasterize  singlehouse -----

singlehouse_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/singlehouse_proj.shp"),
  BURN = 1,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/singlehouse_r.tif")
)
singlehouse_r <- raster(here("data/output/landuse_raster/singlehouse_r.tif")) %>%
  mask(studyarea)
writeRaster(singlehouse_r, here("data/output/landuse_raster/singlehouse_r.tif"), overwrite =TRUE)
## ---- stream  --------
# 6 rasterize stream ----
stream_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/stream.shp"),
  BURN = 1,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/stream_r.tif")
)
stream_r <- raster(here("data/output/landuse_raster/stream_r.tif")) %>%
  mask(studyarea)
writeRaster(stream_r, here("data/output/landuse_raster/stream_r.tif"), overwrite =TRUE)
## ---- junction  --------
# 7 rasterize  junction ----
junction_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/junction.shp"),
  BURN = 1000,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/junction_r.tif")
)
junction_r <- raster(here("data/output/landuse_raster/junction_r.tif")) %>%
  mask(studyarea)
writeRaster(junction_r, here("data/output/landuse_raster/junction_r.tif"), overwrite =TRUE)
## ---- openwater  --------
# 8 rasterize  openwater ----
openwater_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/openwater.shp"),
  BURN = 1000,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/openwater_r.tif")
)
openwater_r <- raster(here("data/output/landuse_raster/openwater_r.tif")) %>%
  mask(studyarea)
writeRaster(openwater_r, here("data/output/landuse_raster/openwater_r.tif"), overwrite =TRUE)
## ---- motorway  --------
# 9 ratserize motorway ----
motorway_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/motorway_buf.shp"),
  BURN = 200,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/motorway_r.tif")
)
motorway_r <- raster(here("data/output/landuse_raster/motorway_r.tif")) %>%
  mask(studyarea)
writeRaster(motorway_r, here("data/output/landuse_raster/motorway_r.tif"), overwrite =TRUE)
## ---- wildlife_crossing  --------
# 9 ratserize wildlife_crossing ----
crossing_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/crossing.shp"),
  BURN = -200,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/crossing_r.tif")
)
crossing_r <- raster(here("data/output/landuse_raster/crossing_r.tif"))
motorway_r <- raster(here("data/output/landuse_raster/motorway_r.tif"))

crossing_r <- mask(crossing_r, motorway_r,  maskvalue = 0, updatevalue = 0)
crossing_r <- mask(crossing_r, studyarea)
writeRaster(crossing_r, here("data/output/landuse_raster/crossing_r.tif"), overwrite =TRUE)

## ---- wildlife_crossing  --------
# 9 ratserize wildlife_crossing ----
underpass_r <- qgis_run_algorithm(
  "gdal:rasterize",
  INPUT = here("data/output/landuse_shape/underpass.shp"),
  BURN = -200,
  DATA_TYPE = 5,
  WIDTH = 25,
  HEIGHT = 25,
  EXTENT = here("data/output/landuse_raster/rasterdummy.tif"),
  UNITS = 1,
  OUTPUT = here("data/output/landuse_raster/underpass_r.tif")
)
underpass_r <- raster(here("data/output/landuse_raster/underpass_r.tif"))
motorway_r <- raster(here("data/output/landuse_raster/motorway_r.tif"))

underpass_r <- mask(underpass_r, motorway_r,  maskvalue = 0, updatevalue = 0)
underpass_r <- mask(underpass_r, studyarea)
writeRaster(underpass_r, here("data/output/landuse_raster/underpass_r.tif"), overwrite =TRUE)

## ---- raster-b   --------