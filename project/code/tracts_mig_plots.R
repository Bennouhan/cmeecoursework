##### Script to make plots of ancestry proportion over time fromm tracts output

### Clear workspace and past outputs, set working directory
rm(list = ls())
setwd('~/cmeecoursework/project/data/')
#unlink(c("../results/admix*.pdf", "../data/analysis/*admix*"))

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

### Defines function to make a single plot based on subpop eg PUR and npop (3/4)
tract_plot <- function(subpop, npop, legend=FALSE){

#subpop <- "ACB"; npop <- 3 #for debug only
    ### Import _mig data
    fpath <- paste0("analysis/bed_files/", subpop, "/output/", npop, "_pop/")
    data <- read.csv(dir(fpath, full.names=T, pattern=glob2rx("boot0*_mig")),
                    sep='\t', header=FALSE) #0 for test, will be 49^^
    ### Corrects 4_pop data by merging the 2 Eur columns
    if (npop == 4){
        data[,1] <- data[,1] + data[,4]
        data <- data[,1:3] }
    ### Initialises data frame for plotting and counts number of genertions
    n_gen <- nrow(data)
    mig_events <- data.frame(Generation=integer(0), eur=numeric(0),
                                    nat=numeric(0), afr=numeric(0))
    ### Populates migration event df with all rows which arent just 3 0s
    for (row in n_gen:1){
        if (sum(data[row,]) > 0){
            mig_events[nrow(mig_events)+1,] <- as.numeric(c(row, data[row,]))}}
    ### Adjusts mig_events to give anc proportions totalling 1 each mig gen
    for (row in 2:nrow(mig_events)){
        prev_row <- mig_events[row-1,2:4]
        adjustment <- 1-sum(mig_events[row,2:4])
        mig_events[row,2:4] <- prev_row*adjustment + mig_events[row,2:4]}
    ### Adjusts original dataset to have the full ancestry proportion data for each gen, a new column of gen numbers, and named columns
    for (row in 1:nrow(mig_events)){
        data[mig_events[row,1],] <- mig_events[row,2:4] }
    for (row in nrow(data):1){
        if (sum(data[row,])==0){
            data[row,] <- data[row+1,] }}
    data <- cbind(data, 1:nrow(data))
    colnames(data) <- c("European", "Native", "African", "Generation")
    ### Cuts ngen to a given number, if goes unnecessarily high (optional)
    max <- 23; if (n_gen > max){ data <- data[1:max,]; n_gen <- max}
    ### Pivots data longer for easy stacked barplotting
    stacked <- data %>%
    pivot_longer(!Generation, names_to="Ancestry", values_to="Proportion")
    ### Set break vectors for axis formatting
    ybreaks <- seq(0, 1, 0.05)
    ylabs <- rep("", length(ybreaks))
    ylabs[c(1,6,11,16,21)] <- ybreaks[c(1,6,11,16,21)]
    xbreaks <- seq(n_gen, 1, -1)
    xlabs <- rep("", length(xbreaks))
    xlabs[seq(2-n_gen%%2, floor((n_gen+1)/2)*2-n_gen%%2, 2)] <-
    seq(floor((n_gen+1)/2)*2-1, 1, -2)
    ### Plot chart
    p <- ggplot(data=stacked, aes(fill=Ancestry, y=Proportion, x=Generation)) +
        geom_bar(position="fill", stat="identity", width=1) + theme_bw() +
        theme(text = element_text(size=16),
              plot.title = element_text(hjust=0.5, vjust=0,
                                        face="plain", size=18)) +
        scale_y_continuous(expand=c(0,0), limits=c(0,1),
                           breaks=ybreaks, labels=ylabs) +
        scale_x_reverse(expand=c(0,0), limits=c(n_gen+.5, .5), 
                        breaks=xbreaks, labels=xlabs) +
        scale_fill_manual(values = anc_palette) + ggtitle(subpop)
    ### Removes axis titles and legend if not used for get_legend()
    if (legend==FALSE){
        p <- p + theme(legend.position="none", axis.title=element_blank())
    }
    return(p)
}
#tract_plot("PEL", 3)


### Creates vectors with population and subpopulation names, & plotting colours
pops    <- c("African", "European", "Native")
subpops <- c("PEL", "MXL", "CLM", "PUR", "ASW", "ACB")
anc_palette <- brewer.pal(3,"Set1")


##### General plot setup
### Create Legend from scratch
legend <- get_legend(tract_plot("PEL", 3, legend=TRUE)
 + guides(color = guide_legend(nrow = 1)) +
    theme(legend.position = "top",
          legend.key.size = unit(0.5, "cm"),
          legend.title=element_text(size=11, face="bold.italic"), 
          plot.margin = margin(0, 0, 10, 0),
          legend.text=element_text(size=10, face="italic")))   
### Set common y and x labels
xGrob <- textGrob("Number of Generations Ago",
                  gp=gpar(col="black", fontsize=20), hjust=.54)
yGrob <- textGrob("Ancestry Proportion",
                  gp=gpar(col="black", fontsize=20), rot=90)




##### Lays out 3_pop multiplot
plot <- cowplot::plot_grid(
  tract_plot("PEL", 3), tract_plot("MXL", 3), 
  tract_plot("CLM", 3), tract_plot("PUR", 3), 
  tract_plot("ASW", 3), tract_plot("ACB", 3),
  ncol=2,
  labels = "AUTO",
  label_size = 20,
  axis=c("b"),
  align = "hv",
  label_x = 0.065, 
  label_y = 0.99)
### Arrange 3_pop multiplot, legend and axis titles, saves to png
ggsave(file="../results/3pop_tracts_mig_plot.png",
grid.arrange(arrangeGrob(plot,left=yGrob,bottom=xGrob), legend,heights=c(2,.1)),
width=13, height=10, units="in")




##### Lays out 4_pop multiplot
plot <- cowplot::plot_grid(
  tract_plot("PEL", 4), tract_plot("MXL", 4), 
  tract_plot("CLM", 4), tract_plot("PUR", 4), 
  tract_plot("ASW", 4), tract_plot("ACB", 4), 
  ncol=2,
  labels = "AUTO",
  label_size = 20,
  axis=c("b"),
  align = "hv",
  label_x = 0.048, 
  label_y = 0.99)
### Arrange 4_pop multiplot, legend and axis titles, saves to png
ggsave(file="../results/4pop_tracts_mig_plot.png",
grid.arrange(arrangeGrob(plot,left=yGrob,bottom=xGrob), legend,heights=c(2,.1)),
width=13, height=10, units="in")