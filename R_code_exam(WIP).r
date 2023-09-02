

### Wildfires correlation with water content, surface temperature and forested areas in Emilia Romagna during 2020.


# Exam project for the "Monitoring Ecosystem Changes and Functioning" class
# Student: Filippo Arceci
# Teacher: Duccio Roccini
# 2023


# This project aims to see if there is a significant correlation of soil water content, surface temperature and forested areas with the wildfires occurred in 2020
# All data is from 1/07/2020 besides the wildfires datasets. This date has been chosen since most of the fires occurr during the summer months, so this is when
# considering the variables we are going to use makes the most sense.
# Data concerning the soil water index, the forested area and the surface temperature have all been downloaded from the copernicus program website
## https://land.copernicus.vgt.vito.be/PDF/portal/Application.html#Home
# The wildfires shp has instead been downloaded from the official regional website 
## https://ambiente.regione.emilia-romagna.it/it/parchi-natura2000/foreste/gli-incendi-boschivi/il-catasto-regionale-delle-aree-percorse-dal-fuoco/shape-incendi
# Lastly, the shapefile containing the boundaries of Emilia Romagna has been downoladed from the geoportal of Emilia Romagna
## https://geoportale.regione.emilia-romagna.it

# setting the working directory where all the data I need will be located and where I want my outputs to go

setwd("D:\\Uni\\Progetti_R\\esame_2")

library(ncdf4) # package for netcdf manipulation
library(rgdal) # package for shp reading
library(ggplot2) # package for plotting
library(raster) # package for raster manipulation
library(sp) # package for importing, manipulating and exporting spatial data
library(viridis) # beautiful and colorblind inclusive colour patterns
library(RStoolbox) # to bypass the "fortify()" functionc coherction limitations
library(sf) # used to make polygons a simple feature for manipulations
# reading the raster of the soil water index (SWI)

swi <- brick("c_gls_SWI1km_202005011200_CEURO_SCATSAR_V1.0.1.nc", varname = "SWI_002") # brick creates a raster object

# let's see if it has been imported correctly

plot(swi)

# we only need the Emilia Romagna area, so we will use the shapefile extent of it to cut down the SWI image
# and then the shapefile itself to mask it so that they match their extention
# the middle steps will be shown in simple plots as the code progresses to check for errors

er <- readOGR('V_REG_GPG.Shp')

er

extent(er)

swi_c <- crop(swi, extent(er))

plot(swi_c)

swi_er <- mask(swi_c, er)

# time to plot the result using ggplot and a viridis colour scale

ggplot() +
  geom_raster(swi_er, mapping=aes(x=x,y=y,fill=X2020.05.01)) +
  scale_fill_viridis(option = "G") +
  labs(fill = 'Water Content') +
  ggtitle("SWI Emilia Romagna") 
 
# I will do the same passeges on the forest cover file now. Please nothe that the "raster" 
# function can be used as well as "brick" to import the data.

fc <- raster("c_gls_FCOVER-RT2_202005310000_GLOBE_PROBAV_V2.0.1.nc")

plot(fc)

fc

fc_c <- crop(fc, extent(er))

fc_er <- mask(fc_c, er)

fc_er

ggplot() +
  geom_raster(fc_er, mapping=aes(x=x,y=y,fill=Fraction.of.green.Vegetation.Cover.1km)) +
  scale_fill_viridis(option = "H") +
  labs(fill = 'Forest Cover') +
  ggtitle("FC Emilia Romagna")

# I am now importing the wildfires dataset as a raster

fires <- readOGR("incendi_rer2020Completo_dati_ccfor.shp")

extent(fires)

# the coordinates returned byy the extent are too far from what we would expect:
# that means the file is in a different geografical projection from the one we are using
# the projection can be easily switched with the "spTransform()" function in wgs84

fires <- spTransform(fires, CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

extent(fires)

# all the data has been made usable, so to visualize it all together i will plot the environmental variables
# in a scale from black to white, where black is generally the range of values we predict is more suitable for fires.
# making the plots semi-transparents we can see how theu all stack up
# the fires shapefile is treated separately as will be explained in the following lines

noir <- colorRampPalette(c("white","black"))(100)

plot(fc_er, col = alpha(noir, 0.3))

plot(swi_er, col = alpha(noir, 0.3), add = T)

# adding the region boundaries for aestetics

plot(er, add = T)

# fires are represented in a shp containing the area that burnt down for each.
# these areas are very small compared to the regional extention, so to better
# visualize them I calculated the centroids of every polygon representing a fire
# and plotted it so that its dimentions would be dependant on its area.
# Therefore, bigger circles on the plot represent bigger fires.
# The centroids are calculated taking each element of the 103 contained in the
# "fires" SpatialPolygonsDataFrame, making it a simple feature, getting the centroid
# coordinates and making it a spatial element again for plotting.

for (i in 1:length(fires)) {
  plot( fires[i,] %>% 
    sf::st_as_sf() %>%          
    sf::st_centroid() %>% 
    as(.,'Spatial'),
    cex = fires[i,]$Shape_Area/20000, pch = 21, col = "red", bg = alpha("yellow", alpha = 0.3), add = T)
}
