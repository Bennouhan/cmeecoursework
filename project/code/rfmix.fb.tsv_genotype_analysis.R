
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
anc_ami_boxplot <- function(pop_num){
### Function to plot jittered comparative boxplot by subpop for argued pop number (corresponding to pops vector below)

  ### Takes subset of the dataframe with fewer NAs
  ami4plot <- ami4plot[!is.na(ami4plot[,2+pop_num]),]
  q <- ggplot(ami4plot,
              aes_string(x="fct_inorder(Subpop)", y=pops[pop_num])) +
        labs(y=paste("Biallelic", pops[pop_num], "AMI")) +
        ylim((min(ami4plot[,2+pop_num])-.2), (max(ami4plot[,2+pop_num])+.2)) +
        geom_boxplot(outlier.shape=NA, na.rm=TRUE) + #avoid duplicate outliers
        geom_jitter(position=position_jitter(width=.2, height=.05),
                    colour=anc_palette[pop_num], size=.2, na.rm=TRUE) +
        stat_boxplot(geom ='errorbar', na.rm=TRUE) + theme_bw() + 
        # top whisker goes to last value within 1.5x the interquartile range &vv
        theme(axis.title.x = element_blank(),
              axis.title.y = element_text(face="bold"))
  for (i in 1:6) {
  q <- q + geom_text(x=i, y=(min(ami4plot[,2+pop_num])-.25), label = meanSDtable[i,pop_num+1], size=3, fontface="plain")}
  return(q)
}

subpop_ami_boxplot <- function(subpop_num, legend=FALSE){
### Function to plot jittered comparative boxplot by ancestry for argued subpop number (corresponding to subpops vector below)

  ### Takes subset of the dataframe of the given subpop, pivots, removes NAs
  ami4plot <- ami4plot[ami4plot$Subpop == subpops[subpop_num],] %>% 
              pivot_longer(3:5, names_to="Ancestry", values_to="AMI") %>% 
              na.omit()

  q <- ggplot(ami4plot,
        aes_string(x="fct_inorder(Ancestry)", y="AMI")) +
        labs(y=paste("Biallelic AMI of Ancestry")) + 
        ggtitle(subpops[subpop_num]) +
        ylim((min(ami4plot$AMI)-.2), (max(ami4plot$AMI)+.2)) +
        geom_boxplot(outlier.shape=NA, na.rm=TRUE) + #avoid duplicate outliers
        geom_jitter(position=position_jitter(width=.2, height=.05), size=.2,
                    na.rm=TRUE, aes(color=Ancestry)) +
        stat_boxplot(geom ='errorbar', na.rm=TRUE) + theme_bw() + 
        # top whisker goes to last value within 1.5x the interquartile range &vv
        theme(axis.title = element_blank(),
              plot.title = element_text(hjust=0.5, vjust=-6.5,
                                                    face="plain", size=18))
  for (i in 1:3){
    q <- q + geom_text(x=i, y=min(ami4plot[["AMI"]] -.25),
              label = meanSDtable[subpop_num,i+2], size=3, fontface="plain") }
  if (legend == FALSE){
    q <- q + theme(legend.position="none") +
             scale_color_manual(values = anc_palette)}
  return(q)
}

MeanSD3 <- function(vector, fun=round, num=3){
### Converts vector into its mean ± SD to 3 decimal places each
  vector = vector[!is.na(vector)]
  mean <- fun(mean(vector), num)
  sd   <- fun(  sd(vector), num)
  return(paste0(mean, "±", sd))
}

expSup <- function(w, digits=0) { #was %d but didnt work with 0s; g sorta does
  sprintf(paste0("%.", digits, "f*x*10^%g"), w/10^floor(log10(abs(w))), floor(log10(abs(w))))
}

