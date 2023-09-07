

#### WILDFIRES BURN AREA CORRELATION WITH SOIL WATER CONTENT, SURFACE TEMPERATURE AND FOREST COVER IN EMILIA ROMAGNA DURING 2020 ####


# Exam project for the "Monitoring Ecosystem Changes and Functioning" class
# Student: Filippo Arceci
# Teacher: Duccio Roccini
# 2023


# This project aims to see if there is a significant correlation of soil water content, surface temperature and forested areas with area 
# burnt by the wildfires occurred in 2020. 
# All data is from 1/07/2020 besides the wildfires datasets (spanning all year round). 
# This date has been chosen since most of the fires occurr during the summer months, so this is when considering the variables we are 
# going to use makes the most sense.
# Data concerning the soil water index, the forested area and the surface temperature have all been downloaded from the copernicus program website
## https://land.copernicus.vgt.vito.be/PDF/portal/Application.html#Home
# The wildfires shp has instead been downloaded from the official regional website 
## https://ambiente.regione.emilia-romagna.it/it/parchi-natura2000/foreste/gli-incendi-boschivi/il-catasto-regionale-delle-aree-percorse-dal-fuoco/shape-incendi
# Lastly, the shapefile containing the boundaries of Emilia Romagna has been downoladed from the geoportal of Emilia Romagna
## https://geoportale.regione.emilia-romagna.it

# Setting the working directory where all the data I need will be located and where I want my outputs to go

setwd("D:\\Uni\\Progetti_R\\esame_2")

# Calling for all the packages I need

library(ncdf4) # package for netcdf manipulation
library(rgdal) # package for shp reading
library(ggplot2) # package for plotting
library(raster) # package for raster manipulation
library(sp) # package for importing, manipulating and exporting spatial data
library(viridis) # beautiful and colorblind inclusive colour patterns
library(basemaps) # for ggraster() function
library(sf) # used to make polygons a simple feature for manipulations
library(patchwork) # simple graph multiframe


### IMPORT AND DATA PREPARATION ###



# Reading the .netCDF of the soil water index (SWI).
# Since it contains multiple other datasets we don't need I specify that i only need the "SWI_002" object,
# containing the soil water index.
# Brick creates a raster object

swi <- brick("c_gls_SWI1km_202007021200_CEURO_SCATSAR_V1.0.1.nc", varname = "SWI_002") 

# Let's see if it has been imported correctly

plot(swi)

# We now need the Emilia Romagna area, so we will use the shapefile extent of it to cut down the SWI image
# and then the shapefile itself to mask it so that they match their extention.
# The middle steps will be shown in simple plots as the code progresses to check for errors

er <- readOGR('V_REG_GPG.Shp')

er

extent(er)

# The extent returned does not match wgs84 expected values, so i swap the original crs with the wgs84 one
# to make the extent overlap the other datasets with the same crs

crs(er) <-"+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

swi_c <- crop(swi, extent(er))

plot(swi_c)

swi_m <- mask(swi_c, er)

# Time to plot the result using ggraster, ggplot graphical arguments and a viridis colour scale
# water content ranges from 1 to 100%, but the digital values in this dataset range from 12 to 126
# dividing by the max and multiplying time 100 returns the % scale.
# The output is saved as a jpeg image with set values of the desired dimentions and resolution

swi_100 <- (swi_m/126)*100

jpeg("swi.jpeg", units="cm", width=25, height=25, res=300)

gg_raster(swi_100, r_type = "gradient") +
  scale_fill_viridis(option = "mako") +
  labs(fill = 'Water Content %') +
  ggtitle("SWI Emilia Romagna") +
  theme(legend.position = c(0,0),
        legend.title = element_text(size=10),
        legend.justification = c("left", "bottom"),
        legend.box.just = "right",
        legend.margin = margin(2, 2, 2, 2))

dev.off()

# I will do the same passeges on the forest cover file now. Please note that the "raster" 
# function can be used as well as "brick" to import the data. Plotting will be skipped as
# this is a particularly heavy dataset

fc <- raster("c_gls_FCOVER300-RT6_202007100000_GLOBE_OLCI_V1.1.1.nc")

fc

fc_c <- crop(fc, extent(er))

fc_m <- mask(fc_c, er)

fc_m




jpeg("fc.jpeg", units="cm", width=25, height=25, res=300)

gg_raster(fc_m, r_type = "gradient") +
  scale_fill_viridis(option = "A") +
  labs(fill = 'Forest Cover %area') +
  ggtitle("FC Emilia Romagna") +
  theme(legend.position = c(0,0),
        legend.title = element_text(size=10),
        legend.justification = c("left", "bottom"),
        legend.box.just = "right",
        legend.margin = margin(2, 2, 2, 2))

dev.off()

# For last, the surface temperature. I will only consider the median temperatures for the 10 day data gather period

stemp <- brick("c_gls_LST10-DC_202007010000_GLOBE_GEO_V1.2.1.nc", varname = "MEDIAN")

stemp_c <- crop(stemp, extent(er))

stemp_m <- mask(stemp_c, er)

stemp_m 

# I switch temperature scale from °k to °C

stemp_C <- stemp_m - 272.15

stemp_C

# The LST-V1 files contain the mean temperature from 10 days of observations, for each hour of the day.
# Since we need an indicative temperature amount for the area a mean of the temperatures during the daytime this
# will be calculated and used as graphical showcase
# The stemp_C[[n]] subset returns the values for the given n hour of the day in UTM time.
# Assuming daytime as the 08:00 - 20:00 timespan, the required subset will be [[6:18]] as italy is 1 hour ahead
# of the utm time normally, and 1 more for the legal hour shift


mean_t <- calc(stemp_C[[6:18]], fun = mean, na.rm = T)




