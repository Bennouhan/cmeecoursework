#PBS -lselect=1:ncpus=500:ompthreads=500:mem=6000gb
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
-m ../data/sample_maps/sample_map_no_admix.txt \
-g ../data/gen_maps/rfmix2_altered/chr${PBS_ARRAY_INDEX}.b38.alt.gmap \
-o ../data/RFMix2/output/RFMix2_output_chr${PBS_ARRAY_INDEX} \
--chromosome=${PBS_ARRAY_INDEX}

## Warning: excessive genetic drift loss during simulated population generation. Reference panel is too unbalanced. Program may not exit simulation loop.
# some subpop samples too small?

# nb https://github.com/slowkoni/rfmix/issues/5 - can duplicate samples to bolster small sample sizes rather than delete, and there's another option too - cause of what's wrong?

# if not enough cpus again, try single node 48 ncpus https://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/computing/job-sizing-guidance/high-throughput/ (24 hour max runtime tho)
# failing that, play with above stuff, or try large memory option https://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/computing/job-sizing-guidance/large-memory/


# The command qstat -w -T can be used to show projected start times for jobs. These are estimates, not guarantees. Use them for guidance but do not rely on them. They may in some cases be quite inaccurate.