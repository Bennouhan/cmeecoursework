#PBS -lselect=1:ncpus=16:mem=124gb
#PBS -lwalltime=71:0:0


### Load modules for any applications
module load anaconda3/personal

### Change to the right directory
cd ~/project/code


### Merging
#Get a list of all PLINK files
rm -r -f -d ../data/admixture/PLINK_merged/
mkdir -p ../data/admixture/PLINK_merged 

find ../data/admixture/ -name "*.bim" | grep -e "no_duplicates" > ../data/admixture/PLINK_merged/merge.list.temp ;#may be an error here, not sure where the bim files are, use right dir
sed 's/.bim//g' ../data/admixture/PLINK_merged/merge.list.temp > ../data/admixture/PLINK_merged/merge.list ;
rm ../data/admixture/PLINK_merged/merge.list.temp ;

#Merge all projects into a single PLINK fileset
plink --merge-list ../data/admixture/PLINK_merged/merge.list --out ../data/admixture/PLINK_merged/merge


### Admixture
rm -r -f -d ../data/admixture/admixture/
mkdir -p ../data/admixture/admixture/
cd ../data/admixture/admixture/
admixture ../PLINK_merged/merge.bed 3 -j16 #16 ncpus in theory; 3 ancestral pops
# want SE estimates? see bottom of https://github.com/austin-putz/Admixture



### RFMix2 Prep
# Make relevent dirs
cd ~/project/code
mkdir -p ../data/RFMix2/query_vcfs/ ../data/RFMix2/output/ ../data/gen_maps/rfmix2_altered
# Make the reference sample map and the list of query samples
python3 make_ref_samplemap.py
python3 make_ref_samplemap_balanced.py
python3 make_query_list.py
# Alter genetic map files
for chr in {1..22}; do
    rm -f ../data/gen_maps/rfmix2_altered/chr${chr}.b38.alt.gmap #rm old files
    gunzip ../data/gen_maps/chr${chr}.b38.gmap.gz
    tail -n +2 ../data/gen_maps/chr${chr}.b38.gmap | \
    awk ' { t = $1; $1 = $2; $2 = t; print; } '  > \
    ../data/gen_maps/rfmix2_altered/chr${chr}.b38.alt.gmap
    gzip ../data/gen_maps/chr${chr}.b38.gmap
done
