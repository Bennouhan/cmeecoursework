# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: PP_Regress.R
#
# Desc: Visualises linear regression of predator mass vs prey mass by lifestage
#
# Arguments:
# -
#
# Output:
# PP_Regress_Results.pdf - Linear regression plot by lifestage and interaction
# PP_Regress_Results.csv - Statistical values of the plotted regressions
#
# Date: 6 Nov 2020

rm(list = ls())

library(dplyr)
library(ggplot2)
library(tidyverse)
library(broom)

### Load and prepare the data
mydf <- read.csv("../data/EcolArchives-E089-51-D1.csv")
# removes rows resulting in Nas and NaNs
dim(mydf)
mydf <- mydf[-c(30914, 30929, 277, 321),]
dim(mydf)
# make these factors so we can use them as grouping variables
mydf$Type.of.feeding.interaction <- as.factor(mydf$Type.of.feeding.interaction)
mydf$Predator.lifestage <- as.factor(mydf$Predator.lifestage)
# converts all prey masses in mg to g
for(row in 1:nrow(mydf)){
  if(mydf[row,14]=="mg"){
    mydf[row,14] <- "g"
    mydf[row,13] <- mydf[row,13]/1000
  }
}

### Create the Linear Regression plots as pdf
p <-  qplot(Prey.mass, Predator.mass, data = mydf, log="xy",
            xlab = "Prey Mass (g)", ylab = "Predator Mass (g)",
            colour = Predator.lifestage, shape = I(3)) + theme_bw() 
# Add regression lines and faceting by feeding interaction type
p <-  p + geom_smooth(method = "lm", fullrange=TRUE) + 
      facet_grid(Type.of.feeding.interaction ~ .)
# Formatting legend position, text, colours and line number
p <-  p + theme(legend.position = "bottom",
            panel.border = element_rect(colour = "grey")) +
          theme(legend.title = element_text(size = 10, face = "bold")) +
          guides(colour = guide_legend(nrow = 1))
# Write to pdf file in results/
pdf("../results/PP_Regress_Results.pdf", 8.3, 11.7)
print(p); graphics.off();


### Calculate statistics for the table and write csv
pp_regress <- mydf %>%
  # Select and group by interaction type and lifestage
  select( Type.of.feeding.interaction, Predator.lifestage,
          Predator.mass, Prey.mass) %>%
  group_by(Type.of.feeding.interaction, Predator.lifestage) %>%
  # Fit linear models for each in group
  do(mod = lm(log(Predator.mass)~log(Prey.mass), data = .)) %>%
  # Take each statistic from summary and write into data frame
  mutate( Regression_Slope = summary(mod)$coeff[2],
          Regression_Intercept = summary(mod)$coeff[1],
          R_Squared = summary(mod)$adj.r.squared,
          F_Statistic = summary(mod)$fstatistic[1],
          p_Value = summary(mod)$coeff[8]) %>%
  # Remove unwanted column, round numericals to 3dp, and write into csv
  select(-mod)
  pp_regress[,3:7]<-round(pp_regress[,3:7], 3)
  write.csv(pp_regress, "../results/PP_Regress_Results.csv")