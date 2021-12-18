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
#load files ############

pal_fun <- colorRampPalette(c("#EE7621","forestgreen")) #"#008B00",
pal <- pal_fun(5)
#same colors but different direction
pal_fun <- colorRampPalette(c("forestgreen","#EE7621"))
pal_dir <- pal_fun(5)


studyarea <- read_sf(here("data/shapes/studyarea.shp")) 
studyarea$area <- st_area(studyarea)/10000
tm_studyarea <- tm_shape(studyarea, is.master = TRUE) +
  tm_borders(col = "red", lwd = 2) 

textfield <- tm_credits("Geodaten im Hintergrund:\n© OpenStreetMap-Mitwirkende (ODbL)", 
                        position= c("LEFT", "BOTTOM"), size=.5 )

homerange_pol <-
  read_sf(here("data/output/homerange_shape/homerange_redefined.shp"))
tm_homerange <- tm_shape(homerange_pol) +
  tm_fill(id= "OBJ_ID",col= "#aaecb6", popup.vars = c("area", "OBJ_ID")) +
  tm_borders(col = "grey60", lwd=.3)


autobahn <- read_sf(here("data/output/landuse_shape/motorway.shp")) %>%
  st_union() %>%
  st_buffer(5) %>%
  st_intersection(studyarea)
tm_autobahn <- tm_shape(autobahn) +
  tm_polygons(border.col = "chocolate1",col = "chocolate1",
              lwd = 1, border.alpha = .5, interactive=FALSE)

wika <- read_sf(here("data/wika_nachweise_redefined.shp"))
stock <- read_sf(here("data/shapes/lockstock_heide.shp"))
stock$legend <- "legend"

tm_basemap <- tm_basemap(c("OpenStreetMap", "Esri.WorldTopoMap", "Esri.WorldGrayCanvas"))

underpass_crossing <- read_sf(here("data/output/landuse_shape/underpass_crossing.shp"))

rivers <- read_sf(here("data/shapes/fluss_kanal.shp"))%>%
   st_transform(st_crs(studyarea))%>%
   st_intersection(studyarea)%>%
   st_union()%>%
   st_buffer(5)

tm_river <- tm_shape(rivers) +
   tm_polygons(border.col = "#b6c6f3", col="#b6c6f3",
               lwd = 1, border.alpha = 1, interactive=FALSE)

citys <- geocode_OSM(c("Hannover","Hamburg","Braunschweig","Wolfsburg"), as.sf = TRUE)
tm_citys <- tm_shape(citys)+
   tm_dots(col="tomato", popup.vars = c(), shape = 22, size = 0.9)



lcp <- read_sf(here("linkagemapper/export/linkagemapper_LCPs.shp"))
lcp_notactive <- read_sf(here("linkagemapper/export/linkagemapper_Inactive_LCPs.shp"))

costs_raster <- raster(here("data/output/cost_surface_raster/costs1_rescaled.tif")) 
crs(costs_raster) <- crs(studyarea)


#load till here for next script
stick_activ <- read_sf(here("linkagemapper/export/linkagemapper_Sticks.shp"))

stick_inactiv <- read_sf(here("linkagemapper/export/linkagemapper_Inactive_Sticks.shp"))

costs_raster <- raster(here("data/output/cost_surface_raster/costs1_rescaled.tif")) 
crs(costs_raster) <- crs(studyarea)


habitat_raster <- raster(here("data/output/habitat_prob_raster/habitat_prob.grd"))
crs(habitat_raster) <- crs(studyarea)

nlcc_raster <- raster(here("linkagemapper/export/linkagemapper_corridors_truncated_at_10k1.tif"))

current_pairs_raster <- raster(here("linkagemapper/export/linkagemapper_current_adjacentPairs_10k1.tif"))

current_network_raster <- raster(here("data/output/circuitscape/all-to-one/all_to_one_no_pairs_cum_curmap_zero_NA_masked.tif")) 

remodel_raster <- raster(here("data/output/circuitscape/advanced/1/circuitscape_adv_voltmap_procent.tif")) 
remodel_cur_raster <- raster(here("data/output/circuitscape/advanced/1/current_masked.tif")) 

ground1 <- read_sf(here("data/output/circuitscape/advanced/1/input/ground_shape.shp"))
source1 <- read_sf(here("data/output/circuitscape/advanced/1/input/source_shape.shp"))

remodel_2_raster <- raster(here("data/output/circuitscape/advanced/2/circuitscape_adv_2_voltmap_procent.tif"))

ground2 <- read_sf(here("data/output/circuitscape/advanced/2/input/ground_shape.shp"))
source2 <- read_sf(here("data/output/circuitscape/advanced/2/input/source_shape.shp"))

remodel_3_raster <- raster(here("data/output/circuitscape/advanced/3/circuitscape_adv_3_voltmap_procent.tif")) 

ground3 <- read_sf(here("data/output/circuitscape/advanced/3/input/ground_shape.shp"))
source3 <- read_sf(here("data/output/circuitscape/advanced/3/input/source_shape.shp"))

core_centrality <- read_sf(here("linkagemapper/export/core_centrality/linkagemapper_Cores.shp"))

 

#activ Sticks#########
sticks <- tm_autobahn+
  tm_river+
  tm_homerange+
  tm_citys+
  tm_shape(stick_activ) +
  tm_lines(col = "green4",
           lwd = 1.4,
           legend.format = list(text.separator = "-", big.mark = " "),
           id="Link_ID") +
  tm_shape(stick_inactiv) +
  tm_lines(col = "firebrick2",
           lwd = 1.4,
           legend.format = list(text.separator = "-", big.mark = " "),
           id="Link_ID") +
  tm_studyarea+
  tm_layout(
    title = "Aktive und inaktive\nVerbindungen (Sticks) ",
    title.position = c("RIGHT", "TOP"),
    legend.position = c("left", "top"),
    legend.title.size = 0.8,
    title.size = 1.5
  )+
  tm_compass(type="arrow")+
  tm_scale_bar(width = 0.1)+
  tm_add_legend("line", labels = "Aktive Verbindungen", col="green4", lwd = 1.4, title = "Ergebnis der\nNachbarschaftsanalyse")+
  tm_add_legend("line", labels = "Inaktive Verbindungen", col="firebrick2", lwd = 1.4)+
  tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", border.col = "grey60", lwd=.7, alpha = 1)+
  tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
  tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
  tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
  textfield

