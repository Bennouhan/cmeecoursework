#!/usr/bin/env python3

"""Programme that takes the DNA sequences as an input from a single external file and saves
the best alignment along with its corresponding score in a single text file
!!!!!!But this includes partial overlap of strands at bth ends, not just latter!!!!!!"""

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
    global matched #################change 4##################### allows best match to be saved later
    matched = "" # to hold string displaying alignements
    score = 0
    for i in range(l2):  
        if (i + startpoint) < (l1 + l2 - 1):  #####################change 3################## shows matches all the way along
            if l2 - i > startpoint + 1:
                matched = matched + "."  #dots before they start overlapping
            elif s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*" #matched bases
                score = score + 1 #adds one to score
            else:
                matched = matched + "-" #not matched bases
    global shift, end_shift, global_startpoint
    global_startpoint = startpoint
    shift = startpoint * "."
    end_shift = (l2 + l1 - startpoint - 2) * "." #dots at end, but only up until end of dots tailing l1
    if startpoint > 14:
        print(shift + matched + (l2 - 1) * "." )
    else:
        print(shift + matched + end_shift)
    print(shift + s2 + end_shift)
    print(s1)
    print(str(score) + "\n")
    return score


def output_seq(out_fpath):
    """Writes best alignment into argued file"""
    g = open(out_fpath, 'w')
    csvwrite = csv.writer(g)
    if my_best_startpoint > l1 - 2:
        csvwrite.writerow([my_best_shift + my_best_matched + (l2 - 1) * "."])
    else:
        csvwrite.writerow([my_best_shift + my_best_matched + my_best_end_shift])
    csvwrite.writerow([my_best_shift + my_best_align + my_best_end_shift])
    csvwrite.writerow([s1])
    csvwrite.writerow(["The best alignment occurs when the smaller strand (" + str(l2) + "nt in length) attaches from base " + str(my_best_startpoint - l2 + 2) + " of the larger strand, with a score of " + str(my_best_score) + "."])
    g.close()


def main(argv):  # start with all assignments (except ones that must be assigned later) then everything else including calling functions defined above
    """Gets input from file, assigns longer seq to s1 & v.v., calculates scores, and saves highest-scoring in new file"""
    
    ### gets data from csv, sets variables, converts to stings, removes non-A-Z chars
    get_seqs('../data/seq.csv')
    seq1 = re.sub('[^A-Z]+', "", seqs[0]) #requires import re
    seq2 = re.sub('[^A-Z]+', "", seqs[1])
    
    ### Assign the longer sequence to s1, and the shorter to s2
    global s1, s2, l1, l2 #allows the write function to use these
    l1 = len(seq1)
    l2 = len(seq2)
    if l1 >= l2:
        s1 = ((l2 - 1) * "." + seq1 + (l2 - 1) * ".") ############CHANGE 1########## - adds the extra dots to left of l1
        s2 = seq2
    else:
        s1 = ((l1 - 1) * "." + seq2 + (l1 - 1) * ".") ##############################
        s2 = seq1
        l1, l2 = l2, l1  # swap the two lengths

    ### finds alignment with highest score
    global my_best_align, my_best_score, my_best_matched, my_best_shift, my_best_end_shift, my_best_startpoint #allows the write function to use these
    my_best_align = None
    my_best_score = -1 #so 0 beats it
    for i in range(l1 + l2 -1): ###############change 2################ - makes l2 move across the whole way
        z = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
            my_best_align = (s2) ######### nb: used to be i * "." + s2, but compounded with my_best_shift below.
            my_best_score = z
            my_best_matched = matched ############changed################
            my_best_shift = shift
            my_best_end_shift = end_shift
            my_best_startpoint = global_startpoint
    if my_best_startpoint > l1 - 2:
        print(my_best_shift + my_best_matched + (l2 - 1) * ".")
    else:
        print(my_best_shift + my_best_matched + my_best_end_shift)
    print(my_best_shift + my_best_align + my_best_end_shift)
    print(s1)
    print("The best alignment occurs when the smaller strand (" + str(l2) + "nt in length) attaches from base " + str(my_best_startpoint - l2 + 2) + " of the larger strand, with a score of " + str(my_best_score) + ".")

    ### outputs best alignment
    output_seq('../results/best_align.csv')


if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