pvalue_heatmap <- function(p_df, pop=NULL){
  options(warn = -1)
  p <-  ggplot(p_df, aes(fct_inorder(y), fct_inorder(x))) + 
        geom_tile(aes(fill=p)) + theme_bw() + ggtitle(pop) + 
        geom_text(label=parse(text=expSup(p_df$p, digits=3)), size=3) +
        scale_fill_gradientn( name ="p-value", 
            colours=c(pal[11], pal[9], pal[7], pal[5], pal[3], pal[2], pal[1]),
            values =c(0,       0.01,   0.05,   0.051,   0.1,    0.5,    1),
            limits=c(0,1), breaks=c(0.01, 0.05, 0.25, 0.5, 0.75),
            guide=guide_colourbar(nbin=100, draw.ulim=FALSE, draw.llim=TRUE)) + 
        theme(legend.key.width=unit(2.5, 'cm'), legend.position="bottom", 
              legend.text = element_text(angle = 45, vjust=1.3, hjust=1),
              legend.title = element_text(vjust = .9, face="bold"),
              axis.title=element_blank(),
              plot.title = element_text(hjust = 0.5))
  if (length(pop) > 0){
    p <- p + theme(legend.position = "none") }
  return(p)
  options(warn = getOption("warn"))
}


subpop_ami_scatter <- function(subpop_num=FALSE, legend=FALSE){
### Function to make scatterplot by ancestry for argued subpop number (corresponding to subpops)
  ### Uses scat_data as dataset
  if (subpop_num == FALSE){
  data <- scat_data
  size <- 2.5
 }else{ 
  ### Takes subset of the dataframe of the given subpop, pivots, removes NAs
  temp1 <- ami4plot[ami4plot$Subpop == subpops[subpop_num],][,c(1,3:5)] %>% 
              pivot_longer(2:4, names_to="Ancestry", values_to="AMI")
  temp2 <- ami4plot[ami4plot$Subpop == subpops[subpop_num],][,c(1,6:8)] %>% 
              pivot_longer(2:4, names_to="Ancestry", values_to="Proportion")
  data <- cbind(temp1[,2:3], temp2[,3]) %>% na.omit()
  size <- .2}
  ### Creates plot
  q <- ggplot(data=data, mapping=aes(x=Proportion, y=AMI)) +
      geom_point(aes(color=Ancestry), size=size) +
      ### Axis and Title formatting
      labs(y="Biallelic Ancestral AMI", x="Ancestry Proportion") +
      theme_bw() + theme(axis.title = element_text(face="bold", size=13)) +
      ggtitle(subpops[subpop_num]) +
      ### Legend formatting
      theme(legend.position="bottom",
            legend.key.size = unit(.5, "cm"),
            legend.title=element_text(size=11, face="bold.italic"), 
            legend.text=element_text(size=10, face="italic"),
            plot.title = element_text(hjust=0.5,    vjust=-6.5,
                                                    face="plain", size=18)) +
            scale_color_manual(name = "Ancestry:",
                            values = anc_palette, # messed with order above but 
                            labels = pops) + # it works out correctly coloured
            guides(color = guide_legend(override.aes = list(size = 3)))
  if (legend == FALSE){
    q <- q + theme(legend.position="none",
                   axis.title = element_blank()) }
  return(q)
}




################################# ANALYSIS #####################################


