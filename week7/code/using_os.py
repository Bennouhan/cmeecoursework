#!/usr/bin/env python3

""" Script demonstrating use of subprocess.os.walk

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import sys
import subprocess


def main(argv):
    """ Performs the below exercises
    
    """
    

    # Use the subprocess.os module to get a list of files and directories
    # in your ubuntu home directory

    # Hint: look in subprocess.os and/or subprocess.os.path and/or
    # subprocess.os.walk for helpful functions


    #################################
    #~Get a list of files and directories in your home/ that start with an uppercase 'C'

    home = subprocess.os.path.expanduser("~")
    Cname = []
    for (dir, subdir, files) in subprocess.os.walk(home):
        Cname = Cname + [name for name in files or subdir if name.startswith("C")]

    #################################
    # Get files and directories in your home/ that start with either an upper or lower case 'C'

    cname = []
    for (dir, subdir, files) in subprocess.os.walk(home):
        cname = cname + [name for name in files or subdir if name.lower().startswith("c")]

    #################################
    # Get only directories in your home/ that start with either an upper or lower case 'C'

    cdir = []
    for (dir, subdir, files) in subprocess.os.walk(home):
        cdir = cdir + [name for name in subdir if name.lower().startswith("c")]


    return None


if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)