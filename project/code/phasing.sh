# Format:

# shapeit4 --input unphased.vcf.gz\ #what alex gives me, shouldnt need to do anything else to it
#          --map chr20.b37.gmap.gz\ #b38 - supposedly best for phase 3 1000g
#          --region 20\ #chromosome
#          --output phased.vcf.gz\ #output name
#          --seed 123456 #for reproducibility
# if using bcf, just replace v with b in input and output




# Reference panel:

# Taking into account reference haplotypes when phasing can improve the accuracy of the estimates, especially when the number of reference haplotypes is much large than the number of individuals to be phased.
# To do so, include the following between --region and --output:
#  --reference reference.bcf

# SHAPEIT4 only retain variants that are in the overlap (i.e. intersection) between the two panels specified with --input and --reference.
# In practice, it proceeds exactly the same way than bcftool isec -c none and therefore keeps only variants with chromosome ID, position, REF and ALT alleles that perfectly match between the two panels.

# The file specified by --reference needs to be indexed. This can be done using bcftools index reference.bcf.

# As 100g data is already phased, should be able to use it as reference panel, and 1000g data should be ignored when phasing

# Code:

# Use this for each run for each chromosome

#!!!!!!!!!!!!!!!!!!!!!!v
#NB: The file provided to --input needs to be indexed. This can be done using bcftools index unphased.vcf.gz.





###  reference
# In theory I suppose simply splitting dataset, leaving only 1000g and saving as reference_chr${chr}.bcf could act as reference?
# 3 sets of sample columns: (non-contiguous ranges)
#  - HG00096_HG00096 to HG04303_HG04303
#  - HGDP00449_HGDP00449 to HGDP01419_HGDP01419
#  - NA06984_NA06984 to NA20832_NA20832

# let's assume we want the HGs only:
# (see https://samtools.github.io/bcftools/bcftools.html#common_options)
# (use Ob, v or u depending on format alex gives)

# allows to choose which you view, but doesnt save and doesnt allow for range yet (only list)
#bcftools view -s HG00096_HG00096 HGDP_1000g_3pop_22.phased.vcf | less

#bcftools view -s HG00096_HG00096 HGDP_1000g_3pop_22.phased.vcf > filtered.vcf #creates new subset

#may be easier to use -S not -s to create a file to read from?



# ### Changes to correct dir
# cd ~/project/code

# ### Makes array of all individual codes
# inds_array=($(cut -d' ' -f1 ../data/sample_maps/ind_3pop_popgroup.txt))
# ### Filters out HGDP codes and formats: code -> code_code
# inds_array_subset=()
# for i in "${inds_array[@]}"; do
#     if [[ $i != HGDP* ]]; then
#         inds_array_subset+=($i\_$i)
#     fi
# done
# #printf '%s\n' "${inds_array_subset[@]}"
# printf -v inds_list_subset '%s,' ${inds_array_subset[@]}

# # bcftools view -s ${inds_list_subset%,} --force-samples HGDP_1000g_3pop_22.phased.vcf > HG_filtered.vcf #will be named by chr num when done on each chromosome

# #according to alex this filtered vcf can be used as reference? since it's phased? seems to not be the case, obselete





# ### Rough structure, incomplete
# echo "Running SHAPEIT4"
# for chr in {22..22} ; do
#     ### Run bcftools with list to create reference file, filtering out HGDPs
#     bcftools view -s ${inds_list_subset%,} --force-samples \
#     ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_"${chr}".vcf.gz > \
#     ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_ref_"${chr}".vcf
#     bgzip -c \
#     ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_ref_22.vcf > \
#     ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_ref_22.vcf.gz
#     ### Index unphased query and ref files
#     bcftools index -f \
#     ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_"${chr}".vcf.gz
#     bcftools index -f \
#     ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_ref_"${chr}".vcf.gz
#     ### Make directories for phasing output
#     mkdir -p ../data/phased/"${chr}"/
#     ### Run Shapeit4 with that reference
#     shapeit4\
#     --input ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_"${chr}".vcf.gz\
#     --map ../data/gen_maps/chr"${chr}".b38.gmap.gz\
#     --region "${chr}"\
#     --output ../data/phased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_"${chr}".vcf.gz\
#     --reference ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_ref_"${chr}".vcf.gz\
#     --seed 1
# done
# # RESULT OUTPUT:
# # Initialization:
# #   * VCF/BCF scanning [Nm=1690 / Nr=1411 / L=328451 / Reg=22] (210.70s)
# #   * VCF/BCF parsing [Hom=91.6% / Het=8.3% / Mis=0.0%] (266.32s)

