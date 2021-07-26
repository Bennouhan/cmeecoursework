
### Clear workspace, set working directory
rm(list = ls())
setwd('~/cmeecoursework/project/data/')
unlink("../results/rf_vs_admix.png")


### Import packages
library(ggplot2) #need to install - tidyverse
library(RColorBrewer)
library(forcats)
library(tidyr)
library(dplyr,warn.conflicts=F)
library(grid)
library(gridExtra,warn.conflicts=F)
library(cowplot) #needed installing
library(qwraps2) #needed installing


##### Setup

### Reads saved output dataframes and makes them equivalent
rfmix <- readRDS("../data/analysis/rfmix_output_full.rds")
admix <- readRDS("../data/analysis/admixture_output_full.rds")
admix <- admix[(admix$Pop == "ADM"),] #removes non-adm samples, admix ~ rfmix

### Sets plotting colours and their corresponding ancestry
anc_palette <- brewer.pal(3,"Set2")
pops <- c("African", "European", "Native")

### Merges them for plotting, renames columns
data <- cbind.data.frame(admix, rfmix[,4:6])
colnames(data)[4:9] <- c("ad_Nat","ad_Afr","ad_Eur", "rf_Nat","rf_Afr","rf_Eur")

### Plots rfmix output against admix output by ancestry
ggplot(data, aes(x=ad_Afr,y=rf_Afr, col=anc_palette[2])) + geom_point(size=.4) +
    geom_point(aes(x=ad_Eur,y=rf_Eur, col=anc_palette[3]), size=.4) +
    geom_point(aes(x=ad_Nat,y=rf_Nat, col=anc_palette[1]), size=.4) +
    ### Axis formatting
    labs(y="RFMix-assigned Ancestry Proportion", 
         x="Admixture-assigned Ancestry Proportion") +
    ylim(0,1) + xlim(0,1) +
    theme_bw() + theme(axis.title = element_text(face="bold", size=13)) +
    ### Legend formatting
    theme(legend.position="bottom",
          legend.key.size = unit(.5, "cm"),
          legend.title=element_text(size=11, face="bold.italic"), 
          legend.text=element_text(size=10, face="italic")) +
          scale_color_manual(name = "Ancestry:",
                           values = anc_palette, # messed with order above but 
                           labels = pops) + # it works out correctly coloured
          guides(color = guide_legend(override.aes = list(size = 3) ) )

### Save plot as png file
ggsave(file="../results/rf_vs_admix.png", width=7, height=7.4, units="in")
