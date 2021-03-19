#https://github.com/armartin/ancestry_pipeline good pipeline BUT rfmix 1.5
#https://github.com/slowkoni/rfmix rfmix2 original source

#Thanks again for this information. My attempts at improving phasing seem to have done the trick with regard to resolving the multiple switch-errors. I am using Shapeit4, and the trick was to include a reference phased VCF during phasing. Previously, I was just running Shapeit4 on the query data with no external reference. I decided to use the same reference VCF for Shapeit as I was using for RFmix, and this seems to have produced mostly sensible results.

#Ahh, I had not realized that her scripts did reference based phasing. What I've done is essentially the same then, I believe. I have a reference VCF (taken from 1000Genomes), which was already phased. I then used this phased reference VCF when phasing my query data. RFMix2 will take the phased BCF as input, so no conversion is necessary for me after running shapeit. We do remove rare and duplicated SNPs as well as ones that violate HWE expectation.

# type just "rfmix" to show all options. will be run on HPC, will need to install there(?)


# See notes in notebook for input info (notes from manual.md)





####### FROM ALEX TIDD'S: ##########

for chr in {1..22} ; do #do for every number, representing chromosomes, 1-22
    bcftools query -f '%POS\n' filtered/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf | wc -l # wc -l counts lines
    #bcftools requires installation
done

echo "####RFMIX RUN####"
#Creating the subsetted bcf files for the QUERY and REFERENCE populations
echo "Creating the subsetted BCF files for the query and reference populations..."
mkdir query_pop reference_pop
for chr in $(seq $lowerchr $upperchr); do
    bcftools view --samples-file "${query_population_prefix}_ids.txt" --force-samples filtered/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf -Ob > query_pop/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf ;
    bcftools index query_pop/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf ;
    
    bcftools view --samples-file "${ref_populations_prefix}_ids.txt" --force-samples filtered/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf -Ob > reference_pop/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf ;
    bcftools index reference_pop/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf ;
done

#Writing the reference sample map. Reference sample map file for RFMIXv2.03 - The reference sample map used in the input for RFMIXv2.03 matches reference samples to their respective reference population. It consists of a tab-delimited text file with two columns: [Sample ID][Population]. The reference sample mape file is created during the run by wrangling the sample info file.
echo "Writing the reference sample map for RFMIXv2..."
mkdir rfmixout
../Code/reference_sample_map.R ${ref_populations[@]} ;
cp filtered_"${ref_populations_prefix}"_reference_sample_map.txt ./rfmixout


#### ACTUAL RUN WITH RFMIX COMMANDS ####################################
#Running RFMIX.
echo "Running RFMIX"
for chr in $(seq $lowerchr $upperchr); do
    rfmix \
    --query-file=query_pop/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf \
    --reference-file=reference_pop/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf \
    --sample-map=rfmixout/filtered_${ref_populations_prefix}_reference_sample_map.txt \
    --genetic-map=1000_Genomes_Phase3/reordered_rfmixv2/genetic_map_chr"${chr}"_combined_b37.txt \
    -o rfmixout/rfmix_output_chr"${chr}" \
    --chromosome=${chr} ;
done

#Plotting the RFMIX output on karyograms and pie charts can be done in the . Calculating global ancestry proportions. By summing up local ancestry proportions, global ancestry propportions can be obtained.




#test
for chr in {1..22} ; do 
    echo ${chr}
done