# code for environmental analysis

# "install.packages()" installs r add ons, using "" to specify the requested package since "" must be used to refer to files outside the r environment

install.packages("sp")

# once downloaded, a package is called into the session and rendered usable through "library()" or "require()"

library(sp)

# "sp", as many other packages, contains a dataset that you can use to do excercise with it

data(meuse)

# "meuse" is the measurements of 4 heavy metals in top soil based in Northern Europe
# to see inside a dataset you can easily type the name of it or use "view()", or "head()" to see just the tip of it

meuse 

View(meuse) 
head(meuse) 

# a fourth option is "names()", which returns the columns' names

names(meuse) 

# if mean values are required we can use "summary()" to find it

summary(meuse)

# need to plot together cadmium and zinc values. it can be done calling for the column name from dataset such as "meuse$cadmium",
# but also from the position of the column: 3d column will be selected writing "meuse[,3]"
plot(meuse[,3], meuse[,6])  

dev.off() # closes the plot

# two more alternatives: assigning the column to a variable to call or attaching the dataset to call for the col. names directly

attach(meuse)

plot(cadmium, zinc) # such as in here

# creating a scatterplot matrice to plot all variables

pairs(meuse)

# if i want to only use the env. variables for the plot (excluding firt two columns)

pairs(meuse[,3:6])

# or in a more uncofortable way

pairs(~ cadmium + copper + lead + zinc, data=meuse) 

# we can play around with colours, symbols and such whwn doing graphs

pairs(~ cadmium + copper + lead + zinc, data=meuse, col="red", pch=17, cex=3) 
