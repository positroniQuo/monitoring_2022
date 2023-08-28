# Calculate vegetation indices from remote sensing

library(raster)     
library(RStoolbox)  
library(ggplot2)  
library(patchwork)  
library(viridis)

# Upload the data

setwd("D:\Uni\Progetti_R\allenamento_2") 

#Image from 1992

l1992 <- brick("defor1.png")

# Bands: 1 NIR, 2 red, 3 green

plotRGB(l1992, r=1, g=2, b=3, stretch="lin")

# Image from 2006

l2006 <- brick("defor2.png")

plotRGB(l2006, r=1, g=2, b=3, stretch="lin")

# Create a multiframe

par(mfrow=c(2,1))

plotRGB(l1992, r=1, g=2, b=3, stretch="lin")
plotRGB(l2006, r=1, g=2, b=3, stretch="lin")

# Pure water completely absorbs the NIR (appears black), if there is soil it is a light colour

# Calculate the DVI of 1992:

dvi1992 <- l1992[[1]] - l1992[[2]]

cl <- colorRampPalette(c("darkblue","yellow","red","black"))(100)

plot(dvi1992, col=cl)

# Higher vegetation = higher value (red-black)

# DVI of 2006

dvi2006 <- l2006[[1]] - l2006[[2]]

cl <- colorRampPalette(c("darkblue","yellow","red","black"))(100)

plot(dvi2006, col=cl)

# Low vegetation = low color (darblue-yellow)
# Threshold for trees
# unsuperClass function: Unsupervised Classification. The software decides the threshold.
# It is possible to use the original image or the DVI
# For 1992
  # d1c: deforestation first classification

    d1c <- unsuperClass(l1992, nClasses=2)

  # To plot the map:

    plot(d1c$map)

  #freq function: generate frequency tables (how many pixel belong to each class)
    # class 1: tropical forest
    # class 2: human impact

      freq(d1c$map)

        #   value  count
        # [1,]     1 304490
        # [2,]     2 36802
  # Calculate the proportion of pixels:
    # Forest: 

      f1992 <- 304490 / (304490+36802) # = 0.8921686 (in 1992 90% of the pixel were forest)

    # Human impact

      h1992 <- 36802 / (304490+36802) # = 0.1078314

# For 2006
  # d2c: deforestation second classification

    d2c <- unsuperClass(l2006, nClasses=2)
    plot(d2c$map)

      # class 1: forest
      # class 2: human impact
# the classes are not always the same, check with the graph (class 1 has the color of the value 1, class two the color of the value 2)

    freq(d2c$map)

      #   value  count
      # [1,]     1 179154
      # [2,]     2 163572
  # Forest proportion in 2006:

    f2006 <- 179154 / (179154+163572) # =0.5227324

  # Human impact proportion in 2006:
    h2006 <- 163572 / (179154+163572) # =0.4772676

# 1992 vs. 2006
  # 1992
    # forest: 0.8921686
    # human impact: 0.1078314
  # 2006
    # forest: 0.5227324
    # human impact: 0.4772676
# Build a dataframe

landcover <- c("forest", "humans")

percent_1992 <- c(89.22, 10.78)
percent_2006 <- c(52.27, 47.76)

# Specify the columns of the dataframe:

perc <- data.frame(landcover, percent_1992, percent_2006)


# To create the histogram: ggplot function. Syntax ggplot(name of the object used as a table, aes(x= , y= , color= ) 
  # aes = aesthetics 
  # + to add single pieces
  # geom_bar = histogram
  # identity = identical to the percentage values
# To put it in a multiframe use the patchwork library

p1 <- ggplot(perc, aes(x=landcover, y=percent_1992, color=landcover)) + 
geom_bar(stat="identity", fill="light green")

p2 <- ggplot(perc, aes(x=landcover, y=percent_2006, color=landcover)) + 
geom_bar(stat="identity", fill="light green")

# To put one plot beside the other

p1 + p2

# To put one plot on top of the other

p1 / p2 



# ggplot examples
# using defor1
# Plot RGB (band 1 = NIR

plotRGB(l1992, r=1, g=2, b=3, stretch="lin")

ggRGB(l1992, 1, 2, 3)   # same result, but more simple!

# Plot the DVI

dvi1992 <- l1992[[1]] - l1992[[2]]

plot(dvi1992)

ggplot() +
geom_raster(dvi1992, mapping=aes(x=x, y=y, fill=layer)) +       
scale_fill_viridis(option="viridis")                         

# Example for other colors

ggplot() +
geom_raster(dvi1992, mapping=aes(x=x, y=y, fill=layer)) +        
scale_fill_viridis(option="magma")      

# Exercise: with patchwork package, put two graphs one beside the other with two different viridis coloramps

p1 <- ggplot() +
geom_raster(dvi1992, mapping=aes(x=x, y=y, fill=layer)) +         
scale_fill_viridis(option="mako") 

# + ggtitle("") to add a title

p2 <- ggplot() +
geom_raster(dvi1992, mapping=aes(x=x, y=y, fill=layer)) +        
scale_fill_viridis(option="plasma")  

p1 + p2
