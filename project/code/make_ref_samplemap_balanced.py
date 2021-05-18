#!/usr/bin/env python3


from pathlib import Path
from random import sample, seed

### Delete file, make new one, initialise set - uncomment when one decided upon
# try:
#     Path('../data/sample_maps/sample_map_no_admix_balanced.txt').unlink()
# except FileNotFoundError:
#     pass

new_map = open('../data/sample_maps/sample_map_no_admix_400balanced.txt', "w+")


# creates sets of pops and subpops - ONLY NEEDED FOR UTILITY LOOPS BELOW
sub_pop_set = set()
sub_pop_ls = []
pop_set = set()
pop_ls = []

### Populate set with PEL & non-ADM samples w/ >99% purity EUR/AFR or >95% NAT ancestry
sample_tup_ls = [] # create list of tuples
with open("../data/sample_maps/sample_map_no_admix.txt") as non_admix:
    for line in non_admix:
        words = line.split()
        # Populates list of tuples
        sample_tup_ls.append(tuple(words))
        ## populates set of pops and set of subpops - ONLY NEEDED FOR UTILITY LOOPS BELOW
        sub_pop_set.add(words[1])#
        sub_pop_ls.append(words[1])#
        pop_set.add(words[2])#
        pop_ls.append(words[2])#





### Create sets and lists of eur and afr samples for undersampling:
exclusion_ls = []
eur_ls = []
afr_ls = []
eur_pop_set = set()
afr_pop_set = set()

### Populates these eur and afr lists
for tup in sample_tup_ls:
    if tup[2] == "EUR":
        eur_ls.append(tup)
        eur_pop_set.add(tup[1])
    if tup[2] == "AFR":
        afr_ls.append(tup)
        afr_pop_set.add(tup[1])

### Randomly samples from subpopulations larger than 10 (EUR) or 12 (AFR), adding all but 10 or 12 to a list which will be excluded when writing the new file

seed(10) #set seed
eur_num = 71 #NB set to what you ultimately decide upon
afr_num = 61 

for pop in eur_pop_set: # Europeans
    temp_ID_ls = []
    for ID in eur_ls:
        if ID[1] == pop:
            temp_ID_ls.append(str(ID[0]))   
    if len(temp_ID_ls) > eur_num:
        temp_ID_ls = sample(temp_ID_ls, len(temp_ID_ls)-eur_num)
        exclusion_ls.extend(temp_ID_ls)

for pop in afr_pop_set: # Africans
    temp_ID_ls = []
    for ID in afr_ls:
        if ID[1] == pop:
            temp_ID_ls.append(str(ID[0]))   
    if len(temp_ID_ls) > afr_num:
        temp_ID_ls = sample(temp_ID_ls, len(temp_ID_ls)-afr_num)
        exclusion_ls.extend(temp_ID_ls)



### Print corresponding lines from sample map into new sample map
for tup in sample_tup_ls:
    if tup[0] in set(exclusion_ls):
        continue
    else:
        # Relabels PEL as native not ADM, as they're >95% NAT
        if tup[1] == "PEL":
            pop = "NAT"
        else:
            pop = tup[2]
        # Saves writes all remaining non-ADM samples to file, swaps pop and subpop round for RFMix
        print(tup[0] + "\t" + pop + "\t" + tup[1], file=new_map)
    #NB: may want to filter out small subpop sizes here, especially n=1

### Close files
non_admix.close()
new_map.close()









## Utility loops to count various things, obselete

# Count sample of each pop
for pop in pop_set:
    count = 0
    for tup in range(len(sample_tup_ls)):
        sample_pop = sample_tup_ls[tup][2]
        if sample_pop == pop:
            count += 1
    print(pop, "samples:", count)


# Count sub_pop of each pop
for pop in pop_set:
    count = 0
    sub_pop_temp = set()
    for tup in range(len(sample_tup_ls)):
        sample = sample_tup_ls[tup]
        if sample[2] == pop and sample[1] not in sub_pop_temp:
            count += 1
            sub_pop_temp.add(sample[1])
    print(pop, "subpops:", count)


# Count samples of each subpop, and which pop it belongs to
for pop in pop_set:
    print(pop, "SUB-POPULATION DISTRIBUTION:")
    for sub_pop in sub_pop_set:
        count = 0
        sample_temp = set()
        for tup in range(len(sample_tup_ls)):
            sample = sample_tup_ls[tup]
            if sample[2] == pop and sample[1] == sub_pop and sample[0] not in sample_temp:
                count += 1
                sub_pop_temp.add(sample[0])
        if count > 0:
            print(count, sub_pop)


