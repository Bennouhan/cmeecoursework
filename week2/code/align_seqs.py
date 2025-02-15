#!/usr/bin/env python3

"""
Programme that takes the DNA sequences from two (argued or default) FASTA files
and saves the best alignment along with the corresponding score in a single
text file - includes alignments with partial overlap of strands at both ends.
"""

__author__ = 'Ben Nouhan(b.nouhan.20@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import csv
import re

def get_seqs(in_fpath):
    """
    Reads the file entered as argument, adds each row as a string to a list
    called seqs, extracts all letter characters from lines 1 and 2.
    
    Parameters:
    
    in_fpath - file path to text file containing the two desired sequences
    
    
    Returns:
    
    seq1 - sequence on first line of input file
    seq2 - sequence on second line of input file
    """
    f = open(in_fpath, 'r')
    csvread = csv.reader(f)
    seqs = [str(row) for row in csvread]
    seq1 = re.sub('[^A-Z]+', "", seqs[0])
    seq2 = re.sub('[^A-Z]+', "", seqs[1])
    return seq1, seq2


def calculate_score(s1, s2, l1, l2, startpoint): 
    """
    Computes score of the alignment given as parameters, 1 point per matching
     base pair, and prints a representation of the alignment with said score.
     
    Parameters:
    
    s1 - longer input sequence, with (l2-1)*"."s appended to either end 
    s2 - shorter input sequence
    l1 - length of s1 prior to "."s appendage to either end
    l2 - length of s2
    startpoint - point along s1 at which alignment calc_score with s2 is occurrs
    
    
    Returns:
    
    score - number of matched bases between s1 and s2
    matched - sequence of "."s, "-"s and "*"s to annotate alignment
    shift - "."s before s2 to indicate there are no matches between sequences
    end_shift - "."s after s2 to indicate there are no matches between sequences
    """
    matched = "" # to hold string displaying alignements
    score = 0
    for i in range(l2):  
        if (i + startpoint) < (l1 + l2 - 1): 
            if l2 - i > startpoint + 1:
                matched = matched + "."  #dots before they start overlapping
            elif s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*" #matched bases
                score = score + 1 #adds one to score
            else:
                matched = matched + "-" #not matched bases
    shift, end_shift = startpoint * ".", (l2 + l1 - startpoint - 2) * "."
    # dots at end, but only up until end of dots tailing l1
    # if startpoint is bigger than l1-2, end shift is less than l2 according to
    # this formula. the below check stops it from getting less than l2.
    if startpoint < l1 - 1:
        print(shift + matched + end_shift)
    else:
        print(shift + matched + (l2 - 1) * ".")
    print(shift + s2 + end_shift)
    print(s1)
    print(str(score) + "\n")
    return score, matched, shift, end_shift


def main(argv):
    """
    Gets input from files, assigns longer seq to s1 & vv, calculates scores,
    and saves highest-scoring alignment in new file with explanation
    """
    
    ### gets data from csv, sets variables
    seq1, seq2 = get_seqs('../data/seq.csv')
    
    
    # Assign the longer sequence to s1, and the shorter to s2
    l1, l2 = len(seq1), len(seq2)
    if l1 >= l2:
        s1, s2 = ((l2 - 1) * "." + seq1 + (l2 - 1) * "."), seq2
        #puts l2-1 "."s both sides of l1, allows alignment of all overlap combos
    else:
        s1, s2 = ((l1 - 1) * "." + seq2 + (l1 - 1) * "."), seq1
        l1, l2 = l2, l1 

    # writes alignment(s) with highest score into output file
    my_best_score = -1 #so 0 beats best score
    for i in range(l1 + l2 -1):
        score, matched, shift, end_shift = calculate_score(s1, s2, l1, l2, i)
        #assigns returns from calc_score function to these variables
        if score > my_best_score:
            my_best_score = score
            statement = "This alignment occurs when the smaller strand (" + \
            str(l2) + "nt in length) attaches from base " + str(i - l2 + 2) + \
            " of the larger strand, with the highest score of " + str(score) + \
            ":\n"
            #statement explaining the alignment in detail
            best_comparison_highSP =  (shift + matched + (l2 - 1) * "." + "\n")
            best_comparison_lowSP = (shift + matched + end_shift + "\n")
            best_s2, best_s1 = (shift + s2 + end_shift + "\n"), (s1 + "\n\n\n")
            #formats the matching, s1 and s2 lines to line-up neatly
            if i < l1 - 1:
                best_alignment = (str(statement) + str(best_comparison_lowSP) \
                + str(best_s2) + str(best_s1))
            else:
                best_alignment = (str(statement) + str(best_comparison_highSP) \
                + str(best_s2) + str(best_s1))
            # uses returned variables to write a statement about the alignment 
            # giving its score and startpoint, and assigns 3 lines of alignment 
            # (s1, s2 and matching bases) to a variable each for later printing
    f = open('../results/seqs_align.txt', 'w')
    f.write(best_alignment)
    f.close()
    print("Done!")
    return None
        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
