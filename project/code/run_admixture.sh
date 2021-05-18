#PBS -lselect=1:ncpus=16:mem=64gb
#PBS -lwalltime=71:0:0


### Load modules for any applications
module load anaconda3/personal

### Change to the right directory, set path variable
cd ~/project/code
fname=HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4

### Create relevent directories
rm -r -f -d ../data/admixture/merged/* ../data/admixture/pruned_plink/*
mkdir -p ../data/admixture/merged ../data/admixture/pruned_plink

### Merge chromosomes into one vcf file
bcftools concat ../data/phased/$fname\_{1..22}.vcf.gz \
        -O z -o ../data/admixture/merged/$fname\_allchr.vcf.gz
### Index and prune the merged file
tabix ../data/admixture/merged/$fname\_allchr.vcf.gz
plink --vcf-half-call missing \
--vcf ../data/admixture/merged/$fname\_allchr.vcf.gz --indep-pairwise 50 10 0.1 --out ../data/admixture/pruned_plink/pruned
### Convert to plink format
plink --vcf-half-call missing \
--vcf ../data/admixture/merged/$fname\_allchr.vcf.gz \
--extract ../data/admixture/pruned_plink/pruned.prune.in -make-bed \
--out ../data/admixture/pruned_plink/$fname\_allchr_pruned --threads 16


### Admixture
rm -r -f -d ../data/admixture/output/
mkdir -p ../data/admixture/output/
cd ../data/admixture/output/
admixture ../pruned_plink/$fname\_allchr_pruned.bed 3 -j16 #16 ncpus in theory; 3 ancestral pops
# want SE estimates? see bottom of https://github.com/austin-putz/Admixture


### RFMix2 Prep
# Make relevent dirs
cd ~/project/code
mkdir -p ../data/RFMix2/query_vcfs/ ../data/RFMix2/output/ ../data/gen_maps/rfmix2_altered
# Make the reference sample map and the list of query samples
python3 make_query_list.py
python3 make_ref_samplemap.py
### Alter genetic map files, swapping columns
for chr in {1..22}; do
    rm -f ../data/gen_maps/rfmix2_altered/chr${chr}.b38.alt.gmap #rm old files
    gunzip ../data/gen_maps/chr${chr}.b38.gmap.gz
    tail -n +2 ../data/gen_maps/chr${chr}.b38.gmap | \
    awk ' { t = $1; $1 = $2; $2 = t; print; } '  > \
    ../data/gen_maps/rfmix2_altered/chr${chr}.b38.alt.gmap
    gzip ../data/gen_maps/chr${chr}.b38.gmap
done
