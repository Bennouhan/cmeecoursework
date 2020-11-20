#!/usr/bin/env python3

""" Script demonstrating use of REGEX

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import re
import sys


def main(argv):
    """
    Contains and runs examples of REGEX for future reference
    """

    ### Simple re.search examples
    my_string = "a given string"
    match = re.search(r'\s', my_string)
    print(match)
    #That’s only telling you that a match was found (the object was created
    #successfully). To see the match, use:
    print(match.group())
    
    match = re.search(r'\d', my_string)
    print(match)
    
    ### re,search example with if statement
    MyStr = 'an example'
    match = re.search(r'\w*\s', MyStr) # string of A-N chars followed by whitepace
    if match:                      
        print('found a match:', match.group()) 
    else:
        print('did not find a match')    
    
    ### Slightly more complex examples
    match = re.search(r'2' , "it takes 2 to tango")
    match.group()
    match = re.search(r'\d' , "it takes 2 to tango")
    match.group()
    match = re.search(r'\d.*' , "it takes 2 to tango")
    match.group()
    match = re.search(r'\s\w{1,3}\s', 'once upon a time')
    match.group()
    match = re.search(r'\s\w*$', 'once upon a time')
    match.group()
    
    ### Even more complex examples
    re.search(r'\w*\s\d.*\d', 'take 2 grams of H2O').group()
    re.search(r'^\w*.*\s', 'once upon a time').group()  # 'once upon a '
    re.search(r'^\w*.*?\s', 'once upon a time').group()
    re.search(r'<.+>', 'This is a <EM>first</EM> test').group()
    re.search(r'<.+?>', 'This is a <EM>first</EM> test').group()
    re.search(r'\d*\.?\d*', '1432.75+60.22i').group() #skips 60.22; stops after finding one match
    re.search(r'[AGTC]+', 'the sequence ATTCGT').group()
    re.search(r'\s+[A-Z]\w+\s*\w+',
              "The bird-shit frog's name is Theloderma asper.").group()
    
    ### Email extraction examples
    MyStr = 'Samraat Pawar, s.pawar@imperial.ac.uk, Systems biology and ecological theory'
    match = re.search(r"[\w\s]+,\s[\w\.@]+,\s[\w\s]+",MyStr)
    match.group()
    MyStr = 'Samraat Pawar, s-pawar@imperial.ac.uk, Systems biology and ecological theory'
    match = re.search(r"[\w\s]+,\s[\w\.-]+@[\w\.-]+,\s[\w\s]+", MyStr)
    match.group()
    
    return None
        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)

