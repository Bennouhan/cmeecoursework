### Setup Required Every Time

# Connect to VPN (find ID with nmcli con, might change over time?)
nmcli con up d40351d6-52cf-4060-ac8c-d6691f6808f9

# start secure shell
ssh -XY bjn20@login.cx1.hpc.ic.ac.uk
# (enter imperial password)

# load conda software
module load anaconda3/personal

# Root to my main project directory
cd ~/project/data

# code
cd ~/project/code
cd ~/project/data/unphased/22/

# Root to lab dir
cd ~/../projects/human-popgen-datasets/live


# FUll details: http://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/support/getting-started/using-ssh/

../data/admixture/admixture/merge.3.Q
../data/sample_maps/ind_3pop_popgroup.txt
../data/sample_maps/ind_3pop_popgroup_no_admixture.txt


### Utilities

# To unzip .gz file:
gunzip #fname
# To unzip tar.gz file:
tar -zxvf file.tar.gz

# Copy file between ssh and local
scp ~/cmeecoursework/project/code/*shapeit4*  bjn20@login.cx1.hpc.ic.ac.uk:~/project/code/

# View reduced version of bcf or vcf file
bcftools view file.ext | less

# Count lines of bcf or vcf file (ie gives num variants), ignoring hashes
bcftools view file.ext | grep -v '^#' | wc -l #takes a couple mins (for chr22)

# Get example HPC job script:
module load my-first-job
make-templates
#throughput-array most relevent?

### Using conda (and first time setup)

#On the login node run: (must be done each login)
module load anaconda3/personal

#if its the first time loading you will need to run: (already done)
anaconda-setup

# Check if file exists
FILE=../data/unphased/"${chr}"/HGDP_1000g_regen_no_AT_CG_3pop_geno05_"${chr}".vcf.gz.csi
if test -f "$FILE"; then
    echo "$FILE exists."
fi




### Loading programmes needed:

conda install -c bioconda shapeit4
conda install -c bioconda rfmix
conda install -c bioconda admixture
conda install -c bioconda bcftools
conda install -c bioconda plink

#or all in one go
conda install -c bioconda shapeit4 rfmix admixture bcftools plink

#solve bcftools bug (which didnt arise on local machine)
conda update -n base -c defaults conda

conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

conda install -c bioconda -y samtools
conda install python-3.7 #create issues later on? see below
conda install openssl=1.0

#### NB
## reverting to python3.7 lead to this
# conda-package-handli | 915 KB    | ################################# | 100% 
# setuptools-49.6.0    | 947 KB    | ################################# | 100% 
# ruamel_yaml-0.15.80  | 252 KB    | ################################# | 100% 
# pysocks-1.7.1        | 27 KB     | ################################# | 100% 
# conda-4.9.2          | 3.0 MB    | ################################# | 100% 
# certifi-2020.12.5    | 143 KB    | ################################# | 100% 
# numpy-1.18.1         | 5.2 MB    | ################################# | 100% 
# python_abi-3.7       | 4 KB      | ################################# | 100% 
# pycosat-0.6.3        | 107 KB    | ################################# | 100% 
# scipy-1.4.1          | 18.8 MB   | ################################# | 100% 
# cffi-1.14.5          | 224 KB    | ################################# | 100% 
# chardet-4.0.0        | 204 KB    | ################################# | 100% 
# cryptography-3.4.6   | 1.1 MB    | ################################# | 100% 
# six-1.15.0           | 14 KB     | ################################# | 100% 
# pip-21.0.1           | 1.1 MB    | ################################# | 100% 
# brotlipy-0.7.0       | 346 KB    | ################################# | 100% 
# python-3.7.10        | 45.2 MB   | ################################# | 100% 

## then openssl=1.0 (which fails with python3.9 hence downgrade) leads to this
# pyopenssl-19.0.0     | 81 KB     | ################################# | 100% 
# cryptography-2.5     | 643 KB    | ################################# | 100% 
# python-3.7.1         | 36.4 MB   | ################################# | 100% 
# shapeit4-4.1.3       | 251 KB    | ################################# | 100% 
# libssh2-1.8.0        | 246 KB    | ################################# | 100% 
# asn1crypto-1.4.0     | 78 KB     | ################################# | 100% 
# sqlite-3.28.0        | 1.9 MB    | ################################# | 100% 
# cffi-1.14.4          | 224 KB    | ################################# | 100% 
# curl-7.61.0          | 859 KB    | ################################# | 100% 
# openssl-1.0.2u       | 3.2 MB    | ################################# | 100% 
# htslib-1.9           | 1.2 MB    | ################################# | 100% 
# libffi-3.2.1         | 47 KB     | ################################# | 100% 
# readline-7.0         | 391 KB    | ################################# | 100% 
# krb5-1.14.6          | 4.0 MB    | ################################# | 100% 

### This leads to bcftools 1.8, rather than 1.9 on local machine
# may be other discrepencies. NB local machine had python3.8, this was 3.9, here downgraded to 3.7 so maybe 3.8 would work - do if other software versions need later update.



### Random stuff

head ../data/sample_maps/sample_map_no_admix.txt


ls ../data/RFMix2/query_vcfs
ls ../data/phased/
ls ../data/gen_maps/rfmix2_altered/

ls ../data/RFMix2/output/



cat eo/rfmix2/3352997/run_rfmix2.sh.e3352997.21

PBS_ARRAY_INDEX=22

cat ../data/sample_maps/sample_map_no_admix.txt | wc -l
cat ../data/RFMix2/query_vcfs/query_list.txt

# referece (all samples, sample map specifies which to be used)
bcftools view ../data/phased/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz | less

# query (admixed only)
bcftools view ../data/RFMix2/query_vcfs/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_${PBS_ARRAY_INDEX}.vcf.gz | less

PBS_ARRAY_INDEX=22