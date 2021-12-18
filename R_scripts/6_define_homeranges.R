# 6_define_homerange

# This script will use the already created polygons with areas 
# with right probability values and the right sizes 
# together with 3, by Klar et al., 2009 defined, rules to 
# select the possible homerange of the wildcats.



# Load the required packages
library("here")                 # used for relative paths
library("sf")                   # used to handle spatial data
library("raster")               # used to handle raster data
library("stars")

  rm(list=ls()[! ls() %in% c( "old","time1", "time2", "time3", "time4","time5", "time6", "time7", "time8","time9", "time10", "time11")])  
  

# load studyarea shape file
studyarea       <-
  read_sf(here("data/shapes/studyarea.shp"))            # used as mask
village_r      <-
  raster(here("data/output/landuse_raster/village_r.tif"))            # used in rule 1
habitat_prob_65 <-
  raster(here("data/output/habitat_prob_raster/habitat_prob_65.grd")) # used in rule 2
habitat_prob_45 <-
  raster(here("data/output/habitat_prob_raster/habitat_prob_45.grd")) # used in rule 3


# Define homerange by RULES ------------------------------------------------------------
## ---- filter ------
# Focal Filter ------
# function to make a circular matrix
# of given radius and resolution.
# The radius must be an even multiple of res!
# Something like this: (radius 2, res. 1)
#     -2-1 0 1 2
# -2   0 0 1 0 0
# -1   0 1 1 1 0
#  0   1 1 1 1 1
#  1   0 1 1 1 0
#  2   0 0 1 0 0
make_circ_filter <-
  function(radius, res) {
    circ_filter <-
      matrix(0,
             nrow = 1 + (2 * radius / res),
             ncol = 1 + (2 * radius / res))
    dimnames(circ_filter)[[1]] <- seq(-radius, radius, by = res)
    dimnames(circ_filter)[[2]] <- seq(-radius, radius, by = res)
    sweeper <- function(mat) {
      for (row in 1:nrow(mat)) {
        for (col in 1:ncol(mat)) {
          dist <- sqrt((as.numeric(dimnames(mat)[[1]])[row]) ^ 2 +
                         (as.numeric(dimnames(mat)[[1]])[col]) ^ 2)
          if (dist <= radius) {
            mat[row, col] <- 1
          }
        }
      }
      return(mat)
    }
    out <- sweeper(circ_filter)
    return(out)
  }


# make a circular filter with 1500m radius and 25m resolution
cf <-
  make_circ_filter(1500, 25)                    


# Rules 1-3 ---------------------------------------------------------
## ------ rule1 --------
# rules for focal functions: NA = suitable, 1 = unsuitable
# check if a cell has a value of "Village raster", this would be a 1.
# is there any human settlement?  
#src: Wildkatzenwegeplan_Niedersachsen_2009_Bericht_06-2009

# rule 1
rule1 <- function(x) {
  sum1 <- sum(x, na.rm = TRUE)
  if (sum1  >= 1) {
    return(1)                                     
  } else
    return(0)
}
# rule 2 
# check if there are more than 1504 cells with a 1.
rule2 <- function(x) {
  sum2 <-
    sum(x, na.rm = TRUE)                      
  if (sum2 >= 1504) {
    # means 25*25 m^2 = > 94 ha of 0.65 habitat
    return(0)
  } else
    return(1)
}
# rule 3 
# check if there are more than 296 cells with a 1.
rule3 <- function(x) {
  sum3 <-
    sum(x, na.rm = TRUE)                      
  if (sum3 >= 296) {
    # means 25*25 m^2 = > 185 ha of 0.45 habitat
    return(0)
  } else
    return(1)
}

## ----- focal -----------
village_filt <- focal(village_r, w = cf, fun = rule1) # use of rule 1
#village_filt <- mask(village_filt, studyarea)
save(village_filt,
     file = here("data/output/homerange_raster/rule1.rds"))
rm(village_filt)

h65_filt <- focal(habitat_prob_65, w = cf, fun = rule2)# use of rule 2
#h65_filt <- mask(h65_filt, studyarea)
save(h65_filt,
     file = here("data/output/homerange_raster/rule2.rds"))
rm(h65_filt)

h45_filt <- focal(habitat_prob_45, w = cf, fun = rule3)# use of rule 3
#h45_filt <- mask(h45_filt, studyarea)
save(h45_filt,
     file = here("data/output/homerange_raster/rule3.rds"))
rm(h45_filt)
## ----- focal-2 -----------

# Focal results ----------------------------------
# homerange-------------------------------------

load(file = here("data/output/homerange_raster/rule1.rds"))
load(file = here("data/output/homerange_raster/rule2.rds"))
load(file = here("data/output/homerange_raster/rule3.rds"))
## ----- core -----------
homerange_core <-
  h65_filt + h45_filt + village_filt # combine results of the 3 spatial filters
# to get the cores of the home ranges


homerange_class <-
  c(0, 0.9, 1,                      # create classification matrix, to have only 0 and 1 in the raster
    0.91, Inf, NA)

homerange_class_matrix <-
  matrix(homerange_class,    # reshape the vector into a matrix with columns and rows
         ncol = 3,
         byrow = TRUE)
homerange_core <- reclassify(homerange_core,
                             homerange_class_matrix)
## ----- core-2 -------------

