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

### loads & summarises the data frame "ats" from the below file in data/
load("../data/KeyWestAnnualMeanTemperature.RData"); print(str(ats))

### plots data, writes to a pdf in results/
pdf("../data/ACC_Data.pdf")#to data so available for .tex file; would be results
par(mfcol=c(2,1))
par(mfg = c(1,1))
plot(ats$Year, ats$Temp, pch = 19, col = "darkred", cex = 0.6,
    xlab = "Year", ylab = "Mean Temp (°C)")
par(mfg = c(2,1))
plot(ats$Temp[1:99], ats$Temp[2:100], pch = 19, col = "darkblue", cex = 0.6,
    xlab = "Mean Temp in Year 'n' (°C)", ylab = "Mean Temp in Year 'n+1' (°C)")
graphics.off();


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
#   stronger than abs(acc_ats), ie the approx p-value from first principles, 
#   and writes a pdf plotting the histogram of acc_vect 
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
sapp_acc_perm <- function(Tyear_ordered, num_calcs, acc){
    acc_vect <- sapply(1:num_calcs, function(i) acc_perm(Tyear_ordered))
    pdf("../data/ACC_Hist.pdf") #to data so available for .tex file
    hist(acc_vect,xlab="Randomised ACC Values", main="")
    abline(v=acc, col="black", lty=3); graphics.off();
    return( p_value <- sum(acc_vect > abs(acc_ats)) / num_calcs )
    # abs(acc_ats) alows it to work with negative correlations & be 1-tailed
    # expected no. < -acc_ats == expected no. > +acc_ats so this works
}
#should it be 2-tailed tho? question is "signif. correlated", doesn't
#specify if positive or negative, but was said in Q&A just 1-tailed

### Runs sapp_acc_perm with 10000 as num_calc, prints off explanatory statement
cat("The approximate p-value is", sapp_acc_perm(ats$Temp,100000,acc_ats), "\n")
# add more zeros for a more precise p-value; will asymptote on true p-value
