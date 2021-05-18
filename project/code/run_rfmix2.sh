#PBS -lselect=1:ncpus=32:mem=124gb
#PBS -lwalltime=5:59:0
#PBS -J 1-22

### Load modules for any applications
module load anaconda3/personal

### Change to the right directory
cd ~/project/code


### Remove files generated from previous runs
rm -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_merged_shapeit4_${PBS_ARRAY_INDEX}.* \
../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz.csi \
../data/RFMix2/output/RFMix2_output_chr${PBS_ARRAY_INDEX}*


### Create query sample subset of vcf.gz files
bcftools view -S "../data/RFMix2/query_vcfs/query_list.txt" --force-samples \
../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz > \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf
bgzip -c \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf > \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz #zip the result
bcftools index -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz #index the result


### Create PEL-only (<0.99) query sample subset of vcf.gz files
bcftools view -S "../data/RFMix2/query_vcfs/PEL_sub_99.txt" --force-samples \
../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz > \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_shapeit4_${PBS_ARRAY_INDEX}.vcf
bgzip -c \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_shapeit4_${PBS_ARRAY_INDEX}.vcf > \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz #zip the result
bcftools index -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz #index the result


### Rename PEL samples to [PEL].1 (includes >0.99) and [PEL].2 (sub 0.99 only)
bcftools reheader --samples "../data/RFMix2/query_vcfs/query_list_renamed.txt" \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
-o ../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_renamed_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz
bcftools reheader --samples "../data/RFMix2/query_vcfs/PEL_sub_99_renamed.txt" \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
-o ../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_renamed_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz
bcftools index -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_renamed_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz
bcftools index -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_renamed_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz
#index the results

### Merge the renamed full query set to the renamed PEL_sub_99 set
bcftools merge --merge all \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_renamed_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_renamed_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
-O v > ../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_merged_shapeit4_${PBS_ARRAY_INDEX}.vcf #merge the files
bgzip -c \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_merged_shapeit4_${PBS_ARRAY_INDEX}.vcf > \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_merged_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz #zip the result


### Delete all files previously generated except PEL_merged*.vcf.gz & its index
rm -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.* \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_shapeit4_${PBS_ARRAY_INDEX}.* \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_renamed_shapeit4_${PBS_ARRAY_INDEX}.* \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_sub_99_renamed_shapeit4_${PBS_ARRAY_INDEX}.* \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_merged_shapeit4_${PBS_ARRAY_INDEX}.vcf #no * or .gz and index deleted


### Index new merged query files and reference files
bcftools index -f \
../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_merged_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz
bcftools index -f \
../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz
#index the results


### Run RFMix2
rfmix \
-f ../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_PEL_merged_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
-r ../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
-m ../data/sample_maps/sample_map_no_admix.txt \
-g ../data/gen_maps/rfmix2_altered/chr${PBS_ARRAY_INDEX}.b38.alt.gmap \
-o ../data/RFMix2/output/RFMix2_output_chr${PBS_ARRAY_INDEX} \
--chromosome=${PBS_ARRAY_INDEX} \
--n-threads=32 -G 19 -e 3 #32 ncpus, 19 generations of admixture extimate, 3 runs of algorith (default is 1)
