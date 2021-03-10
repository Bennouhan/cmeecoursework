
---
---
<br/>

# **CMEE Main Project** 



<br/><br/><br/>

# Contents

<br/>

 * Description

 * Files list
  
 * Requirements
 
 * Contributions
 
 * Credits

<br/>


<br/><br/><br/>

# Description
<br/>


Ignore all below so far, needs to be updated. All files in writeup dir need to be updated, they run but the comments etc need to be changed. run_Project currently only rune compile_report with dev>null. It's all basically a shell at the moment.


This is all the assessed coursework from Week 7 (16th Nov - 22nd Nov 2020) of the CMEE course at Silwood Campus, Imperial College London. <br/><br/>

All work was done through VSCode on a system running Ubuntu 20.04, and is explained in further details in The Multilingual Quantitative Biologist book (link below). <br/><br/>

Advanced Python topics covered this week include: <br/><br/>



 - Linear algebra (matrix and vector operations) using scipy.linalg

 - Sparse Eigenvalue Problems using scipy.sparse

 - Numerical integration (including solving of Ordinary Differential Equations (ODEs)) using scipy.integrate

 - Random number generation and using statistical functions and transformations using scipy.stats

 - Optimization using scipy.optimize

 - Signal Processing using scipy.signal

 - Data manipulations and calculations using numpy
  
<br/>

**Author: &nbsp; Ben Nouhan, &nbsp; bjn20@ic.ac.uk**
<br/><br/>


<br/><br/><br/>

# File List
<br/>

## **week7/code/**
<br/>

boilerplate.sh &emsp;-&emsp; Example script to print out simple statement

CompileLaTeX.sh &emsp;-&emsp; Compiles a .tex file into a new pdf document in data/

ConcatenateTwoFiles.sh &emsp;-&emsp; Creates a third, new file in results/ with the content of the second file appended to content of the first

CountLines.sh &emsp;-&emsp; Returns the number of lines of a file

csvtospace.sh &emsp;-&emsp; Substitutes commas with spaces; Saves output into a .ssv file in results/

FirstBiblio.bib &emsp;-&emsp; Example citation for use in LaTeX files

FirstExample.tex &emsp;-&emsp; Example LaTeX file

MyExampleScript.sh &emsp;-&emsp; Greets the user, repeats greeting

tabtocsv.sh &emsp;-&emsp; Substitutes tabs with commas; Saves output into a .csv file in results/

tiff2png.sh &emsp;-&emsp; Converts a .tif file in working directory to a .png

variables.sh &emsp;-&emsp; Repeats a user-input string; returns the sum of two user-input numbers

UnixPrac1.txt &emsp;-&emsp; Contains 5 terminal commands for the following analyses on FASTA files: 
  1. &ensp;Count how many lines there are
  2. &ensp;Print everything starting from the second line for the E. coli genome
  3. &ensp;Count the sequence length of the E. coli genome
  4. &ensp;Count the matches of a particular sequence, “ATGC” in the E. coli genome
  5. &ensp;Compute the AT/GC ratio of the E. coli genome
                  
<br/><br/>

## **week7/data/** 

<br/>

spawannxs.txt - Text file containing list of species of marine and coastal flora 
protected under UN article 11(1)(a), used to practice command line functions

/fasta/*.fasta - FASTA files used for analysis with UnixPrac1.txt commands

/Temperature/180*.csv - CSV files used to test conversion using csvtospace.sh script

 
<br/>


<br/><br/><br/>

# Requirements
<br/>

## **Languages:**
<br/>

[![](https://img.shields.io/badge/Python-3.9.0-blue.svg)](https://www.python.org/downloads/release/python-390/) &emsp;
[![](https://img.shields.io/badge/R-4.0.3-green)](https://cran.r-project.org/) &emsp;
![](https://img.shields.io/badge/Bash-5.0-red) &emsp;
[![](https://img.shields.io/badge/LaTeX-2e-white)](https://www.latex-project.org/get/)

<br/>

## **Libraries:**
<br/>

#### Python

[![](https://img.shields.io/badge/numpy-1.18.1-red)](https://pypi.org/project/numpy/) &emsp;
[![](https://img.shields.io/badge/pandas-1.1.4-purple)](https://pypi.org/project/pandas/) &emsp;
[![](https://img.shields.io/badge/matplotlib-3.3.3-green)](https://pypi.org/project/matplotlib/) &emsp;
[![](https://img.shields.io/badge/scipy-1.5.4-blue)](https://pypi.org/project/matplotlib/) &emsp;



#### R

[![](https://img.shields.io/badge/minpack.lm-1.2_1-red)](https://cran.r-project.org/web/packages/minpack.lm/index.html) &emsp;
[![](https://img.shields.io/badge/ggplot2-3.3.2-yellow)](https://cran.r-project.org/web/packages/ggplot2/index.html) &emsp;
[![](https://img.shields.io/badge/dplyr-1.0.2-black)](https://cran.r-project.org/web/packages/dplyr/index.html) &emsp;
[![](https://img.shields.io/badge/lme4-1.1_25-blue)](https://cran.r-project.org/web/packages/lme4/index.html) &emsp;
[![](https://img.shields.io/badge/reshape2-1.4.4-brown)](https://cran.r-project.org/web/packages/reshape2/index.html) &emsp;
[![](https://img.shields.io/badge/toOrdinal-1.1_0.0-darkgrey)](https://cran.r-project.org/web/packages/toOrdinal/vignettes/toOrdinal.html) &emsp;
[![](https://img.shields.io/badge/tidyverse-1.3.0-green)](hhttps://cran.r-project.org/web/packages/toOrdinal/vignettes/toOrdinal.html) &emsp;
[![](https://img.shields.io/badge/broom-0.7.2-purple)](https://cran.r-project.org/web/packages/broom/index.html) &emsp;

#### LaTeX

[![](https://img.shields.io/badge/graphicx-1.2b-blue)](https://ctan.org/pkg/graphicx) &emsp;

<br/>


<br/><br/><br/>

# Contributions
<br/>


I am not currently looking for contributions, but feel free to send me any suggestions related to the project at &ensp; b.nouhan.20@imperial.ac.uk

<br/>


<br/><br/><br/>

# Credits
<br/>

This project was (almost exclusively) inspired by The Multilingual Quantitative Biologist book: (https://mhasoba.github.io/TheMulQuaBio/intro.html)<br/>
Special thanks to Dr Samraat Pawar, Pok Ho and Francis Windram for their help.

<br/><br/><br/><br/><br/>

---
---