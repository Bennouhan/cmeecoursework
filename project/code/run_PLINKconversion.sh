#PBS -lselect=1:ncpus=16:mem=124gb
#PBS -lwalltime=1:0:0
#PBS -J 1-22


### Load modules for any applications
module load anaconda3/personal

### Change to the right directory
cd ~/project/code

#Generate distinct variant IDs for PLINK wrangling. Sets the ID field to a unique value: CHROM:POS:REF:ALT.
rm -r -f -d ../data/admixture/IDs/*shapeit4_${PBS_ARRAY_INDEX}.*
mkdir -p ../data/admixture/IDs

bcftools annotate -Oz -x ID -I +'%CHROM:%POS:%REF:%ALT' \
../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
> ../data/admixture/IDs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz ;
bcftools index ../data/admixture/IDs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz ;
echo "ID assignment successful"

#Convert the VCF files to PLINK format
rm -r -f -d ../data/admixture/PLINK/*shapeit4_${PBS_ARRAY_INDEX}.*
mkdir -p ../data/admixture/PLINK

#changing parameters give alternative result?
plink --noweb --vcf ../data/admixture/IDs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz \
--keep-allele-order --vcf-idspace-to _ --const-fid --allow-extra-chr 0 --split-x b38 no-fail --make-bed \
--out ../data/admixture/PLINK/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes ;
echo "VCF to PLINK conversion successful"


##Identify and remove any duplicates
rm -r -f -d ../data/admixture/no_duplicates/*shapeit4_${PBS_ARRAY_INDEX}.*
mkdir -p ../data/admixture/no_duplicates

plink --noweb --bfile ../data/admixture/PLINK/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes \
--list-duplicate-vars ids-only ;
plink --noweb --bfile ../data/admixture/PLINK/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes \
--exclude plink.dupvar --make-bed \
--out ../data/admixture/no_duplicates/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes ;
rm plink.dupvar ;
echo "Duplicate removal successful"


#NB - may not be necessary. used by run_admixture_pruned.sh, skipped by un_admixture.sh
##Prune variants from each chromosome (changed parameters for pruning)
rm -r -f -d ../data/admixture/pruned/*shapeit4_${PBS_ARRAY_INDEX}.*
mkdir -p ../data/admixture/pruned

#will chnaging parameters give thebalternative results?
plink --noweb --bfile ../data/admixture/no_duplicates/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes \
--maf 0.05 --indep 50 5 2 \
--out ../data/admixture/pruned/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes ;

plink --noweb --bfile ../data/admixture/no_duplicates/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes \
--extract ../data/admixture/pruned/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes.prune.in \
--make-bed --out ../data/admixture/pruned/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.genotypes ;
echo "Pruning successful"
