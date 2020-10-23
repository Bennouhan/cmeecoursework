
"""Reads .csv file (data/testcsv.csv), extracts species name and bodymass\
 columns, and writes into a new file (results/bodymass.csv)"""


import csv

__author__ = 'Ben Nouhan (b.nouhan.20@imperial.ac.uk)'
__version__ = '0.0.1'

# Read a file containing:
# 'Species','Infraorder','Family','Distribution','Body mass male (Kg)'
f = open('../data/testcsv.csv','r')
csvread = csv.reader(f)
temp = []
for row in csvread:
    temp.append(tuple(row))
    print(row)
    print("The species is", row[0])

f.close()

# write a file containing only species name and Body mass
f = open('../data/testcsv.csv','r')
g = open('../results/bodymass.csv','w')

csvread = csv.reader(f)
csvwrite = csv.writer(g)
for row in csvread:
    print(row)
    csvwrite.writerow([row[0], row[4]])

f.close()
g.close()
