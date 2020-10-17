CMEE COURSEWORK WEEK ****

Author: Ben Nouhan

____________________________________________________
----------------------------------------------------

########################  many formatting changes made in week1, copy them over!!!###########


 * Description

 * Files list
  
 * Requirements
 
 * Recommended modules
 
 * Installation
 
 * Configuration
 
 * Troubleshooting
 
 * Contributions
 
 * Credits



----------------------
DESCRIPTION
----------------------


This is all the assessed coursework from Week ****** (5th Oct - 11th Oct 2020) of the CMEE course at Silwood Campus, Imperial College London. 

All work was done through VSCode on a system running Ubuntu 20.04, and is explained in further details in The Multilingual Quantitative Biologist book (link below).

Topics covered this week include introductions to:

 - Use of UNIX and Linux operating systems
 
 - Shell scripting 

 - Version control with Git 
 
 - Creating scientific documents with LaTeX


----------------------
FILES LIST
----------------------

//////////
      CODE
//////////


############# write doc strings for all; use the first one as desc, like # desc last week. modify script. ######################

boilerplate.sh - Example script to print out simple statement

FirstExample.tex - Example LaTeX file

tabtocsv.sh - Substitutes tabs with commas; Saves output into a .csv file in results/

variables.sh - Repeats a user-input string; returns the sum of two user-input numbers

tiff2png.sh - Converts all .tif files in working dir, or a dir specified by argument, to a .png in same dir

CountLines.sh - Returns the number of lines of a file

FirstBiblio.bib - Example citation for use in LaTeX files

CompileLaTeX.sh - Compiles a .tex file into a new pdf document in data/

csvtospace.sh - Substitutes commas with spaces; Saves output into a .ssv file in results/

ConcatenateTwoFiles.sh - Creates a third, new file in results/ with the content of the second file appended to content of the first

MyExampleScript.sh - Greets the user, repeats greeting

UnixPrac1.txt - Contains 5 terminal commands for the following analyses on FASTA files: 
  1. Count how many lines there are
  2. Print everything starting from the second line for the E. coli genome
  3. Count the sequence length of the E. coli genome
  4. Count the matches of a particular sequence, “ATGC” in the E. coli genome
  5. Compute the AT/GC ratio of the E. coli genome
                  

//////////
      DATA
//////////


spawannxs.txt - Text file containing list of species of marine and coastal flora 
protected under UN article 11(1)(a), used to practice command line functions

/fasta/*.fasta - FASTA files used for analysis with UnixPrac1.txt commands

/Temperature/180*.csv - CSV files used to test conversion using csvtospace.sh script


//////////
   RESULTS
//////////


1800.ssv - Output of csvtospace.sh script

abomination.txt - Output of ConcatenateTwoFiles.sh script

FirstExample.pdf - Output of CompileLaTeX.sh script

test.csv - Output of tabtocsv.sh script
 


----------------------
REQUIREMENTS
----------------------


List of all modules etc required to run every script in this project:

bc                              - GNU bc arbitrary precision calculator lang
grep                            - GNU grep, egrep and fgrep
perl                            - Larry Wall's Practical Extraction and Repo
perl-modules-5.30               - Core Perl modules                     
imagemagick                     - image manipulation programs -- binaries   
    
(python 3) and r in future
###The requirements section (required) shall make it clear whether this project requires anything outside of Drupal core to work (modules, libraries, etc). List all requirements here, including those that follow indirectly from another module, etc. The idea is to inform the users about what is required, so that everything they need can be procured and included in advance of attempting to install the module. If there are no requirements, write "No special requirements".


RECOMMENDED MODULES
----------------------
###This optional section lists modules that are not required, but that may enhance the usefulness or user experience of your project. Make sure to describe the benefits of enabling these modules.


----------------------
INSTALLATION
----------------------


----------------------
CONFIGURATION
----------------------


----------------------
TROUBLESHOOTING
----------------------


----------------------
CONTRIBUTIONS
----------------------


I am not currently looking for contributions, but feel free to send me any suggestions related to the project at b.nouhan.20@imperial.ac.uk

----------------------
CREDITS
----------------------


This project was (almost exclusively) inspired by The Multilingual Quantitative Biologist book (https://mhasoba.github.io/TheMulQuaBio/intro.html). Special thanks to Dr Samraat Pawar, Pok Ho and Francis Windram for their help.
