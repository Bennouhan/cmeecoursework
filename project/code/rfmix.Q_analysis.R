##### Script to make stacked barcharts of RFMix2 output and save dataframe used as .rda file
### Clear workspace, set working directory
rm(list = ls())
setwd('~/cmeecoursework/project/data/')
unlink(c("../results/rfmix.Q*.pdf", "../data/analysis/*rfmix*"))

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

### Sets ancestry colour palette for diagrams
anc_palette <- brewer.pal(3,"Set2")

### Initialises total output matrix, creates chromosome size list
nsamples <- nrow(read.table('RFMix2/output/RFMix2_output_chr1.rfmix.Q'))
rfmix_output <- matrix(0, nrow=nsamples, ncol=3)
chr_sizes <- c(248956422, 242193529, 198295559, 190214555, 181538259,	170805979, 159345973, 145138636, 138394717, 133797422, 135086622, 133275309, 114364328, 107043718, 101991189, 90338345, 83257441, 80373285, 58617616, 64444167, 46709983, 50818468)

### Iterates through each chromosome, summing the resulting outputs to a single matrix equivalent to that of admix_output
for (chr in 1:22){
  proportion <- chr_sizes[chr]/sum(chr_sizes) #normalises each chr
  fname <- paste0('RFMix2/output/RFMix2_output_chr', chr, '.rfmix.Q')
  #print(dim(read.table(fname)[,2:4]))
  rfmix_output_chr <- read.table(fname)[,2:4]*proportion #proportionalise output
  rfmix_output <- rfmix_output_chr + rfmix_output #sum the outputs
}
rfmix_output[1:3] <- rfmix_output[c(3,1,2)] #changes to order Nat Afr Eur, as with admix output

### Reads the 3 sample lists used in RFMix2 run, and the original ind_3pop file for the missing Pop and Subpop data from query files
query_list  <- read.table('RFMix2/query_vcfs/query_list_renamed.txt')#pelID.1
PEL_sub_99  <- read.table('RFMix2/query_vcfs/PEL_sub_99_renamed.txt')#pelID.2
ref_sampmap <- read.table('sample_maps/sample_map_no_admix.txt')
all_samples <- read.table('sample_maps/ind_3pop_popgroup.txt')
whole_query_list <- rbind(query_list, PEL_sub_99) # merges query files

### Matches query files' samples to the original sample file, to add the Pop and Subpop data
temp <- all_samples[match(substr(whole_query_list[,1], 1, 7), all_samples$V1),] 
temp[2:3] <- temp[c(3,2)] #swaps column values but not names
whole_query_df <- cbind(whole_query_list, temp[,2:3])

### Merges now-identically formatted query and reference sample data 
all_output_samples <- rbind(whole_query_df, ref_sampmap)

### Merges merged sample data with RFMix2 output data, making an equivalent to the "data" dataframe from admixture_analysis.R, except with the duplicated (and renamed) PEL samples, and with admixed Afr, Nat and Eur samples removed
data2 <- cbind(all_output_samples, rfmix_output)
colnames(data2) <- c("ID", "Pop", "Subpop", "Native", "African", "European")

### Creates new ADM subpop, "PEL_sub_99" for samples from PEL_sub_99_renamed.txt
for (row in 1:nrow(data2)){
  ID <- data2[row,1]
  if(substr(ID, nchar(ID)-1, nchar(ID)) == ".2"){
    data2[row,3] <- "PEL_sub_99" }
} # may be useful in future, although about to get rid of - not helpful in the below plots

### Subsets the dataframe to only ADM samples, and no "PEL_sub_99" - since seeing the distribution without the 99+ NAT isnt at all helpful here
data <- data2 %>% filter(Pop == "ADM" & Subpop != "PEL_sub_99")

### Save dataframe for use by other scripts
saveRDS(data, paste0("../data/analysis/rfmix_output_full.rds"))







##### Plotting the stackplot, as in admixture_analysis.R

