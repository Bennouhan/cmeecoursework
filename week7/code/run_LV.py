#!/usr/bin/env python3

""" Script to print runtime of other python scripts

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import sys
import importlib
import cProfile
import pstats
import io
import os


def profile_py(fname, arg):
    """
    Import file as module, profiles running of main function, processes and prints results
    
    Args:
        fname (string): relative path from working directory of script to be tested
        arg (list): List of whatever argument the tested file requires, with a None inserted in position 0 since no filename in argvar[0]

    Returns:
        -
    """
    ### Import file as module
    sans_ext = fname.split(".")[0] #remove .py
    i = importlib.import_module(sans_ext)
    
    ### Profile running of main function while preventing its printing
    pr = cProfile.Profile()
    print("Profiling", fname, "...")
    pr.enable() #start profiling
    old_stdout = sys.stdout             #v
    sys.stdout = open(os.devnull, "w")  #prevents output
    if arg is not None and len(arg) == 4:
        i.main(*arg) #calls main function with arg objects as arguments
    else: 
        i.main(arg)  #calls main function, uses arg as sys.argv
    sys.stdout = old_stdout             #^
    pr.disable() #stops profiling
    
    ### Create and fill buffer with profile stats
    s = io.StringIO()
    p = pstats.Stats(pr, stream=s)
    p.print_stats(0).sort_stats('calls')
    #sort by number of calls; first will be total run of function
    #change number to change which is printed
    
    ### Print profiling results
    print(fname, "profile:", s.getvalue())
    #Note 2 self:https://docs.python.org/3/library/profile.html for more details
    return None

def main(argv):
    """
    Calls function on all 4 LVn.py files
    """
    
    ### Profile LV1.py
    profile_py("LV1.py", None)
    
    ### Profile LV2.py
    profile_py("LV2.py", (None, 1., .1, 1.5, 0.75))
    
    ### Profile LV3.py
    profile_py("LV3.py", (1., .1, 1.5, 0.75))
    
    ### Profile LV4.py
    profile_py("LV4.py", (1., .1, 1.5, 0.75))

    
    return None
        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