### Read and concatenate each chromosome's genotype assignment
table <- readRDS(paste0("../data/analysis/count_tables/chr",1,".rds")) 
for (chr in c(2:22)){ #change to 2:22 ultimately
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
ami4plot    <- data.frame(v1=character(0),  v2=numeric(0), v3=numeric(0),
v4=numeric(0), v5=numeric(0),v6=numeric(0), v7=numeric(0), v8=numeric(0))
meanSDtable <- data.frame(v1=character(0), v2=numeric(0), v3=numeric(0),
                                           v4=numeric(0), v5=numeric(0))

### Generates AMI values (overall and for each ancestry) from genotype counts
for (subpop in 1:length(subpops)){
  ### Extracts relevent data from "table", and counts each position's alleles
  genotype_counts <- t(table[(subpop*6-5):(subpop*6),])
  nalleles <- rowSums(genotype_counts)*2
  ### Calculates observed frequency for eur, nat and afr haplotypes
  obs_eur <- rowSums(genotype_counts[,c(1,1,4,5)])/nalleles
  obs_nat <- rowSums(genotype_counts[,c(2,2,4,6)])/nalleles
  obs_afr <- rowSums(genotype_counts[,c(3,3,5,6)])/nalleles
  ### Calculates and enters observed frequency for each genotype
  obs_genotypes <- genotype_counts/nalleles*2
  ### Calculates and enters expected frequency for each genotype
  exp_homs <- cbind(obs_eur, obs_nat, obs_afr)^2
  exp_genotypes <- cbind(exp_homs, 2*obs_eur*obs_nat, 2*obs_eur*obs_afr, 
                                   2*obs_afr*obs_nat)
  ### calculates overall AMIs triallelicly & AMI for each ancestry biallelicly
  AMIs    <-  log(
          (rowSums(obs_genotypes[,1:3])/     rowSums(exp_genotypes[,1:3]))/
          (rowSums(obs_genotypes[,4:6])/     rowSums(exp_genotypes[,4:6])))
  European <- log(
          (rowSums(obs_genotypes[,c(1:3,6)])/rowSums(exp_genotypes[,c(1:3,6)]))/
          (rowSums(obs_genotypes[,4:5])/     rowSums(exp_genotypes[,4:5])))
  Native <-   log(
          (rowSums(obs_genotypes[,c(1:3,5)])/rowSums(exp_genotypes[,c(1:3,5)]))/
          (rowSums(obs_genotypes[,c(4,6)])/  rowSums(exp_genotypes[,c(4,6)])))
  African <-  log(
          (rowSums(obs_genotypes[,1:4])/     rowSums(exp_genotypes[,1:4]))/
          (rowSums(obs_genotypes[,5:6])/     rowSums(exp_genotypes[,5:6])))
  ### Rounds to 4 sf, replaces inf with NA for plotting
  AMI_df <- signif(cbind(AMIs, African, European, Native), 4)
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
  ### Renames subpop-specific df for use in wilcoxin test; too large to append
  assign(paste0(subpops[subpop], "_AMI_df"), AMI_df)
  ### Takes sample for plotting, and appends subpop tables to overall tables
  sub_seq <- seq(1, nrow(AMI_df), subset)
  ami4plot <- rbind(ami4plot, cbind(AMI_df[sub_seq,], Afr_prop=obs_afr[sub_seq], Eur_prop=obs_eur[sub_seq], Nat_prop=obs_nat[sub_seq]))
  meanSDtable <- rbind(meanSDtable, meanSDtable_subpop)
  print(paste("Finished calculating AMIs for population", subpops[subpop]))
}

### Reorders meanSDtable rows to match order of subpops vector
meanSDtable <- meanSDtable[match(subpops, meanSDtable$Subpop),] #reorders rows





################################## BOX PLOTS ###################################




##### Overall AMI figure
### Makes plot
OGami4plot <- ami4plot[!is.na(ami4plot[,2]),]
AMI_plot <- ggplot(OGami4plot,
      aes_string(x="fct_inorder(Subpop)", y="AMIs")) +
      labs(y="Assortative Mating Index", x="Admixed Population") +
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
ggsave(AMI_plot, file="../results/AMI_plot.png", dpi=1000, width=6, height=5, units="in")
print("Finished plotting overall AMI plot")


##### Multiplot figure by subpopulation
### Gets legend
legend <- get_legend(
            subpop_ami_boxplot(1, legend=TRUE) +
            theme(legend.position="bottom",
                  legend.key.size = unit(.5, "cm"),
                  legend.title=element_text(size=15, face="bold.italic"), 
                  legend.text =element_text(size=14, face="italic")) +
                  scale_color_manual(name = "Ancestry:",
                                     values = anc_palette, 
                                     labels = pops) + 
                  guides(color = guide_legend(override.aes = list(size = 3))))

### Lays out multiplot
plot <- cowplot::plot_grid(
  subpop_ami_boxplot(1), subpop_ami_boxplot(2), subpop_ami_boxplot(3),
  subpop_ami_boxplot(4), subpop_ami_boxplot(5), subpop_ami_boxplot(6),
  ncol=3,
  labels = "AUTO",
  label_size = 18,
  axis=c("b"),
  align = "hv",
  label_x = .075, 
  label_y = 0.92)
y.grob <- textGrob("Biallelic Ancestral AMI", rot=90,
                     gp=gpar(fontface="bold", col="black", fontsize=15))
### Arrange plot, legend and axis titles, saves to png
ggsave(file="../results/subpop_AMI_plot.png",
grid.arrange(arrangeGrob(plot, left=y.grob), legend, heights=c(2,.2)),
width=15, height=10, units="in")
print("Finished plotting ancestry-specific AMI by subpopulation multiplot")




##### Multiplot figure by ancestry
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
  label_x = .09, 
  label_y = 0.985)
  ### Common x label
  x.grob <- textGrob("Admixed Population", 
                     gp=gpar(fontface="bold", col="black", fontsize=11))
