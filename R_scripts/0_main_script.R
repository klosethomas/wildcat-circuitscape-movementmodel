# 0_main_script.R
 "(This script will bundle all functions located in scripts inside the project folder in to one.
 Sub folder structure is created.)"


# install the required packages
 packages <-
   c(
     "tidyverse",
     "RStoolbox",
     "raster",
     "sf",
     "sp",
     "ggplot2",
     "ggspatial",
     "here",
     "ggmap",
     "RColorBrewer",
     #"rmarkdown",# You need this library to run this template.
     "png",
     "knitr",
     "githubinstall",
     "devtools",
     "stars",
     "fasterize"
   )
 dev_packages <- c("epuRate" # Install with devtools: install_github("holtzy/epuRate", force=TRUE))
 )
 # Install packages not yet installed
 install.packages(setdiff(packages, rownames(installed.packages())), repos = "http://cran.us.r-project.org")  
 # Packages loading
 lapply(packages, library, character.only = TRUE)
 
 # Install packages not yet installed
 #install_github("holtzy/epuRate", upgrade = "ask")
 lapply(dev_packages, library, character.only = TRUE)


# create time file folder
dir.create(here("data/input"))
  dir.create(here("data/input/studyarea_shape"))
dir.create(here("figure"))
dir.create(here("src"))
dir.create(here("data/output"))
  dir.create(here("data/output/circuitscape"))
   # dir.create(here("data/output/circuitscape/output"))
    dir.create(here("data/output/circuitscape/advanced"))
    dir.create(here("data/output/circuitscape/all-to-one"))
  dir.create(here("data/output/cost_surface_raster"))
  dir.create(here("data/output/distance_raster"))
  dir.create(here("data/output/habitat_prob_raster"))
  # dir.create(here("data/output/habitat_prob_shape"))
  dir.create(here("data/output/homerange_raster"))
  dir.create(here("data/output/homerange_shape"))
  dir.create(here("data/output/landuse_raster"))
  dir.create(here("data/output/landuse_shape"))
  dir.create(here("data/output/landuse_shape/workmemory"))
  #dir.create(here("data/output/lcp"))
  dir.create(here("data/output/transitionlayer"))


