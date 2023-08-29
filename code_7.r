# working on Copernicus data

library(ncdf4)    
library(raster)     
library(ggplot2)    
library(RStoolbox) 
library(viridis)    
library(patchwork) 
setwd("D:\Uni\Progetti_R\allenamento_2")

# register and Log In to Copernicus, search for the desired data set in the Cryosphere folder
# with the "raster()" function instead of the "brick()" function an image can be uploaded as a RasterLayer object
# it then can be assigned to an object, in this example snow

snow <- raster("c_gls_SCE_202012210000_NHEMI_VIIRS_V1.0.1.nc")

snow

# showing the characteristics of snow, under names you can find Snow.Cover.Extent which can be used in the next step to create a ggplot
# plotting the data with the "ggplot()" function as a raster geometry

ggplot() + geom_raster(snow,mapping=aes(x=x,y=y,fill=Snow.Cover.Extent)) + scale_fill_viridis(option="mako") + ggtitle("Snow Cover Extent on the 21st of December 2020")
                                                                                
# instead of showing the entire data (in this case the Northern Hemisphere) using an array including the maximum and minimum longitutes as well as latitudes to only focus on Europe

ext <- c(-15,50,35,72)

# with the "crop()" function we can reduce the object snow with the values of the previously defined array called ext

snow.europe <- crop(snow,ext)

# this can now be plotted in the same way as the entire Northern Hemisphere by using the following function

ggplot() + geom_raster(snow.europe,mapping=aes(x=x,y=y,fill=Snow.Cover.Extent)) + scale_fill_viridis(option="mako")

# using the patchwork packages the two different plots (entire Northern Hemisphere or only Europe) the plots can be assigned to objects and then by adding the objects together shown next to each other

p1 <- ggplot() + geom_raster(snow,mapping=aes(x=x,y=y,fill=Snow.Cover.Extent)) + scale_fill_viridis(option="mako") + ggtitle("Snow Cover Extent 21.12.2020")

p2 <- ggplot() + geom_raster(snow.europe,mapping=aes(x=x,y=y,fill=Snow.Cover.Extent)) + scale_fill_viridis(option="mako") + ggtitle("Snow Cover Extent 21.12.2020 Europe")

p1 + p2
