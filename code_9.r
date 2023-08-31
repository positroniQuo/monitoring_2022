# R code for species distribution modelling: modeling the potential distribution of species given environmental conditions

library(sdm) 
library(raster) 
library(rgdal)

file <- system.file("external/species.shp", package="sdm") 

# the system.file function finds the full file names of files in packages etc.
# external is the folder of the smd package containig the species.shp file

file

# translate the path into a file 

 species <- shapefile(file)

# the shapefile function reads or writes a shapefile
# shapefile: simple, nontopological format for storing the geometric location and attribute information of geographic features. 
# geographic features in a shapefile can be represented by points, lines, or polygons (areas).
      
# looking at the set

species

#plot

plot(species)

# Subset
# looking at all the occurrences

species$Occurrence

# Subset only those points meaning presence (1)

presences <- species[species$Occurrence == 1,]

absences <- species[species$Occurrence == 0,]

plot(presences, col = "blue", pch = 19)

# adding points to the plot

points(absences, col = "red", pch = 19)

# Upload the environmental conditions (predictors)

path <- system.file("external", package = "sdm")

# path to the external folder
# in the folder the predicors are stored with .asc 
# list the predictors (explanatory variables)

lst <- list.files(path = path, pattern = "asc$", full.names = T)

  # the list.files function produces a character vector of the names of files or directories in the named directory  

lst

# Create a RasterStack object

preds <- stack(lst)

  # this creates a RasterStack project with four layers

# Plot preds

cl <- colorRampPalette(c('blue','orange','red','yellow')) (100)

plot(preds, col=cl)

# Plot the different predictors and occurences
# Elevation

plot(preds$elevation, col=cl)

points(species[species$Occurrence == 1,], pch=16)

# Temperature

plot(preds$temperature, col=cl)

points(species[species$Occurrence == 1,], pch=16)

# Precipitation

plot(preds$precipitation, col=cl)

points(species[species$Occurrence == 1,], pch=16)

# Vegetation

plot(preds$vegetation, col=cl)

points(species[species$Occurrence == 1,], pch=16)

# Create the species distribution model
  # set the data for the sdm

datasdm <- sdmData(train = species, predictors = preds)

# sdmData function: creates a sdmdata objects that holds species (single or multiple) and explanatory variates.

# model

m1 <- sdm(Occurrence ~ elevation + precipitation + temperature + vegetation, data = datasdm, methods = "glm")

# sdm function: fit and evaluate species distribution models
# create the logistic model for all the variables together
# Occurrence (y)
# ~: =
# data: a sdmdata object created using sdmData function
# methods: glm (generalized lineard method)
# make the raster output layer

p1 <- predict(m1, newdata = preds)

  # predict function: predict the spread of the speices based on the model and the data

# plot the output

plot(p1, col=cl)

  # predicts the prediction of spread of the species

points(presences)

# add to the stack

s1 <- stack(preds,p1)

plot(s1, col=cl)

# Change the names in the plot of the stack:

names(s1) <- c("elevation", "precipitation", "temperature", "vegetation", "model")
