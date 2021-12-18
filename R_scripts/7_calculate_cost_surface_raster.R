# 7_calculate_cost_surface_raster.R

# This Script will generate raster files with a cost value in each cell. The costs are
# based on the habitatprobability raster and some landuse raster with barriers. The
# barriers like streets and villages have defined values, reported in the method of
# Klar et al., 2009. There are 3 mathematics described in the methods to calculate the costs.


# Load the required packages
library("here") # used for relative paths
library("raster") # used to handle raster data

# Source functions
openwater_r <- raster(here("data/output/landuse_raster/openwater_r.tif"))
village_r <- raster(here("data/output/landuse_raster/village_r.tif"))
junction_r <- raster(here("data/output/landuse_raster/junction_r.tif"))
motorway_r <- raster(here("data/output/landuse_raster/motorway_r.tif"))
crossing_r <- raster(here("data/output/landuse_raster/crossing_r.tif"))
underpass_r <- raster(here("data/output/landuse_raster/underpass_r.tif"))
habitat_prob <- raster(here("data/output/habitat_prob_raster/habitat_prob.grd"))
homerange_wood_cast <-
  sf::read_sf(here("data/output/homerange_shape/homerange.shp"))

## ----- barrier -------
# * Define barriers ------------------------------------------------------
# rename the objects to be clear with their value
junction_v1000 <-
  junction_r # junction == 1000
openwater_v1000 <-
  openwater_r # openwater == 1000
motorway_v200 <-
  motorway_r # motorway == 200
# crossing_r                                              # crossing == -200
# underpass_r                                             # underpass == -200
## ----- cost -------
# intersect the motorways by the crossings
motorway_v200 <- motorway_v200 + crossing_r + underpass_r
motorway_v200 <- reclassify(motorway_v200, cbind(-Inf, 0, 0), right = TRUE)
# reclassify village raster with barrier value
# 1000 instead of 1 as value
village_v1000 <-
  reclassify(village_r, cbind(0.9, Inf, 1000), right = TRUE)
village_v1000[is.na(village_v1000)] <-
  0
## ----- barrier-2 -------


## ----- cost1 -------
# calculate costraster
costs1 <- (0.76 - habitat_prob) * 100
# add barrier values
costs1 <-
  costs1 - junction_v1000 - motorway_v200 - openwater_v1000 - village_v1000
costs1 <- reclassify(costs1, cbind(-Inf, 0, 0), right = TRUE)
costs1 <-
  costs1 + junction_v1000 + motorway_v200 + openwater_v1000 + village_v1000
costs1 <- reclassify(costs1, cbind(1001, Inf, 1000), right = TRUE)

# rescale to 1-100
costs1_rescaled <- ((costs1 - minValue(costs1)) * (100 - 1) / (maxValue(costs1) - minValue(costs1))) + 1
## ----- cost1a -------
projection(costs1_rescaled) <- crs(homerange_wood_cast)
#cat_raster_wgs84 = projectRaster(costs1_rescaled, crs = "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs", method = "ngb")

writeRaster(costs1,
  here("data/output/cost_surface_raster/costs1.asc"),
  overwrite = TRUE
)
writeRaster(costs1_rescaled,
            here("data/output/cost_surface_raster/costs1_rescaled.tiff"),
            overwrite = TRUE
)
writeRaster(costs1_rescaled,
            here("data/output/cost_surface_raster/costs1_rescaled.asc"),
            overwrite = TRUE
)






save(costs1, costs1_rescaled,
  file = here("data/output/cost_surface_raster/costs1.rds")
)

