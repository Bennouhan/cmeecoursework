#!/usr/bin/env python3


from pathlib import Path


### Delete file, make new one, initialise set
try:
    Path('../data/RFMix2/query_vcfs/query_list.txt').unlink()
except FileNotFoundError:
    pass

query_list = open('../data/RFMix2/query_vcfs/query_list.txt', "w+")
query_list_renamed = open('../data/RFMix2/query_vcfs/query_list_renamed.txt', "w+")


with open("../data/sample_maps/ind_3pop_popgroup.txt") as samples:
    for line in samples:
        words = line.split()
        if words[2] == "ADM" and words[1] != "PEL":
            print(words[0] + "_" + words[0], file=query_list)
            print(words[0] + "_" + words[0], file=query_list_renamed)
        ### Renames whole PEL dataset - rfmix won't allow duplicates between query samples and reference panel - renames x.1_x.1
        elif words[1] == "PEL":
            print(words[0] + "_" + words[0], file=query_list)
            print(words[0] + ".1_" + words[0] + ".1", file=query_list_renamed)

samples.close()
query_list.close()
query_list_renamed.close()


######## NB!!!!!!!! bcftools won't recognise .1 and .2, will need to duplicate and rename them there first! possibly at end of run_admixture?