### Combine multiplot and axis label, prints out to pdf
ggsave(file="../results/anc_AMI_plot.png",
grid.arrange(arrangeGrob(plot, bottom=x.grob)),
dpi=1000, width=6, height=15, units="in")
print("Finished plotting ancestry-specific AMI by ancestry multiplot")




################################# Wilcoxin test ################################
print("Performing and plotting Wilcoxin comparisons of AMI distributions. These take several minutes each (especially the subpop by ancestry heatmap), as the distributions have over 40,000,000 datapoints each...")


### Set palette for plotting
pal <- brewer.pal(n=11, name="RdYlGn")

### Create template df to fill with various data comparing subpopulations
combs <- combn(subpops, 2)
combs <- split(combs, rep(1:ncol(combs), each = nrow(combs)))
pvalues <- rep(0, length(combs))
template_p_df <- cbind.data.frame(pvalues, t(as.data.frame(combs)))
colnames(template_p_df) <- c("p", "x", "y")





##### Overall AMI figure (full dataset)

### Plot overall AMI comparison p-value heatmap
p_df <- template_p_df
for (comb in 1:length(combs)){ #calculate p-value for each subpop combination
  p_df[comb,1] <- signif(as.numeric(wilcox.test(
                        get(paste0(combs[[comb]][1], "_AMI_df"))[["AMIs"]],
                        get(paste0(combs[[comb]][2], "_AMI_df"))[["AMIs"]],
                                alternative = "two.sided")[3]) ,2) }
p_df[p_df == 0] <- signif(1e-299,2) # replaces values rounded to 0 with smallest number R can handle     
overall <- pvalue_heatmap(p_df) #plot
ggsave(file="../results/overall_AMI_comp_by_subpop_heatmap.png",
overall, width=6, height=5, units="in")
print("Finished plotting overall AMI Wilcoxin heatmap, starting subpop by ancestry...")






##### Multiplot figure by subpop (full dataset)

### AMI Anc plot
for (pop in pops){
  p_df <- template_p_df
  for (comb in 1:length(combs)){
    p_df[comb,1] <- signif(as.numeric(wilcox.test(
                        get(paste0(combs[[comb]][1], "_AMI_df"))[[pop]],
                        get(paste0(combs[[comb]][2], "_AMI_df"))[[pop]],
                                          alternative = "two.sided")[3]) ,2) }
  p_df[p_df == 0] <- signif(1e-299,2) # replaces values rounded to 0 with smallest number R can handle     
  assign(pop, pvalue_heatmap(p_df, paste(pop, "Ancestry"))) }
### Lays out multiplot
plot <- cowplot::plot_grid( African, European,  Native, ncol=1)
### Create Legend from scratch for both multiplot heatmaps
p_legend <- get_legend(overall)
### Arrange plot, legend and axis titles, saves to png
ggsave(file="../results/AMI_subpop_comp_by_anc_heatmap.png",
grid.arrange(arrangeGrob(plot, p_legend,heights=c(2,.2))),
width=6, height=12, units="in")
print("Finished plotting subpop by ancestry AMI Wilcoxin heatmap, starting ancestry by subpop...")






##### Multiplot figure by ancestry (full dataset)

