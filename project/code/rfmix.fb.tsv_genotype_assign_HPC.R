##### Script to analyse RFMix2 output .fb.tsv file, using haplotypes to assign genotypes for more efficiet analysis later on which can be done on the local machine


### Clear workspace, set working directory
rm(list = ls())
#setwd('~/cmeecoursework/project/data/') #for local
setwd('~/project/data/') #for ssh, IMPORTANT!

### Import packages
library(parallel)
library(data.table,warn.conflicts=F) #needs installing

### Define Functions
assign_genotype <- function(sample_num, nrow){
### Takes sample number and a row (genomic window), assigns genotype for the given sample at the given window
  eur_hom <-0; nat_hom <-0; afr_hom <-0; eur_nat <-0; afr_eur <-0; afr_nat <-0
  haps <- as.numeric(fb[nrow, (sample_num*6-1):(sample_num*6+4)])
  if (sort(haps)[5] > 0.9){
    geno <- which(round(haps) == 1)
          if(setequal(geno, c(2,5))){
            eur_hom <- eur_hom + 1
    }else if(setequal(geno, c(3,6))){
            nat_hom <- nat_hom + 1
    }else if(setequal(geno, c(1,4))){
            afr_hom <- afr_hom + 1
    }else if(setequal(geno, c(2,6)) | setequal(geno, c(3,5))){
            eur_nat <- eur_nat + 1
    }else if(setequal(geno, c(1,5)) | setequal(geno, c(2,4))){
            afr_eur <- afr_eur + 1
    }else if(setequal(geno, c(1,6)) | setequal(geno, c(3,4))){
            afr_nat <- afr_nat + 1 }}
  return(c(eur_hom, nat_hom, afr_hom, eur_nat, afr_eur, afr_nat))
}

sum_pop_genotypes <- function(sample_nums, nrow){
### Takes subpop sample number vector and a row (genomic window), sums the genotypes of given subpop for that window
  output <- lapply(sample_nums,function(x) assign_genotype(x,nrow))
  # output = list, 1 obj for each sample of the query population eg PEL, giving the genotype in binary form (see analyse_haps return for order)
  output <- array(as.numeric(unlist(output)), dim=c(1, 6, length(sample_nums)))
  return(as.numeric(rowSums(output, dim=2)))
}



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
subpops <- c("PEL", "MXL", "CLM", "PUR", "ASW", "ACB")

### Reads fb files; sets important parameters
ncores <- 16
if (length(commandArgs(trailingOnly=TRUE)) > 1){
  ncores <-   as.numeric(commandArgs(trailingOnly=TRUE)[2]) }
chr <- as.numeric(commandArgs(trailingOnly=TRUE)[1]) #mandatory CL argument!
################ Reads fb file #################################################
fb <- fread(paste0('RFMix2/output/RFMix2_output_chr',chr,'.fb.tsv'), 
            nThread=ncores)
################################################################################
range <- 1:nrow(fb) #when not testing
if (length(commandArgs(trailingOnly=TRUE)) > 2){
  range  <- 1:as.numeric(commandArgs(trailingOnly=TRUE)[3]) }

### Create count input table with each genotype at each position
count_table <- data.frame(row.names=paste0(rep(subpops, each=6), rep(c("_eur_hom", "_nat_hom", "_afr_hom", "_eur_nat", "_afr_eur", "_afr_nat"),6)))

### For each admixed subpopulation... 
for (subpop in subpops){
  # finds which samples by number in query file correspond to each subpop
  assign(subpop, which(whole_query_df$Subpop == subpop))
  # analyses each subpop, tallying their genotypes at each position
  output <- mclapply(range, function(x)
                      sum_pop_genotypes(get(subpop), x), mc.cores=ncores)
  # Populates input table with the sum_pop_genotypes outputs for each subpop
  count_table <- rbind(count_table, as.data.frame(do.call(cbind, output)))
}

### Creates directories if don't exist, and deletes past outputs if exists
dir.create(file.path("../results/"), showWarnings=FALSE)
dir.create(file.path("../results/analysis/"), showWarnings=FALSE)
dir.create(file.path("../results/analysis/count_tables/"), showWarnings=FALSE)
unlink(paste0("../results/analysis/count_tables/chr",chr,".rds"))
# save to results not data to avoid any overwriting; will never be saved in data on local computer

### Name columns and save, to be used when consolidating the chromosomes prior to final analysis 
colnames(count_table) <- as.character(fb$physical_position[range])
saveRDS(count_table, paste0("../results/analysis/count_tables/chr",chr,".rds"))
### NB: just save() saves name also. readRDS(file = "my_data.rds") to read:
# test <- readRDS(file = paste0("../results/analysis/count_tables/chr",chr,".rds"))
# 300 rows takes 32 seconds, so the full file would take 1.7 hours, which would be 1.7 * (1/0.017676) = 96 hours for the full chromosome