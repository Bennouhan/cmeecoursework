#PBS -lselect=1:ncpus=32:mem=124gb
#PBS -lwalltime=71:0:0
#PBS -J 1-22


### Load modules for any applications
module load anaconda3/personal

### Change to the right directory
cd ~/project/code

### Remove files generated from previous runs
rm -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.* \
../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz.csi \
../data/RFMix2/output/RFMix2_output_chr${PBS_ARRAY_INDEX}

### Create query sample subset of vcf.gz files
bcftools view -S "../data/RFMix2/query_vcfs/query_list.txt" --force-samples \
../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz > \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf
bgzip -c \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf > \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz
rm -f ../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf

### Index new query files and reference files
bcftools index -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz
bcftools index -f \
../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz

### Run RFMix2
rfmix \
-f ../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
-r ../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
-m ../data/sample_maps/sample_map_no_admix_balanced.txt \
-g ../data/gen_maps/rfmix2_altered/chr${PBS_ARRAY_INDEX}.b38.alt.gmap \
-o ../data/RFMix2/output/RFMix2_output_chr${PBS_ARRAY_INDEX} \
--chromosome=${PBS_ARRAY_INDEX}

## Warning: excessive genetic drift loss during simulated population generation. Reference panel is too unbalanced. Program may not exit simulation loop. - but seems to get past this issue, ie "nternally simulated 434 samples from 102 randomly selected reference parents.
#=>> PBS: job killed: ncpus 39.46 exceeded limit 32 (sum)"



# some subpop samples too small? see below - change to 2.02?:
# I am running RFMIX on our lab's server as well as the university's computing cluster. The former uses the older version RFMIX v2.02-r1 and the latter the newer RFMIX v2.03-r0
# v2.02-r1 seems to work just fine, but v2.03-r0 keeps crashing when generating internal simulation samples.
# Generating internal simulation samples... Warning: excessive genetic drift loss during simulated population generation. Reference panel is too unbalanced. Program may not exit simulation loop.
# Is this is a bug, or has something changed between the two versions. They are using the exact same input files on both machines.
###NB - cant find 2.02, may not be an option



# nb https://github.com/slowkoni/rfmix/issues/5 - can duplicate samples to bolster small sample sizes rather than delete, and there's another option too - cause of what's wrong?
###NB - maybe make subset as I have in the past, rename, merge back into main? See if removing smaller helps first, if it doesn't then no point, and try the --crf-weight=3 command, altho since I get past the samples generation it may not be the issue...



# if not enough cpus again, try single node 48 ncpus https://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/computing/job-sizing-guidance/high-throughput/ (24 hour max runtime tho)
# failing that, play with above stuff, or try large memory option https://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/computing/job-sizing-guidance/large-memory/
# doing this now, runs on thursday