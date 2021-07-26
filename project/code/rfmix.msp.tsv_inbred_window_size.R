### Clear workspace, set working directory
rm(list = ls())
setwd('~/cmeecoursework/project/data/') #for local
unlink("../results/inbred_window_lengths*")


### Import packages
library(data.table,warn.conflicts=F) #needs installing
library(parallel)
library(ggplot2) #need to install - tidyverse
library(RColorBrewer)
library(forcats)
library(tidyr)
library(dplyr,warn.conflicts=F)
library(grid)
library(gridExtra,warn.conflicts=F)
library(cowplot) #needed installing
library(qwraps2) #needed installing





### Reads the 2 query sample lists used in RFMix2 run, and the original ind_3pop file for the missing Pop and Subpop data from query files
query_list  <- read.table('RFMix2/query_vcfs/query_list_renamed.txt')#pelID.1
PEL_sub_99  <- read.table('RFMix2/query_vcfs/PEL_sub_99_renamed.txt')#pelID.2
all_samples <- read.table('sample_maps/ind_3pop_popgroup.txt')
whole_query_list <- rbind(query_list, PEL_sub_99) # merges query files

### Matches query files' samples to the original sample file, to add the Pop and Subpop data; makes list of subpops; defines colour palette
temp <- all_samples[match(substr(whole_query_list[,1], 1, 7), all_samples$V1),] 
temp[2:3] <- temp[c(3,2)] #swaps column values but not names
whole_query_df <- cbind(whole_query_list, temp[,2:3])
colnames(whole_query_df) <- c("ID", "Pop", "Subpop")
subpops <- c("PEL", "PEL_sub_99", "MXL", "CLM", "PUR", "ASW", "ACB")
anc_palette <- brewer.pal(3,"Set2")


### Creates new ADM subpop, "PEL_sub_99" for samples from PEL_sub_99_renamed.txt
for (row in 1:nrow(whole_query_df)){
  ID <- whole_query_df[row,1]
  if(substr(ID, nchar(ID)-1, nchar(ID)) == ".2"){
    whole_query_df[row,3] <- "PEL_sub_99" }
}



### Reads and merges MSP files
msp <- fread(paste0('RFMix2/output/RFMix2_output_chr',1,'.msp.tsv'),nThread=6)
for (chr in 2:22){ 
  msp <- rbind(msp,
      fread(paste0('RFMix2/output/RFMix2_output_chr',chr,'.msp.tsv'),nThread=6))
}


### Creates a table of values for each ancestry for each subpopulation
for (subpop in 1:length(subpops)){
  ### Creates matrix of the first 6 columns and the columns specific to each subpopulation
  samples <- which(whole_query_df[,3] == subpops[subpop])
  samp_cols <- 1:6
  for (sample in samples){
    samp_cols <- c(samp_cols, 6+(sample*2-1):(sample*2))}
  subpop_df <- as.matrix(msp)[,samp_cols]
  ### Converges both haplotypes to a single column, giving the same ancestry number as before if position is homozygous for that ancestry, and replacing heterozygous positions with 3
  # (3s won't be used; stand-in for NA but rle treats NA weirdly)
  for (col in seq(7,ncol(subpop_df),2)){
    subpop_df[,col][subpop_df[,col] != subpop_df[,(col+1)]] <- 3
  }
  ### runs rle on all converged columns for that subpop
  rle_on_cols <- lapply(seq(7,ncol(subpop_df),2),function(x) rle(subpop_df[,x]))
  ### make a list of 4 vectors you can append grangments to; afr=0, eur=1, nat=2, NA=3, so value +1 is the list fragment length is appended to
  frag_ls <- list(vector(), vector(), vector(), vector())
  for (col_num in 1:length(rle_on_cols)){
    col_output <- data.frame(unclass(rle_on_cols[[col_num]]))
    col_output$lengths <- cumsum(col_output$lengths)
    col_output <- rbind(c(0,0), col_output) 
    ### Find length between each fragment, appends to relevent row
    for (frag in 2:nrow(col_output)){
      ls_num <- col_output$values[frag]+1
      frag_ls[[ls_num]] <- c(frag_ls[[ls_num]],
      as.integer(subpop_df[ col_output$lengths[frag],3] - 
                subpop_df[(col_output$lengths[frag-1]+1),2]))
    } 
  }
  ### Finds longest column, matches it with one of repeated subpop labels
  max <- max(c(length(frag_ls[[1]]),length(frag_ls[[2]]),length(frag_ls[[3]])))
  label <- rep(subpops[subpop], max)
  ### Creates dataframe with all fragments of each ancestry and subpop in long format for plotting, same format and colnames as in rfmix.Q_analysis.R
   if (subpop == 1){
    frag_df <- qpcR:::cbind.na(label, frag_ls[[1]], frag_ls[[2]], frag_ls[[3]])
    colnames(frag_df) <- c("Subpop", "African", "European", "Native")
  }else{
    temp    <- qpcR:::cbind.na(label, frag_ls[[1]], frag_ls[[2]], frag_ls[[3]])
    colnames(temp) <- c("Subpop", "African", "European", "Native")
    frag_df <- rbind.data.frame(frag_df, temp)
  }
}

