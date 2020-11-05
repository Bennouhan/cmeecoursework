
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: TreeHeight.R
#
# Desc: Imports data frame, adds 4th column, uses colmumn 2&3 to calc 4th colum
#
# Arguments:
# -
#
# Output:
# ../results/TreeHts.csv
#
# Date: 21 Oct 2020



### This function calculates heights of trees given distance of each tree 
# from its base and angle to its top, using  the trigonometric formula 
#
# height = distance * tan(radians)
#
#
# ARGUMENTS
#
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
#
#
# RETURN
#
# height:    The heights of the tree, same units as "distance"
#
TreeHeight <- function(degrees, distance){
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return (height)
}

MyData <- read.csv("../data/trees.csv", header = TRUE) # import with headers
MyData["Tree.Height.m"] <- NA
#adds Height.m column, with NA as data

for(i in 1:nrow(MyData)) {
    MyData[i,4] <- TreeHeight(MyData[i,3], MyData[i,2])
}

write.csv(MyData, "../results/TreeHts.csv")