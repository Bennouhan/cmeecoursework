#!/usr/bin/env python3

"""Programme that takes the DNA sequences as an input from a single external file and saves
the best alignment along with its corresponding score in a single text file"""

__author__ = 'Ben Nouhan (b.nouhan.20@imperial.ac.uk)'
__version__ = '0.0.1'

import ipdb
import sys
import csv
import re


def get_seqs(in_fpath):
    """Reads the file entered as argument, adds each row as a string to a list called seqs"""
    f = open(in_fpath, 'r')
    csvread = csv.reader(f)  # requires import csv
    global seqs  # assign variable globally
    seqs = [str(row) for row in csvread]


def calculate_score(s1, s2, l1, l2, startpoint): #need to make implicit loop to try each startpoint, choose highest score, give corresponding seqeunce side by side
    """Computes score of the alignment given as parameters, 1 point per matching base pair"""
    matched = "" # to hold string displaying alignements
    score = 0
    for i in range(l2): # shorter seq
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*" #matched bases
                score = score + 1 #adds one to score
            else:
                matched = matched + "-" #not matched bases
    shift = startpoint * "."
    print(shift + matched)
    print(shift + s2)
    print(s1)
    print(str(score) + "\n") 
    return score


def output_seq(out_fpath):
    """Writes best alignment into argued file"""
    g = open(out_fpath, 'w')
    csvwrite = csv.writer(g)
    #print("." * startpoint + matched)
    #print("." * startpoint + s2) #include these (but best only somehow)? make it more clear, do as Q says tho
    # find way to make this 1 line with newlines
    csvwrite.writerow([my_best_align])
    csvwrite.writerow([s1])
    csvwrite.writerow(["Score: " + str(my_best_score)])
    g.close()


def main(argv):  # start with all assignments (except ones that must be assigned later) then everything else including calling functions defined above
    """Gets input from file, assigns longer seq to s1 & v.v., calculates scores, and saves highest-scoring in new file"""

    ### gets data from csv, sets variables, converts to stings, removes non-A-Z chars
    get_seqs('../data/seq.csv')
    seq1 = re.sub('[^A-Z]+', "", seqs[0]) #requires import re
    seq2 = re.sub('[^A-Z]+', "", seqs[1])
    
    ### Assign the longer sequence to s1, and the shorter to s2
    global s1
    l1 = len(seq1)
    l2 = len(seq2)
    if l1 >= l2:
        s1 = seq1
        s2 = seq2
    else:
        s1 = seq2
        s2 = seq1
        l1, l2 = l2, l1  # swap the two lengths

    ### finds alignment with highest score
    global my_best_align, my_best_score  # way around this? ask
    #global my_best_score
    my_best_align = None
    my_best_score = -1 #so 0 beats it
    for i in range(l1): # make this a function?
        z = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
            my_best_align = ("." * i + s2)
            my_best_score = z
    print(my_best_align)
    print(s1)
    print("Best score:", my_best_score)

    ### outputs best alignment
    output_seq('../results/best_align.csv')


if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)


#Convert align_seqs.py to a Python program that takes the DNA sequences as an input from a single external file and saves the best alignment along
#with its corresponding score in a single text file(your choice of format and file type) to an appropriate location.

# No external input should be required that is , you should still only need to use python align_seq.py to run it. For example, the input file can be
# a single .csv file with the two example sequences given at the top of the original script.
