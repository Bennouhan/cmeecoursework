#!/usr/bin/env python3

__author__ = 'Ben Nouhan (b.nouhan.20@imperial.ac.uk)'

# Script: 1_prep_data.py
#
# Date: 21 Oct 2020
#
# Argument: -
#
# Output: '../data/preped_data.csv' - Dataframe prepared for analysis

"""Script to import growth data from .csv file, assign each entry from each 
experiment a unique integer experiment ID, and saves it to a new .csv file in 
../data/ called 'preped_data.csv' for subsequent analysis"""


import pandas


### Imports growth data .csv as panda dataframe, deletes obsolete column "X"
data = pandas.read_csv("../data/LogisticGrowthData.csv")
data.drop(['X'], axis=1, inplace=True)

### Labels rows with IDs unique to each experiment, and converts to hash values
data.insert(0, "Experiment_ID", data.Species + "_" + 
            data.Temp.map(str) + "_" + data.Medium + "_" + data.Citation)
data['Experiment_ID'] = abs(data['Experiment_ID'].apply(hash))

### Writes adapted data frame to new .csv
data.to_csv('../data/preped_data.csv')