writeRaster(
  homerange_core,
  here("data/output/homerange_raster/homerange_core_raster.grd"),
  overwrite = T
)


homerange_core_pol <- st_as_stars(homerange_core) %>% st_as_sf(merge = TRUE) # homerange core raster to polygon
st_write(homerange_core_pol,
         here("data/output/homerange_shape/homerange_core_pol.shp"),
         overwrite = TRUE)                                # homerange core polygon export as shape
                                                             


rm(list=ls()[! ls() %in% c( "old","time1", "time2", "time3", "time4","time5", "time6", "time7", "time8","time9", "time10", "time11")])  
# clear workspace


# import Homerange Raster and Shapefiles -----
homerange_core     <-
  raster(here("data/output/homerange_raster/homerange_core_raster.grd"))
homerange_core_pol <-
  st_read(here("data/output/homerange_shape/homerange_core_pol.shp")) 
homerange_core_pol <- st_buffer(homerange_core_pol,0)

## ----- buffer -------------
# select wood patches and buffer with 300 m ----------
wood             <-
  st_read(here("data/output/landuse_shape/wood.shp"))  # read the wood shapefile cut
wood_transformed       <-
  st_transform(wood, crs(homerange_core_pol))       # change the projection of wood
wood_transformed <- st_buffer(wood_transformed,0)

# select only wood than overlap with home range cores


homerange_wood <- wood_transformed[st_intersects(wood_transformed, homerange_core_pol ) %>% lengths > 0,]


## ----- buffer-2 -------------
homerange_wood_buf <-
  st_buffer(homerange_wood, 300)             # buffer remaining wood with 300 m

homerange_wood_buf$FID <-
  NULL                                      # tidy up the file

homerange_wood_buf$layer <- NULL

homerange_wood_union <-
  st_union(homerange_wood_buf)             # bring all the (overlapping) wood patches together

homerange_wood_cast <-
  st_cast(homerange_wood_union, "POLYGON")  # and then divide the multi-polygon into home range areas
homerange_wood_cast <- st_sf(homerange_wood_cast) # sfc (simple feature geometry list/ collection) to sf object
# with specific IDs
homerange_wood_cast$OBJ_ID <- seq.int(nrow(homerange_wood_cast)) 
homerange_wood_cast$area <- st_area(homerange_wood_cast)
homerange_wood_cast <- homerange_wood_cast[!st_is_empty(homerange_wood_cast),,drop=FALSE]
homerange_wood_cast <- st_transform(homerange_wood_cast, crs = 32632)
# * * Write Shapefile
st_write(homerange_wood_cast,
         here("data/output/homerange_shape/homerange.shp"),
         delete_layer = TRUE)
## ----- buffer-3 -------------


rm(list=ls()[! ls() %in% c( "old","time1", "time2", "time3", "time4","time5", "time6", "time7", "time8","time9", "time10", "time11")])  
                                                                            # clear workspace




## ---- rast -----------------
# * Rasterize home_range_wood_buf
homerange_wood_cast <-
  read_sf(here("data/output/homerange_shape/homerange.shp")) # load home range shape back in
rasterdummy           <-
  raster(here("data/output/landuse_raster/rasterdummy.tif")) # load rasterdummy in


homerange_wood_cast$FID <- NULL 
homerange_wood_cast <- unique(homerange_wood_cast) 
#homerange_wood_cast$ID <- seq.int(nrow(homerange_wood_cast))
#homerange_wood_cast <- homerange_wood_cast[!st_is_empty(homerange_wood_cast),,drop=FALSE]
#homerange_wood_cast  <- as_Spatial(homerange_wood_cast)                     # change the format
homerange_wood_buf_r <-
  rasterize(homerange_wood_cast,
            rasterdummy,
            field = "OBJ_ID",
            background = NA)  # rasterize with rasterdummy


# * * Write Raster

writeRaster(homerange_wood_buf_r,
            here("data/output/homerange_raster/homerange.asc"),
            overwrite = TRUE)


save(homerange_wood_buf_r,
     file = here("data/output/homerange_shape/homerange.rda"))
## ---- rast-2 -----------------

## Raster the redefined Homerange Shapefile
## Redefenition is done in qgis (split some parts, add some new, delete small parts)
## ---- rast-3 -----------------
# * Rasterize home_range_wood_buf
homerange_wood_cast <-
  read_sf(here("data/output/homerange_shape/homerange_redefined.shp")) # load home range shape back in
rasterdummy           <-
  raster(here("data/output/landuse_raster/rasterdummy.tif")) # load rasterdummy in


homerange_wood_cast$FID <- NULL 
homerange_wood_cast <- unique(homerange_wood_cast) 
#homerange_wood_cast$ID <- seq.int(nrow(homerange_wood_cast))
#homerange_wood_cast <- homerange_wood_cast[!st_is_empty(homerange_wood_cast),,drop=FALSE]
#homerange_wood_cast  <- as_Spatial(homerange_wood_cast)                     # change the format
homerange_wood_buf_r <-
  rasterize(homerange_wood_cast,
            rasterdummy,
            field = "OBJ_ID",
            background = NA)  # rasterize with rasterdummy


# * * Write Raster

writeRaster(homerange_wood_buf_r,
            here("data/output/homerange_raster/homerange_redefined.asc"),
            overwrite = TRUE)


## ---- rast-4 -----------------

