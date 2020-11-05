# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: TAutoCorr.R
#
# Desc: Determines if the annual mean temperatures in a given location one year
#       is significantly correlated with the next (successive years)
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
load("../data/KeyWestAnnualMeanTemperature.RData"); plot(ats); print(str(ats))

### Calculates temperature autocorrelation coefficient (ACC) for ats data
acc_ats <- cor(ats$Temp[1:99], ats$Temp[2:100], method="pearson")

### Calculates ACC for ats data with random permutation of ats$Temp 
#
#
# ARGUMENTS
#
# Tyear_ordered: Vector of Temperatures (or other numerical variables), ordered 
#                by year measured, of which to find autocorrelation coefficient
#
#
# RETURN
#
# [ACC]:         Returns the auto-correlation coefficient of the argument
#
acc_perm <- function(Tyear_ordered){
    T_reordered <- sample(Tyear_ordered, length(Tyear_ordered), replace = FALSE)
    return( cor(T_reordered[1:99], T_reordered[2:100], method="pearson") )
}

### Runs "num_calc" interations of acc_perm, finds fraction of resultant ACCs
#   stronger than abs(acc_ats), ie the approx p-value from first principles
#
# ARGUMENTS
#
#
# Tyear_ordered: Vector of Temperatures (or other numerical variables) ordered 
#                by year they were measured, to find autocorrelation coefficient
#                and approximate p-value for. Feeds into acc_perm
# num_calcs:     Number of iterations of acc_perm run
#
#
# RETURN 
#
# p_value:       Returns the p_value for the auto-correlation coefficient of
#                Tyear_ordered, based on "num_calcs" iterations
#
sapp_acc_perm <- function(Tyear_ordered, num_calcs){
    acc_vect <- sapply(1:num_calcs, function(i) acc_perm(Tyear_ordered))
    return( p_value <- sum(acc_vect > abs(acc_ats)) / num_calcs )
    # abs(acc_ats) alows it to work with negative correlations & be 1-tailed
    # expected no. < -acc_ats == expected no. > +acc_ats so this works
}
#should it be 2-tailed tho? question is "signif. correlated", doesn't
#specify if positive or negative, but was said in Q&A just 1-tailed


### Runs sapp_acc_perm with 10000 as num_calc, prints off explanatory statement
cat("The approximate p-value is", sapp_acc_perm(ats$Temp,10000000), "\n")
# add more zeros for a more precise p-value; will asymptote on true p-value

#####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#####
##### DON'T FORGET TO PRESENT THIS IN LATEX!!!!!!!!#####
##### pdf file and the .tex file it came from!!!!!!#####