# # WARNING: 195 missing genotypes in the reference panel (randomly imputed)

# # WARNING: 463444361 unphased genotypes in the reference panel (randomly phased)
# #   * GMAP parsing [n=45141] (0.12s)
# # Illegal instruction (core dumped)



#karyogram after? see run.sh line



# Return line with all names

# bcftools view HGDP_1000g_regen_no_AT_CG_3pop_geno05_1.vcf.gz | less | grep -v '^##' | head -1
# | wc -w = 1699, so about 1699 HGDPs I assume; ind_...txt has 1690 so looks eqivalent









#troubleshooting index issue

##fileformat=VCFv4.2
##FILTER=<ID=PASS,Description="All filters passed">
##fileDate=20210329
##source=PLINKv1.90
##contig=<ID=22,length=50805810>
##INFO=<ID=PR,Number=0,Type=Flag,Description="Provisional reference allele, may not be based on real reference genome">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##INFO=<ID=AC,Number=A,Type=Integer,Description="Allele count in genotypes">
##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
##bcftools_viewVersion=1.8+htslib-1.8

##fileformat=VCFv4.2
##FILTER=<ID=PASS,Description="All filters passed">
##fileDate=20210329
##source=PLINKv1.90
##contig=<ID=22,length=50805810>
##INFO=<ID=PR,Number=0,Type=Flag,Description="Provisional reference allele, may not be based on real reference genome">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##bcftools_viewVersion=1.8+htslib-1.8
##bcftools_viewCommand=view HGDP_1000g_regen_no_AT_CG_3pop_geno05_22.vcf.gz; Date=Wed Mar 31 13:51:00 2021


### SECOND ATTEMPT, ON LOCAL MACHINE: gets to later point, then...
# Burn-in iteration [1/5]
#   * V2H transpose (0.90s)
#   * PBWT selection (5.82s)
#   * C2H transpose (0.08s)
#   * HMM computations [K=534.075+/-226.446 / W=2.42Mb] (1752.28s)
# free(): invalid pointer
# Aborted



##### ATTEMPT 2 WITH ALTERNATIVE REF FILE ##########

### Get to right dir
cd ~/project/code

### Clear previous outputs
rm -r -f -d ../data/phased/* ../data/unphased/*/*.csi

### Rough structure, incomplete
echo "Running SHAPEIT4"
for chr in {1..22} ; do
    ### Index unphased query files
    bcftools index -f \
    ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_"${chr}".vcf.gz
    ### Make directories for phasing output
    mkdir -p ../data/phased/"${chr}"/
    ### Run Shapeit4 with that reference
    shapeit4\
    --input ../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_"${chr}".vcf.gz\
    --map ../data/gen_maps/chr"${chr}".b38.gmap.gz\
    --region "${chr}"\
    --output ../data/phased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_"${chr}".vcf.gz\
    --reference ../data/reference/shapeit4/CCDG_14151_B01_GRM_WGS_2020-08-05_chr"${chr}".filtered.shapeit2-duohmm-phased_header.vcf.gz\
    --seed 1
done

# using CCDG ref file: (csi or tbi file doesnt seem to matter)
#ERROR: No variants to be phased in files

# skipping ref altogether: 
# Illegal instruction (core dumped)

# trying with 21 instead of 22:
# same issue

# CORE DUMPED ISSUE: 
# https://github.com/odelaneau/shapeit4/issues/28
# avx2 an issue? way to update?