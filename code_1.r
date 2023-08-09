# fist code of the class
# let's go over some basic commands

# first we create some data sets from imaginary observations
# let's say somebody just wanted to do a field study on beavers
# we'll pretend that this scientist sampled multiple plots in Belarus and wrote down how many beavers he found per plot

beavers <- c(7,4,8,1,8)

# to do this we used "<-" and "c()", which respectively assign something to a variable and group elements together

# now the scientist was in the mood so he also counted the number of squacco herons in the plots
# here are the results

squacc <- c(5,14,2,20,7)

# he literally cannot chill so he now wants to plot the two data sets together to visualize the combined values

plot(beavers,squacc)

# the "plot()" function unbelievably gives back a plot with the specified values

# he wants it coloured now

plot(beavers, squacc, col="brown")

# "i want it to be prettier!" ok i gotcha

plot(beavers, squacc, col="brown", pch=3)

# "bigger!"

plot(beavers, squacc, col="brown", pch=3, cex=2)

# the graph is now absolutely perfect and only needs a title

plot(pescivores, herbivores, col = "orange", pch = 18, cex = 6, main = "squacco herons per beaver")

# let's build a dataframe with our data

ecodata <- data.frame(beavers, squacc)

ecodata

# r can do simple calculations as well, like the mean number of beavers
(7+4+8+1+8)/5 # = 5.6

# most of the important statistics can be visualized easily with "summary()"

summary(ecodata) 