### Replace negatives (which are the gaps between chromosomes) with NA
frag_df[frag_df < 1] <- NA







###################### Creating window size histogram ##########################


subpop_hist <- function(subpop, x, y){
### Creates histogram from a named subpopulation and x&y tick numbers
  histo <- frag_df %>% 
                  pivot_longer(!Subpop, names_to = "Ancestry") %>% 
                  filter(Subpop == subpop & is.na(value) == FALSE) %>% 
                  transmute(Ancestry, value=log10(as.numeric(value))) %>% 
                  ggplot(aes(x = value, fill = Ancestry)) + ggtitle(subpop) +
                    geom_histogram(position="identity", alpha=0.5, bins=100) +
                    scale_fill_manual(values=anc_palette) + theme_bw() + 
                    theme(axis.title.x = element_blank(),
                          axis.title.y = element_blank(),
                          plot.title = element_text(hjust=0.55,    vjust=-80,
                                                    face="plain", size=16)) + 
                    scale_x_continuous(expand = c(0, 0), limits = c(NA, NA),
                    breaks=scales::pretty_breaks(n = x)) + 
                    scale_y_continuous(expand = c(0, 0), limits = c(0, 100*y),
                    breaks=scales::pretty_breaks(n = y)) +
                    theme(legend.position = "none")
  return(histo)
}



