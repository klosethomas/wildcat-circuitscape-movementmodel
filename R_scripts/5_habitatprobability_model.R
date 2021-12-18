# 5_habitatprobability_model

# This script will use the formula in Klar et al., 2009 
# to calculate a raster 
# map with the probability a wildcat
# chooses a raster cell as a habitat. The distance raster 
# files are especially needed in this step.
# This script will also sort the raster cells by their 
# value as needed in the method. Cells with habitat probability
# higher than 45 % and higher than 65 %. Areas with this 
# criteria are filtered and saved as raster and shape files.


  # Load the required packages
  library("here")                 # used for relative paths
  library("sf")                   # used to handle spatial data
  library("raster")               # used to handle raster data
  

## ----- habitatmodell --------
# load studyarea shape file
studyarea <-
  read_sf(here("data/shapes/studyarea.shp")) # used as mask

# load distance raster files

meadow_dist <-
  raster(here("data/output/distance_raster/meadow_dist.tif"))
village_dist <-
  raster(here("data/output/distance_raster/village_dist_max900.tif"))
singlehouse_dist <-
  raster(here("data/output/distance_raster/singlehouse_dist_max200.tif"))
wood_dist <-
  raster(here("data/output/distance_raster/wood_dist.tif"))
street_dist <-
  raster(here("data/output/distance_raster/street_dist_max200.tif"))
stream_dist <-
  raster(here("data/output/distance_raster/stream_dist.tif"))
## ----- formula --------
# CREATE Habitat probability by formula --------------------------
log_p <- 1.14 -
  0.013 * wood_dist -
  0.001 * meadow_dist -
  0.001 * stream_dist +
  0.002 * (village_dist - 900) +
  0.002 * (street_dist - 200) +
  0.004 * (singlehouse_dist - 200) 
# formula described in Klar et al. 2009

habitat_prob <-
  (exp(log_p) / (1 + exp(log_p)))
writeRaster(
  habitat_prob,
  here("data/output/habitat_prob_raster/habitat_prob.grd"),
  overwrite = T
)
## ----- formula-2 --------
rm(
  wood_dist,
  meadow_dist,
  stream_dist,
  village_dist,
  street_dist,
  singlehouse_dist,
  studyarea
) # clear environment to save memory

habitat_prob <-
  raster(here("data/output/habitat_prob_raster/habitat_prob.grd"))
## ----- 65 --------
# * filter by Size ---------------------------------------------------
# * * greater than .65 --------------------------------------------
reclass_65 <-
  c(
    0, 0.6499999999999999999, NA, # create classification matrix
    0.65, Inf, 1
  )
# reshape the vector into a matrix with columns and rows
reclass_65m <-
  matrix(reclass_65, 
    ncol = 3,
    byrow = TRUE
  )
# reclassify the raster using the reclass matrix - reclass_m
habitat_prob_65 <-
  reclassify(
    habitat_prob, 
    reclass_65m
  )

writeRaster(
  habitat_prob_65,
  here("data/output/habitat_prob_raster/habitat_prob_65.grd"),
  overwrite = T
)

patches_prob_65 <-
  raster::clump(habitat_prob_65) 
# clumb all individual touching pixel to one object
# Detect clumps (patches) of connected cells. Each clump
# gets a unique ID. NA and zero are used as background values
# (i.e. these values are used to separate clumps).
writeRaster(
  patches_prob_65,
  here("data/output/habitat_prob_raster/patches_prob_65.grd"),
  overwrite = T
)

## ----- 45 --------
# * * * greater than .45 ---------------------------------------------
# create classification matrix
reclass_45 <-
  c(
    0, 0.4499999999999999999, NA, 
    0.45, Inf, 1
  )
# reshape the vector into a matrix with columns and rows
reclass_45m <-
  matrix(reclass_45, 
    ncol = 3,
    byrow = TRUE
  )
# reclassify the raster using the reclass matrix - reclass_m
habitat_prob_45 <-
  reclassify(
    habitat_prob, 
    reclass_45m
  )

writeRaster(
  habitat_prob_45,
  here("data/output/habitat_prob_raster/habitat_prob_45.grd"),
  overwrite = T
)

patches_prob_45 <-
  clump(habitat_prob_45) 

writeRaster(
  patches_prob_45,
  here("data/output/habitat_prob_raster/patches_prob_45.grd"),
  overwrite = T
)













