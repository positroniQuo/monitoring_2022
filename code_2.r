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

