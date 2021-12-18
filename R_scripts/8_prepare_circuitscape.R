# 8_prepare_circuitscape.R

# 'The Julia Programming Language' must be installed on the PC
# Download it from https://julialang.org/
# The R script is calling in Julia the Circuitscape Package for calulations


# Check if Julia, R and RStudio are all set to 64 bit / 32 bit
# Load the required packages

if (!require('JuliaCall'))
  install.packages('JuliaCall') # installs JuliaCall if not happened before

library("here")                 # used for relative paths
library("raster")               # used to handle raster data
library("JuliaCall")
library("sf")
library("mapview")

# DATA IMPORT ------------------------------------------------------------------------------
# Cost surface raster
costs1_rescaled <- raster(here("data/output/cost_surface_raster/costs1_rescaled.asc"))

# DATA PREPERATION -------------------------------------------------------------------------
## ----- shortcut --------------
## Home ranges as short cut areas. Areas of 0 resistance.
homerange_pol <-
  read_sf(here("data/output/homerange_shape/homerange_redefined.shp"))   # as shapefile
homerange_pol <- homerange_pol[!st_is_empty(homerange_pol),,drop=FALSE]
homerange_pol$FID <- NULL
homerange_pol <- unique(homerange_pol)
#homerange_pol <- homerange_pol[-1,]    # some needed changes to write an ID for every home range
homerange_pol <- st_cast(homerange_pol, "POLYGON")

sites <-
  st_point_on_surface(homerange_pol)    # create sites = centroids in home range polygons

# rasterize points using the cost1 extent
sites_raster <- rasterize(x = sites, y = costs1_rescaled,  background = NA, field = "OBJ_ID")


writeRaster(sites_raster,
            here("data/output/circuitscape/sites_raster.asc"),
            overwrite = TRUE) # Write rasters

#mask the resistance raster with the 10k corridors
corridors10k <- raster(here("linkagemapper/export/linkagemapper_corridors_truncated_at_10k1.tif"))
homerange_redefined <-  raster(here("data/output/homerange_raster/homerange_redefined.asc"))
corridors10k <- corridors10k+1
#corridors10k <- corridors10k + homerange_redefined
corridors10k <- crop(corridors10k, costs1_rescaled )

writeRaster(corridors10k,
            here("data/output/cost_surface_raster/linkagemapper_corridors_truncated_at_10k.asc"),
            overwrite = TRUE
)


#write points as shapefile
st_write(sites,
         here("data/output/circuitscape/sites_shape.shp"),
         delete_layer = TRUE)


## ----- julia-1 --------------
# Setup Julia ------------------------------------------------------------------------------

## Specify the path to `bin` directory
## This path may vary depending upon Julia version or operating system
JULIA_HOME <-
  "C:/Users/ThomasKlose/AppData/Local/Programs/Julia-1.6.1/bin"

julia_setup(JULIA_HOME)

# * Install CS in Julia ---------------------------------------------------------------------
# Check if its correctly installed
jl.cs <- julia_installed_package("Circuitscape")

if (jl.cs == "nothing") {
  stop(cat(
    paste(
      "You must install the Julia CIRCUITSCAPE package!",
      "https://github.com/Circuitscape/Circuitscape.jl",
      sep = "\n"
    )
  ))
  julia_install_package('Circuitscape')
} else
  ("Julia CIRCUITSCAPE package is installed.")




# Make Julia load the .ini file ---------------------------------------------------------------

# adopt the Path to Julia Language
input.dir <- here("data/output/circuitscape/")
input.dir <- paste0(input.dir, "/")

# if (Sys.info()[['sysname']] == "Windows") {
#   input.dir <- normalizePath(input.dir, winslash = "\\")
# }

# RUN CIRCUITSCAPE IN JULIA ------------------------------------------------------------------
julia_library("Libdl")
dyn.load("C:/Users/thoma/AppData/Local/Programs/Julia 1.5.2/bin/libopenlibm.dll")      # Maybe load some dlls
dyn.load("C:/Users/thoma/AppData/Local/Programs/Julia 1.5.2/bin/libdSFMT.dll")         # Maybe load some dlls

# * * Load Circuitscape Library in Julia -----------------------------------------------------
julia_library("Circuitscape")
## ----- julia-4 --------------
#   "
# _
#    _       _ _(_)_     |  Documentation: https://docs.julialang.org
#   (_)     | (_) (_)    |
#    _ _   _| |_  __ _   |
#   | | | | | | |/ _` |  |
#   | | |_| | | | (_| |  |
#  _/ |\__'_|_|_|\__'_|  |
# |__/                   |
# "

#`-````````````````````````````````````````````````()
#"-dd```````````````````````````````````````````````()
#"`.dh:``````````````````````````````````````.``````()
#"```:ddddddddddhhdd+:-..``.-:ddddddhhhhddddhdd.````()
#"``````-dddddddd.dddddddddhhhhhddddddddddddddddd```()
#"````````````````ddddddddddddddddddddddddddddhd.```()
#"```````````.ddddddddddddddddddddddddddddhhhd.`````()
#"````````.ddddddddddddd```````````/dddddd/dddd:````()
#"print(````.ddddddddd-----.````````````````````````()
#"````.dddddd.````.ooo```````/o/```````:oo-`````````()
#"``.````````````/oooo/o```oo/oo/o```oooo.:/o```````()
#"`ooo///o.````:o/`````oooo/`````-oooo.`````ooooooo-()
#"``.`````/oo/o/```````oo/````````oo.````````````..`()
#"`````````oo/````````oo````````.o.`````````````````()

#
# Welcome to Circuitscape."
#
## ----- julia-5 --------------
















