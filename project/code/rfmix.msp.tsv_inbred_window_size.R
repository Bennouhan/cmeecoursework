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
                    theme(plot.margin = unit(c(-.5, 0, 0, 0.3), "cm"),
                          axis.title.x = element_blank(),
                          axis.title.y = element_blank(),
                          axis.text    = element_text(size=14),
                          plot.title = element_text(hjust=0.53,    vjust=-86.5,
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
  subpop_hist("PEL", 8, 4), 
  subpop_hist("MXL", 8, 4), 
  subpop_hist("CLM", 8, 6), 
  subpop_hist("PUR", 8, 8), 
  subpop_hist("ASW", 8, 4), 
  subpop_hist("ACB", 8, 4), 
  ncol=3,
  labels = c("B", "", "", "", "", ""),
  label_size = 24,
  axis=c("b"),
  align = "hv",
  label_x = .12, 
  label_y = 0.98)


### Create Legend from scratch
legend <- get_legend(subpop_hist("PEL", 24, 7)
 + guides(color = guide_legend(nrow = 1)) +
    theme(legend.position = "top",
          legend.key.size = unit(0.8, "cm"),
          legend.title=element_text(size=14, face="bold.italic"), 
          plot.margin = margin(0, 0, 10, 0),
          legend.text=element_text(size=12, face="italic")))
          
### Set common y and x labels
xGrob <- textGrob(expression(bold(paste("Length of Fragment  (log"["10"]," bp)"
))),               gp=gpar(fontface="bold", col="black", fontsize=18))
yGrob <- textGrob("Fragment Count",
                   gp=gpar(fontface="bold", col="black", fontsize=18), rot=90)

### Arrange plot, legend and axis titles, saves to png
ggsave(file="../results/inbred_window_lengths_histogram.png",
grid.arrange(arrangeGrob(plot,left=yGrob,bottom=xGrob),
             heights=c(2)), width=13, height=9.5, units="in")
