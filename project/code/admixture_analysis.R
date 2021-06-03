##### Script to make stacked barchart of Admixture output

### Clear workspace and past outputs, set working directory
rm(list = ls())
setwd('~/cmeecoursework/project/data/')
unlink(c("../results/admix*.pdf", "../data/analysis/*admix*"))

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

### Import and label Admixture output table
admix_output <- read.table('admixture/output/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_allchr_pruned.3.Q')
colnames(admix_output) <- c("Native", "African", "European")

### Import and label sample info table
sample_info <- read.table('sample_maps/ind_3pop_popgroup.txt')
colnames(sample_info) <- c("ID", "Subpop", "Pop")

### Combine tables, swapping pop and subpop columns
data <- cbind(sample_info[,c(1,3,2)], admix_output)

### Save dataframe for use by other scripts
saveRDS(data, paste0("../data/analysis/admixture_output_full.rds"))

### Sets ancestry colour palette for diagrams
anc_palette <- brewer.pal(3,"Set1")







##### Creating a stacked barchart showing anc distribution of each subpop
#need to find average for each subpop of each anc, then pivot longer

### Wrangle data to find each subpop's average ancestry, and convert long format
stacked <- data %>%
  group_by(Pop, Subpop) %>%
  # Find averages of each ancstry for each subpop
  summarize(.groups="keep", Native   = mean(Native, na.rm=TRUE), 
                            African  = mean(African, na.rm=TRUE), 
                            European = mean(European, na.rm=TRUE)) %>%
  # Arange by each Pop and then by African Ancestry, then pivots for plotting
  arrange(desc(Pop), African) %>% 
  pivot_longer(!c(Subpop,Pop), names_to="Ancestry", values_to="Proportion")

### Plot chart
p <- ggplot(data=stacked, aes(fill=Ancestry, y=Proportion,
                                             x=fct_inorder(Subpop))) +#OrderKept
     geom_bar(position="fill", stat="identity", width=1) + theme_bw() + #stacks
     theme(axis.text.x  = element_text(angle=90, hjust=1, vjust=.5),
           axis.title   = element_text(face="bold"),
           legend.title = element_text(face="bold")) + 
     labs(x="Subpopulation", y="Proportion of Ancestry") +
     scale_y_continuous(expand = c(0,0), limits = c(-0.003,1.003)) + #no gaps
     scale_fill_manual(values = anc_palette) 

### Saves as pdf file
pdf("../results/admixture_subpop_barplot.pdf", 6, 5)
print(p); graphics.off()








##### Creating multiple stacked barcharts for each ADM subpop, showing ancestry proportion of each individual in said population

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
      labs(x="Subpopulation Individuals", y="Proportion of Ancestry") +
      geom_text(label=paste0("n=",n), x=n*.5,y=.04, size=2, fontface="plain") +
      scale_y_continuous(expand = c(0,0), limits = c(0,1)) +
      scale_fill_manual(values = anc_palette) 
  return(samples) #probs want to return instead for multiplot
}


### Create Legend
legend <- get_legend(
  stackplot(28) + 
    guides(color = guide_legend(nrow = 1)) +
    #scale_x_discrete(limits=c("2", "0.5", "1")) +
    theme(legend.position = "top",
          legend.key.size = unit(0.3, "cm"),
          legend.title=element_text(size=7, face="bold.italic"), 
          plot.margin = margin(0, 0, 10, 0),
          legend.text=element_text(size=6, face="italic")))

### Creates stacked bar multiplot
plot <- cowplot::plot_grid(
  stackplot(28),
  stackplot(29) + theme(axis.text.y=element_blank(),
                        axis.ticks=element_blank()),
  stackplot(30) + theme(axis.text.y=element_blank(),
                        axis.ticks=element_blank()), 
  stackplot(31),
  stackplot(32) + theme(axis.text.y=element_blank(),
                        axis.ticks=element_blank()), 
  stackplot(33) + theme(axis.text.y=element_blank(),
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
x.grob <- textGrob("Subpopulation Individuals", 
                   gp=gpar(fontface="bold", col="black", fontsize=8))

### Combine plots, legend and axis labels, prints ou to pdf
pdf("../results/admixture_sample_barplots.pdf", 6, 4)
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
  x.grob <- textGrob("Admixed Subpopulation", 
                     gp=gpar(fontface="bold", col="black", fontsize=11))

### Combine plot and axis label, prints out to pdf
pdf("../results/admixture_boxplots.pdf", 6, 15)
grid.arrange(arrangeGrob(plot, bottom=x.grob))
graphics.off()







# ##### Not using yet

# ### Wilcoxin test - between ancestry for each subpop - basically between every boxplot and the others vertically and horizontally
# #for loop for ancestry and nested loop for subpop?

# nat_pel <- subset(data, Subpop=="PEL")[,4]
# nat_pur <- subset(data, Subpop=="PUR")[,4]
# #experiment
# test <- wilcox.test(nat_pel, nat_pur) #understand output before scaling up

# #


