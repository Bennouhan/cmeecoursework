
### Clear workspace, set working directory
rm(list = ls())
setwd('~/cmeecoursework/project/data/') #for local
#setwd('~/project/data/') #for ssh, IMPORTANT!


### Read and concatenate each chromosome's genotype assignment
load(paste0("../results/analysis/count_tables/chr",22,".Rda"))
table <- count_table
for (chr in c(22, 22)){#2:22 #when ready; 1 above
  load(paste0("../results/analysis/count_tables/chr",chr,".Rda"))
  table <- cbind(table, count_table)
}

### Creates & names 19 (num needed by function for each subpop) blank rows
extra_rows <- data.frame(matrix(0, nrow=19, ncol=ncol(table)))
colnames(extra_rows) <- colnames(table)
new_row_names <- c("obs_eur", "obs_nat", "obs_afr", 
          "obs_eur_hom", "obs_nat_hom", "obs_afr_hom",
          "obs_eur_het", "obs_nat_het", "obs_afr_het",
          "exp_eur_hom", "exp_nat_hom", "exp_afr_hom",
          "exp_eur_het", "exp_nat_het", "exp_afr_het", 
          "AMI", "AMI_eur", "AMI_nat", "AMI_afr")

### Appends the 19 blank rows, and adds copies of it below each subpop's counts
table <- rbind(table, extra_rows)
table <- table[c(1:6, 37:55, 7:12, 37:55, 13:18, 37:55, 19:24, 37:55, 25:30, 37:55, 31:36, 37:55),]

### Rename row names apropriately, so each set of 25 consecutive rows correspond to one of six subpopulations, named for that subpopulation and: the 6 rows each that were previously there when loading, and the names in the new_row_names list above
subpops <- c("PEL", "MXL", "CLM", "PUR", "ASW", "ACB")
rownames <- paste0(rownames(table), "_geno_count")
rownames[c(7:25, 32:50, 57:75, 82:100, 107:125, 132:150)] <-
  paste0(rep(subpops, each=19), "_", new_row_names)
rownames(table) <- rownames


### Takes subpop sample number vector and a row (genomic window), sums the genotypes of given subpop for that window
analyse_column <- function(ncol, npop){
  ### Finds first row relevent to this subpop, creates vector of the 6 genotype counts, and sums them to find the total number of samples assigned with >90% confidence, of that subpop, at that position
  table[1:25,1] #for debugging, DELETE AFTER!!!!
  row1 <- npop*25-24 
  genotypes <- table[row1:(row1+5),ncol]
  nsamples <- sum(genotypes)
  ### Calculates and enters observed frequency for eur, nat and afr haplotypes
  table[row1+6,ncol] <- (genotypes[1] + (genotypes[4]+genotypes[5])/2) /nsamples
  table[row1+7,ncol] <- (genotypes[2] + (genotypes[4]+genotypes[6])/2) /nsamples
  table[row1+8,ncol] <- (genotypes[3] + (genotypes[5]+genotypes[6])/2) /nsamples
  ### Calculates and enters observed frequency for each genotype
  table[(row1+9):(row1+14),ncol]  <- genotypes/nsamples
  ### Calculates and enters expected frequency for each homozygous genotype
  table[(row1+15):(row1+17),ncol] <- table[(row1+6):(row1+8),ncol]^2
  ### Calculates and enters expected frequency for each heterozygous genotype
  table[(row1+18):(row1+20),ncol] <- c(2*table[row1+6,ncol]*table[row1+7,ncol],
                                       2*table[row1+8,ncol]*table[row1+6,ncol],
                                       2*table[row1+8,ncol]*table[row1+7,ncol])
  ### Calculates Assortative Mating Index (AMI) for subpop at that position
  table[row1+21,ncol] <- log((sum(table[(row1+ 9):(row1+11),ncol])/ #overall AMI
                              sum(table[(row1+15):(row1+17),ncol]))/
                             (sum(table[(row1+12):(row1+14),ncol])/
                              sum(table[(row1+18):(row1+20),ncol])))
  ### Calculates ancestry-specific AIMs for subpop at that position
  # NB - do these AMI_x values mean anything? ask 
  table[row1+22,ncol] <- log(table[row1+ 9,ncol]/table[row1+15,ncol]/ #AMI_eur
                             (sum(table[(row1+12):(row1+13),ncol])/
                              sum(table[(row1+18):(row1+19),ncol])))
  table[row1+23,ncol] <- log(table[row1+10,ncol]/table[row1+16,ncol]/ #AMI_nat
                             (sum(table[(row1+12):(row1+14),ncol])/
                              sum(table[(row1+18):(row1+20),ncol])))
  table[row1+24,ncol] <- log(table[row1+11,ncol]/table[row1+17,ncol]/ #AMI_afr
                             (sum(table[(row1+13):(row1+14),ncol])/
                              sum(table[(row1+19):(row1+20),ncol])))
}       
######## NB, when this is confirmed to work, vectorise down and accross by splitting the above into 2 functions (one vectorising the other) as in assign script













### NB - the resulting dataframe will be just under half as big as the chr1 fb
# chr1fb <- 350000 * 3500
# this   <- 350000 * 10 * 150