jpeg("mean_t.jpeg", units="cm", width=25, height=25, res=300)

gg_raster(mean_t, r_type = "gradient") + 
  scale_fill_viridis(option = "H") +
  labs(fill = 'Temperature in °C') +
  ggtitle("mean surface temperature") +
  theme(legend.position = c(0,0),
        legend.title = element_text(size=10),
        legend.justification = c("left", "bottom"),
        legend.box.just = "right",
        legend.margin = margin(2, 2, 2, 2))

dev.off()

# I am now importing the wildfires dataset as a SpatialPolygonsDataFrame

fires <- readOGR("incendi_rer2020Completo_dati_ccfor.shp")

extent(fires)

# The coordinates returned by the "extent()" function are too far from what we would expect:
# that means the file is again in a different geografical projection from the one we are using
# for the project. The projection can be easily switched with the "spTransform()" function in wgs84
# as done before directly assigning the crs of the dataset

fires <- spTransform(fires, CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

extent(fires)

### GRAPHICAL SHOWCASE OF RESULTS ###




# All the data has been made usable, so to visualize it all together i will plot the environmental variables
# in a scale from black to white, where black is generally the range of values we predict is more suitable for fires.
# Making the plots semi-transparents we can see how they all stack up
# the fires shapefile is treated separately as will be explained in the following lines

# The final image will be exported as a .jpeg

# Simply plotting and adding the images together would result in graphical mismatches, both for extents not exactly
# equivalent and a bug in the "plot(..., add = T)" argument.
# To solve this issue I first make sure all extents match by resampling the images, and then i will draw the
# plots with a combination of the "plot()" and "image()" functions

fc_er <- resample(fc_m, raster(extent(er), ncol=500, nrow=500))
swi_er <- resample(swi_100, raster(extent(er), ncol=500, nrow=500))
mean_t_er <- resample(mean_t, raster(extent(er), ncol=500, nrow=500))

# Making a list for easier argument calls

env <- list(fc_er, swi_er, mean_t_er)

# Suitable color palette

noir <- colorRampPalette(c("white","black"))(100)

# Since the fires spatial polygons are sometimes way too small to see in the final plot, they have been
# represented by extracting the centroid of each after being coherced into a simple feature, and then
# making them spatial elements again for the plot, with the circle representing the single fire event drawn
# in dimentions scaling with its area

jpeg("Fires_X_env.jpeg", units="cm", width=25, height=25, res=300)

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

### STATISTICS ###

# The main aim of the project is to assess wether the burnt area of wildfires is correlated to the chosen
# environmental variables.
# To correlate the values first they should be extracted from the extention of every wildfire polygon in order
# to get the environmental variable value for each wilfire pixel.
# After this a mean of the values for each pixel is extracted as a representative summary of that environmental
# variable for the specific fire event, so that the areas and values to correlate are lists of the same lenght.

# First let's make empty vectors to put the values in

fires_fc <- vector()
fires_mean_t <- vector()
fires_swi<- vector()

# These loops extracts the values from the 'env' list using each fire polygon, unlists the values and uses them to
# Get the mean of them and assignt them to the previously created vectors

for (k in 1:length(fires))  {fires_fc[k] <-
  mean(
    unlist(
      extract(
        env[[1]], fires[k,1] )))
}  

for (k in 1:length(fires))  {fires_swi[k] <-
  mean(
    unlist(
      extract(
        env[[2]], fires[k,1] )))
}

for (k in 1:length(fires))  {fires_mean_t[k] <-
  mean(
    unlist(
      extract(
        env[[3]], fires[k,1] )))
}

# Creating a dataset complete with all the info

fires_data <- cbind( fires_fc, fires_mean_t, fires_swi)

fires_data <- cbind( fires, fires_data)

# Now the correlation tests.
# It is expected that the fire area:
   # grows with more material to burn, represented by fc
   # grows with the mean temperature being higher
   # decreases when soil water content is higher

cor.test(fires_data$Shape_Area, fires_data$fires_fc, alternative = "greater")

cor.test(fires_data$Shape_Area, fires_data$fires_mean_t, alternative = "greater")

cor.test(fires_data$Shape_Area, fires_data$fires_swi, alternative = "less")

# No significant p-values have been found for either variable.
# This could be for many reasons, spanning from the choice of variables to correlate, interactions
# between the former, external complex factors such as human interention, or a combination of these.
# It may be interesting to note that the sign of the correlation matches the expected outcome, thought
# non significant.
# To plot the values another loop is used

# For every test combination the loop:
   # makes i a local value reassigning it to itself in local env
   # assigns to x the ggplot and its graphical arguments
   # prints the plot
   # assigns all the former to the ith element of the 'graphs' object
   # messages i as a sign of operation completion for the ith graph

for(i in 1:3) {
  message(i)
  graphs[[i]] <- local({
    i <- i
    x <- ggplot() + 
      geom_point(
        aes(x =fires_data$Shape_Area, y =fires_data[[i+13]]),
        col='red', 
        cex=3, 
        pch = 21, 
        bg = alpha("yellow", alpha = 0.3)) +
      labs(title = titles[i], 
           x = "BURNT AREA IN M²", 
           y = titles[(i+3)]) +
      theme(plot.title = element_text(size = 8),
            axis.title.x = element_text(size = 6),
            axis.title.y = element_text(size = 6))
    print(x)
  })
}

# The "patchwork" package makes it easy to buil a multiframe using simple operators such as + to
# add side by side and / to add on top multiple graphs.

jpeg("graphs.jpeg", units="cm", width=25, height=25, res=300)

(graphs[[1]] + graphs[[2]]) / (graphs[[3]] + plot_spacer())

dev.off()

