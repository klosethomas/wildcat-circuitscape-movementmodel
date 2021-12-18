# circuit_no_pais_all_to_one.R

# 8_prepare_circuitscape must run before!

# runs circuitscape as pinchpoint mapper. all-to-one for 140 homeranges
# summed up. shows barriers in the network context. (centrality)
# settings file is stored in circuitscape oputput folder.


# Check if Julia, R and RStudio are all set to 64 bit / 32 bit
# Load the required packages


library("here")                 # used for relative paths
library("raster")               # used to handle raster data
library("JuliaCall")
library("sf")
library("mapview")


# # Define the Options in Circuitscape with .ini file ------------------------------------------
cs_settings <- c(
  "[Options for advanced mode]",
  "ground_file_is_resistances = False",
  "remove_src_or_gnd = keepall",
   "ground_file = (Browse for a ground point file)",
  "use_unit_currents = False",
  "source_file = (Browse for a source point file)",
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
  "max_parallel = 1",

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
  "set_null_currents_to_nodata = False",
  "set_focal_node_currents_to_zero = True",
  "set_null_voltages_to_nodata = False",
  "compress_grids = False",
  "write_cur_maps = True",
  "write_volt_maps = False",
  paste(c("output_file ="),
        paste(
          here("data/output/circuitscape/all-to-one/all-to-one_no_pairs.out"),
          sep = "/"
        )),

  "write_cum_cur_map_only = True",
  "log_transform_maps = True",
  "write_max_cur_maps = False",



  "[Options for reclassification of habitat data]",
  "reclass_file = (Browse for file with reclassification data)",
  "use_reclass_table = False",

  "[Logging Options]",
  "log_level = INFO",
  paste(c("log_file ="),
        paste(
          here("data/output/circuitscape/all-to-one/all-to-one_no_pairs_log"),
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
  "scenario = all-to-one"
)

# Write the .ini file
writeLines(cs_settings,
           here("data/output/circuitscape/cs_settings_all-to-one_no_pairs.ini"))




# * * Load Circuitscape Library in Julia -----------------------------------------------------
julia_library("Circuitscape")
# Command to use Circuitscape in Julia
julia_call('compute',
           paste0(input.dir, 'cs_settings_all-to-one_no_pairs', ".ini"),
           show_value = TRUE)    


#load result map
all_to_one_no_pairs_cum_curmap <- raster(here("data/output/circuitscape/all-to-one/all-to-one_no_pairs_cum_curmap.asc"))


#set zero to NA
all_to_one_no_pairs_cum_curmap_zero_NA <- all_to_one_no_pairs_cum_curmap
all_to_one_no_pairs_cum_curmap_zero_NA[all_to_one_no_pairs_cum_curmap_zero_NA == 0] <- NA
crs(all_to_one_no_pairs_cum_curmap_zero_NA) <- crs(homerange_pol)
writeRaster(all_to_one_no_pairs_cum_curmap_zero_NA,
            here("data/output/circuitscape/all-to-one/all_to_one_no_pairs_cum_curmap_zero_NA.tif"),
            overwrite = TRUE) # Write rasters

#mask with home ranges polygons
all_to_one_no_pairs_cum_curmap_zero_NA_masked <- mask(all_to_one_no_pairs_cum_curmap_zero_NA, homerange_pol, inverse=TRUE)
crs(all_to_one_no_pairs_cum_curmap_zero_NA_masked) <- crs(homerange_pol)
writeRaster(all_to_one_no_pairs_cum_curmap_zero_NA_masked,
            here("data/output/circuitscape/all-to-one/all_to_one_no_pairs_cum_curmap_zero_NA_masked.tif"),
            overwrite = TRUE) # Write rasters

#mask the corridors, get homerange ranks
all_to_one_no_pairs_cum_curmap_homeranges <- mask(all_to_one_no_pairs_cum_curmap_zero_NA, homerange_pol)
crs(all_to_one_no_pairs_cum_curmap_homeranges) <- crs(homerange_pol)
writeRaster(all_to_one_no_pairs_cum_curmap_homeranges,
            here("data/output/circuitscape/all-to-one/all_to_one_no_pairs_cum_curmap_homeranges.tif"),
            overwrite = TRUE) # Write rasters