### Wrangle data to find each subpop's average ancestry, and convert long format
# (Obsolete, only kept from previous script so below stackplot function works, and in correct order of ancestries for plot to look sensible)
stacked <- data %>%
  group_by(Pop, Subpop) %>%
  # Find averages of each ancstry for each subpop
  summarize(.groups="keep", Native   = mean(Native, na.rm=TRUE), 
                            African  = mean(African, na.rm=TRUE), 
                            European = mean(European, na.rm=TRUE)) %>%
  # Arange by each Pop and then by African Ancestry, then pivots for plotting
  arrange(desc(Pop), African) %>% 
pivot_longer(!c(Subpop,Pop), names_to="Ancestry", values_to="Proportion")

stackplot <- function(nSubpop){
  ### Function to create a stacked barplot from a subpop number (from stacked)
  subpop <- stacked[3*nSubpop,2] # get subpop name
  n <- dim(subset(data, Subpop == as.character(subpop)))[1] # get sample size
  samples <- subset(data, Subpop == as.character(subpop)) %>% #subset
    ### Arange by African Ancestry, then pivots for plotting
    arrange(African, European) %>% 
    pivot_longer(!c(Subpop,Pop,ID), names_to="Ancestry", values_to="Prop") %>%
    ### Plot chart
    ggplot(aes(fill=Ancestry, y=Prop, x=fct_inorder(ID))) +
      geom_bar(position="fill", stat="identity", width=1) +
      theme_bw() + ggtitle(subpop) +
      theme(axis.text.x       = element_blank(),
            axis.text.y       = element_text(size=6, margin=margin(t=1, b=1)),
            axis.title.x      = element_blank(),
            axis.title.y      = element_blank(),
            axis.ticks        = element_line(colour = "black", size = .2),
            axis.ticks.length = unit(1.5, "pt"), #length of tick marks
            axis.ticks.x      = element_blank(),
            legend.position   = "none",
            plot.title        = element_text(hjust=0.5, vjust=-1.8,
                                             face="plain", size=8),
            plot.margin       = unit(c(0, 0, .8, 0), "pt")) +
      labs(x="Population Individuals", y="Proportion of Ancestry") +
      geom_text(label=paste0("n=",n), x=n*.5,y=.04, size=2, fontface="plain") +
      scale_y_continuous(expand = c(0,0), limits = c(0,1)) +
      scale_fill_manual(values = anc_palette) 
  return(samples) #probs want to return instead for multiplot
}


### Create Legend
legend <- get_legend(
  stackplot(1) + 
    guides(color = guide_legend(nrow = 1)) +
    #scale_x_discrete(limits=c("2", "0.5", "1")) +
    theme(legend.position = "top",
          legend.key.size = unit(0.3, "cm"),
          legend.title=element_text(size=7, face="bold.italic"), 
          plot.margin = margin(0, 0, 10, 0),
          legend.text=element_text(size=6, face="italic")))

### Creates stacked bar multiplot
plot <- cowplot::plot_grid(
  stackplot(1),
  stackplot(2) + theme(axis.text.y=element_blank(),
                        axis.ticks=element_blank()),
  stackplot(3) + theme(axis.text.y=element_blank(),
                        axis.ticks=element_blank()), 
  stackplot(4),
  stackplot(5) + theme(axis.text.y=element_blank(),
                        axis.ticks=element_blank()), 
  stackplot(6) + theme(axis.text.y=element_blank(),
                        axis.ticks=element_blank()), 
  ncol=3,
  labels = "AUTO",
  label_size = 10,
  axis=c("b"),
  align = "hv",
  label_x = .068, 
  label_y = .99)

### Common y and x labels
y.grob <- textGrob("Proportion of Ancestry", 
                   gp=gpar(fontface="bold", col="black", fontsize=8), rot=90)
x.grob <- textGrob("Population Individuals", 
                   gp=gpar(fontface="bold", col="black", fontsize=8))