#sticks
tmap_save(sticks, here("TexFiles/figure/sticks.pdf"))
sticks_view <- tmap_leaflet(sticks+ tm_basemap, mode = "view", show = FALSE) 
#sticks_view
mapshot(sticks_view, url = here("TexFiles/figure/sticks.html"))

#LCP_CWD#########
lcp_CWD <- tm_shape(autobahn) +
  tm_polygons(border.col = "red", col = "red",
              lwd = 1, border.alpha = .5, interactive=FALSE)+
  tm_river+
  tm_homerange+
  tm_shape(lcp) +
  tm_lines(col = "CW_Dist",
           style = "quantile",
           lwd = 4,
           palette = pal_dir,
           title.col="Kostengew. Distanz\nin Meter (CWD)",
           legend.format = list(text.separator = "-", big.mark = " "),
           id="CW_Dist") +
  tm_studyarea +
  tm_citys+
  tm_layout(
    title = "Least-Cost-Paths\nCWD",
    title.size = 1.5,
    legend.title.size = 0.8,
    title.position = c("RIGHT", "TOP"),
    legend.position = c("left", "top")
  )+
  tm_compass(type="arrow")+
  tm_scale_bar(width = 0.1)+
  tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", alpha = 1, border.col = "grey60")+
  tm_add_legend("line", labels = "Autobahn", col="red", lwd = 2, alpha = .5)+
  tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
  tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
  textfield