### Lays out multiplot
plot <- cowplot::plot_grid(
  subpop_hist("PEL", 20, 4), 
  subpop_hist("MXL", 20, 4), 
  subpop_hist("CLM", 20, 6), 
  subpop_hist("PUR", 20, 8), 
  subpop_hist("ASW", 20, 4), 
  subpop_hist("ACB", 20, 4), 
  ncol=3,
  labels = "AUTO",
  label_size = 20,
  axis=c("b"),
  align = "hv",
  label_x = .08, 
  label_y = 0.92)##### Script to make plots of ancestry proportion over time fromm tracts output

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
tract_plot <- function(subpop, npop, bootstrap, interval=25, legend=FALSE){
#subpop="MXL"; npop=4; bootstrap=25; legend=FALSE; interval=5#for debug only
    ### Import _mig data
    pattern <- paste0("boot", bootstrap, "_*_mig") #works > "boot0*_mig"
    fpath <- paste0("analysis/bed_files/", subpop, "/output/", npop, "_pop/")
    data <- read.csv(dir(fpath, full.names=T, pattern=glob2rx(pattern)),
                    sep='\t', header=FALSE) #0 for test, will be 49^^
    ### Corrects 4_pop data by merging the 2 Eur columns
    if (npop == 4){
        data[,1] <- data[,1] + data[,4]
        data <- data[,1:3] }
    ### Initialises dataframe for plotting and counts number of genertions
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
    max <- 20; dif <- max-n_gen
    if (n_gen >= max){
        data <- data[1:max,]
   }else{ #Or adds pure NAT ancestry to previous gens if n_gen < max
        pure_nat <- cbind(rep(0, dif), rep(1, dif), rep(0, dif), (n_gen+1):max)
        colnames(pure_nat) <- colnames(data); data <- rbind(data, pure_nat)
   }
    n_gen <- max
    ### Pivots data longer for easy stacked barplotting
    stacked <- data %>%
    pivot_longer(!Generation, names_to="Ancestry", values_to="Proportion")
    ### Alters stacked df to be compatible with 5-year interval data
    if (interval == 5){
      seq <- numeric()
      for (num in seq(0, 57, 3)){ seq <- c(seq, num+rep(c(1,2,3), 5)) }
      stacked <- stacked[seq, ]
      stacked$Generation <- rep(seq(1, 20.8, by=.2), each=3)}

    ### Set break vectors for axis formatting
    # 1st y axis
    ybreaks <- seq(0, 1, 0.05)
    ylabs <- rep("", length(ybreaks))
    ylabs[c(1,6,11,16,21)] <- ybreaks[c(1,6,11,16,21)]
    # 2nd y axis
    y2breaks <- seq(0, 7, 0.2)
    y2labs <- rep("", length(y2breaks))
    y2labs[c(1,6,11,16,21,26,31,36)] <- y2breaks[c(1,6,11,16,21,26,31,36)]
    # x axis
    xbreaks <- seq(n_gen, 1, -1)
    xlabs <- seq(1500, 1975, 25)
    xlabs[c(FALSE, TRUE)] <- ""
    ## outdated!!  xbreaks, when unit was "generations ago", not years
    # xbreaks <- seq(n_gen, 1, -1)
    # xlabs <- rep("", length(xbreaks))
    # xlabs[seq(2-n_gen%%2, floor((n_gen+1)/2)*2-n_gen%%2, 2)] <-
    # seq(floor((n_gen+1)/2)*2-1, 1, -2)
    ############ WORKS##########################################################
    ### Plot tract chart
    if (legend==TRUE){
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
   }else{
    
    # if (legend==FALSE){ # was previously just above plus this for legend=false
    # ### Removes axis titles and legend if not used for get_legend()
    # p <- p + theme(legend.position="none", axis.title=element_blank()) }
    ##### HASH EVERYTHING BELOW, UNHASH EVERYTHING IN "WORKS" SECTION TO REVERT
    ############### TEST########################################################
    
    ################ Adds slave voyage line graph to the plot ##################
    ### Creates dataframe based on port numbers and interval (years)
    voy_df <- get(paste0("data", interval))[,get(subpop)]
    ### Converts numbers with commas to numeric, then sums each row
    for (col in 1:ncol(voy_df)){
    voy_df[,col] <- as.numeric(gsub(",", "", voy_df[,col])) } 
    sums         <- log10(cumsum(c(rowSums(voy_df), rep(0,(2000-1875)/interval))))
    stacked      <- cbind(stacked, SlaveCount=rep(rev(sums), each=3))
    ###(Outdated)Creates df from summed rows and sequence of corresponding years
    # years <- seq(1500, 2000, interval)[-1] - interval/2
    # voy_df <- data.frame(sums, years)
    ### Creates line graph of the df
    # p <- p + ggplot(data=voy_df, aes(x=years, y=sums, group=1)) +
    # geom_line(colour=anc_palette[1], cex=1.5) + theme_bw() + 
    # scale_x_continuous(breaks = seq(1500, 2000, by=25))
    #     ### Plot tract chart
    # stacked
    p <- ggplot(stacked) +
        # plots ancestry proportion stacked barplot
        geom_bar( aes(y=Proportion, x=Generation, fill=factor(Ancestry,
          levels=c("Native", "European", "African"))), #swaps AFR to bottom
          position="fill", stat="identity", width=1) +
        # plots number of slaves transported to region each generation linegraph
        geom_line(aes(y=SlaveCount/7, x=Generation),
          colour="darkgreen", cex=.6) +
        # formats plot text
        theme(plot.title=element_text(hjust=.55, face="plain", size=18),
              axis.title.y=element_blank()) + #swap with below if titles wanted
              #axis.title.y=element_text(face="bold", size=12)) +
        ylab("Ancestry Proportion") +
        # formats axes: flips x axis, adds second y axis, sets fill colours
        scale_y_continuous(expand=c(0,0), limits=c(0,1),
                           sec.axis=sec_axis(~.*7,
                           name="Slaves Transported to Region",
                           breaks=y2breaks, labels=y2labs),
                           breaks=ybreaks,  labels=ylabs) +
        scale_x_reverse(expand=c(0,0), limits=c(n_gen+.5, .5), 
                           breaks=xbreaks, labels=xlabs) +
        scale_fill_manual(values = rev(anc_palette)) + ggtitle(subpop) #rev needed to reverse colours after changing african to bottom
    ### Removes axis titles and legend if not used for get_legend()
    p <- p + theme(legend.position="none", axis.title.x=element_blank()) #nb
    }
    #print(p)
    return(p)
}




