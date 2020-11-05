# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: DataWrang.R
#
# Desc: A script to illustrate data-wrangling, especially wide-long conversion
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 5 Nov 2020



################################################################
################## Wrangling the Pound Hill Dataset ############
################################################################


############# Load the dataset ###############
# header = false because the raw data don't have real headers
MyData <- as.matrix(read.csv("../data/PoundHillData.csv",header = F)) 

# header = true because we do have metadata headers
MyMetaData <- read.csv("../data/PoundHillMetaData.csv",header = T, sep=";", stringsAsFactors = F)

############# Inspect the dataset ###############
head(MyData)
dim(MyData) #dimensions - 45 rows, 60 columns
str(MyData)
# fix(MyData) #you can also do this; shows as spreadsheet
# fix(MyMetaData) #metadata is data on the data

############# Transpose ###############
# To get those species into columns and treatments into rows 
MyData <- t(MyData) #transpose; swaps columns for rows
head(MyData)
dim(MyData)

############# Replace species absences with zeros ###############
MyData[MyData == ""] = 0 #swaps all blank cells for 0

############# Convert raw matrix to data frame ###############

TempData <- as.data.frame(MyData[-1,], stringsAsFactors = F) #
# From matrix to dataframe; doesn't make it string of factors (f=false)
#do it manually later (as below) so we can control; eg don't want int -> factor
#stringsAsFactors = F is important!
colnames(TempData) <- MyData[1,] # assign column names from original data



############# Convert from wide to long format  ###############
require(reshape2)
#data often recorded in wide, but long is better for analysis. Look up diff if 
#  you can't remember, or fgo to DM&V in book, convert wide...

#?melt #check out the melt function - "Convert object into a molten data frame."

MyWrangledData <- melt(TempData, id=c("Cultivation", "Block", "Plot",
"Quadrat"), variable.name = "Species", value.name = "Count")

MyWrangledData[, "Cultivation"] <- as.factor(MyWrangledData[, "Cultivation"])
MyWrangledData[, "Block"] <- as.factor(MyWrangledData[, "Block"])
MyWrangledData[, "Plot"] <- as.factor(MyWrangledData[, "Plot"])
MyWrangledData[, "Quadrat"] <- as.factor(MyWrangledData[, "Quadrat"])
MyWrangledData[, "Count"] <- as.integer(MyWrangledData[, "Count"])
fix(MyWrangledData)
str(MyWrangledData)
head(MyWrangledData)
dim(MyWrangledData)

############# Exploring the data (extend the script below)  ###############
