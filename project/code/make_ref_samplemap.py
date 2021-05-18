#!/usr/bin/env python3


from pathlib import Path


### Delete file, make new one, initialise set
try:
    Path('../data/sample_maps/sample_map_no_admix.txt').unlink()
except FileNotFoundError:
    pass

new_map = open('../data/sample_maps/sample_map_no_admix.txt', "w+")
query_list = open('../data/RFMix2/query_vcfs/query_list.txt', "a")
### Files for duplicating the PEL samples with bcftools, one set including the >99% and one without
PEL_sub_99 = open('../data/RFMix2/query_vcfs/PEL_sub_99.txt', "w+")
PEL_sub_99_renamed = open('../data/RFMix2/query_vcfs/PEL_sub_99_renamed.txt', "w+")


line_num_ls = set()
nat_query_line_ls = set()

### create blank structures for the counting of each subpop - keep commented
# sub_pop_set = set()
# sub_pop_ls = []
# pop_set = set()
# pop_ls = []



### Populate set with sample numbers with >99% EUR/AFR purity, or >95% NAT
admix_line_num = 0
with open("../data/admixture/output/HGDP_1000g_regen_no_AT_CG_3pop_geno05_shapeit4_allchr_pruned.3.Q") as admix:
    for line in admix:
        admix_line_num += 1
        probs = line.split()
        if float(probs[0]) >= 0.99 or \
           float(probs[1]) >= 0.99 or \
           float(probs[2]) >= 0.99:
            line_num_ls.add(admix_line_num)
        if float(probs[0]) < 0.99:
            nat_query_line_ls.add(admix_line_num)

### Print corresponding lines from sample map into new sample map
f=open("../data/sample_maps/ind_3pop_popgroup.txt")
lines=f.readlines()
for line in range(1690):
    if line+1 in line_num_ls:
        words = lines[line].split()
        # Excludes ADM samples
        if words[2] == "ADM" and words[1] != "PEL":
            continue
        else:
            if words[1] == "PEL":
                words[2] = "NAT"
            # Counts each pop and sub-pop
            # sub_pop_set.add(words[1])#
            # sub_pop_ls.append(words[1])#
            # pop_set.add(words[2])#
            # pop_ls.append(words[2])#
            # Saves writes all remaining non-ADM samples to file
            print(words[0] + "_" + words[0] + "\t" + words[2] + \
                                              "\t" + words[1], file=new_map)
        #NB: may want to filter out small subpop sizes here, especially n=1
    ### Adds PEL samples not used in reference panel to query list as x.2_x.2
    if line+1 in nat_query_line_ls:
        words = lines[line].split()
        if words[1] == "PEL":
            print(words[0] + "_" + words[0], file=PEL_sub_99)
            print(words[0] + ".2_" + words[0] + ".2", file=PEL_sub_99_renamed)


### Close files
query_list.close()
admix.close()
new_map.close()
f.close()
PEL_sub_99.close()
PEL_sub_99_renamed.close()


# ### Counts each subpop, writes to file:
# sub_pop_count = open('../data/sample_maps/sub_pop_count.txt', "w+")
# print("Sub-population\tCount", file=sub_pop_count)


# for sub_pop in sub_pop_set:
#     print(sub_pop + "\t" + str(sub_pop_ls.count(sub_pop)), file=sub_pop_count)


# for pop in pop_set:
#     print(pop + "\t" + str(pop_ls.count(pop)), file=sub_pop_count)


# sub_pop_count.close()