### Combine plots, legend and axis labels, prints ou to pdf
pdf("../results/rfmix.Q_sample_barplots.pdf", 6, 4)
grid.arrange(arrangeGrob(plot, left=y.grob, bottom=x.grob),
                         legend, heights=c(2, .1))
graphics.off()









##### Creating comparative boxplots

anc_boxplot <- function(pop_num){
  ### Function to plot jittered comparative boxplot by subpop for argued pop number (corresponding to pops vecotr below)
  q <- ggplot(adm, aes_string(x="fct_inorder(Subpop)", y=pops[pop_num])) +
        labs(y=paste("Proportion",pops[pop_num])) + ylim(0, 1) +
        geom_boxplot(outlier.shape=NA) + #avoid plotting outliers twice
        geom_jitter(position=position_jitter(width=.2, height=0),
                    colour=anc_palette[pop_num], size=.5) +
        stat_boxplot(geom ='errorbar') + theme_bw() + 
        # top whisker goes to last value within 1.5x the interquartile range &vv
        theme(axis.title.x = element_blank(),
              axis.title.y = element_text(face="bold"))
  for (i in 1:6) {
  q <- q + geom_text(x=i, y=-0.025, label = table[i,pop_num+1], size=3, fontface="plain")}
  
  return(q)
}

MeanSD3 <- function(vector, fun=round, num=3){
  ### Converts vector into its mean ± SD to 3 decimal places each
  mean <- fun(mean(vector), num)
  sd   <- fun(  sd(vector), num)
  return(paste0(mean, "±", sd))
}


### Names the 3 pops for use in function above, and the 6 subpops
pops    <- c("African", "European", "Native")
subpops <- c("ACB", "ASW","PUR", "CLM", "MXL", "PEL")

### Subsets and reorders data so subpops are plotted by African/Native ancestry
adm <- data.frame()
for (subpop in subpops){
  adm <- rbind(adm, subset(data, Subpop==subpop))
}

### table in same layout as boxplots, giving mean+-SD for each box
table <- adm %>% 
         group_by(Subpop) %>%
         summarize(.groups="keep", 
                   Native   = MeanSD3(Native),
                   African  = MeanSD3(African), 
                   European = MeanSD3(European)) %>% as.data.frame()
table <- table[match(subpops, table$Subpop),] #reorders rows
table <- table[,c(1, 3:4, 2)] #reorders cols

### Lays out multiplot
plot <- cowplot::plot_grid(
  anc_boxplot(1) + theme(axis.text.x=element_blank(),
                        axis.ticks.x=element_blank()),
  anc_boxplot(2) + theme(axis.text.x=element_blank(),
                        axis.ticks.x=element_blank()), 
  anc_boxplot(3),
  ncol=1,
  labels = "AUTO",
  label_size = 13,
  axis=c("b"),
  align = "hv",
  label_x = .09, 
  label_y = 0.985)
  ### Common x label
  x.grob <- textGrob("Admixed Population", 
                     gp=gpar(fontface="bold", col="black", fontsize=11))

### Combine plot and axis label, prints out to pdf
pdf("../results/rfmix.Q_boxplots.pdf", 6, 15)
grid.arrange(arrangeGrob(plot, bottom=x.grob))
graphics.off()




##### Differences to admix output:

# minor differences here and there, not in any particular direction

# for stacked barplot PEL, rfmix detected small, differing amounts of Afr ancestry, where admix just assigned lots of them 0.001. The weighted averaging of the chromosomes account for the differing amounts, but also seems to assign more african on average. This leads to the more messy looking one, as only sorts by non-afr ancestry if afr ancestry are the same; not the case here

# RFmix also seems more sensitive in the boxplots, and the distributions are consistently wider, if only by a small amount. This is particularly useful in afr PEL and native ACB, which are basically just lines at 0 for admix but are v small, squished boxplots with wider spread of data for rfmix