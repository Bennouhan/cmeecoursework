
### Index unphased query files
bcftools index -f \
../data/unphased/"${1}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_"${1}".vcf.gz
### Make directories for phasing output
mkdir -p ../data/phased/"${1}"/
### Run Shapeit4 with that reference
shapeit4 \
--input ../data/unphased/"${1}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_"${1}".vcf.gz \
--map ../data/gen_maps/chr"${1}".b38.gmap.gz \
--region "${1}" \
--output ../data/phased/"${1}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_"${1}".vcf.gz \
--reference ../data/reference/shapeit4/CCDG_14151_B01_GRM_WGS_2020-08-05_chr"${1}".filtered.shapeit2-duohmm-phased_header.vcf.gz \
--seed 1 --thread 16 #number of ncpus!!
