# monitoring the ice cover in greenland

library(raster)
library(ggplot2)
library(RStoolbox)
library(patchwork)
library(viridis)

setwd("D:\Uni\Progetti_R\allenamento_2")

# listing the downloaded files

rlist <- list.files(pattern = "lst")

import <- lapply(rlist, raster)

# stacking them as a single element

tgr <- stack (import)

# let's take a look at the result

cl <- colorRampPalette(c('blue2', 'blue4', 'cadetblue1', 'brown4'))(100)

plot(tgr, col = cl)

# ggplot the first and last images: 2000 vs 2015
# 2000

p1 <- ggplot() + 
geom_raster (tgr$lst_2000, mapping=aes(x=x, y=y, fill=lst_2000 )) + 
scale_fill_viridis( option = "magma") + ggtitle ("LST in 2000")

# 2015

p2 <- ggplot() + 
geom_raster (tgr$lst_2015, mapping=aes(x=x, y=y, fill=lst_2015 )) + 
scale_fill_viridis( option = "magma") + ggtitle ("LST in 2015")

# plotting the frequency distribution using an histogram

par(mfrow=c(1,2))
hist(tgr$lst_2000)
hist(tgr$lst_2015)  

# all of them

par(mfrow=c(2,2))
hist(tgr$lst_2000)
hist(tgr$lst_2005)
hist(tgr$lst_2010)
hist(tgr$lst_2015)

plot(tgr$lst_2010, tgr$lst_2015, xlim=c(12500, 15000), ylim=c(12500, 15000))
abline(0, 1, col="red")

# make a plot with all the histograms and regressions for all the data

par(mfrow=c(3,4))
hist(tgr$lst_2000)
hist(tgr$lst_2005)
hist(tgr$lst_2010)
hist(tgr$lst_2015)
plot(tgr$lst_2010, tgr$lst_2015, xlim=c(12500, 15000), ylim=c(12500, 15000))
plot(tgr$lst_2005, tgr$lst_2015, xlim=c(12500, 15000), ylim=c(12500, 15000))
plot(tgr$lst_2000, tgr$lst_2015, xlim=c(12500, 15000), ylim=c(12500, 15000))
plot(tgr$lst_2010, tgr$lst_2005, xlim=c(12500, 15000), ylim=c(12500, 15000))
plot(tgr$lst_2000, tgr$lst_2005, xlim=c(12500, 15000), ylim=c(12500, 15000))
plot(tgr$lst_2010, tgr$lst_2000, xlim=c(12500, 15000), ylim=c(12500, 15000))

# or do the same with the pairs() function

pairs(tgr)

