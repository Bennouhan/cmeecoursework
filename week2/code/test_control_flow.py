#!/usr/bin/env python3

"""Copy of control_flow.py, used to demonstrate the doctest module"""

__author__ = 'Ben Nouhan (b.nouhan.20@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import doctest # imports doctest module, allows it to run

def even_or_odd(x=0): # if not specified, x should take value 0.
    """Find whether a number x is even or odd.
    
    Parameters:

    x - number


    Returns:

    Statement that x is even or odd 


    >>> even_or_odd(10)
    '10 is Even!'

    >>> even_or_odd(5)
    '5 is Odd!'
    
    whenever a float is provided, then the closest integer is used:
    >>> even_or_odd(3.2)
    '3 is Odd!'

    in case of negative numbers, the positive is taken:    
    >>> even_or_odd(-2)
    '-2 is Even!'
    
    """
    ###function to be tested
    if x % 2 == 0: #
        return "%d is Even!" % x
    return "%d is Odd!" % x

def main(argv):
   print(even_or_odd(22))
   print(even_or_odd(33))
   doctest.testmod()
   return 0

if (__name__ == "__main__"):
   status = main(sys.argv)
   sys.exit(status)