################################ SET-UP ########################################

### Sets interval size - 5 or 25; whether 3_pop is plotted; & which bootstrap numbers should be plotted
plot3 <- FALSE
bootstraps <- 0:49 # 0:49 to plot all of them! 25 may be good example
defaultW <- getOption("warn")
options(warn = -1)
options(scipen=1000000)


fpath <- "../results/tracts+voy/"

### Creates vectors with population and subpopulation names, & plotting colours
pops    <- c("African", "European", "Native")
subpops <- c("PEL", "MXL", "CLM", "PUR", "ASW", "ACB")
anc_palette <- brewer.pal(3,"Set2")

### Read dataframes from https://www.slavevoyages.org/voyage/database#tables:
# Row == 25/5-year periods (as below - data[x]),
# Column == Principal place of landing, 
# Cell == Sum of disembarkwed slaves
# Downloaded, renamed as below and moved into data/voyages directory
zeros <- rep(0, 275)
data25 <- rbind(              read.csv("voyages/Slaves_per_25years.csv"))
data5  <- rbind(zeros, zeros, read.csv("voyages/Slaves_per_5years.csv" ), zeros)
# (Adds blank rows to span same period as data25 - 1500 to 1875)

### Defines vector of ports, as ordered in above DFs, which correspond to each of the 6 Populations - Decided to use wider historically related regions (as outlined below), as transport between slave ports and migration were very common
# NB: 190 is the Honduran Trujillo, not the Peruvian one, hence not included
# ACB - Ports on British Carribean Islands
ACB <- 102:142
# ASW - Ports North of Rio Grande in North America
ASW <- 12:56
# PEL - Ports in North-Eastern South America - only Peru, Venzuala, Colombia
PEL <- c(180:189, 198)
# CLM - Ports in North-Eastern South America - only Peru, Venzuala, Colombia
CLM <- c(180:189, 198)
# PUR - Ports on Spanish Carribean Islands
PUR <- 57:91
# MXL - Ports in New Spain & elsewhere now part of Mexico (Campeche & Veracruz)
MXL <- 174:176

### Creates tracts subdir in results dir
dir.create(file.path("../results/tracts+voy"), showWarnings=FALSE)


#print(tract_plot("ACB", 4, 25, 5, legend=FALSE)) #test only


############################## PLOTTING #######################################