### template df to fill with various data comparing ancestries
anc_combs <- list(c(pops[1], pops[2]), c(pops[2], pops[3]), c(pops[1], pops[3]))
pvalues <- rep(0, length(anc_combs))
template_p_df2 <- cbind.data.frame(pvalues, t(as.data.frame(anc_combs)))
colnames(template_p_df2) <- c("p", "x", "y")
### AMI Anc plot
for (subpop in subpops){
  p_df <- template_p_df2
  for (comb in 1:length(anc_combs)){
    p_df[comb,1] <- signif(as.numeric(wilcox.test(
                        get(paste0(subpop, "_AMI_df"))[[anc_combs[[comb]][1]]],
                        get(paste0(subpop, "_AMI_df"))[[anc_combs[[comb]][2]]],
                                          alternative = "two.sided")[3]) ,2) }
  p_df[p_df == 0] <- signif(1e-299,2) # replaces values rounded to 0 with smallest number R can handle     
  assign(subpop, pvalue_heatmap(p_df, subpop)) }
### Lays out multiplot
plot <- cowplot::plot_grid( PEL, MXL, CLM, PUR, ASW, ACB, ncol=3)
### Arrange plot, legend and axis titles, saves to png
ggsave(file="../results/AMI_anc_comp_by_subpop_heatmap.png",
grid.arrange(arrangeGrob(plot, p_legend, heights=c(2,.4))),
width=7, height=4, units="in")
print("Finished plotting ancestry by subpop AMI Wilcoxin heatmap")







################################ Scatter Plots #################################

##### Average subpop ancestry vs average subpop AMI for that ancestry

### Load & wrangle data to find each subpop's average ancestry in long format
anc_means <- readRDS("../data/analysis/admixture_output_full.rds") %>%
  group_by(Pop, Subpop) %>%
  # Find averages of each ancstry for each subpop
  summarize(.groups="keep", African  = mean(African,  na.rm=TRUE), 
                            European = mean(European, na.rm=TRUE),
                            Native   = mean(Native,   na.rm=TRUE)) %>%
  # Arange by each Pop and then by African Ancestry, then pivots for plotting
  arrange(desc(Pop), African) %>% 
  pivot_longer(!c(Subpop,Pop), names_to="Ancestry", values_to="Proportion") %>% 
  filter(Pop == "ADM") %>% ungroup() %>%
  select(-one_of("Pop"))

### Formats mean AMIs in the same way
ami_means <- meanSDtable[,c(1,3:5)] %>% 
  pivot_longer(!c(Subpop), names_to="Ancestry", values_to="AMI") %>%
  transmute(Subpop, Ancestry,
  AMI=as.numeric(t(as.data.frame(strsplit(AMI, "±")))[,1]))

### Merges to two
scat_data <- cbind(anc_means, AMI=ami_means$AMI)

### Plots
p <- subpop_ami_scatter(legend=TRUE)
ggsave(p, file="../results/anc_prop_vs_AMI.png", width=7,height=7.4, units="in")





##### Multi-scatterplot figure by subpopulation

### Lays out multiplot
plot <- cowplot::plot_grid(
  subpop_ami_scatter(1), subpop_ami_scatter(2), subpop_ami_scatter(3),
  subpop_ami_scatter(4), subpop_ami_scatter(5), subpop_ami_scatter(6),
  ncol=3,
  labels = "AUTO",
  label_size = 18,
  axis=c("b"),
  align = "hv",
  label_x = .074, 
  label_y = 0.91)
x.grob <- textGrob("Ancestry Proportion", 
                     gp=gpar(fontface="bold", col="black", fontsize=15))
y.grob <- textGrob("Biallelic Ancestral AMI", rot=90,
                     gp=gpar(fontface="bold", col="black", fontsize=15))
### Arrange plot, legend and axis titles, saves to png
ggsave(file="../results/subpop_anc_prop_vs_AMI.png",
grid.arrange(arrangeGrob(plot, bottom=x.grob, left=y.grob), 
legend, heights=c(2,.2)),width=15, height=10, units="in")
print("Finished plotting ancestry-specific AMI against ancestry proportion by subpopulation multiplot")

