library("tmap")
library("mapview")
library("tmaptools")
library("sf")
library("raster")
library("here")
library("dplyr")
#library("colourpicker")


#high res
tmap_options(max.raster = c(plot=32478906    , view=8285436    ) ) # view mode = 70*70

pal <- viridisLite::inferno(5, begin = 0.21, end = 0.82, direction = -1)

pal3 <- c("#01163d","#044aa5","#d21f0b","#fc5102","#fdf902")

tm_homerange <- tm_shape(homerange_pol)+
  tm_polygons(col = "darkgreen", border.alpha = 0, alpha=0.5, id="OBJ_ID", popup.vars = c("area", "OBJ_ID"))


tm_lcp <-tm_shape(lcp) +
  tm_lines(col = "green",
           lwd = 10,
           palette = pal,
           title.col="LCP",id="Link_ID", popup.vars = c("Link_ID", "CW_Dist") )


masks <- read_sf(here("data/shapes/masks.shp"))%>%
  st_transform("+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs")
tm_mask <- tm_shape(masks)+
  tm_borders(col="grey")
#masks1<- masks[masks$id == '1', ]

# all Barrier Raster are the summed ones about the three search diameter

#load barrier data
#percentages
barrier_cen_pct_sum_100 <- raster(here("linkagemapper/export/barrier_sum/linkagemapper_BarrierCenters_Pct_Sum_Rad100.tif")) %>%
  raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
q <- unname(quantile(barrier_cen_pct_sum_100,probs = 0.95))  
barrier_cen_pct_sum_100 <-  raster::reclassify(barrier_cen_pct_sum_100,cbind(q, Inf, q), right=TRUE)
#95-quantil:0.03093676
#max:1.172789    
barrier_cen_pct_sum_500 <- raster(here("linkagemapper/export/barrier_sum/linkagemapper_BarrierCenters_Pct_Sum_Rad500.tif")) %>%
  raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
q <- unname(quantile(barrier_cen_pct_sum_500,probs = 0.95))  
barrier_cen_pct_sum_500 <-  raster::reclassify(barrier_cen_pct_sum_500,cbind(q, Inf, q), right=TRUE)
#95-quantil:0.02689848
#max:0.2110074   
barrier_cen_pct_sum_100500 <- raster(here("linkagemapper/export/barrier_sum/linkagemapper_BarrierCenters_Pct_Sum_Rad100To500Step200.tif")) %>%
  raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
q <- unname(quantile(barrier_cen_pct_sum_100500,probs = 0.95))  
barrier_cen_pct_sum_100500 <-  raster::reclassify(barrier_cen_pct_sum_100500,cbind(q, Inf, q), right=TRUE)
#95-quantil:0.02941495
#max:1.172789   

# improvment score
#max, without percentages
barrier_cen_sum_100 <- raster(here("linkagemapper/export/barrier_sum/linkagemapper_BarrierCenters_Sum_Rad100.tif")) %>%
  raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
q <- unname(quantile(barrier_cen_sum_100,probs = 0.95))  
barrier_cen_sum_100 <-  raster::reclassify(barrier_cen_sum_100,cbind(q, Inf, q), right=TRUE)
#95-quantil:11.58631
#max:418.2949  

barrier_cen_sum_500 <- raster(here("linkagemapper/export/barrier_sum/linkagemapper_BarrierCenters_Sum_Rad500.tif")) %>%
  raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
q <- unname(quantile(barrier_cen_sum_500,probs = 0.95))  
barrier_cen_sum_500 <-  raster::reclassify(barrier_cen_sum_500,cbind(q, Inf, q), right=TRUE)
#95-quantil:11.95481  
#max:0.02941495

barrier_cen_sum_100500 <- raster(here("linkagemapper/export/barrier_sum/linkagemapper_BarrierCenters_Sum_Rad100To500Step200.tif")) %>%
   raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
#95-quantil:12.3211  
#max:566.7626  


#load files##############################################################################################################
 #barrier_cen_sum_pct_100#########


