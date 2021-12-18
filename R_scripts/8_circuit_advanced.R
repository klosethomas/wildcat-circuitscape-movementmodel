# circuit_adv.R

# 8_prepare_circuitscape must run before!

# runs circuit in advanced mode. variable source strengths.
# grounds as a portion of the ground patch size to alle grounds.


# Check if Julia, R and RStudio are all set to 64 bit / 32 bit
# Load the required packages

library("here")                 # used for relative paths
library("raster")               # used to handle raster data
library("JuliaCall")
library("sf")
library("mapview")
library("dplyr")

# # Define the Options in Circuitscape with .ini file ------------------------------------------
cs_settings <- c(
  "[Options for advanced mode]",
  "ground_file_is_resistances = False",
  "remove_src_or_gnd = keepall",
  paste(c("ground_file ="),
        paste(
          here("data/output/circuitscape/advanced/1/input/ground_raster.asc"),
          sep = "/"
        )),
  "use_unit_currents = False",
  paste(c("source_file ="),
        paste(
          here("data/output/circuitscape/advanced/1/input/source_raster.asc"),
          sep = "/"
        )),
  "use_direct_grounds = False",
  
  "[Mask file]",
  "use_mask = True",
  paste(c("mask_file ="),
        paste(
          here("data/output/cost_surface_raster/linkagemapper_corridors_truncated_at_10k.asc"),
          sep = "/"
        )),
  
  "[Calculation options]",
  "low_memory_mode = False",
  "parallelize = False",
  "solver = cholmod",
  "print_timings = True",
  "preemptive_memory_release = False",
  "print_rusages = False",
  "max_parallel = 3",
  
  "[Short circuit regions (aka polygons)]",
  "use_polygons = True",
  paste(c("polygon_file ="),
        paste(
          here("data/output/homerange_raster/homerange_redefined.asc"),
          sep = "/"
        )),
  
  
  "[Options for one-to-all and all-to-one modes]",
  "use_variable_source_strengths = False",
  "variable_source_file = None",
  
  "[Output options]",
  "set_null_currents_to_nodata = True",
  "set_focal_node_currents_to_zero = False",
  "set_null_voltages_to_nodata = False",
  "compress_grids = False",
  "write_cur_maps = True",
  "write_volt_maps = True",
  paste(c("output_file ="),
        paste(
          here("data/output/circuitscape/advanced/1/circuitscape_adv.out"),
          sep = "/"
        )),
  
  "write_cum_cur_map_only = False",
  "log_transform_maps = True",
  "write_max_cur_maps = False",
  
  
  
  "[Options for reclassification of habitat data]",
  "reclass_file = (Browse for file with reclassification data)",
  "use_reclass_table = False",
  
  "[Logging Options]",
  "log_level = INFO",
  paste(c("log_file ="),
        paste(
          here("data/output/circuitscape/advanced/1/log_adv.log"),
          sep = "/"
        )),
  "profiler_log_file = None",
  "screenprint_log = False",
  
  "[Options for pairwise and one-to-all and all-to-one modes]",
  "included_pairs_file = None",
  "use_included_pairs = False",
  paste(c("point_file ="),
        paste(
          here("data/output/circuitscape/sites_raster.asc"),
          sep = "/"
        )),
  
  
  "[Connection scheme for raster habitat data]",
  "connect_using_avg_resistances = True",
  "connect_four_neighbors_only = True",
  
  "[Habitat raster or graph]",
  "habitat_map_is_resistances = True",
  paste(c("habitat_file ="),
        paste(
          here("data/output/cost_surface_raster/costs1_rescaled.asc"),
          sep = "/"
        )),
  
  
  
  "[Circuitscape mode]",
  "data_type = raster",
  "scenario = advanced"
)

# Write the .ini file
writeLines(cs_settings,
           here("data/output/circuitscape/cs_settings_adv.ini"))


# DATA IMPORT ------------------------------------------------------------------------------
# Cost surface raster
costs1_rescaled <- raster(here("data/output/cost_surface_raster/costs1_rescaled.asc"))

# DATA PREPERATION -------------------------------------------------------------------------
## ----- shortcut --------------
homerange_pol <-
  read_sf(here("data/output/homerange_shape/homerange_redefined.shp"))   # as shapefile

#specify the attributs to assign source and ground values
sites_shape <- read_sf(here("data/output/circuitscape/sites_shape.shp"))
####################################################################################################
# source = homeranges in the south
# strength defined by size

source <- sites_shape   # create shape with sources
#source <- source %>% select(-ground) #delete other points
source$source <- NA
# assign area as source value
source$source[sites_shape$OBJ_ID == c(136)] <- sites_shape$area[sites_shape$OBJ_ID == c(136)]
source$source[sites_shape$OBJ_ID == c(5  )] <- sites_shape$area[sites_shape$OBJ_ID == c(5  )]
source$source[sites_shape$OBJ_ID == c(125)] <- sites_shape$area[sites_shape$OBJ_ID == c(125)]


source <- na.omit(source) # delete NAs