### For loop to run everything below for each bootstrap
for (bs in bootstraps){
#bs <- 20# for debug only
##### General plot setup
### Create Legend from scratch
legend <- get_legend(tract_plot("PEL", 3, 0, legend=TRUE)
 + guides(color = guide_legend(nrow = 1)) +
    theme(legend.position = "top",
          legend.key.size = unit(0.5, "cm"),
          legend.title=element_text(size=11, face="bold.italic"), 
          plot.margin = margin(0, 0, 10, 0),
          legend.text=element_text(size=10, face="italic")))   
### Set common y and x labels
xGrob <-  textGrob("Year", #mention year generation started in figure legend!!
                           gp=gpar(col="black", fontsize=20), hjust=.54)
yGrob <-  textGrob("Proportion of Ancestry in Population",
                           gp=gpar(col="black", fontsize=20), rot=90)
yGrob2 <- textGrob(expression(paste("Cumulative Number of Slaves Transported to Region  (log"["10"],")")), gp=gpar(col="black", fontsize=20), rot=270)

# expression(paste("Cumulative Number of Slaves Transported to Region  (log"["10"],")"))

##### Lays out Saves 3_pop multiplot, if switch is turned on (TRUE)
if (plot3 == TRUE){
plot <- cowplot::plot_grid(
  tract_plot("PEL", 3, bs, 25), tract_plot("MXL", 3, bs, 25), 
  tract_plot("CLM", 3, bs, 25), tract_plot("PUR", 3, bs, 25), 
  tract_plot("ASW", 3, bs, 25), tract_plot("ACB", 3, bs, 25),
  ncol=2,
  labels = "AUTO",
  label_size = 20,
  axis=c("b"),
  align = "hv",
  label_x = 0.065, 
  label_y = 0.99)
### Arrange 3_pop multiplot, legend and axis titles, saves to png
ggsave(file=paste0(fpath, "3pop_tracts_bs", bs, "_mig_plot_25yrs.png"),
grid.arrange(arrangeGrob(plot, left=yGrob, bottom=xGrob, right=yGrob2), legend,
heights=c(2,.1)), width=13, height=10, units="in") }

##### Lays out & Saves 4_pop multiplot
plot <- cowplot::plot_grid(
  tract_plot("PEL", 4, bs, 25), tract_plot("MXL", 4, bs, 25), 
  tract_plot("CLM", 4, bs, 25), tract_plot("PUR", 4, bs, 25), 
  tract_plot("ASW", 4, bs, 25), tract_plot("ACB", 4, bs, 25), 
  ncol=2,
  labels = "AUTO",
  label_size = 20,
  axis=c("b"),
  align = "hv",
  label_x = 0.050, 
  label_y = 1)
### Arrange 4_pop multiplot, legend and axis titles, saves to png
ggsave(file=paste0(fpath, "4pop_tracts_bs", bs, "_mig_plot_25yrs.png"),
grid.arrange(arrangeGrob(plot, left=yGrob, bottom=xGrob, right=yGrob2), legend, 
heights=c(2,.1)), width=13, height=10, units="in")





########################## PLOT w/ 5-year interval #############################

##### Lays out & Saves 4_pop multiplot with 5-year interval line graph
plot <- cowplot::plot_grid(
  tract_plot("PEL", 4, bs, 5), tract_plot("MXL", 4, bs, 5), 
  tract_plot("CLM", 4, bs, 5), tract_plot("PUR", 4, bs, 5), 
  tract_plot("ASW", 4, bs, 5), tract_plot("ACB", 4, bs, 5), 
  ncol=2,
  labels = "AUTO",
  label_size = 20,
  axis=c("b"),
  align = "hv",
  label_x = 0.050, 
  label_y = 1)
### Arrange 4_pop multiplot, legend and axis titles, saves to png
ggsave(file=paste0(fpath, "4pop_tracts_bs", bs, "_mig_plot_5yrs.png"),
grid.arrange(arrangeGrob(plot, left=yGrob, bottom=xGrob, right=yGrob2), legend, 
heights=c(2,.1)), width=13, height=10, units="in")

}

######## NB! need to suppress warnings or solve them 
options(warn = defaultW)


### Create Legend from scratch
legend <- get_legend(subpop_hist("PEL", 24, 7)
 + guides(color = guide_legend(nrow = 1)) +
    theme(legend.position = "top",
          legend.key.size = unit(0.5, "cm"),
          legend.title=element_text(size=11, face="bold.italic"), 
          plot.margin = margin(0, 0, 10, 0),
          legend.text=element_text(size=10, face="italic")))
          
### Set common y and x labels
xGrob <- textGrob(expression(paste("Length of Homozygous Fragment  (log"["10"]," bp)")), 
                   gp=gpar(col="black", fontsize=20))
yGrob <- textGrob("Fragment Count",
                   gp=gpar(col="black", fontsize=20), rot=90)

### Arrange plot, legend and axis titles, saves to png
ggsave(file="../results/inbred_window_lengths_histogram.png",
grid.arrange(arrangeGrob(plot,left=yGrob,bottom=xGrob), legend,heights=c(2,.1)),
width=13, height=10, units="in")
