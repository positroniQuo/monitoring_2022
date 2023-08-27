# R code for remote sensing data analysis in ecosystem monitoring
# we're gonna need the raster package

library(raster)

setwd("C:/lab/")

# the data we are using is a stack of several layers so to import this kind of data, we use the function brick("") to form a raster brick
# we take the function and are now assigning it to an object

p224r63_2011 <- brick("p224r63_2011_masked.grd")

# the kind of data we are using is RasterBrick- it is basically bands one on top of the other
# resolution explains the size of each pixel, here it is 30m by 30m
# crs explains coordinates

p224r63_2011 

# plotting the bands

plot(p224r63_2011)

cl <- colorRampPalette(c("green", "brown", "yellow")) (150)

plot(p224r63_2011, col=cl)

# to plot a single band there a re multiple options

# 1

plot(p224r63_2011$B1_sre, col=cl) 

# 2

plot(p224r63_2011[[1]], col=cl)

# multiframing images specifying the dimentions of the desired grid

par(mfrow=c(1,2))

plot(p224r63_2011[[1]], col=cl)
plot(p224r63_2011[[2]], col=cl)

# now with 4 bands

par(mfrow=c(2,2))

plot(p224r63_2011[[1]], col=cl)
plot(p224r63_2011[[2]], col=cl)
plot(p224r63_2011[[3]], col=cl)
plot(p224r63_2011[[4]], col=cl)

# putting 1988 data into the equation

p224r63_1988 <- brick("p224r63_1988_masked.grd")

p224r63_1988

#everything fine with the import
# to see the image in "real colors" we can use "plotRGB()" assigning each respective band to its matching color (Red, Green, Blue)

plotRGB(p224r63_1988, r=3, g=2, b=1, stretch="lin")

# this can be done even if the color of the bands doesen't match
# we can also use the ir band

plotRGB(p224r63_1988, r=4, g=3, b=2, stretch="lin")

plotRGB(p224r63_1988, r=3, g=4, b=2, stretch="lin")

# let's compare the 1988 and 2011 images one alongside the other

par(mfrow=c(2,1))

plotRGB(p224r63_1988, r=3, g=2, b=4, stretch="lin")
plotRGB(p224r63_2011, r=3, g=2, b=4, stretch="lin")

# Multi-temporal analysis
# basically comparing one layer/band= color band of information from one year to another
# difference in the reflectance can help us understand the situation better
# for eg: if reflectance from some point in year 1988 (assumed) is reduced, it means that the tree has been cut- deforestation
# calculating the difference between images 
# difference in the near-infrared = difnir 

difnir <- p224r63_1988[[4]] - p224r63_2011[[4]]  

plot(difnir, col=cl)

# DVI= Difference Vegetation Index (based on 2 bands- red and near infra-red)
# red is being absorbed for photosythesis while near infrared is being reflected maximum
# usually the difference between the two in a healthy plant would be higher
# if the plant is suffering, the value of red will increase and the value of infrared would decrease

# let's calculate the DVI for 2011 and 1988

dvi2011 <- p224r63_2011[[4]]- p224r63_2011[[3]]

plot(dvi2011)

dvi1988 <- p224r63_1988[[4]]- p224r63_1988[[3]]

plot(dvi1988)

# plot the difference between the dvi of both years
# if DVI is lower, that implies the vegetation is not healthy or is cut

difdvi <- dvi1988-dvi2011

plot(difdvi, col=cl)
