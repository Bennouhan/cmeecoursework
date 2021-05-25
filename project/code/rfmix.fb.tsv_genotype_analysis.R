
### Clear workspace, set working directory
rm(list = ls())
setwd('~/cmeecoursework/project/data/') #for local
unlink("../results/*AMI*")



### Loads necessary package(s)
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


##### Assign functions
anc_ami_boxplot <- function(pop_num, subset=FALSE){
### Function to plot jittered comparative boxplot by subpop for argued pop number (corresponding to pops vecotr below)

  ### Takes subset of the dataframe if too many datapoints to plot
  ami4plot <- ami4plot[!is.na(ami4plot[,2+pop_num]),]
  q <- ggplot(ami4plot,
              aes_string(x="fct_inorder(Subpop)", y=pops[pop_num])) +
        labs(y=paste(pops[pop_num], "AMIs")) +
        ylim((min(ami4plot[,2+pop_num])-.2), (max(ami4plot[,2+pop_num])+.2)) +
        geom_boxplot(outlier.shape=NA, na.rm=TRUE) + #avoid duplicate outliers
        geom_jitter(position=position_jitter(width=.2, height=.05),
                    colour=anc_palette[pop_num], size=.2, na.rm=TRUE) +
        stat_boxplot(geom ='errorbar', na.rm=TRUE) + theme_bw() + 
        # top whisker goes to last value within 1.5x the interquartile range &vv
        theme(axis.title.x = element_blank(),
              axis.title.y = element_text(face="bold"))
  for (i in 1:6) {
  q <- q + geom_text(x=i, y=(min(ami4plot[,2+pop_num])-.3), label = meanSDtable[i,pop_num+1], size=3, fontface="plain")}
  return(q)
}

MeanSD3 <- function(vector, fun=round, num=3){
### Converts vector into its mean ± SD to 3 decimal places each
  vector = vector[!is.na(vector)]
  mean <- fun(mean(vector), num)
  sd   <- fun(  sd(vector), num)
  return(paste0(mean, "±", sd))
}




################################# ANALYSIS #####################################


### Fetch assignment output from HPC:
# scp bjn20@login.cx1.hpc.ic.ac.uk:~/project/results/analysis/count_tables/chr*.rds ~/cmeecoursework/project/data/analysis/count_tables/

### Read and concatenate each chromosome's genotype assignment
table <- readRDS(paste0("../data/analysis/count_tables/chr",1,".rds")) 
for (chr in c(1:3,5:10,12,14:22)){ #change to 2:22 ultimately
  table <- cbind(table,
            readRDS(paste0("../data/analysis/count_tables/chr",chr,".rds")))
} ## NB: genotype_assign.R -> .Rda, genotype_assign_HPC -> .rds
print("Finished loading RDS files. Starting AMI calculation, will take several minutes...")

### Creates vectors with population and subpopulation names, & plotting colours
pops    <- c("African", "European", "Native")
subpops <- c("PEL", "MXL", "CLM", "PUR", "ASW", "ACB")
anc_palette <- brewer.pal(3,"Set1")

### Sets the subset value - the n value for which every nth row is taken; plotting crashes without it
subset <- 3000 #set to false if none wanted

### Creates empty dfs for AMIs and their mean+-SDs to rbind to
ami4plot    <- data.frame(v1=character(0), v2=numeric(0), v3=numeric(0),
                                           v4=numeric(0), v5=numeric(0))
meanSDtable <- data.frame(v1=character(0), v2=numeric(0), v3=numeric(0),
                                           v4=numeric(0), v5=numeric(0))

