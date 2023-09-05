

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
library(scales) # to make a graph show relative instead of absolute values

# reading the raster of the soil water index (SWI)

swi <- brick("c_gls_SWI1km_202007021200_CEURO_SCATSAR_V1.0.1.nc", varname = "SWI_002") # brick creates a raster object

# let's see if it has been imported correctly

plot(swi)

# we only need the Emilia Romagna area, so we will use the shapefile extent of it to cut down the SWI image
# and then the shapefile itself to mask it so that they match their extention
# the middle steps will be shown in simple plots as the code progresses to check for errors

er <- readOGR('V_REG_GPG.Shp')

er

extent(er)

crs(er) <-"+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

swi_c <- crop(swi, extent(er))

plot(swi_c)

swi_m <- mask(swi_c, er)

# time to plot the result using ggplot and a viridis colour scale
# water content ranges from 1 to 100%, but the digital values in this dataset range from 12 to 126
# dividing by the max and multiplying time 100 returns the % scale

swi_100 <- (swi_m/126)*100

ggplot() +
  geom_raster(swi_100, mapping=aes(x=x,y=y,fill=X2020.07.02)) +
  scale_fill_viridis(option = "mako") +
  labs(fill = 'Water Content %') +
  ggtitle("SWI Emilia Romagna") +
  theme(legend.position = c(.26, .32),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(5, 5, 5, 5))
 
# I will do the same passeges on the forest cover file now. Please nothe that the "raster" 
# function can be used as well as "brick" to import the data. Plotting will be skipped as
# this is a particularly heavy dataset

fc <- raster("c_gls_FCOVER300-RT6_202007100000_GLOBE_OLCI_V1.1.1.nc")

fc

fc_c <- crop(fc, extent(er))

fc_m <- mask(fc_c, er)

fc_m

ggplot() +
  geom_raster(fc_m, mapping=aes(x=x,y=y,fill=Fraction.of.green.Vegetation.Cover.333m)) +
  scale_fill_viridis(option = "A") +
  labs(fill = 'Forest Cover %area') +
  ggtitle("FC Emilia Romagna")  +
  theme(legend.position = c(.35, .32),
    legend.justification = c("right", "top"),
    legend.box.just = "right",
    legend.margin = margin(5, 5, 5, 5))


# for last, the surface temperature. I will only consider the median temperature for the 10 day data gather period

stemp <- brick("c_gls_LST10-DC_202007010000_GLOBE_GEO_V1.2.1.nc", varname = "MEDIAN")

stemp_c <- crop(stemp, extent(er))

stemp_m <- mask(stemp_c, er)

stemp_m 

# I switch temperature scale from °k to °C

stemp_C <- stemp_m - 272.15

stemp_C

# the LST-V1 files contain the mean temperature from 10 days of observations, for each hour of the day.
# since we need an indicative temperature amount for the area a mean of the temperatures during the days
# will be calculated and used as graphical showcase

mean_t <- calc(stemp_C, fun = mean, na.rm = T)

ggplot() +
  geom_raster(mean_t, mapping=aes(x=x,y=y,fill=layer)) +
  scale_fill_viridis(option = "H") +
  labs(fill = 'Temperature in °C') +
  ggtitle("surface temperature") +
  theme(legend.position = c(.34, .32),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(5, 5, 5, 5))

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

# the final image will be exported as a .pdf


fc_er <- resample(fc_m, raster(extent(er), ncol=500, nrow=500))
swi_er <- resample(swi_100, raster(extent(er), ncol=500, nrow=500))
mean_t_er <- resample(mean_t, raster(extent(er), ncol=500, nrow=500))

env <- list(fc_er, swi_er, mean_t_er)

noir <- colorRampPalette(c("white","black"))(100)

box=extent(er)

yxscale=(box@ymax-box@ymin)/(box@xmax-box@xmin-1)

xsize=5

ysize=xsize*yxscale

par(pin=c(xsize,ysize))

jpeg("Fires_X_env.jpeg")

par(pin=c(xsize,ysize))

  plot(er, main = "Fires and environmental variables", cex.main = 1.5)

  image(env[[1]], col = alpha(noir, 0.4), add= T)
  
  image(env[[2]], col = rev(alpha(noir, 0.4)), add= T)
  
  image(env[[3]], col = alpha(viridis(100, option = "turbo"), 0.2), add= T)
  
  for (i in 1:length(fires)) {
    plot( fires[i,] %>% 
            sf::st_as_sf() %>%          
            sf::st_centroid() %>% 
            as(.,'Spatial'),
          cex = fires[i,]$Shape_Area/15000, pch = 21, col = "red", bg = alpha("yellow", alpha = 0.3), add = T) }

dev.off()
