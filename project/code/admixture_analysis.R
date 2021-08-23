##### Script to make stacked barcharts of Admixture output and save dataframe used as .rda file

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




################################### Setup ######################################

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
anc_palette <- brewer.pal(3,"Set2")




########################## Creating stacked barplots ###########################


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
           axis.title.x = element_text(vjust=5),
           legend.title = element_text(size=10, face="bold.italic"),
           legend.text  = element_text(size=9,   face="italic"),
           legend.key.size = unit(.65,"line"),
           legend.position = "top") + 
     labs(x="Population", y="Proportion of Ancestry") +
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
      labs(x="Population Individuals", y="Proportion of Ancestry") +
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
x.grob <- textGrob("Population Individuals", 
                   gp=gpar(fontface="bold", col="black", fontsize=8))

### Combine plots, legend and axis labels, prints ou to pdf
pdf("../results/admixture_sample_barplots.pdf", 6, 4)
grid.arrange(legend, arrangeGrob(plot, left=y.grob, bottom=x.grob),
             heights=c(.1, 2))
graphics.off()








####################### Creating comparative boxplots ##########################

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
              axis.title.y = element_text(face="bold", size=14),
              axis.text    = element_text(size=11))
  for (i in 1:6) {
  q <- q + geom_text(x=i, y=-0.026, label = table[i,pop_num+1], size=3.5, fontface="plain")}
  
  return(q)
}

MeanSD3 <- function(vector, fun=round, num=2){
  ### Converts vector into its mean ± SD to 3 decimal places each
  mean <- fun(mean(vector), num)
  sd   <- fun(  sd(vector), num)
  return(paste0(mean, " ± ", sd))
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
  label_size = 14,
  axis=c("b"),
  align = "hv",
  label_x = .105, 
  label_y = 0.985)
  ### Common x label
  x.grob <- textGrob("Admixed Population", 
                     gp=gpar(fontface="bold", col="black", fontsize=14))

### Combine plot and axis label, prints out to pdf
pdf("../results/admixture_boxplots.pdf", 6, 15)
grid.arrange(arrangeGrob(plot, bottom=x.grob))
graphics.off()





################################ Wilcoxin plots ################################


### Function to make cell entries have fancu scientific notation
expSup <- function(w, digits=0) { #was %d but didnt work with 0s; g sorta does
  sprintf(paste0("%.", digits, "f*x*10^%g"), w/10^floor(log10(abs(w))), floor(log10(abs(w))))
}

### Function to plot the heatmap
pvalue_heatmap <- function(p_df, nudge_x, pop=NULL){
  options(warn = -1)
  p <-  ggplot(p_df, aes(fct_inorder(y), fct_inorder(x))) + 
        geom_tile(aes(fill=p)) + theme_bw() + #ggtitle(pop) + 
        geom_text(label=parse(text=expSup(p_df$p, digits=3)), size=3) + ##
        geom_text(aes(label=replace(rep("<", nrow(p_df)), p_df[,1]>1e-8, "")), nudge_x=nudge_x, size=3) +
        scale_fill_gradientn( name ="p-value", 
            colours=c(pal[10], pal[9], pal[7], pal[5], pal[3], pal[2], pal[1]),
            values =c(0,       0.01,   0.05,   0.051,   0.1,    0.5,    1),
            limits=c(0,1), breaks=c(0.01, 0.05, 0.25, 0.5, 0.75),
            guide=guide_colourbar(nbin=100, draw.ulim=FALSE, draw.llim=TRUE)) + 
        theme(legend.key.width=unit(2.5, 'cm'), legend.position="bottom", 
              legend.text  = element_text(angle = 45, vjust=1.3, hjust=1),
              legend.title = element_text(vjust = .9, face="bold"),
              axis.title   = element_blank(),
              axis.text    = element_text(size=11),
              plot.title   = element_text(hjust = 0.5)) +
        scale_y_discrete(position = "right")
  if (length(pop) > 0){
  p <- p + theme(legend.position = "none")
  if      (pop == "African Ancestry"){
        p <- p + theme(plot.margin=unit(c(-1,0,3.9,0),"cm"))
 }else if (pop == "European Ancestry"){
        p <- p + theme(plot.margin=unit(c(-.6,0,3.2,0),"cm"))
 }else{ p <- p + theme(plot.margin=unit(c(-.2,0,2.7,0),"cm"))}}
  return(p)
  options(warn = getOption("warn"))
}



### Set palette for plotting
pal <- brewer.pal(n=11, name="RdYlBu") #formerly "RdYlGn", chaned for colorblind

### Create template df to fill with various data comparing subpopulations
combs <- combn(subpops, 2)
combs <- split(combs, rep(1:ncol(combs), each = nrow(combs)))
pvalues <- rep(0, length(combs))
template_p_df <- cbind.data.frame(pvalues, t(as.data.frame(combs)))
colnames(template_p_df) <- c("p", "x", "y")

### Generate legend
p_df <- template_p_df
p_df[,1] <- 1:15
p_legend <- get_legend(pvalue_heatmap(p_df, -0.22))


### AMI Anc plot
for (pop in pops){
  p_df <- template_p_df
  adm_subset <- cbind.data.frame(adm$Subpop, adm[[pop]])
  for (comb in 1:length(combs)){
    p_df[comb,1] <- signif(as.numeric(wilcox.test(
                           adm_subset[adm_subset[,1] == combs[[comb]][1],][,2],
                           adm_subset[adm_subset[,1] == combs[[comb]][2],][,2],
                                          alternative = "two.sided")[3]) ,2) }
  p_df[p_df < 1e-8] <- signif(1e-8,2) 
  assign(pop, pvalue_heatmap(p_df, -0.22, paste(pop, "Ancestry"))) }
### Lays out multiplot
plot <- cowplot::plot_grid( African, European,  Native, ncol=1)
### Arrange plot, legend and axis titles, saves to png
ggsave(file="../results/ADMIXTURE_subpop_comp_by_anc_heatmap.png",
grid.arrange(arrangeGrob(p_legend, plot, heights=c(.2,2))),
width=6, height=17.5, units="in")
print("Finished plotting subpop by ADMIXTURE anc Wilcoxin heatmap, starting ancestry by subpop...")

