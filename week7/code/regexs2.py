#!/usr/bin/env python3

""" Script demonstrating use of REGEX re.findall and webscraping

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import re
import sys
import urllib3

def main(argv):
    """
    Demonstrates use of REGEX re.findall and webscraping
    """
    
    ### Set string, find matches within string
    MyStr = "Samraat Pawar, s.pawar@imperial.ac.uk, Systems biology and ecological theory; Another academic, a.academic@imperial.ac.uk, Some other stuff thats equally boring; Yet another academic, y.a.academic@imperial.ac.uk, Some other stuff thats even more boring"
    found_matches = re.findall(r"([\w\s]+),\s([\w\.-]+@[\w\.-]+)", MyStr)
    print(found_matches)
        
    ### Webscrapes imperial website, sets data as variable, decodes it
    conn = urllib3.PoolManager()  # open a connection
    r = conn.request(
        'GET', 'https://www.imperial.ac.uk/silwood-park/academic-staff/')
    webpage_html = r.data  # read in the webpage's contents
    type(webpage_html) #bytes - not string
    # decode it (remember, the default decoding that this method applies is utf-8):
    My_Data = webpage_html.decode()
    
    ### Uses regex pattern to create a list of all academic names in decoded data
    pattern = r"Dr\s+\w+\s+\w+" #extract all names of academics
    regex = re.compile(pattern) # example use of re.compile(); you can also ignore case  with re.IGNORECASE 
    for match in regex.finditer(My_Data): # example use of re.finditer()
        print(match.group())
    New_Data = re.sub(r'\t', " ", My_Data)  # replace all tabs with a space
    return None
        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
    
