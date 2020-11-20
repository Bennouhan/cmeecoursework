
---
---
<br/>

# **CMEE Coursework Week 7: Python 2** 



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

## **week7/code/** THIS NEEDS TO BE UPDATED!
<br/>


LV1.py &emsp;-&emsp; Script to integrate resource and consumer data using a Lotka-Volterra model, and plot the result

LV2.py &emsp;-&emsp; Script to integrate resource and consumer data using a prey density dependent Lotka-Volterra model, and plot the result

LV3.py &emsp;-&emsp; Script to itteritively calculate resource and consumer data using a discrete-time prey density dependent Lotka-Volterra model, and plot the result

TestR.R &emsp;-&emsp; Script used by TestR.py to illustrate use of R in Python

TestR.py &emsp;-&emsp; Script demonstrating use of subprocesses, including of R, in Python

blackbirds.py &emsp;-&emsp; Uses single regex pattern to extract labelled data from .txt file

fmr.R &emsp;-&emsp; Plots log(field metabolic rate) against log(body mass) for the Nagy et al 1999 dataset

profileme.py &emsp;-&emsp; Script to run some arbitrary functions to use as test for profiling

profileme2.py &emsp;-&emsp; Script to run some arbitrary functions, with improved efficiency over profileme.py, to use as test for profiling

re4.py &emsp;-&emsp; Script for future reference - playing around with extracting email addresses or their subsets

regexs.py &emsp;-&emsp; Script demonstrating use of REGEX

regexs2.py &emsp;-&emsp; Script demonstrating use of REGEX re.findall and webscraping

run_LV.py &emsp;-&emsp; Script to print runtime of other python scripts

run_fmr_R.py &emsp;-&emsp; Script demonstrating use of subprocesses to run .R files and manipulate their output

timeitme.py &emsp;-&emsp; Script to demonstrate use of timeit on functions imported from other scripts

using_os.py &emsp;-&emsp; Script demonstrating use of subprocess.os.walk
                  
<br/><br/>

## **week7/data/** 

<br/>

blackbirds.txt &emsp;-&emsp; Text file containing list of blackbirds in awkward format - used by blackbirds.py for regex exercise
protected under UN article 11(1)(a), used to practice command line functions

NagyEtAl1999.csv &emsp;-&emsp; Dataset including field metabolic rate and body mass from Nagy et al, 1999 study, used by fmr.R for plotting


 
<br/>


<br/><br/><br/>

# Requirements
<br/>

## **Languages:**
<br/>

[![](https://img.shields.io/badge/Python-3.9.0-blue.svg)](https://www.python.org/downloads/release/python-390/) &emsp;
[![](https://img.shields.io/badge/R-4.0.3-green)](https://cran.r-project.org/) &emsp;
![](https://img.shields.io/badge/Bash-5.0-red) &emsp;


<br/>

## **Libraries:**
<br/>

#### Python

[![](https://img.shields.io/badge/numpy-1.18.1-red)](https://pypi.org/project/numpy/) &emsp;
[![](https://img.shields.io/badge/pandas-1.1.4-purple)](https://pypi.org/project/pandas/) &emsp;
[![](https://img.shields.io/badge/matplotlib-3.3.3-green)](https://pypi.org/project/matplotlib/) &emsp;
[![](https://img.shields.io/badge/scipy-1.5.4-blue)](https://pypi.org/project/scipy/) &emsp;
[![](https://img.shields.io/badge/urllib3-1.26.2-yellow)](https://pypi.org/project/urllib3/) &emsp;



#### R

\-

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