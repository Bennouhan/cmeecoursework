### Manual: https://github.com/austin-putz/Admixture


### Convert vcf to plink format (.ped)
plink --vcf HG_filtered.vcf --maf 0.05 --recode --out plink/myplink


### Run Admixture
admixture plink/myplink.ped 3 #3 ancestral populations
# input file error :(





### from alex tidd (replaces the above):
# IDs necessary? Pruning ncessary? Apropriate plink format to run admixture with?

#Generate distinct variant IDs for later PLINK wrangling. Sets the ID field to a unique value: CHROM:POS:REF:ALT, in the VCF file 
mkdir -p ../data/admixture/IDs
for chr in {11..22}; do
    bcftools annotate -Oz -x ID -I +'%CHROM:%POS:%REF:%ALT' \
    ../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.vcf.gz\
     > ../data/admixture/IDs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.vcf.gz ;
    bcftools index ../data/admixture/IDs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.vcf.gz ;
done


#Convert the VCF files to PLINK format
mkdir -p ../data/admixture/PLINK
for chr in {1..22}; do
    plink --noweb --vcf ../data/admixture/IDs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.vcf.gz \
    --keep-allele-order --vcf-idspace-to _ --const-fid --allow-extra-chr 0 --split-x b38 no-fail --make-bed \
    --out ../data/admixture/PLINK/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.genotypes ;
done

##Identify and remove any duplicates
mkdir -p ../data/admixture/no_duplicates
for chr in {1..22}; do
    plink --noweb --bfile ../data/admixture/PLINK/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.genotypes \
    --list-duplicate-vars ids-only ;
    plink --noweb --bfile ../data/admixture/PLINK/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.genotypes \
    --exclude plink.dupvar --make-bed \
    --out ../data/admixture/no_duplicates/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.genotypes ;
    rm plink.dupvar ;
done

#Prune variants from each chromosome (changed parameters for pruning)
mkdir -p ../data/admixture/pruned
for chr in {1..22}; do
    plink --noweb --bfile ../data/admixture/no_duplicates/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.genotypes \
    --maf 0.05 --indep 50 5 2 \
    --out ../data/admixture/pruned/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.genotypes ;

    plink --noweb --bfile DupsRemoved/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes \
    --extract ../data/admixture/pruned/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.genotypes.prune.in \
    --make-bed --out ../data/admixture/pruned/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${chr}.genotypes ;
done

#Get a list of all PLINK files
mkdir -p ../data/admixture/PLINK_merged pca #pca may not be needed, maybe delete
find ../data/admixture/ -name "*.bim" | grep -e "Pruned" > merge.list.temp ;#may be an error here, not sure where the bim files are, use right dir
sed 's/.bim//g' merge.list.temp > PLINK_merged/merge.list ;
rm merge.list.temp ;

#Merge all projects into a single PLINK fileset
plink --merge-list PLINK_merged/merge.list --out PLINK_merged/merge ;
#run admix here? see top of file for failed attempt
../Code/admixture_pop_file.R 
#calls this file, sort this out! will need to be pretty different, see email from alex and the sample file (i think) to see different population names.
#Is this even needed? just a figure? where is admixture run?