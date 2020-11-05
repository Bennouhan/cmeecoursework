
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: PP_Dists.R
#
# Desc: Script to produce plots of predator and prey mass and size ratio
#
# Arguments:
# -
#
# Output:
# Pred_Subplots.pdf - Predator mass subplots of different feeding interactions
# Prey_Subplots.pdf - Prey mass subplots of different feeding interactions
# SizeRatio_Subplots.pdf - Size ratio subplots of different feeding interactions
# PP_Results.csv - Mean and median log10(values) of the plotted variables 
#
# Date: 5 Nov 2020

### Load and prepare the data
mydf <- read.csv("../data/EcolArchives-E089-51-D1.csv")
# make these factors so we can use them as grouping variables
mydf$Type.of.feeding.interaction <- as.factor(mydf$Type.of.feeding.interaction)
mydf$Location <- as.factor(mydf$Location)
mydf$Size.ratio <- (mydf$Predator.mass/mydf$Prey.mass)

## NOTE TO MARKER## predator mass not clear, data seems poor. average weight for 
#  Atlantic sharpnose shark is about 4kg; mass for record numbers 3 and 4
#  are 1.84E+003 and 8.76E+001 respectively, and they were both adults.
#  either 3 was 2 tonnes or 4 was 9g, both imposible. But will use g as units.

for(row in 1:nrow(mydf)){ # converts all prey masses in mg to g
  if(mydf[row,14]=="mg"){
    mydf[row,14] <- "g"
    mydf[row,13] <- mydf[row,13]/1000
  }
}

### Make dataframe for stats input
AverageForGivenFeedingType<-c("Mean (piscivorous)", "Median (piscivorous)",
"Mean (predacious)", "Median (predacious)",
"Mean (predacious/piscivorous)", "Median (predacious/piscivorous)",
"Mean (insectivorous)", "Median (insectivorous)",
"Mean (planktivorous)", "Median (planktivorous)")
ppresults <- data.frame(AverageForGivenFeedingType)

### Subset assignment for different feeding interaction types
pisci <- subset(mydf, Type.of.feeding.interaction=='piscivorous')
preda <- subset(mydf, Type.of.feeding.interaction=='predacious')
pred_pisc <- subset(mydf, Type.of.feeding.interaction=='predacious/piscivorous')
insecti <- subset(mydf, Type.of.feeding.interaction=='insectivorous')
plankti <- subset(mydf, Type.of.feeding.interaction=='planktivorous')


plot_and_calc_var <- function(variable, unit, fname){
  ### Subplots of different feeding interaction types
  pdf(paste("../results/",fname,"_Subplots.pdf"), 8.3, 11.7)
  par(mfcol=c(3,2))
  par(mfg = c(1,1))
  hist(log10(pisci[,variable]),
      xlab = paste("log10(",variable,unit,")", sep=""),
      ylab = "Count", col = "lightblue", border = "black",
      main = paste("Piscivorous",variable,"Distribution", sep=" "))
  par(mfg = c(1,2))
  hist(log10(preda[,variable]),
      xlab = paste("log10(",variable,unit,")", sep=""),
      ylab = "Count", col = "red", border = "black",
      main = paste("Predacious",variable,"Distribution", sep=" "))
  par(mfg = c(2,1))
  hist(log10(pred_pisc[,variable]),
      xlab = paste("log10(",variable,unit,")", sep=""),
      ylab = "Count", col = "purple", border = "black",
      main = paste("Predacious/Piscivorous",variable,"Distribution", sep=" "))
  par(mfg = c(2,2))
  hist(log10(insecti[,variable]),
      xlab = paste("log10(",variable,unit,")", sep=""),
      ylab = "Count", col = "orange", border = "black",
      main = paste("Insectivorous",variable,"Distribution", sep=" "))
  par(mfg = c(3,1))
  hist(log10(plankti[,variable]),
      xlab = paste("log10(",variable,unit,")", sep=""),
      ylab = "Count", col = "lightgreen", border = "black",
      main = paste("Planktivorous",variable,"Distribution", sep=" "))
  graphics.off(); 
  ### Mean and Median
  ppresults[,paste("log10(",variable,")", sep="")] <-
  c(mean(log(pisci[,variable])),median(log(pisci[,variable])),
  mean(log(preda[,variable])),median(log(preda[,variable])),
  mean(log(pred_pisc[,variable])),median(log(pred_pisc[,variable])),
  mean(log(insecti[,variable])),median(log(insecti[,variable])),
  mean(log(plankti[,variable])),median(log(plankti[,variable])))
  return(ppresults)
} #could hugely condense with a nested function but don't have the time rn

### Call function on pred mass, prey mass, and size ratio, write into csv
ppresults <- plot_and_calc_var("Predator.mass", " (g)", "Pred")
ppresults <- plot_and_calc_var("Prey.mass", " (g)", "Prey")
ppresults <- plot_and_calc_var("Size.ratio","", "SizeRatio")
write.csv(ppresults, "../results/PP_Results.csv")