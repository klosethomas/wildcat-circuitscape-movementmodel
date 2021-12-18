library("raster")
library("sf")
library("here")

resistance <- raster(here("data/output/circuitscape/advanced/1/resistance.tif"))
inverse_mask <- read_sf(here("data/inverse_mask1.shp")) %>%
  st_buffer(0)
st_is_valid(inverse_mask)
resistance_masked <- mask(resistance, inverse_mask)
writeRaster(resistance_masked, here("data/output/circuitscape/advanced/1/resistance_masked.tif"))



current <- raster(here("data/output/circuitscape/advanced/1/circuitscape_adv_curmap_zero_NA.tif"))
inverse_mask <- read_sf(here("data/inverse_mask1.shp")) %>%
  st_buffer(0)
st_is_valid(inverse_mask)
current_masked <- mask(current, inverse_mask)
writeRaster(current_masked, here("data/output/circuitscape/advanced/1/current_masked.tif"))


volt <- raster(here("data/output/circuitscape/advanced/1/circuitscape_adv_voltmap_zero_NA.tif"))
inverse_mask <- read_sf(here("data/volt_mask1.shp")) %>%
  st_buffer(0)
st_is_valid(inverse_mask)
volt_masked <- mask(volt, inverse_mask)
writeRaster(volt_masked, here("data/output/circuitscape/advanced/1/volt_masked.tif"))

