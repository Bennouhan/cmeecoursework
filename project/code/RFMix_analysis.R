
### Clear workspace, set working directory
rm(list = ls())
setwd('../data/')
unlink("../results/rfmix*barplot*")

### Import packages
#library(pophelper) #need to install #not available in this R version
library(ggplot2) #need to install - tidyverse
library(RColorBrewer)
library(forcats)
library(tidyr)
library(dplyr,warn.conflicts=F)
library(grid)
library(gridExtra,warn.conflicts=F)
library(cowplot) #needed installing




# average ancestry proportion of population accross genome for given pop: https://www.nature.com/articles/s41598-019-50362-2/figures/2

# Also write a script for analysis of homozygosity vs hetero for each population and ancestry, and plot results somehow. use the fb file, use 0.9 as cut-off

# also do some additional analysis of admixture, see notes for ideas (summary statistics, boxplots etc)






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






####### - generate same plots as admixture with the .Q file, should be effectivelt the same (to run and the results)


### Import and label Admixture output table
############# NB change to correct file name, and link to correct samples ######
# rfmix_output <- read.table('RFMix2/output/RFMix2_output_chr##num##.rfmix.Q')
## use for loop for each chr, with estimates of chr length? (NB)
colnames(rfmix_output) <- c("Native", "African", "European") #may be different order

### Import and label sample info table
sample_info <- 

query_list <- read.table('../data/RFMix2/query_vcfs/query_list_renamed.txt')
pel_sub_99 <- read.table('../data/RFMix2/query_vcfs/PEL_sub_99_renamed.txt')
sample_info <- rbind(query_list, pel_sub_99)
colnames(sample_info) <- c("ID")#, "Pop", "Subpop")

### Combine tables, swapping pop and subpop columns
data2 <- cbind(sample_info, rfmix_output)



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
     scale_fill_manual(values = brewer.pal(3,"Set1")) 

### Saves as pdf file
pdf("../results/rfmix_subpop_barplot.pdf", 6, 5)
print(p); graphics.off()





##### Creating multiple stacked barcharts for each ADM subpop, showing ancestry proportion of each individual in said population

### Function to create a stacked barplot from a subpop number (from stacked)
stackplot <- function(nSubpop){
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
      scale_fill_manual(values = brewer.pal(3,"Set1")) 
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

### Creates multiplot
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
pdf("../results/rfmix_sample_barplots.pdf", 6, 4)
grid.arrange(arrangeGrob(plot, left=y.grob, bottom=x.grob),
                         legend, heights=c(2, .1))
graphics.off()



