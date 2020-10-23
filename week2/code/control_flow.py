#!/usr/bin/env python3

"""Some functions exemplifying the use of control statements"""


import ipdb
__author__ = 'Ben Nouhan (b.nouhan.20@imperial.ac.uk)'
__version__ = '0.0.1'

import sys


def even_or_odd(x=0): # if not specified, x should take value 0.
    """Find whether a number x is even or odd.
    
    Parameters:

    x - number


    Returns:

    Statement that x is even or odd 
    """
    if x % 2 == 0: #The conditional if
        return "%d is Even!" % x
    return "%d is Odd!" % x


def largest_divisor_five(x=120):
    """Find which is the largest divisor of x among 2,3,4,5.
    
    Parameters:

    x - number


    Returns:

    Statement giving largerst divisor of x (2-5) or no divisor
    """
    largest = 0
    if x % 5 == 0:
        largest = 5
    elif x % 4 == 0: #means "else, if"
        largest = 4
    elif x % 3 == 0:
        largest = 3
    elif x % 2 == 0:
        largest = 2
    else: # When all other (if, elif) conditions are not met
        return "No divisor found for %d!" % x 
        # Each function can return a value or a variable.
    return "The largest divisor of %d is %d" % (x, largest)

#ipdb.set_trace()  #allows enter ipdb command prompt mid-running of programme

def is_prime(x=70):
    """Find whether an integer is prime.
    
    Parameters:

    x - integer


    Returns:

    Statement that x is or is not a prime number
    """
    for i in range(2, x): #  "range" returns a sequence of integers
        if x % i == 0:
          print("%d is not a prime: %d is a divisor" % (x, i)) 
          return False
    print("%d is a prime!" % x)
    return True 


def find_all_primes(x=22):
    """Find all the primes up to x - requires is_prime(x)
    
    Parameters:

    x - number


    Returns:

    Statement of whether every number from 2 to 100 is a prime number, a divisor
    if there is one, and a count of all primes stated at the end.
    """
    allprimes = []
    for i in range(2, x + 1):
      if is_prime(i):
        allprimes.append(i)
    print("There are %d primes between 2 and %d" % (len(allprimes), x))
    return allprimes
      
      
def main(argv):
    """Demonstrates each function of the module using arbitrary arguments, \
    printing the output"""
    print(even_or_odd(22))
    print(even_or_odd(33))
    print(largest_divisor_five(120))
    print(largest_divisor_five(121))
    print(is_prime(60))
    print(is_prime(59))
    print(find_all_primes(100))
    return 0


if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
