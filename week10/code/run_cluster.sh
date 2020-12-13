#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=1gb
module load anaconda3/personal
echo "R is about to run"
R --vanilla < $HOME/hpc/bjn20_HPC_2020_cluster.R
mv output_file* $HOME/hpc/output_files
echo "R has finished running"
