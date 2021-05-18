#PBS -lselect=1:ncpus=16:mem=124gb
#PBS -lwalltime=71:59:00
#PBS -J 1-22


### Load modules for any applications
module load anaconda3/personal

### Change to the right directory
cd ~/project/code

### Clear previous outputs
rm -r -f -d ../data/phased/${PBS_ARRAY_INDEX}/* ../data/unphased/${PBS_ARRAY_INDEX}/*.csi

### Index unphased query files
bcftools index -f \
../data/unphased/${PBS_ARRAY_INDEX}/HGDP_1000g_regen_no_AT_CG_3pop_geno05_${PBS_ARRAY_INDEX}.vcf.gz
### Make directories for phasing output
mkdir -p ../data/phased/${PBS_ARRAY_INDEX}/

### Run Shapeit4 with that reference
shapeit4 \
--input ../data/unphased/${PBS_ARRAY_INDEX}/HGDP_1000g_regen_no_AT_CG_3pop_geno05_${PBS_ARRAY_INDEX}.vcf.gz \
--map ../data/gen_maps/chr${PBS_ARRAY_INDEX}.b38.gmap.gz \
--region ${PBS_ARRAY_INDEX} \
--output ../data/phased/${PBS_ARRAY_INDEX}/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
--reference ../data/shapeit4/reference/CCDG_14151_B01_GRM_WGS_2020-08-05_chr${PBS_ARRAY_INDEX}.filtered.shapeit2-duohmm-phased_header.vcf.gz \
--thread 16
