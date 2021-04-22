#!/usr/bin/env python3


from pathlib import Path


### Delete file, make new one, initialise set
try:
    Path('../data/RFMix2/query_vcfs/query_list.txt').unlink()
except FileNotFoundError:
    pass

query_list = open('../data/RFMix2/query_vcfs/query_list.txt', "w+")
line_num_ls = set()

samples_line_num = 0
with open("../data/sample_maps/ind_3pop_popgroup.txt") as samples:
    for line in samples:
        samples_line_num += 1
        words = line.split()
        if words[2] == "ADM" and words[1] != "PEL":
            line_num_ls.add(samples_line_num)
            print(words[0] + "_" + words[0], file=query_list)

samples.close()
query_list.close()