cen_pct_sum_100 <-  
  tm_autobahn+
   tm_river+
   tm_homerange+
   tm_shape(barrier_cen_pct_sum_100, raster.downsample = TRUE)+
   tm_raster(title="prozentuale \u0394LCP pro\nrenaturiertes Suchfenster (200 m)",
             style = "cont", palette = pal3,# labels = c("niedrig","","","","hoch"), 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=","), legend.reverse = FALSE)+ 
   tm_studyarea+
   tm_citys+
   tm_layout(bg.color = "white",
     title = "Barrierewirkung",
     title.size = 1.5,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("LEFT", "top"),
     legend.title.size = 0.8,
     legend.text.size=0.67)+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("symbol", labels = "Streifgebiete", col="darkgreen", alpha = 0.5, border.alpha = 0, shape = 22)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
  textfield
 

 tmap_save(cen_pct_sum_100, here("TexFiles/figure/barrieren/pct/barrier_cen_pct_sum_100.png"))
 cen_pct_sum_100_view <- tmap_leaflet(cen_pct_sum_100 + tm_mask+
                                         tm_basemap, mode = "view", show = FALSE) 
 mapshot(cen_pct_sum_100_view, url = here("TexFiles/figure/barrieren/pct/barrier_cen_pct_sum_100.html"))

 #barrier_cen_sum_pct_100_500#########
cen_pct_sum_100500 <- 
   tm_autobahn+
   tm_river+
   tm_homerange+
   tm_shape(barrier_cen_pct_sum_100500)+
   tm_raster(title="prozentuale \u0394LCP pro\nrenaturiertes Suchfenster",
             style = "cont", palette = pal3,# labels = c("niedrig","","","","hoch"), 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=","), legend.reverse = FALSE)+ 
   tm_studyarea+
   tm_citys+
   tm_layout(bg.color = "white",
             title = "Barrierewirkung",
             title.size = 1.5,
             title.position = c("RIGHT", "TOP"),
             legend.position = c("LEFT", "top"),
             legend.title.size = 0.8,
             legend.text.size=0.67)+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="darkgreen", alpha = 0.5, border.alpha = 0, shape = 22)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", border.col = "#585855", shape = 22)+
   textfield
 
 
 tmap_save(cen_pct_sum_100500, here("TexFiles/figure/barrieren/pct/barrier_cen_pct_sum_100500.png"))
 cen_pct_sum_100500_view <- tmap_leaflet(cen_pct_sum_100500 + tm_lcp+
                                            tm_basemap, mode = "view", show = FALSE) 
 mapshot(cen_pct_sum_100500_view, url = here("TexFiles/figure/barrieren/pct/barrier_cen_pct_sum_100500.html"))
 
 
 #barrier_cen_sum_pct_500#########
 cen_pct_sum_500 <- 
   tm_autobahn+
   tm_river+
   tm_homerange+
   tm_shape(barrier_cen_pct_sum_500)+
   tm_raster(title="prozentuale \u0394LCP pro\nrenaturiertes Suchfenster",
             style = "cont", palette = pal3, 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+ 
   tm_studyarea+
   tm_citys+
   tm_layout(bg.color = "white",
             title = "Barrierewirkung",
             title.size = 1.5,
             title.position = c("RIGHT", "TOP"),
             legend.position = c("LEFT", "top"),
             legend.title.size = 0.8,
             legend.text.size=0.67)+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="darkgreen", alpha = 0.5, border.alpha = 0, shape = 22)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", border.col = "#585855", shape = 22)+
   textfield
 
 
 tmap_save(cen_pct_sum_500, here("TexFiles/figure/barrieren/pct/barrier_cen_pct_sum_500.png"))
 cen_pct_sum_500_view <- tmap_leaflet(cen_pct_sum_500 + tm_lcp +
                                           tm_basemap, mode = "view", show = FALSE) 
 mapshot(cen_pct_sum_500_view, url = here("TexFiles/figure/barrieren/pct/barrier_cen_pct_sum_500.html"))
 
 ###-+-+-+-+-+-+-+-+-+-++-+-+-+############################################
 #barrier_diff#########

 barrier_cen_sum_100500 <- raster(here("linkagemapper/export/barrier_sum/linkagemapper_BarrierCenters_Sum_Rad100To500Step200.tif")) %>%
    raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
 #barrier_cen_sum_100500 - barrier_cen_100500
 #sum: for diff map
 barrier_cen_100500 <- raster(here("linkagemapper/export/barrier/linkagemapper_BarrierCenters_Rad100To500Step200.tif")) %>%
    raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
 
 diff_sum_max <- barrier_cen_sum_100500 - barrier_cen_100500
 q <- unname(quantile(diff_sum_max,probs = 0.95)) 
 diff_sum_max <-  raster::reclassify(diff_sum_max,cbind(q, Inf, q), right=TRUE)


 barrier_diff <- 
   tm_autobahn+
    tm_river+
    tm_homerange+
   tm_shape(diff_sum_max)+
   tm_raster(title="Differenz aus summierten \u0394LCP\nund max. \u0394LCP", style = "cont", palette = pal3,
             legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+ 
    tm_studyarea+
    tm_citys+
   tm_layout(
     title = "Barrierewirkung",
     title.size = 1.5,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("LEFT", "top"),
     legend.title.size = 0.8,
     legend.text.size=0.67)+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="darkgreen", alpha = 0.5, border.alpha = 0, shape = 22)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", border.col = "#585855", shape = 22)+
   textfield
 
 
 tmap_save(barrier_diff, here("TexFiles/figure/barrieren/diff/barrier_diff.png"))
 barrier_diff_view <- tmap_leaflet(barrier_diff+ tm_lcp+
                                      tm_basemap, mode = "view", show = FALSE) 
 mapshot(barrier_diff_view, url = here("TexFiles/figure/barrieren/diff/barrier_diff.html"))
 
 
 ###-+-+-+-+-+-+-+-+-+-++-+-+-+############################################ 
 #barrier_cen_100_ohneProzent#########
 cen_sum_100 <- 
   tm_autobahn+
    tm_river+
   tm_homerange+
   tm_shape(barrier_cen_sum_100)+
   tm_raster(title="absolute \u0394LCP pro\nrenaturiertes Suchfenster (100 m)",
             style = "cont", palette = pal3, #labels = c("niedrig","","","","hoch"), 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=",")#, legend.reverse = TRUE
             )+ 
    tm_studyarea+
    tm_citys+
   tm_layout(bg.color = "white",
             title = "Barrierewirkung",
             title.size = 1.5,
             title.position = c("RIGHT", "TOP"),
             legend.position = c("LEFT", "top"),
             legend.title.size = 0.8,
             legend.text.size=0.67)+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="darkgreen", alpha = 0.5, border.alpha = 0, shape = 22)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", border.col = "#585855", shape = 22)+
   textfield
 
 
 tmap_save(cen_sum_100, here("TexFiles/figure/barrieren/barrier_cen_sum_100.png"))
 cen_sum_100_view <- tmap_leaflet(cen_sum_100 + tm_lcp+
                                     tm_basemap, mode = "view", show = FALSE) 
 mapshot(cen_sum_100_view, url = here("TexFiles/figure/barrieren/barrier_cen_sum_100.html"))
 
 #barrier_cen_100_ohneProzent#########
 
 
 cen_sum_500 <- 
   tm_autobahn+
   tm_river+
   tm_homerange+
   tm_shape(barrier_cen_sum_100)+
   tm_raster(title="absolute \u0394LCP pro\nrenaturiertes Suchfenster (500 m)",
             style = "cont", palette = pal3, 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=",")
   )+ 
   tm_studyarea+
   tm_citys+
   tm_layout(bg.color = "white",
             title = "Barrierewirkung",
             title.size = 1.5,
             title.position = c("RIGHT", "TOP"),
             legend.position = c("LEFT", "top"),
             legend.title.size = 0.8,
             legend.text.size=0.67)+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="darkgreen", alpha = 0.5, border.alpha = 0, shape = 22)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", border.col = "#585855", shape = 22)+
   textfield
 
 
 tmap_save(cen_sum_500, here("TexFiles/figure/barrieren/barrier_cen_sum_500.png"))
 cen_sum_500_view <- tmap_leaflet(cen_sum_500 + tm_lcp+
                                    tm_basemap, mode = "view", show = FALSE) 
 mapshot(cen_sum_500_view, url = here("TexFiles/figure/barrieren/barrier_cen_sum_500.html"))
 
 #barrier_cen_100500_ohneProzent#########
  q <- unname(quantile(barrier_cen_sum_100500,probs = 0.95))  
 barrier_cen_sum_100500 <-  raster::reclassify(barrier_cen_sum_100500,cbind(q, Inf, q), right=TRUE)
 
 
 cen_sum_100500 <- 
    tm_autobahn+
    tm_river+
    tm_homerange+
    tm_shape(barrier_cen_sum_100500)+
    tm_raster(title="absolute \u0394LCP pro\nrenaturiertes Suchfenster",
              style = "cont", palette = pal3,
              legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+ 
    tm_studyarea+
    tm_citys+
    tm_layout(bg.color = "white",
              title = "Barrierewirkung",
              title.size = 1.5,
              title.position = c("RIGHT", "TOP"),
              legend.position = c("LEFT", "top"),
              legend.title.size = 0.8,
              legend.text.size=0.67)+
    tm_compass(type="arrow")+
    tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="darkgreen", alpha = 0.5, border.alpha = 0, shape = 22)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", border.col = "#585855", shape = 22)+
    textfield
 
 
 tmap_save(cen_sum_100500, here("TexFiles/figure/barrieren/barrier_cen_sum_100500.png"))
 cen_sum_100500_view <- tmap_leaflet(cen_sum_100500 + tm_lcp+
                                     tm_basemap, mode = "view", show = FALSE) 
 mapshot(cen_sum_100500_view, url = here("TexFiles/figure/barrieren/barrier_cen_sum_100500.html"))
 
 ###-+-+-+-+-+-+-+-+-+-++-+-+-+############################################ 
 #no SUM, no %################################
 barrier_cen_100500 <- raster(here("linkagemapper/export/barrier/linkagemapper_BarrierCenters_Rad100To500Step200.tif")) %>%
    raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
 q <- unname(quantile(barrier_cen_100500,probs = 0.95)) 
 barrier_cen_100500 <-  raster::reclassify(barrier_cen_100500,cbind(q, Inf, q), right=TRUE)
 #95-quantil:7.382141  
 #max:99    
 
 cen_100500 <- 
    tm_autobahn+
    tm_river+
    tm_homerange+
    tm_shape(barrier_cen_100500)+
    tm_raster(title="absolute \u0394LCP pro\nrenaturiertes Suchfenster",
              style = "cont", palette = pal3,
              legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+ 
    tm_studyarea+
    tm_citys+
    tm_layout(bg.color = "white",
              title = "Barrierewirkung",
              title.size = 1.5,
              title.position = c("RIGHT", "TOP"),
              legend.position = c("LEFT", "top"),
              legend.title.size = 0.8,
              legend.text.size=0.67)+
    tm_compass(type="arrow")+
    tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="darkgreen", alpha = 0.5, border.alpha = 0, shape = 22)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", border.col = "#585855", shape = 22)+
    textfield
 
 
 tmap_save(cen_100500, here("TexFiles/figure/barrieren/no_sum/cen_100500.png"))
 cen_100500_view <- tmap_leaflet(cen_100500 + tm_lcp+
                                        tm_basemap, mode = "view", show = FALSE) 
 mapshot(cen_100500_view, url = here("TexFiles/figure/barrieren/no_sum/cen_100500.html"))
 

 