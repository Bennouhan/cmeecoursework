#!/usr/bin/env python3

""" Script demonstrating use of subprocesses to run .R files and manipulate their output

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import sys
import subprocess


def main(argv):
    """ Shows how fmr.R can be used as a sub-process in python
    
    """
    
    stdout, stderr = subprocess.Popen(["Rscript", "fmr.R"], stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    print("Running fmr.R: \n")
    print(stdout.decode())
    if stderr.decode() == "":
        print("fmr.R ran successfully")
    else:
        print("fmr.R failed to run, see error message below:\n", stderr.decode())
    
    #alternative: use the file output method, and read files. Better if we also want the output files, but this is simpler if not
    
    
    
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
    
