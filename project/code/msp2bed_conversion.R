
### Clear workspace, set working directory
rm(list = ls())
setwd('~/cmeecoursework/project/data/') #for local


### Import packages
library(parallel)
library(data.table,warn.conflicts=F) #needs installing
library(qpcR) #needs installing
library(dplyr,warn.conflicts=F)


### Reads the 2 query sample lists used in RFMix2 run, and the original ind_3pop file for the missing Pop and Subpop data from query files
query_list  <- read.table('RFMix2/query_vcfs/query_list_renamed.txt')#pelID.1
PEL_sub_99  <- read.table('RFMix2/query_vcfs/PEL_sub_99_renamed.txt')#pelID.2
all_samples <- read.table('sample_maps/ind_3pop_popgroup.txt')
whole_query_list <- rbind(query_list, PEL_sub_99) # merges query files

### Matches query files' samples to the original sample file, to add the Pop and Subpop data; makes list of subpops
temp <- all_samples[match(substr(whole_query_list[,1], 1, 7), all_samples$V1),] 
temp[2:3] <- temp[c(3,2)] #swaps column values but not names
whole_query_df <- cbind(whole_query_list, temp[,2:3])
colnames(whole_query_df) <- c("ID", "Pop", "Subpop")
subpops <- c("PEL", "PEL_sub_99", "MXL", "CLM", "PUR", "ASW", "ACB")

### Creates new ADM subpop, "PEL_sub_99" for samples from PEL_sub_99_renamed.txt
for (row in 1:nrow(whole_query_df)){
  ID <- whole_query_df[row,1]
  if(substr(ID, nchar(ID)-1, nchar(ID)) == ".2"){
    whole_query_df[row,3] <- "PEL_sub_99" }
}

### Creates directories if don't exist, and deletes past outputs if exists
dir.create(file.path("../data/analysis/"), showWarnings=FALSE)
dir.create(file.path("../data/analysis/bed_files/"), showWarnings=FALSE)
for (subpop in subpops){
  dir.create(file.path(paste0("../data/analysis/bed_files/",subpop,"/")),
             showWarnings=FALSE)
  dir.create(file.path(paste0("../data/analysis/bed_files/",subpop,"/output")),
             showWarnings=FALSE)
  dir.create(file.path(paste0("../data/analysis/bed_files/",subpop,"/output/3_pop")), showWarnings=FALSE)
  dir.create(file.path(paste0("../data/analysis/bed_files/",subpop,"/output/4_pop")), showWarnings=FALSE) }
dir.create(file.path("../results/tracts"), showWarnings=FALSE)

### Reads and merges MSP files
msp <- fread(paste0('RFMix2/output/RFMix2_output_chr',1,'.msp.tsv'),nThread=6)
for (chr in 2:22){ #change to 2:22 ultimately
  msp <- rbind(msp,
      fread(paste0('RFMix2/output/RFMix2_output_chr',chr,'.msp.tsv'),nThread=6))
}

### Prints message to user
print("Generating .bed files; should take about 1 minute")

### Creates a table of values for each ancestry for each subpopulation
for (subpop in 1:length(subpops)){
  ### Creates matrix of the first 6 columns and the columns specific to each subpopulation
  samples <- which(whole_query_df[,3] == subpops[subpop])
  samp_cols <- 1:6
  for (sample in samples){
    samp_cols <- c(samp_cols, 6+(sample*2-1):(sample*2))}
  subpop_df <- as.matrix(msp)[,samp_cols]
  ### Creates list of matricies, one for each chromosome within subpop_df
  chr_array <- list()
  for (chr in 1:22){  chr_array[[chr]] <- subpop_df[subpop_df[,1] == chr,]  }
  ### Analyses and makes .bed file for each sample within the subpop as below
  for (col_num in 7:ncol(subpop_df)){
    ### runs rle on all columns for that subpop
    rle_on_cols <- lapply(1:22, function(x) rle(chr_array[[x]][,col_num]))
    ### Makes dataframe for entry, to be saved as .bed file
    bed_format <- bed_copy <- data.frame(chrom=integer(0), begin=integer(0), end=integer(0), assignment=integer(0), cmBegin=numeric(0), cmEnd=numeric(0))
    for (chr in 1:22){
      ### Makes identical blank dataframe for entry for this one chromosome, to be rbound to the bottom of the initial df "bed_format"
      bed_format_chr <- bed_copy
      ### Alters rle output for each chromosome to allow data extraction below
      chr_output <- data.frame(unclass(rle_on_cols[[chr]])) 
      chr_output$lengths <- cumsum(chr_output$lengths)
      chr_output <- rbind(c(1,1), chr_output)
      for (frag in 2:nrow(chr_output)){
        ### fill up bed_format, then alter with intersect stuff from reverse
        start <- as.numeric(chr_array[[chr]][chr_output$lengths[frag-1],
                                             c(1:6,(col_num))])
        end <- as.numeric(  chr_array[[chr]][chr_output$lengths[frag],
                                             c(1:6,(col_num))])
        bed <- c(start[c(1,3)], end[c(3,7)], start[5], end[5])
        bed_format_chr[(frag-1),] <- bed }
      ### Corrects row 1, which has spos and sgpos as epos and egpos of frag 1
      bed_format_chr[1,c(1,2,5)] <- as.numeric(chr_array[[chr]][1,c(1,2,4)])
      ### Appends chr-specific df to whole-genome df
      bed_format <- rbind(bed_format, bed_format_chr)
      }    
      ### Find ID based on index of rle_on_cols
      ID <- whole_query_df$ID[samples[ceiling((col_num-6)/2)]]
      ID <- strsplit(ID, "_")[[1]][1]
      ### Assign letter (A for 1st haplotype, B for second) and subpop fpath
      AorB <- ifelse((col_num %% 2 == 1), "A", "B")
      fpath <- paste0("./analysis/bed_files/", subpops[subpop], "/")
      ### Writes to .bed file after removing previously-generated file
      unlink(paste0(fpath, ID, "_anc_", AorB, "_cM.bed"))
      write.table(bed_format, file=paste0(fpath, ID, "_anc_", AorB, "_cM.bed"), sep="\t", col.names=FALSE, row.names=FALSE)
  }
}
