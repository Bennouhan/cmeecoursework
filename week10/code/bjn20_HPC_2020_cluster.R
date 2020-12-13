# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: jrosinde_HPC_2020_cluster.R
#
# Date: 10 Dec 2020
#
# Arguments: -
# 
# Output: output_file_[1:100].rda - Rda files containing the ouput of each simulation; see jrosinde_HPC_2020_main.R question 17 for more details
#
# Desc: Imports functions from jrosinde_HPC_2020_main.R, runs 100 simulations with the cluster_run() function, 25 with each population size

### Clear all graphics and workspace
graphics.off(); rm(list=ls())

### Inherit workspace from main file
#source("bjn20_HPC_2020_main.R")
source("/rds/general/user/bjn20/home/hpc/bjn20_HPC_2020_main.R")

### Get job number, set seed
iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))
#for (iter in c(1,20,40,60,80,100)){ #for testing
set.seed(iter)

### Assigns size of community and seed based off of iter number
pop_sizes <- c(500, 1000, 2500, 5000)
itersPerSize <- 100 / length(pop_sizes)
nPop <- pop_sizes[ceiling(iter/itersPerSize)]

### Runs function, params: speciation rate, popsize, wall time, richness and octave intervals, burn-in period (gens), output filename
cluster_run(0.0052206,nPop,690,5,20,nPop*8,paste0("output_file_",iter,".rda"))

### For testing
#}; load(file = "output_file_20.rda"); length(oct_vect)
