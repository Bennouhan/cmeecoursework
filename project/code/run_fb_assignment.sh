#PBS -lselect=1:ncpus=16:mem=124gb
#PBS -lwalltime=24:9:0
#PBS -J 1-22


### Load modules for any applications
module load anaconda3/personal

### Change to the right directory
cd ~/project/code

### Run R script
Rscript rfmix.fb.tsv_genotype_assign_HPC.R ${PBS_ARRAY_INDEX} 16 100