#lcp_CWD
 tmap_save(lcp_CWD, here("TexFiles/figure/lcp/lcp_CWD.pdf"))
 lcp_CWD_view <- tmap_leaflet(lcp_CWD+ tm_basemap, mode = "view", show = FALSE) 
 #lcp_CWD_view
 mapshot(lcp_CWD_view, url = here("TexFiles/figure/lcp/lcp_CWD.html"))
 

 
 #LCP_euc_Dist#########
 lcp_eu <-  tm_shape(autobahn) +
   tm_polygons(border.col = "red", col = "red",
               lwd = 1, border.alpha = .5, interactive=FALSE)+
   tm_river+
   tm_homerange+
   tm_shape(lcp) +
   tm_lines(col = "Euc_Dist",
            style = "quantile",
            lwd = 4,
            palette = pal_dir,
            title.col="Euklidische Distanz in Meter",
            legend.format = list(text.separator = "-", big.mark = " "),
            id="Euc_Dist") +
   tm_studyarea+
   tm_citys+
   tm_layout(
     title = "Least-Cost-Paths\nDistanz",
     title.size = 1.5,
     legend.title.size = 0.8,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", "top")
   )+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", alpha = 1, border.col = "grey60")+
   tm_add_legend("line", labels = "Autobahn", col="red", lwd = 1, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 1, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield
 
 #lcp_eu
 tmap_save(lcp_eu, here("TexFiles/figure/lcp/lcp_eucD.pdf"))
 lcp_eu_view <- tmap_leaflet(lcp_eu+ tm_basemap, mode = "view", show = FALSE) 
 #lcp_eu_view 
 mapshot(lcp_eu_view, url = here("TexFiles/figure/lcp/lcp_eucD.html"))
 
 #LCP_effective_resistance#########
 lcp_resis <-tm_shape(autobahn) +
   tm_polygons(border.col = "red", col = "red",
               lwd = 1, border.alpha = .5, interactive=FALSE)+
   tm_river+
   tm_homerange+
   tm_shape(lcp) +
   tm_lines(col = "Effective_",
            style = "quantile",
            lwd = 4,
            palette = pal_dir,
            title.col="Effektiver Widerstand",
            legend.format = list(text.separator = "-", big.mark = " "),
            id="Effective_") +
   tm_studyarea+
   tm_citys+
   tm_layout(
     title = "Least-Cost-Paths\nWiderstand",
     title.size = 1.5,
     legend.title.size = 0.8,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", "top")
   )+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", alpha = 1, border.col = "grey60")+
   tm_add_legend("line", labels = "Autobahn", col="red", lwd = 1, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 1, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield
 
# lcp_resis
 tmap_save(lcp_resis, here("TexFiles/figure/lcp/lcp_resis.pdf"))
 lcp_resis_view <- tmap_leaflet(lcp_resis+ tm_basemap, mode = "view", show = FALSE) 
 #lcp_resis_view 
 mapshot(lcp_resis_view, url = here("TexFiles/figure/lcp/lcp_resis.html"))

 #LCP_cw_eu#########
 lcp$quality <- max(lcp$CW_Dist/lcp$Euc_Dist)-(lcp$CW_Dist/lcp$Euc_Dist)
#invertieren
 round(unname(quantile(lcp$quality, probs = seq(0, 1, 1/5))),2)
 
 lcp_cw_eu <- tm_shape(autobahn) +
    tm_polygons(border.col = "red", col = "red",
                lwd = 1, border.alpha = .5, interactive=FALSE)+
    tm_river+
    tm_homerange+
    tm_shape(lcp) +
    tm_lines(col = "quality",
             style = "quantile",
             lwd = 4,
             palette = pal,
             title.col="Verbindungs-Qualität als\nInvers von Kostengew. / eukl. Distanz",
             legend.format = list(text.separator = "-", big.mark = " ", decimal = ","),
             id="quality") +
    tm_studyarea +
    tm_citys+
    tm_layout(
       title = "Least-Cost-Paths\nQualität",
       title.size = 1.5,
       legend.title.size = 0.8,
       title.position = c("RIGHT", "TOP"),
       legend.position = c("left", "top")
    )+
    tm_compass(type="arrow")+
    tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", alpha = 1, border.col = "grey60")+
    tm_add_legend("line", labels = "Autobahn", col="red", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
    textfield
 
 #lcp_cw_eu
 tmap_save(lcp_cw_eu, here("TexFiles/figure/lcp/lcp_cw_eu.pdf"))
 lcp_cw_eu_view <- tmap_leaflet(lcp_cw_eu+ tm_basemap, mode = "view", show = FALSE) 
 #lcp_cw_eu_view 
 mapshot(lcp_cw_eu_view, url = here("TexFiles/figure/lcp/lcp_cw_eu.html"))
 
 
 #LCP_robust--------------------

 lcp_robust <-tm_shape(autobahn) +
    tm_polygons(border.col = "red", col = "red",
                lwd = 1, border.alpha = .5, interactive=FALSE)+
    tm_river+
    tm_homerange+
    tm_shape(lcp) +
    tm_lines(col = "cwd_to_Eff",
             style = "quantile",
             lwd = 4,
             palette = pal,
             title.col="Verbindungs-Robustheit als\nKostengew. / eff. Widerstand",
             legend.format = list(text.separator = "-", big.mark = " "),
             id="cwd_to_Eff") +
    tm_studyarea+
    tm_citys+
    tm_layout(
       title = "Least-Cost-Paths\nRobustheit",
       title.size = 1.5,
       legend.title.size = 0.8,
       title.position = c("RIGHT", "TOP"),
       legend.position = c("left", "top")
    )+
    tm_compass(type="arrow")+
    tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", alpha = 1, border.col = "grey60")+
    tm_add_legend("line", labels = "Autobahn", col="red", lwd = 1, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 1, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
    textfield
 
 # lcp_robust
 tmap_save(lcp_robust, here("TexFiles/figure/lcp/lcp_robust.pdf"))
 lcp_robust_view <- tmap_leaflet(lcp_robust+ tm_basemap, mode = "view", show = FALSE) 
 #lcp_robust_view 
 mapshot(lcp_robust_view, url = here("TexFiles/figure/lcp/lcp_robust.html"))

 
 # lcp_index ##########
 lcp$robustness <- lcp$CW_Dist/lcp$Effective_
 lcp$quality <- max(lcp$CW_Dist/lcp$Euc_Dist)-(lcp$CW_Dist/lcp$Euc_Dist)
 #invertieren
 #rescale 0-1
 lcp$robustness <- (lcp$robustness - min(lcp$robustness)) / (max(lcp$robustness) - min(lcp$robustness))
lcp$quality <- (lcp$quality - min(lcp$quality)) / (max(lcp$quality) - min(lcp$quality))

 lcp$index <- ((lcp$quality-min(lcp$quality))/(max(lcp$quality)-min(lcp$quality)))*((lcp$robustness-min(lcp$robustness))/(max(lcp$robustness)-min(lcp$robustness)))
 #quantil classses
 round(unname(quantile(lcp$index, probs = seq(0, 1, 1/5))),2)
 
 lcp_index <-tm_shape(autobahn) +
    tm_polygons(border.col = "red", col = "red",
                lwd = 1, border.alpha = .5, interactive=FALSE)+
    tm_river+
    tm_homerange+
    tm_shape(lcp) +
    tm_lines(col = "index",
             style = "quantile",
             lwd = 4,
             palette = pal,
             title.col="Link-Index = Qualität * Robustheit\nin Quantilen",
             labels = c("I    niedrig","II","III","IV","V    hoch"),
             legend.format = list(text.separator = "-", big.mark = " "),
             id="index") +
    tm_studyarea+
    tm_citys+
    tm_layout(
       title = "Least-Cost-Paths\nLink-Index",
       title.size = 1.5,
       legend.title.size = 0.8,
       title.position = c("RIGHT", "TOP"),
       legend.position = c("left", "top")
    )+
    tm_compass(type="arrow")+
    tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", alpha = 1, border.col = "grey60")+
    tm_add_legend("line", labels = "Autobahn", col="red", lwd = 1, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 1, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
    textfield
 
 # lcp_robust
 tmap_save(lcp_index, here("TexFiles/figure/lcp/lcp_index.pdf"))
 lcp_index_view <- tmap_leaflet(lcp_index+ tm_basemap, mode = "view", show = FALSE) 
 #lcp_robust_view 
 mapshot(lcp_index_view, url = here("TexFiles/figure/lcp/lcp_index.html"))
  
 #LCP_inactive#########
 lcp_inactive <-tm_shape(autobahn) +
   tm_polygons(border.col = "red", col = "red",
               lwd = 1, border.alpha = .5, interactive=FALSE)+
   tm_river+
   tm_homerange+
   tm_shape(lcp_notactive) +
   tm_lines(col = "Link_Info",
            #style = "quantile",
            lwd = 4,
            palette = pal,
            title.col="",
            labels = c("schneidet intermediäres Streifgebiet","verbindet nicht 1-4 nächste Nachbarn"),
            #legend.format = list(text.separator = "-", big.mark = " "),
            id="Link_ID") +
   tm_studyarea+
   tm_citys+
   tm_layout(
     title = "Inaktive Least-Cost-Paths",
     title.size = 1.5,
     legend.title.size = 0.8,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("LEFT", "top")
   )+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", alpha = 1, border.col = "grey60")+
   tm_add_legend("line", labels = "Autobahn", col="red", lwd = 1, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 1, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield
 
 #lcp_inactive
 tmap_save(lcp_inactive, here("TexFiles/figure/lcp/lcp_inactive.pdf"))
 lcp_inactive_view <- tmap_leaflet(lcp_inactive+ tm_basemap, mode = "view", show = FALSE) 
 #lcp_resis_view 
 mapshot(lcp_inactive_view, url = here("TexFiles/figure/lcp/lcp_inactive.html"))

 #LCP_centality#########
 lcp_centrality <- tm_shape(autobahn) +
   tm_polygons(border.col = "red", col = "red",
               lwd = 1, border.alpha = .5, interactive=FALSE)+
   tm_river+
   tm_homerange+
   tm_shape(lcp) +
   tm_lines(col = "Current_Fl",
            style = "quantile",
            lwd = 4,
            palette = pal,
            title.col="Stromflusszentralität",
            legend.format = list(text.separator = "-", big.mark = " "),
            id="Current_Fl") +
   tm_studyarea +
   tm_citys+
   tm_layout(
     title = "Least-Cost-Paths\nZentralität der Korridore",
     title.size = 1.5,
     legend.title.size = 0.8,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", "top")
   )+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", alpha = 1, border.col = "grey60")+
   tm_add_legend("line", labels = "Autobahn", col="red", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield
 
 #lcp_centrality
 tmap_save(lcp_centrality, here("TexFiles/figure/lcp/lcp_centrality.pdf"))
 lcp_centrality_view <- tmap_leaflet(lcp_centrality+ tm_basemap, mode = "view", show = FALSE) 
 #lcp_CWD_view
 mapshot(lcp_centrality_view, url = here("TexFiles/figure/lcp/lcp_centrality.html"))
  
 #streifgebiete#########
streifgebiete <- tm_autobahn+
   tm_river+
   tm_shape(homerange_pol) +
   tm_polygons(id= "OBJ_ID",col= "wika", palette = "Greens", n =1,
               style = "cat", digits=0, popup.vars = c("area", "OBJ_ID", "wika"),
               labels = c("ohne Wildkatzennachweis","mit Wildkatzennachweis","gesichertes Vorkommen"),
               title = "",
               border.col = "grey50", lwd= 0.2) +
   tm_shape(homerange_pol) +
   tm_text("OBJ_ID", size="area", legend.size.show=FALSE,
           size.lowerbound = 0.1, print.tiny =TRUE, scale = 1.5)+
   tm_studyarea+
   tm_citys+
   tm_layout(
     title = "Potentielle Streifgebiete",
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", 0.76),
     legend.title.size = 0.8,
     title.size = 1.7
   )+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield
   
 tmap_save(streifgebiete, here("TexFiles/figure/streifgebiete.pdf"))
 streifgebiete_view <- tmap_leaflet(streifgebiete+ tm_basemap, mode = "view", show = FALSE) 
 
 mapshot(streifgebiete_view, url = here("TexFiles/figure/streifgebiete.html"))
 
 homerange_pol$area <- st_area(homerange_pol)/10000
 sum(homerange_pol$area)/sum(studyarea$area)*100
 summary(homerange_pol$area)
 sd(homerange_pol$area)
 
#core centrality#########
 pal_centrality <- viridisLite::viridis(142, begin = 0.12, end = 1)
 centrality <- tm_autobahn +
   tm_river +
   tm_shape(core_centrality) +
   tm_polygons(id= "OBJ_ID", col =  "CF_Central", palette = pal_centrality, n =5,
               style = "order", popup.vars = c("OBJ_ID", "CF_Central"),
               legend.format = list(text.separator = "-", big.mark = " ", decimal=","), legend.reverse = TRUE,
               labels = c("dezentral","","","","zentral"),
               title = "") +
   tm_studyarea +
   tm_citys+
   tm_layout(
     title = "Zentralitäten der Streifgebiete",
     title.size = 1.5,
     legend.title.size = 0.8,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", "top")
   )+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield

 tmap_save(centrality, here("TexFiles/figure/core_centrality.pdf"))
 centrality_view <- tmap_leaflet(centrality+ tm_basemap, mode = "view", show = FALSE) 

 mapshot(centrality_view, url = here("TexFiles/figure/core_centrality.html"))
 
 #Kostenraster#########
# Raster is downsampled to 55x55 m

costs <- 
  tm_shape(costs_raster) +
   tm_raster(title="skaliert auf 1-100\nDarstellung in Quantilen", style = "quantile", palette = "Greys",alpha = 0.5, 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=",")) +
   tm_shape(studyarea, is.master = TRUE) +
   tm_borders(col = "red", lwd = 2) +
   tm_layout(
     title = "Kosten- bzw.\nwiderstandsraster",
     title.size = 1.5,
     title.position = c("right", "TOP"),
     legend.title.size = 0.8,
     legend.position = c("left", "top"))+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)
 
 tmap_save(costs, here("TexFiles/figure/costs.pdf"))
 costs_view <- tmap_leaflet(costs+ tm_basemap, mode = "view", show = FALSE) 

 mapshot(costs_view, url = here("TexFiles/figure/costs.html"))
 
 #Korridore#########
 
 pal1 <- get_brewer_pal("YlOrRd", n = 7)
 nlcc <- tm_autobahn+
   tm_river+
  tm_homerange+
   tm_shape(nlcc_raster) +
      tm_raster(title="begrenzt auf 10k kostengew. Meter", style = "cont", palette = pal1, 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=",")) +
   tm_shape(lcp, interactive = FALSE) +
   tm_lines(col = "black",
            lwd = 1) +
   tm_studyarea +
   tm_citys+
   tm_layout(
     title = "Normalized-Least-Cost-Corridors",
     title.size = 1.5,
     title.position = c("RIGHT", "TOP"),
     legend.title.size = 0.8,
     legend.position = c("left", "top"))+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("line", labels = "LCP", col="black")+
   tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", border.col = "grey", alpha = 1)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield
 
 tmap_save(nlcc, here("TexFiles/figure/nlcc.pdf"))
 tmap_options(max.raster = c(plot=32478906    , view=(16239453/2)    ) )
 nlcc_view <- tmap_leaflet(nlcc+ tm_basemap, mode = "view", show = FALSE) 

 mapshot(nlcc_view, url = here("TexFiles/figure/nlcc.html"))
 
#current_network#########

pal3 <- viridisLite::magma(20)

current_network <-tm_autobahn+
  tm_river+
  tm_homerange+
   tm_shape(current_network_raster)+
   tm_raster(title="berechnet als \nall-to-one", style = "order", palette = pal3, labels = c("niedrig","","","","hoch"), 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=","), legend.reverse = TRUE)+
   tm_studyarea +
  tm_citys+
   tm_layout(
     title = "Stromstärke",
     title.size = 1.5,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", "top"),
     legend.title.size = 0.8)+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
  tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", border.col = "grey60", alpha = 1)+
  tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
  tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
  tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
  textfield 
 
 tmap_save(current_network, here("TexFiles/figure/current_network.pdf"))
 current_network_view <- tmap_leaflet(current_network + tm_basemap, mode = "view", show = FALSE)
 mapshot(current_network_view, url = here("TexFiles/figure/current_network.html"))

 example_cuts <- read_sf(here("data/example_cuts.shp"))
 current_network <- current_network + tm_shape(example_cuts) + tm_borders(col = "black", lwd = 0.5) + tm_text("id", size = 4) 

 current_network_example_view <- tmap_leaflet(current_network + tm_basemap, mode = "view", show = FALSE)

 mapshot(current_network_example_view, url = here("TexFiles/figure/current_network_example.html"))

#current_pairs#########

 pal3 <- viridisLite::magma(20)
 
current_pairs <-tm_autobahn+
  tm_river+
  tm_homerange+
    tm_shape(current_pairs_raster)+
    tm_raster(title="pairwise berechnet \nzwischen benachbarten \nStreifgebieten", style = "order", palette = pal3, labels = c("niedrig","","","","hoch"), 
              legend.format = list(text.separator = "-", big.mark = " ", decimal=","), legend.reverse = TRUE)+ 
    tm_studyarea +
  tm_citys+
    tm_layout(
       title = "Stromstärke",
       title.size = 1.5,
       title.position = c("RIGHT", "TOP"),
       legend.position = c("left", "top"),
       legend.title.size = 0.8)+
    tm_compass(type="arrow")+
    tm_scale_bar(width = 0.1)+
  tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", border.col = "grey60", alpha = 1)+
  tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
  tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
  tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
  textfield
 

 tmap_save(current_pairs, here("TexFiles/figure/current_pairs.pdf"))
 current_pairs_view <- tmap_leaflet(current_pairs+ tm_basemap, mode = "view", show = FALSE) 

 mapshot(current_pairs_view, url = here("TexFiles/figure/current_pairs.html"))
 
 #remodel_1#########

 tm_homerange <- tm_shape(homerange_pol) +
   tm_borders(col = "grey60", lwd=.7)
 

 pal3 <- viridisLite::magma(8)

 round(unname(quantile(remodel_raster, probs = seq(0, 1, 1/8))),2)  
 
  remodel_1 <- tm_shape(remodel_raster)+
    tm_raster(title="Quantilklassen der\nSpannungsverteilung",
              style = "quantile", n=8, palette = pal3, 
              
              labels = c("Q1","Q2","Q3","Q4","Q5","Q6","Q7","Q8"),
              legend.format = list(digits= 1, text.separator = "-", big.mark = " ", decimal=","))+ 
   tm_autobahn+
   tm_river+
   tm_homerange+
    tm_studyarea+
    tm_citys+
    tm_layout(
       title = "Relative Ausbreitungswahrscheinlichkeit",
       title.position = c("RIGHT", "TOP"),
       legend.position = c("LEFT", "top"),
       legend.title.size = 0.85,
       title.size = 1.3)+
    tm_compass(type = "arrow", position = c("left", 0.09)) +
    tm_scale_bar(width = 0.1, position = c("LEFT", 0.04)) +
   tm_add_legend("fill", labels = "Streifgebiete", col="white", border.col = "grey60", alpha = 1)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield+
    tm_credits("Wildkatzenvorkommen im Süden\nals Quellpopulationen\nSources und Grounds nach\nFlächengröße gewichtet", 
               position= c("right", 0.82), size=.75, align = "right")

 
 remodel_1.1 <- tm_shape(studyarea) +
    tm_borders(col = "red", alpha = 0, lwd = 2) +
    tm_shape(wika)+
    tm_symbols(col = "turquoise1", border.col = "black", shape= 23, scale = 0.4, border.lwd = 0.3)+  #### COPYRIGHTS! Only stytic map
    tm_add_legend("symbol", shape = 23, col = "turquoise1", border.col = "black", title = "Wildkatzennachweis", border.lwd = 0.3 )+
    tm_shape(ground1)+
    tm_symbols(border.col = "darkred", col = "red", size="ground", scale=0.8, title.size =  "Zielleitfähigkeit",
               legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+
    tm_shape(source1)+
    tm_symbols(border.col = "darkgreen", col = "green", size="source",scale=0.8 , title.size =  "Quellstromstärke",
               legend.format = list(text.separator = "-", big.mark = "", decimal=",")) +
    tm_add_legend()+
    tm_layout(legend.position=c('right', 'bottom'), bg.color = NA,
              legend.title.size = 0.9,
              legend.text.size = 0.75,
              legend.height = 0.23,
              legend.width = 0.3)
vp = grid::viewport()
 
 tmap_save(remodel_1, here("TexFiles/figure/remodel/remodel_1.pdf"),
           insets_tm =  remodel_1.1, 
           insets_vp = vp)
remodel_1.1.1 <- remodel_1+
    tm_shape(ground1)+
    tm_symbols(border.col = "darkred", col = "red", scale=0.3, title.size =  "Zielleitfähigkeit",
               legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+
    tm_shape(source1)+
    tm_symbols(border.col = "darkgreen", col = "green", scale=0.3 , title.size =  "Quellstromstärke",
               legend.format = list(text.separator = "-", big.mark = "", decimal=","))
 
 remodel_1_view <- tmap_leaflet(remodel_1.1.1+ tm_basemap, mode = "view", show = FALSE) 
 mapshot(remodel_1_view, url = here("TexFiles/figure/remodel/remodel_1.html"))

 
  
 
 #remodel_1_current_network#########

 tm_homerange <- tm_shape(homerange_pol) +
   tm_fill(id= "OBJ_ID",col= "#aaecb6", popup.vars = c("area", "OBJ_ID")) +
   tm_borders(col = "grey60", lwd=.3)
 
 pal3 <- viridisLite::magma(20)
 
 
 #round(unname(quantile(remodel_raster, probs = seq(0, 1, 1/8))),2)  
 
 remodel_cur_1 <-   tm_autobahn+
   tm_river+
   tm_homerange+
   tm_shape(remodel_cur_raster)+
   tm_raster(title="berechnet im advanced-Modus", style = "order", palette = pal3, labels = c("niedrig","","","","hoch"), 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=","), legend.reverse = TRUE)+
   tm_studyarea+
   tm_citys+
   tm_layout(
     title = "Stromstärke",
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", "top"),
     legend.title.size = 0.85,
     title.size = 1.3)+
   tm_compass(type = "arrow", position = c("left", 0.09)) +
   tm_scale_bar(width = 0.1, position = c("LEFT", 0.04)) +
   tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", border.col = "grey60", alpha = 1)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield+
   tm_credits("Wildkatzenvorkommen im Süden\nals Quellpopulationen\nSources und Grounds nach\nFlächengröße gewichtet", 
              position= c("right", 0.82), size=.75, align = "right")
 
 
 
 remodel_cur_1.1 <- tm_shape(studyarea) +
   tm_borders(col = "red", alpha = 0, lwd = 2) +
   tm_shape(ground1)+
   tm_symbols(border.col = "darkred", col = "red", size="ground", scale=0.8, title.size =  "Zielleitfähigkeit",
              legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+
   tm_shape(source1)+
   tm_symbols(border.col = "darkgreen", col = "green", size="source",scale=0.8 , title.size =  "Quellstromstärke",
              legend.format = list(text.separator = "-", big.mark = "", decimal=",")) +
   tm_add_legend()+
   tm_layout(legend.position=c('right', 'bottom'), bg.color = NA,
             legend.title.size = 0.75,
             legend.text.size = 0.75,
             legend.height = 0.19,
             legend.width = 0.25)
 vp = grid::viewport()
 
 tmap_save(remodel_cur_1, here("TexFiles/figure/remodel/remodel_cur_1.pdf"),
           insets_tm =  remodel_cur_1.1, 
           insets_vp = vp)
 addRasterImage(maxBytes = Inf)
 
 remodel_cur_1_view <- tmap_leaflet(remodel_cur_1+ tm_basemap, mode = "view", show = FALSE) 
 mapshot(remodel_cur_1_view, url = here("TexFiles/figure/remodel/remodel_cur_1.html"))
 
 
 
 #remodel_2_west#########
 
 tm_homerange <- tm_shape(homerange_pol) +
   tm_borders(col = "grey60", lwd=.7)
 
  pal3 <- viridisLite::magma(8)

 round(unname(quantile(remodel_2_raster, probs = seq(0, 1, 1/8))),2)
  
 remodel_2 <- tm_shape(remodel_2_raster)+
   tm_raster(title="Quantilklassen der\nSpannungsverteilung",
             style = "quantile", n=8, palette = pal3,
             labels = c("Q1","Q2","Q3","Q4","Q5","Q6","Q7","Q8"),
             legend.format = list(digits= 1, text.separator = "-", big.mark = " ", decimal=","))+ 
   tm_autobahn+
   tm_river+
   tm_homerange+
   tm_studyarea+
   tm_citys+
   tm_layout(
     title = "Relative Ausbreitungswahrscheinlichkeit",
     title.position = c("RIGHT", "TOP"),
     legend.position = c("LEFT", "top"),
     legend.title.size = 0.8,
     title.size = 1.3)+
   tm_compass(type = "arrow", position = c("left", 0.09)) +
   tm_scale_bar(width = 0.1, position = c("LEFT", 0.04)) +
   tm_add_legend("fill", labels = "Streifgebiete", col="white", alpha = 1, border.col = "grey60")+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield+
   tm_credits("Wildkatzenvorkommen im Südwesten\nals Quellpopulationen\nSources und Grounds nach\nFlächengröße gewichtet", 
              position= c("right", 0.82), size=.75, align = "right")
 
 remodel_2.2 <- tm_shape(studyarea) +
    tm_borders(col = "red", alpha = 0, lwd = 2) +
    tm_shape(wika)+
    tm_symbols(col = "turquoise1", border.col = "black", shape= 23, scale = 0.4, border.lwd = 0.3)+  #### COPYRIGHTS! Only static map
    tm_add_legend("symbol", shape = 23, col = "turquoise1", border.col = "black", title = "Wildkatzennachweis", border.lwd = 0.3 )+
    tm_shape(ground2)+
    tm_symbols(border.col = "darkred", col = "red", size="ground", scale=0.8, title.size =  "Zielleitfähigkeit",
               legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+
    tm_shape(source2)+
    tm_symbols(border.col = "darkgreen", col = "green", size="source",scale=0.8 , title.size =  "Quellstromstärke",
               legend.format = list(text.separator = "-", big.mark = "", decimal=",")) +
    tm_add_legend()+
    tm_layout(legend.position=c('right', 'bottom'), bg.color = NA,
              legend.title.size = 0.75,
              legend.text.size = 0.75,
              legend.height = 0.21,
              legend.width = 0.3)
 vp = grid::viewport()
 
 tmap_save(remodel_2, here("TexFiles/figure/remodel/remodel_2.pdf"),
           insets_tm =  remodel_2.2, 
           insets_vp = vp)
 
 remodel_2.2.2 <- remodel_2+
    tm_shape(ground2)+
    tm_symbols(border.col = "darkred", col = "red", scale=0.3, title.size =  "Zielleitfähigkeit",
               legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+
    tm_shape(source2)+
    tm_symbols(border.col = "darkgreen", col = "green", scale=0.3 , title.size =  "Quellstromstärke",
               legend.format = list(text.separator = "-", big.mark = "", decimal=","))
 
 remodel_2_view <- tmap_leaflet(remodel_2.2.2+ tm_basemap, mode = "view", show = FALSE) 
 mapshot(remodel_2_view, url = here("TexFiles/figure/remodel/remodel_2.html"))
 
 #remodel_3_ost#########

 pal3 <- viridisLite::magma(8)
 
 round(unname(quantile(remodel_3_raster, probs = seq(0, 1, 1/8))),2)
 
 remodel_3 <- tm_shape(remodel_3_raster)+
   tm_raster(title="Quantilklassen der\nSpannungsverteilung",
             style = "quantile", n=8, palette = pal3,
             labels = c("Q1","Q2","Q3","Q4","Q5","Q6","Q7","Q8"),
             legend.format = list(digits= 1, text.separator = "-", big.mark = " ", decimal=","))+ 
   tm_autobahn+
   tm_river+
   tm_homerange+
   tm_studyarea+
   tm_citys+
   tm_layout(
     title = "Relative Ausbreitungswahrscheinlichkeit",
     title.position = c("RIGHT", "TOP"),
     legend.position = c("LEFT", "top"),
     legend.title.size = 0.8,
     title.size = 1.3)+
   tm_compass(type = "arrow", position = c("left", 0.09)) +
   tm_scale_bar(width = 0.1, position = c("LEFT", 0.04)) +
   tm_add_legend("fill", labels = "Streifgebiete", col="white",  border.col = "grey60", alpha = 1)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield+
   tm_credits("Wildkatzenvorkommen im Südosten\nals Quellpopulationen\nSources und Grounds nach\nFlächengröße gewichtet", 
              position= c("right", 0.82), size=.75, align = "right")
 
 remodel_3.3 <- tm_shape(studyarea) +
    tm_borders(col = "red", alpha = 0, lwd = 2) +
    tm_shape(wika)+
    tm_symbols(col = "turquoise1", border.col = "black", shape= 23, scale = 0.4, border.lwd = 0.3)+  #### COPYRIGHTS! Only stytic map
    tm_add_legend("symbol", shape = 23, col = "turquoise1", border.col = "black", title = "Wildkatzennachweis", border.lwd = 0.3 )+
    tm_shape(ground3)+
    tm_symbols(border.col = "darkred", col = "red", size="ground", scale=0.8, title.size =  "Zielleitfähigkeit",
               legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+
    tm_shape(source3)+
    tm_symbols(border.col = "darkgreen", col = "green", size="source",scale=0.8 , title.size =  "Quellstromstärke",
               legend.format = list(text.separator = "-", big.mark = "", decimal=",")) +
    tm_add_legend()+
    tm_layout(legend.position=c('right', 'bottom'), bg.color = NA,
              legend.title.size = 0.75,
              legend.text.size = 0.75,
              legend.height = 0.21,
              legend.width = 0.3)
 vp = grid::viewport()
 
 tmap_save(remodel_3, here("TexFiles/figure/remodel/remodel_3.pdf"),
           insets_tm =  remodel_3.3, 
           insets_vp = vp)
 
 remodel_3.3.3 <- remodel_3+
    tm_shape(ground3)+
    tm_symbols(border.col = "darkred", col = "red", scale=0.3, title.size =  "Zielleitfähigkeit",
                                       legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+
    tm_shape(source3)+
    tm_symbols(border.col = "darkgreen", col = "green", scale=0.3 , title.size =  "Quellstromstärke",
               legend.format = list(text.separator = "-", big.mark = "", decimal=","))
 remodel_3_view <- tmap_leaflet(remodel_3.3.3+ tm_basemap, mode = "view", show = FALSE) 
 #remodel_3_view 
 mapshot(remodel_3_view, url = here("TexFiles/figure/remodel/remodel_3.html"))

 #lockstock------------------------------------------------------------------------------------

  pal4 <- c("#feebe2","#fbb4b9","#f768a1","#ae017e")


lockstock <- tm_autobahn+
    tm_river+
    tm_shape(homerange_pol) +
    tm_polygons(id= "OBJ_ID",col= "#aaecb6", alpha = 1,
                legend.show = F, popup.vars = c("area", "OBJ_ID", "wika"),
                title = "", lwd= 0.1,
                border.col = "grey60") +
    tm_studyarea+
    tm_citys+
    tm_shape(stock)+
    tm_symbols(col ="legend", title.col = "", labels = "Lockstock", palette = "#FF3030", border.col = "#FF3030", scale = 0.1, legend.col.show = T)+  #### COPYRIGHTS! Only stytic map
    tm_shape(wika)+
    tm_symbols(col = "Jahr", style="cat", palette = pal4, border.col = "black",  scale = 0.35, border.lwd = 0.1, legend.col.show = T, 
               legend.format = list(text.separator = "-", big.mark = "", decimal=","), title.col = "Nachweis im Jahr")+  #### COPYRIGHTS! Only stytic map
    tm_layout(
       title = "Wildkatzenlockstockscreening",
       title.size = 1.5,
       title.position = c("RIGHT", "TOP"),
       legend.position = c("left", "top"),
       legend.title.size = 0.8
    )+
    tm_compass(type="arrow")+
    tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiet", col="#aaecb6",border.col = "grey60", lwd = 2, alpha = 1)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
    textfield

 tmap_save(lockstock, here("TexFiles/figure/lockstock.pdf"))

 #habitatmodell------------------------------------------------------------------------------------

pal_habitat <-get_brewer_pal("RdYlGn", n = 14, contrast = c(0.05, 0.8))
 pal_habitat <- c("#FDBC6D", "#FDDB86", "#FEEFA4", "#6CBF63", "#40AA59", "#17934D")
 
 habitatmodell <-
   tm_shape(habitat_raster) +
   tm_raster(
     title = "Habitatqualität", palette = pal_habitat, breaks = c(0.0, 0.1, 0.3, 0.4, 0.5, 0.6, 0.76), labels = c(
       "0,0 - 0,1 ungeeignet", "0,1 - 0,3",
       "0,3 - 0,4",
       "0,4 - 0,5 gut",
       "0,5 - 0,6",
       "0,6 - 0,76 optimal"
     ),
     legend.format = list(text.separator = "-", big.mark = " ", decimal = ",")
   ) +
    tm_studyarea+
    tm_shape(autobahn) +
    tm_polygons(border.col = "chocolate1",col = "chocolate1",
                lwd = 1, border.alpha = 1, interactive=FALSE)+
 tm_shape(rivers) +
    tm_polygons(border.col = "royalblue", col="royalblue",
                lwd = 1, border.alpha = 1, interactive=FALSE)+
    tm_citys+
   tm_layout(
     title = "Wildkatzenhabitatmodell",
     title.size = 1.5,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", "top"),
     legend.title.size = 0.9) +
   tm_compass(type = "arrow") +
   tm_scale_bar(width = 0.1)+
    tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = 1)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = 1)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
    textfield
 
 tmap_save(habitatmodell, here("TexFiles/figure/habitatmodell1.pdf"))

 
 
 

 #remodel_cluster##############################################################################
 remodel_2_raster <- raster(here("data/output/circuitscape/advanced/2/circuitscape_adv_2_voltmap_zero_NA.tif"))
 remodel_3_raster <- raster(here("data/output/circuitscape/advanced/3/circuitscape_adv_3_voltmap_zero_NA.tif"))
 
 palette <- get_brewer_pal("PiYG", n = 8, contrast = c(0, 1))


 source1 <- source1[!(source1$OBJ_ID==71),] #drop the sources next to hildesheim
 source1 <- source1[!(source1$OBJ_ID==96),]
 
 west_neg <- remodel_2_raster * -1 
 ost_pos  <- remodel_3_raster 
 

 cluster_raster <- west_neg + ost_pos

 tm_homerange <- tm_shape(homerange_pol) +
   tm_borders(col = "grey60", lwd=.3)
 

cluster <-  tm_shape(cluster_raster)+
  tm_raster(title = "Klasseneinteilung durch\nExtremwerte und Median,\nUmschlagpunkt bei 0", style = "fixed", palette = palette, breaks = c(minValue(west_neg),unname(quantile(west_neg, probs = 0.5)),0,unname(quantile(ost_pos, probs = 0.5)),maxValue(ost_pos)),
            legend.format = list(text.separator = "bis", big.mark = "", decimal=","),
            labels = c("westliche Route","","","östliche Route"))+ 
   tm_autobahn+
   tm_river+
   tm_homerange+
   tm_studyarea+
   tm_citys+
   tm_layout(
     title = "Clusterdominanzen",
     title.position = c("RIGHT", "TOP"),
     legend.position = c("LEFT", "top"),
     legend.title.size = 0.8,
     title.size = 1.3)+
   tm_compass(type = "arrow", position = c("left", 0.09)) +
   tm_scale_bar(width = 0.1, position = c("LEFT", 0.04)) +
   tm_add_legend("fill", labels = "Streifgebiete", col="white",  border.col = "grey60", alpha = 1)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield+
   tm_credits("nach Verrechnung der\nAusbreitungsanalysen\nüber die westliche\nbzw. östliche Route", 
              position= c("right", 0.82), size=.75, align = "right")
 
 cluster.1 <- tm_shape(studyarea) +
   tm_borders(col = "red", alpha = 0, lwd = 2) +
   tm_shape(wika)+
   tm_symbols(col = "turquoise1", border.col = "black", shape= 23, scale = 0.4, border.lwd = 0.3)+  #### COPYRIGHTS! Only stytic map
   tm_add_legend("symbol", shape = 23, col = "turquoise1", border.col = "black", title = "Wildkatzennachweis", border.lwd = 0.3 )+
   tm_shape(ground1)+
   tm_symbols(border.col = "darkred", col = "red", size="ground", scale=0.8, title.size =  "Zielleitfähigkeit",
              legend.format = list(text.separator = "-", big.mark = " ", decimal=","))+
   tm_shape(source1)+
   tm_symbols(border.col = "darkgreen", col = "green", size="source",scale=0.8 , title.size =  "Quellstromstärke",
              legend.format = list(text.separator = "-", big.mark = "", decimal=",")) +
     tm_layout(legend.position=c('right', 'bottom'), bg.color = NA,
             legend.title.size = 0.75,
             legend.text.size = 0.75,
             legend.height = 0.21,
             legend.width = 0.3)
 vp = grid::viewport()
 
 tmap_save(cluster, here("TexFiles/figure/remodel/cluster.pdf"),
           insets_tm =  cluster.1, 
           insets_vp = vp)
 
cluster_view <- tmap_leaflet(cluster+ tm_basemap, mode = "view", show = FALSE) 

 mapshot(cluster_view, url = here("TexFiles/figure/remodel/cluster.html")) 

 #underpasses##############################################################################
 pal3 <- c("#9abfe4","#ffe889","#ffd45e","#f2a049","#e67137","#b10800")
underpass_crossing$X_max <- round(underpass_crossing$X_max, 2)

tm_homerange <- tm_shape(homerange_pol) +
  tm_borders(col = "grey60", lwd=.3)

underpass <-     
   tm_shape(autobahn) +
    tm_polygons(border.col = "red", col = "red",
                lwd = 1, border.alpha = .5, interactive=FALSE)+
    tm_river+
    tm_homerange+
    tm_shape(underpass_crossing) +
    tm_dots(col = "X_max",
            size= 0.2,
             style = "quantile",
             n=6,
             palette = pal3,
             title="extrahiert aus\nall-to-one-Ergebniskarte",
             legend.format = list(text.separator = "-", big.mark = " "),
             id="X_max") +
    tm_studyarea +
   tm_citys+
    tm_layout(
       title = "Stromfluss in\nAutobahnquerungen",
       title.size = 1.3,
       legend.title.size = 0.8,
       title.position = c("RIGHT", "TOP"),
       legend.position = c("left", "top")
    )+
    tm_compass(type="arrow")+
    tm_scale_bar(width = 0.1)+
    tm_add_legend("fill", labels = "Streifgebiete", col="white", alpha = 1, border.col = "gray31")+
    tm_add_legend("line", labels = "Autobahn", col="red", lwd = 2, alpha = .5)+
    tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
    tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
    textfield
 

 tmap_save(underpass, here("TexFiles/figure/underpass.pdf"))
 underpass_view <- tmap_leaflet(underpass+ tm_basemap, mode = "view", show = FALSE) 

 mapshot(underpass_view, url = here("TexFiles/figure/underpass.html"))
 
 
 #wildlife bridge##############################################################################
 #barrier and current in one html map
 barrier_cen_pct_sum_100 <- raster(here("linkagemapper/export/barrier_sum/linkagemapper_BarrierCenters_Pct_Sum_Rad100.tif")) %>%
   raster::reclassify(cbind(-Inf, 0, NA), right=TRUE)
 q <- unname(quantile(barrier_cen_pct_sum_100,probs = 0.95))  
 barrier_cen_pct_sum_100 <-  raster::reclassify(barrier_cen_pct_sum_100,cbind(q, Inf, q), right=TRUE)
 current_network_raster <- raster(here("data/output/circuitscape/all-to-one/all_to_one_no_pairs_cum_curmap_zero_NA_masked.tif")) 
 
 greenbridge_shape <- read_sf(here("data/output/landuse_shape/crossing.shp")) %>%
   na.omit(greenbridge_shape)
 
 tm_lcp <-tm_shape(lcp) +
   tm_lines(col = "green",
            lwd = 10,
            palette = pal,
            title.col="LCP",id="Link_ID", popup.vars = c("Link_ID", "CW_Dist") )
 
 pal4 <- viridisLite::magma(20)
 pal5 <- c("#01163d","#044aa5","#d21f0b","#fc5102","#fdf902")
 
greenbridge <-tm_autobahn+
   tm_river+
   tm_homerange+
   tm_shape(current_network_raster)+
   tm_raster(title="berechnet als \nall-to-one", style = "order", palette = pal4, labels = c("niedrig","","","","hoch"), 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=","), legend.reverse = TRUE)+
   tm_shape(barrier_cen_pct_sum_100, raster.downsample = TRUE)+
   tm_raster(title="prozentuale \u0394LCP pro\nrenaturiertes Suchfenster (200 m)",
             style = "cont", palette = pal5, 
             legend.format = list(text.separator = "-", big.mark = " ", decimal=","), legend.reverse = FALSE)+
   tm_studyarea +
   tm_citys+
   tm_layout(
     title = "Grünbrücken Braunschweig",
     title.size = 1.5,
     title.position = c("RIGHT", "TOP"),
     legend.position = c("left", "top"),
     legend.title.size = 0.8)+
   tm_compass(type="arrow")+
   tm_scale_bar(width = 0.1)+
   tm_add_legend("fill", labels = "Streifgebiete", col="#aaecb6", border.col = "grey60", alpha = 1)+
   tm_add_legend("line", labels = "Autobahn", col="chocolate1", lwd = 2, alpha = .5)+
   tm_add_legend("line", labels = "Fluss/Kanal", col="royalblue", lwd = 2, alpha = .5)+
   tm_add_legend("symbol", labels = "Großstadt", col="tomato", shape = 22)+
   textfield +
   tm_view(set.view = c(10.67074, 52.25826, 13))+
   tm_shape(greenbridge_shape)+
   tm_borders(col = "red", lwd = 1)+
   tm_text("bridge", size = 2)+   tm_lcp
  
 
 
greenbridge <- tmap_leaflet(greenbridge + tm_basemap, mode = "view", show = FALSE)
 mapshot(greenbridge, url = here("TexFiles/figure/greenbridge_current_barrier.html"))
 
 
 
 
 