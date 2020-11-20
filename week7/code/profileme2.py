#!/usr/bin/env python3

""" Script to run some arbitrary functions, with improved efficiency over profileme.py, to use as test for profiling

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import scipy as sc
import sys


def my_squares(iters):
    """Finds square of all numbers in range of 1:argument in a vecorised fashion within a preallocated scipy array

    Args:
        iters (integer): Any integer for its range to be squared

    Returns:
        out (list): Scipy array of all squares of all numbers in range of 1:argument
    """
    out = sc.array((range(iters)))
    out = out**2
    return out


def my_join(iters, string):
    """Generates a String of "string" repeated "iter" times using implicit string concatenation

    Args:
        iters (integer): Any integer
        string (string): Any string to be repeated "iter" times

    Returns:
        out (string): String of "string" repeated "iter" times
    """
    out = ''
    for i in range(iters):
        out += ", " + string
    return out


def run_my_funcs(x, y):
    """Prints the two arguments together, then feeds them into my_squares() and my_join()

    Args:
        x (integer): Any integer to feed into my_squares() or my_join()
        y (string): Any string to feed into my_join()

    Returns:
        -
    """
    print(x, y)
    my_squares(x)
    my_join(x, y)
    return 0



def main(argv):
    """
    Tests the above functions, to use as an example for profiling
    """
  
    run_my_funcs(10000000, "My string")
    
    
    return None
        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)

#%run with: run -p profileme.py
# See profiling section in book to understand output