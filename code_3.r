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

### let's see the density of the coronavirus cases - Point pattern analysis
# use function ~ppp() from the spatstat package to create a planar point pattern, which explains to R that we are working 
# on a geographical lattice (lat and lon) as well as explain the extent  
attach(covid) # let's first attach the dataset to make sepcification easier (don't need $ to specify column names lat, lon etc.)
covid_planar <- ppp(lon, lat, c(-180, 180), c(-90, 90)) # lon and lat are x and y, 
# function ~c() is used to tell R the range to be used in the form of an array
plot(covid_planar) # take a look at the ppp object created 

# to now print a density map of the case numbers by country use function ~density()
density_map <- density(covid_planar)

plot(density_map) # simply plot the density of cases calculated above (plot overrides previous function/map)
points(covid_planar, pch = 19) # add the points of the cases for each country (points adds object to the previous function/map)

# to visually change the map create a list/legend of colors using function ~colorRampPalette(c()) over a 100 step gradient (?)
colors <- colorRampPalette(c('blue4', 'cadetblue4', 'darkgoldenrod2', 'tan2', 'sienna3', 'firebrick4', 'violetred4', 'purple4'))(100)
plot(density_map, col = colors) # now specify the color by setting col = the list created above
points(covid_planar, pch = 5, ) # add the points of cases for each country

# next we want to add the countries to the map
# install and activate necessary packages
install.packages("rgdal")
library(rgdal)

# after downloading the folder ne 10m coastline, open it using function ~readOGR, which reads a vector map into a spatial object
coastlines <- readOGR("ne_10m_coastline.shp")

# now to combine the density map and the country borders we create a new color gradient, plot the density map and 
# insert the points from covid_planar as well as the coastlines
cl <- colorRampPalette(c('lightskyblue4','chartreuse4','goldenrod3','lightsalmon3','sienna4'))(100)
plot(density_map, col = cl)  # plot the density map
points(covid_planar, pch = 1, col = 'blue', cex = 0.8) # add the points
plot(coastlines, add = TRUE) # add the coastline

# if we want to download this map we can for example do it in png as well as pdf format by using function ~png("") or pdf("")
png("cov_density_countries.png")
c2 <- colorRampPalette(c('steelblue','slategray','seashell2','rosybrown','navajowhite4'))(100)
plot(density_map, col = c2) 
points(covid_planar, pch = 16, col = 'black', cex = 1)
plot(coastlines, add = TRUE) 
dev.off() # closes the window with the map

pdf("cov_density_countries.pdf")
c3 <- colorRampPalette(c('mistyrose3','pink4','violetred','red4','indianred'))(100)  
plot(density_map, col = c3) 
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
