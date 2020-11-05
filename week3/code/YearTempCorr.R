# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: YearTempCorr.R
#
# Desc: Determines if year and annual mean temperature in a given location are
#       significantly correlated over a given period (Just done for fun)  
#       
# Arguments:
# -
#
# Output:
# -
#
# Date: 27 Oct 2020

rm(list= ls())

### loads, summarises & plots the data frame "ats" from the below file in data/
load("../data/KeyWestAnnualMeanTemperature.RData")
summary(ats)
plot(ats)

### Calculates PCC for ats data
pcc_ats <- cor(ats$Year, ats$Temp, method="pearson")

### Calculates PCC for ats data with random permutation of ats$Year 
pcc_perm <- function(year_ordered){
    year_perm <- sample(year_ordered, length(year_ordered), replace = FALSE)
    return(cor(year_perm, ats$Temp, method="pearson"))
}

### Runs "num_calc" interations of pcc_perm, finds fraction of resultant PCCs
#   stronger than abs(pcc_ats), ie the approx p-value from first principles
sapp_pcc_perm <- function(year_ordered, num_calcs){
    pcc_vect <- sapply(1:num_calcs, function(i) pcc_perm(year_ordered))
    p_value <- sum(pcc_vect > abs(pcc_ats)) / num_calcs
    # abs(pcc_ats) makes it work with negative coefficients
    # in a given interation, number < -pcc_ats =/= number > +pcc_ats, but
    # they're generated in exactly the same way so probability is identical
    #hist(pcc_vect) #if you want to see distribution of pccs
    return(p_value)
}

### Runs sapp_pcc_perm with 10000 as num_calc, prints off explanatory statement
cat("The approximate p-value is", sapp_pcc_perm(ats$Year,10000), "\n")