### Generates AMI values (overall and for each ancestry) from genotype counts
for (subpop in 1:length(subpops)){
  ### Extracts relevent data from "table", and counts each position's alleles
  genotype_counts <- t(table[(subpop*6-5):(subpop*6),])
  nalleles <- rowSums(genotype_counts)*2
  ### Calculates observed frequency for eur, nat and afr haplotypes
  obs_eur <- as.numeric(rowSums(genotype_counts[,c(1,1,4,5)])/nalleles)
  obs_nat <- rowSums(genotype_counts[,c(2,2,4,6)])/nalleles
  obs_afr <- rowSums(genotype_counts[,c(3,3,5,6)])/nalleles
  ### Calculates and enters observed frequency for each genotype
  obs_genotypes <- genotype_counts/nalleles*2
  ### Calculates and enters expected frequency for each genotype
  exp_homs <- cbind(obs_eur, obs_nat, obs_afr)^2
  exp_genotypes <- cbind(exp_homs, 2*obs_eur*obs_nat, 2*obs_eur*obs_afr, 
                                  2*obs_afr*obs_nat)
  ### calculates overall AMIs and those for each ancestry
  AMIs    <- log((rowSums(obs_genotypes[,1:3])/rowSums(exp_genotypes[,1:3]))/
                 (rowSums(obs_genotypes[,4:6])/rowSums(exp_genotypes[,4:6])))
  European <- log((obs_genotypes[,1]/exp_genotypes[,1])/
                (rowSums(obs_genotypes[,4:5])/rowSums(exp_genotypes[,4:5])))
  Native <-   log((obs_genotypes[,2]/exp_genotypes[,2])/
              (rowSums(obs_genotypes[,c(4,6)])/rowSums(exp_genotypes[,c(4,6)])))
  African <-  log((obs_genotypes[,3]/exp_genotypes[,3])/
                (rowSums(obs_genotypes[,5:6])/rowSums(exp_genotypes[,5:6])))
  ### Rounds to 4 sf, replaces inf with NA for plotting
  AMI_df <- signif(cbind(AMIs,  African, European, Native),4)
  AMI_df[sapply(AMI_df, is.infinite)] <- NA 
  ### Labels each row with its subpop
  Subpop <- rep(subpops[subpop], ncol(table))
  AMI_df <- cbind.data.frame(Subpop, AMI_df)
  ### Calculates each AMI's mean and standard deviation for this subpop
  meanSDtable_subpop <- AMI_df %>% 
                      group_by(Subpop) %>%
                      summarize(.groups="keep", 
                                Overall  = MeanSD3(AMIs),
                                African  = MeanSD3(African),
                                European = MeanSD3(European), 
                                Native   = MeanSD3(Native)) %>% as.data.frame()
  ### Takes sample for plotting
  AMI_df <- AMI_df[seq(1, nrow(AMI_df), subset),] #should really take mean+-SD first...
  ### Appends subpop tables to overall tables
  ami4plot    <- rbind(ami4plot,    AMI_df)
  meanSDtable <- rbind(meanSDtable, meanSDtable_subpop)
  print(paste("Finished calculating AMIs for subpopulation", subpops[subpop]))
}

### Reorders meanSDtable rows to match order of subpops vector
meanSDtable <- meanSDtable[match(subpops, meanSDtable$Subpop),] #reorders rows





############################### VISUALISATION ##################################


##### Multiplot figure
### Lays out multiplot
plot <- cowplot::plot_grid(
  anc_ami_boxplot(1) + theme(axis.text.x=element_blank(),
                                            axis.ticks.x=element_blank()),
  anc_ami_boxplot(2) + theme(axis.text.x=element_blank(),
                                            axis.ticks.x=element_blank()), 
  anc_ami_boxplot(3),
  ncol=1,
  labels = "AUTO",
  label_size = 13,
  axis=c("b"),
  align = "hv",
  label_x = .07, 
  label_y = 0.985)
  ### Common x label
  x.grob <- textGrob("Admixed Subpopulation", 
                     gp=gpar(fontface="bold", col="black", fontsize=11))
### Combine multiplot and axis label, prints out to pdf
plot <- grid.arrange(arrangeGrob(plot, bottom=x.grob))
ggsave(file="../results/anc_AMI_plot.png", plot, dpi=1000,
width=6, height=15, units="in")
print("Finished plotting ancestry-specific AMI multiplot")





##### Overall AMI figure
### Makes plot
OGami4plot <- ami4plot[!is.na(ami4plot[,2]),]
AMI_plot <- ggplot(OGami4plot,
      aes_string(x="fct_inorder(Subpop)", y="AMI")) +
      labs(y="Assortative Mating Index", x="Admixed Subpopulation") +
      ylim((min(OGami4plot[,2])-.2), (max(OGami4plot[,2])+.2)) +
      geom_boxplot(outlier.shape=NA, na.rm=TRUE) + #avoid duplicate outliers
      geom_jitter(position=position_jitter(width=.2, height=0.05),
                  colour=anc_palette[2], size=.2, na.rm=TRUE) +
      stat_boxplot(geom ='errorbar', na.rm=TRUE) + theme_bw() + 
      # top whisker goes to last value within 1.5x the interquartile range &vv
      theme(axis.title = element_text(face="bold"))
for (i in 1:6) {
AMI_plot <- AMI_plot + geom_text(x=i, y=-.73, 
            label = meanSDtable[i,2], size=3, fontface="plain")}

### Prints out as a png
ggsave(file="../results/AMI_plot.png", dpi=1000, width=6, height=5, units="in")
print("Finished plotting overall AMI figure")
