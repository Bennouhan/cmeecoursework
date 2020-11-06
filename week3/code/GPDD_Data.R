
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: GPDD_Data.R
#
# Desc: Creates world map and superimposes locations held in data frame
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 5 Nov 2020

rm(list = ls())

library(maps)

### Loads data
load("../data/GPDDFiltered.RData")


### Create world map, plots the points from gpdd onto it
map(database = "world", ylim = c(-90, 90), fill = TRUE,
#   Region              y-coord range      fills polygons
    col = "darkgreen", border = "white", bg = "navyblue")
#   polygon colour     border colour     background colour
points(x = gpdd$long, y = gpdd$lat, #feed in coords from df
       col = "brown", pch = 4, cex = 0.4, lwd = 1)
#      colour       , type   , size     , line weighting

###
# Data are concentrated almost exclusively on the US west coast, Canada and
#   Great Britain. This suggests the data borrows heavily from studies by
#   labs based in these regions, with a few others arbitrarily thrown in.
# Studies using this data will not be representative of the whole world, and 
#   should really only be performed in localised areas with relevent data only.