#!/usr/bin/env python3

"""Conditional functions for various calculations"""

import sys

__author__ = 'Ben Nouhan (b.nouhan.20@imperial.ac.uk)'
__version__ = '0.0.1'




def foo_1(x):
    """
    Calculates and returns the squareroot of the argument
    
    Parameters:

    x - number to be squarerooted


    Returns:

    squareroot of x   
    """
    return x ** 0.5



def foo_2(x, y):
    """
    Returns the larger of the two arguments
    
    Parameters:

    x - number to be compared to y
    y - number to be compared to x
    

    Returns:

    the larger of x or y  
    """
    if x > y:
        return x
    return y



def foo_3(x, y, z):
    """
    Returns the 3 arguments in order of size ascending
    
    Parameters:

    x, y, z - numbers to be ordered by size


    Returns:

    x, y, z (in ascending order)
    """
    if x > y:
        tmp = y
        y = x
        x = tmp
    if y > z:
        tmp = z
        z = y
        y = tmp
    return x, y, z



def foo_4(x):
    """
    Calculates and returns the factorial of the argument, using a different\
     method from foo_5 and foo_6
     
    Parameters:

    x - number of which to find the factorial


    Returns:

    factorial of x   
    """
    result = 1
    for i in range(1, x + 1):
        result = result * i
    return result



def foo_5(x):  # a recursive function that calculates the factorial of x
    """
    Calculates and returns the factorial of the argument, using a different\
     method from foo_4 and foo_6
     
    Parameters:

    x - number of which to find the factorial


    Returns:

    factorial of x   
    """
    if x == 1:
        return 1
    return x * foo_5(x - 1)



def foo_6(x):
    """
    Calculates and returns the factorial of the argument, using a different\
     method from foo_4 and foo_5
    
    Parameters:

    x - number of which to find the factorial


    Returns:

    factorial of x   
    """
    facto = 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return facto



def main(argv):
    """Demonstrates the foo_[1-6] functions using arbitrary arguments, by\
     printing the output"""
    print(foo_1(121))
    print(foo_2(94, 3))
    print(foo_3(13, 6, 44))
    print(foo_4(4))
    print(foo_5(5))
    print(foo_6(6))
    return 0


if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
