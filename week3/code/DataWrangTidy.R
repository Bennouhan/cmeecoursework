# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: DataWrangTidy.R
#
# Desc: A script to illustrate data-wrangling; as DataWrang.r but with tidyverse
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 5 Nov 2020

require(tidyverse)

############ Load the dataset ###############

MyData <- read_csv("../data/PoundHillData.csv", col_names=FALSE) #already tibble
MyMetaData <- read_delim("../data/PoundHillMetaData.csv", col_names=FALSE, delim=";")
#stringsAsFactors = F not needed; default. if not comma delim (csv) or tab delim
#(tsv), do read_delim and give the delim as above

############# Inspect the dataset ###############

dim(MyData) #dimensions - still best option for return, altho stated in glimpse
glimpse(MyData) #tidyverse equiv of str()
dplyr::filter(MyData) #dplyr needed due to overlap with stats package

############# Transpose ###############
# To get those species into columns and treatments into rows 

MyData %>% #%>% is a pipe, pipes it to next function
    rownames_to_column() %>%
    pivot_longer(-rowname, 'row.names', 'value') %>%
    pivot_wider(row.names, rowname) -> MyData

############# Replace species absences with zeros ###############

#done as part of pivot_longer

############# Set Column names ###############

colnames(MyData) <- MyData[1,] # assign column names from original data
#1st row removed along with first column with "Xn"s below

############# Convert from wide to long format  ###############

cols2retain <- c("Cultivation", "Block", "Plot", "Quadrat")
#list of cols to not aggregate
MyWrangledData <- MyData[-1,-1] %>% pivot_longer(cols=!all_of(cols2retain),
names_to = "Species", values_to = "Count", values_drop_na = TRUE)
#[-1] removes first column of X1 etc; merges all columns and values as above
MyWrangledData <- arrange(MyWrangledData, Species) #arranged by sepcies


MyWrangledData$Cultivation <- as.factor(MyWrangledData$Cultivation)
MyWrangledData$Block <- as.factor(MyWrangledData$Block)
MyWrangledData$Plot <- as.factor(MyWrangledData$Plot)
MyWrangledData$Quadrat <- as.factor(MyWrangledData$Quadrat)
MyWrangledData$Count <- as.integer(MyWrangledData$Count)
#does species not need to be made factor? wasn't in other)

str(MyWrangledData)
head(MyWrangledData)
dim(MyWrangledData)
#fix(MyWrangledData)

############# Exploring the data (extend the script below)  ###############
