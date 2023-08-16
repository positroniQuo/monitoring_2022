# call for ggplot2 package (previously downloaded)

library(ggplot2)

# let's build a database with some numbers, for example on covid 19. "virus" represent the cases and death numbers are represented in "death"

virus <- c(10, 30, 40, 50, 60, 80) 
death <- c(100, 240, 310, 470, 580, 690)

# doing a simple plot

plot(virus, death)

# to link together the two separate data sets we can utilize the "data.frame()" function.
# assigning it to a variable makes it possible to call for it whenever needed

corona <- data.frame(virus, death)

# basic statistics of the data collected

summary(corona)

# ggplot provides an alternative mean to make graphics with more in depth customization options
# corona is the selected data set, of which we want to plot "virus" in the x axix and "death" in the y
# "geom_ point()" adds a geometric paramether for the graphic to show the data, points in this case

ggplot(corona, aes(x = virus, y = death)) + geom_point() 

# "geom_point()" also contains further aesthetics arguments such as in here

ggplot(corona, aes(x = virus, y = death)) + geom_point(size = 2,  col = "red", pch = 13) 

# there are other geometry options such as "geom_line()" and "geom_polygon()", also you can combine them together using simply +

ggplot(corona, aes(x = virus, y = death)) + geom_line()
ggplot(corona, aes(x = virus, y = death)) + geom_polygon()
ggplot(corona, aes(x = virus, y = death)) + geom_point + geom_line + geom_polygon()

# as we will move on real data sets now a package called "spatstat" is called for spatial statistics analysis

library(spatstat) 

# setting a working directory is fundamental for saving the outputs of our work and
# to call in for additional data that we will put there first

setwd("D:\Uni\Progetti_R\Lezioni")

# now a dataset previously downloaded and put in the right folder will be accessed through "read.table()" function
# "header = T" makes the first row of data's values the names of the columns, since the data has stored them this way

covid <- read.table("covid_agg.csv", header = TRUE)

#checking for errors and such

covid

summary(covid)

# "head()" returns only the first lines

head(covid)

# plotting the coordinates of the points in which data was collected

ggplot(covid, aes(x = lon, y = lat)) + geom_point()

# we can make it so that the points grow in size depending on the number of cases corresponding to a set of coordinates

ggplot(covid, aes(x = lon, y = lat, size = cases)) + geom_point()

# let's visualize covid cases' density
# "ppp()" function comes from the spatstat package and creates a planar point pattern, which explains to R that we are working 
# on a geographical lattice (lat and lon) as well as explain the extent

covid_planar <- ppp(covid$lon, covid$lat, c(-180, 180), c(-90, 90))

plot(covid_planar)

# to get the density now we will just use the "density()" function

density_map <- density(covid_planar)

plot(density_map)

# adding the points from the previous map (the two graphics are stackable)

points(covid_planar, pch = 19)

# making a color palette as ugly as possible to visualize the density

colors <- colorRampPalette(c('blue2', 'blue4', 'cadetblue1', 'brown4', 'brown1', 'green4', 'green1'))(100)

plot(density_map, col = colors)

# adding points again

points(covid_planar, pch = 5, )

# to obtain a map with countries as a background we first of all call for the "rgdal" package

library(rgdal)

# now we can use a shapefile (vector) of the coastlines prophile as a spatial object with the "readOGR()" function

coastlines <- readOGR("ne_10m_coastline.shp")

# putting it all together now

plot(density_map, col = color)  

points(covid_planar, pch = 1, col = 'blue', cex = 0.8) 

plot(coastlines, add = TRUE) 

# save it as a png
# firt you specify that you are doing it, then build the graph and finally save it with "dev.off()"

png("cov_density.png")

plot(density_map, col = color) 

points(covid_planar, pch = 16, col = 'black', cex = 1)

plot(coastlines, add = TRUE) 

dev.off()

# same bu this time with pdf

pdf("cov_density_countries.pdf")

plot(density_map, col = color) 

points(covid_planar, pch = 4, col = 'black', cex = 1)

plot(coastlines, add = TRUE) 

dev.off()

### interpolate case data '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# but these maps simply show the density based on the points, obviously in Europe there is 
# a high country density = highest density of points
# however the parameter abundance is much more informative, as it actually interpolates the number of cases

# 3rd we can do this using the function ~marks(), which assigns data to the points given in covid_planar
attach(covid)
marks(covid_planar) <- cases  # cases is the name of the relevant variable in the original array covid,
# which we attach here, as covid_planar is simply a list of points

# using the function ~Smooth it interpolates the point data given in covid_planar and assigns it the new name map_cases
map_cases <- Smooth(covid_planar)
                    
# to plot this map we use function ~plot
plot(map_cases, col = c2) 
points(covid_planar, pch = 19) # add points
plot(coastlines, add = T) # adds coastlines    
                    
# next we download the package sf
install.packages("sf") # used for spatial vector data
library(sf)

# use function ~st_as_st() to convert the covid object to an sf object(extends data.frame-like objects with a simple feature list column) 
s_points <- st_as_sf(covid, coords = c("lon", "lat"))

# create a new color palette
c1 <- colorRampPalette(c("antiquewhite4", "aquamarine4", "darkslategray", "coral4", "firebrick3"))(100)
plot(map_cases, col = c1) # plot the smoothed case map
plot(s_points, cex = s_points$cases/10000, col = "purple4", lwd = 3, add = T) 
# add circles around the countries with high case numbers, depending on their absolute value

# now we add on the coastlines to the smoothed map above
coastlines <- readOGR("ne_10m_coastline.shp")
plot(coastlines, add = T)
