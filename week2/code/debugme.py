
"""Bugged script by design, for debugging console practice"""


def makeabug(x):
    """Performs a calculation which, when z == 0, causes a bug"""
    y = x**4
    z = 1
    y = y/z
    return y
    

print(makeabug(25))

#turn debugging on using %pdb
#run this (or another bugged) script#you then have new command prompt, ipdb>
#see cmee book for commands