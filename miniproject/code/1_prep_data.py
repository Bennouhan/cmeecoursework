#!/usr/bin/env python3

__author__ = 'Ben Nouhan (b.nouhan.20@imperial.ac.uk)'

# Script: 1_prep_data.py
#
# Date: 21 Oct 2020
#
# Argument: -
#
# Output: ../data/preped_data.csv   - Dataframe prepared for analysis
#         ../data/ID_dictionary.csv - Dataframe with each experiment's full info

"""Script to import growth data from .csv file, assign each entry from each 
experiment a unique integer experiment ID, tidy/reorganise the data and saves it to a new .csv file in 
../data/ called 'preped_data.csv' for subsequent analysis"""

import pandas
from numpy import unique, log2
from pathlib import Path

Path('../data/preped_data.csv').unlink(missing_ok=True)
Path('../data/ID_dictionary.csv').unlink(missing_ok=True)


### Imports growth data .csv as panda dataframe
data = pandas.read_csv("../data/LogisticGrowthData.csv")


### Corrects instances where different repeats were conveyed as species.rep num
for i in range(len(data)):
    if data.loc[i, "Species"].endswith(".2") | data.loc[i, "Species"].endswith(".1"):
        data.loc[i, "Rep"] = int(data.loc[i, "Species"][-1]) #add number to Rep
        data.loc[i, "Species"] = data.loc[i, "Species"][:-2] #remove from Species

### Labels rows with IDs unique to each experiment, including repeat, and converts to hash values
data.insert(0, "ID", data.Species + "_" + data.Temp.map(str) + "_" + data.Medium + "_" + data.Rep.map(str) + data.Citation)
data['ID'] = data['ID'].apply(hash)


### Finds smallest, most convenient ID where all remain unique; robust for other datasets
n = 1
while len(unique(data['ID'])) != len(unique(data['ID'].apply(str).str[-n:])):
  n += 1
data['ID'] = data['ID'].apply(str).str[-n:]


### Time and population size value manipulation: negativity correction and logs
# Callibrates all experiments with negative time values to 0; systematic errors
for i in range(len(data)):
  if data.loc[i, "Time"]<0:
        ID, calib = data.loc[i, "ID"], data.loc[i, "Time"]
        data.loc[data["ID"] == ID, 'Time'] -= calib
# Deletes negative population values; some are likely irreconcilable errors
data.drop(data[data.PopBio < 0].index, inplace=True)
# Creates column with log2 of pop sizes; log2(x+1) transformation to cope with 0s
data['log2.Pop_Size'] = log2(data['PopBio']+1)


### Tidy and split data into two dataframes connected by Experiment IDs
# Gives more descriptive/merged colnames
data = data.rename({'Time':'Time_hrs', 'PopBio':'Pop_Size', "PopBio_units":"Pop_Size_units", 'Temp':'Temp_C', 'Rep':'Repeat'}, axis=1)
# Creates dictionary (not literally) of IDs and their contributing components
ID_dict = data[["ID",'Pop_Size_units','Temp_C','Medium','Species','Repeat',"Citation"]].drop_duplicates()
# Reorders columns to more intuitive order, excluding obsolete columns 
data = data[['ID', 'Time_hrs', 'log2.Pop_Size', 'Pop_Size', 'Pop_Size_units']]


### Writes adapted data frames to a new CSV file each
data.to_csv('../data/preped_data.csv', index=False)
ID_dict.to_csv('../data/ID_dictionary.csv', index=False)
