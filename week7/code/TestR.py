#!/usr/bin/env python3

""" Script demonstrating use of subprocesses, including of R, in Python

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import sys
import subprocess


def main(argv):
    """ Contains examples of subprocesses use, some hashed, for future reference
    
    """
    ### Print something using bash terminology
    p = subprocess.Popen(["echo", "I'm talkin' to you, bash!"],
        stdout=subprocess.PIPE, #pipes to a "child" process
        stderr=subprocess.PIPE) #same; now contains two
    stdout, stderr = p.communicate() #saves as 2 variables
    print(stderr) #can now see error (should be blank here)
    print(stdout) #and output, in binary format
    print(stderr.decode()) #decodes them; now normal format
    print(stdout.decode())
    
    ### List cwd files in long format
    p = subprocess.Popen(["ls", "-l"], stdout=subprocess.PIPE)
    stdout, stderr = p.communicate()
    print(stdout.decode()) #ls -l returns file list long format
    
    ### Run python script
    p = subprocess.Popen(["python3", "../../week2/code/boilerplate.py"], stdout=subprocess.PIPE, stderr=subprocess.PIPE) # A bit silly! 
    stdout, stderr = p.communicate()
    print(stdout.decode())
    
    ### Compile .tex document
    # subprocess.os.system("pdflatex ../../week1/code/FirstExample.tex")
    # stdout, stderr = p.communicate()
    # print(stderr.decode())

    ### Using subprocess.os to make your code Linux-independent. For example to assign paths:
    subprocess.os.path.join('directory', 'subdirectory', 'file')
    # result would be different on Windows (backslashes instead of forward slashes), pretty cool.
    #  A simple eg of catching ouput where output is platform-dependent directory path, is:
    MyPath = subprocess.os.path.join('directory', 'subdirectory', 'file')
    print(MyPath)
    
    ### Running R in python (eg can use ggplot)
    subprocess.Popen(
        "Rscript --verbose TestR.R > ../results/TestR.Rout 2> ../results/TestR_errFile.Rout", shell=True).wait()
    # saves output and error as files in results
    
    # subprocess.Popen(
    #     "Rscript --verbose NonExistScript.R > ../results/outputFile.Rout 2> ../results/errorFile.Rout", shell=True).wait()
    #same but with non-existant file
    
    
    
    
    return None
        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
    
