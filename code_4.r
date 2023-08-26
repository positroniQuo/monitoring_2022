# setting a working directory in my pc for this code
setwd("D:\Uni\Progetti_R")

# package for environmental analysis'
library(vegan)

# to import a complete r project the "load()" function is required. The project needs to be located in the wd
# the following data contains two tables: biomes.cv and biometypes.cv
load("biomes_multivar.RData") 

# "decorana()" (detrended correspondence analysis) is the function for multivariate analysis that we will use
# this simplifies the data by creating new data dimensions in a matrix, just like in a PCA
multivar <- decorana(biomes) 
# to show the properties of the matrix
multivar 

# Call:
# decorana(veg = biomes) 

# Detrended correspondence analysis with 26 segments.
# Rescaling of axes with 4 iterations.

#                   DCA1   DCA2    DCA3    DCA4
# Eigenvalues     0.5117 0.3036 0.12125 0.14267     # so the first DCA explains 51% and the second 30%, 
# these two dimensions already explain >80% of the data, much easier to interpret than all 26 dimensions
# Decorana values 0.5360 0.2869 0.08136 0.04814
# Axis lengths    3.7004 3.1166 1.30055 1.47888

plot(multivar) # use function ~plot() to visualize the matrix created by decorana in a plot showing the first two axis DCA1 and DCA2

# "attach()" calls for the biome types contained in the second table and "ordiellipse()" adds a circle around points of the same biome,
# and specify the table they belong to. "kind = ehull" makes a specific shape of ellipse, lwd is the line width
attach(biomes_types)
ordiellipse(multivar, type, col = c("brown4", "green4", "azureblue4", "yellow4"), kind = "ehull", lwd = 2)

# now use function ~ordispider()  to attach the labels to the circles in a net form (like a spider :D)
attach(biomes_types)
ordispider(multivar, type, col = c("dodgerblue4", "deeppink3", "darkseagreen4", "mediumpurple2"), label = T)

# to save the plot in a pdf format use function ~pdf("")
pdf("multivar.pdf")
plot(multivar)
ordiellipse(multivar, type, col = c("dodgerblue4", "deeppink3", "darkseagreen4", "mediumpurple2"), kind = "ehull", lwd = 2)
ordispider(multivar, type, col = c("dodgerblue4", "deeppink3", "darkseagreen4", "mediumpurple2"), label = T)
dev.off()
