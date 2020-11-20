#!/usr/bin/env python3

""" Script to demonstrate use of timeit on functions imported from other scripts

"""


__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

from profileme2 import my_join as my_join
from profileme import my_join as my_join_join
from profileme2 import my_squares as my_squares_vec
from profileme import my_squares as my_squares_loops
import timeit
import sys

### Run this script, unhash the below, copy and paste it into ipython and run
# %timeit my_squares_loops(2000)
# %timeit my_squares_vec(2000)
# %timeit my_join_join(2000, "Random String")
# %timeit my_join(20000, "Random String")


def main(argv):
    """
    Sets arguments to be used in the timeit example
    """
    ##############################################################################
    # loops vs. vectorised: which is faster?
    ##############################################################################


    iters = 1000000


    ##############################################################################
    # loops vs. the join method for strings: which is faster?
    ##############################################################################

    mystring = "my string"

        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)

# Note to self: HOW TO CORRECT THE LINTING ERROR (UNDERLINED YELLOW) FOR CUSTOM MODULES:
# ctrl+shit+p, back space to rmove > if there, .vscode (will com up with settings.json)
# Go in here, add absoulte (from root) path to directory containing the module (script)
# NB, used to be "python.pythonPath: ["/bin/python3"]; changed to one that accepts multiple