# source$source <- source$area
# source$source <- source$source/100 # km2
# source$source <- source$source*0.3 # wildcats per km2
# source$source <- source$source*2   # reproduction

st_write(source,
         here("data/output/circuitscape/advanced/1/input/source_shape.shp"),
         delete_layer = TRUE)

# create source raster
source_raster <- rasterize(x = source, y = costs1_rescaled,  background = NA, field = "source")

writeRaster(source_raster,
            here("data/output/circuitscape/advanced/1/input/source_raster.asc"),
            overwrite = TRUE) # Write rasters


#####################################################################################################
#####################################################################################################
# ground = all homeranges
# resistance strength defined by size.
# grounds as a portion of the ground patch size to alle grounds.

ground <- sites_shape   # create shape with grounds

#old home ranges to NA
ground$area[ground$OBJ_ID  == c(136)] <- NA
ground$area[ground$OBJ_ID  == c(5  )] <- NA
ground$area[ground$OBJ_ID  == c(125)] <- NA



# delete NAs
ground <- na.omit(ground) 

# assign area as ground resistance value
# big size = low resistance
ground$ground <- ground$area
ground$ground <- (ground$ground/sum(ground$ground))


st_write(ground,
         here("data/output/circuitscape/advanced/1/input/ground_shape.shp"),
         delete_layer = TRUE)

# create ground raster
ground_raster <- rasterize(x = ground, y = costs1_rescaled,  background = NA, field = "ground")

# Write rasters
writeRaster(ground_raster,
            here("data/output/circuitscape/advanced/1/input/ground_raster.asc"),
            overwrite = TRUE)

##############################################################################################


# * * Load Circuitscape Library in Julia -----------------------------------------------------
julia_library("Circuitscape")
# Command to use Circuitscape in Julia
julia_call('compute',
           paste0(input.dir, 'cs_settings_adv', ".ini"),
           show_value = TRUE)   
#----------------------------------------------------------------------------------------------
####    VOLTAGE MAP
#load result map
circuitscape_adv_voltmap <- raster(here("data/output/circuitscape/advanced/1/circuitscape_adv_voltmap.asc"))
homerange_pol <-
  read_sf(here("data/output/homerange_shape/homerange_redefined.shp"))   # as shapefile

#set zero to NA
circuitscape_adv_voltmap_zero_NA <- circuitscape_adv_voltmap
circuitscape_adv_voltmap_zero_NA[circuitscape_adv_voltmap_zero_NA == 0] <- NA
crs(circuitscape_adv_voltmap_zero_NA) <- crs(homerange_pol)
# Write rasters
writeRaster(circuitscape_adv_voltmap_zero_NA,
            here("data/output/circuitscape/advanced/1/circuitscape_adv_voltmap_zero_NA.tif"),
            overwrite = TRUE)

# set to procent
circuitscape_adv_voltmap_procent <- circuitscape_adv_voltmap_zero_NA / maxValue(circuitscape_adv_voltmap_zero_NA)*100
# Write rasters
writeRaster(circuitscape_adv_voltmap_procent,
            here("data/output/circuitscape/advanced/1/circuitscape_adv_voltmap_procent.tif"),
            overwrite = TRUE)

#----------------------------------------------------------------------------------------------
####    CURRENT MAP
#load result map
circuitscape_adv_curmap <- raster(here("data/output/circuitscape/advanced/1/circuitscape_adv_curmap.asc"))
homerange_pol <-
  read_sf(here("data/output/homerange_shape/homerange_redefined.shp"))   # as shapefile

#set zero to NA
circuitscape_adv_curmap_zero_NA <- circuitscape_adv_curmap
circuitscape_adv_curmap_zero_NA[circuitscape_adv_curmap_zero_NA == 0] <- NA
crs(circuitscape_adv_curmap_zero_NA) <- crs(homerange_pol)
# Write rasters
writeRaster(circuitscape_adv_curmap_zero_NA,
            here("data/output/circuitscape/advanced/1/circuitscape_adv_curmap_zero_NA.tif"),
            overwrite = TRUE)
#mask the corridors
circuitscape_adv_curmap_masked <- mask(circuitscape_adv_curmap_zero_NA, homerange_pol)
writeRaster(circuitscape_adv_curmap_masked,
            here("data/output/circuitscape/advanced/1/circuitscape_adv_curmap_masked.tif"),
            overwrite = TRUE)



# set to procent
circuitscape_adv_curmap_procent <- (circuitscape_adv_curmap_zero_NA / sum(source$source))*100
# Write rasters
writeRaster(circuitscape_adv_curmap_procent,
            here("data/output/circuitscape/advanced/1/circuitscape_adv_curmap_procent.tif"),
            overwrite = TRUE)
# #mask the corridors
circuitscape_adv_curmap_procent_masked <- mask(circuitscape_adv_curmap_procent, homerange_pol)
writeRaster(circuitscape_adv_curmap_procent_masked,
            here("data/output/circuitscape/advanced/1/circuitscape_adv_curmap_procent_masked.tif"),
            overwrite = TRUE)

