
---
---
<br/>

# **CMEE Coursework Week 3: R** 



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


This is all the assessed coursework from Week 3 (19th Oct - 25th Oct 2020) of the CMEE course at Silwood Campus, Imperial College London. <br/><br/>

All work was done through VSCode on a system running Ubuntu 20.04, and is explained in further details in The Multilingual Quantitative Biologist book (link below). <br/><br/>

Topics covered this week, almost exclusively related to R, include:


  - Basic R syntax and programming conventions

  - Principles of data processing and exploration (including visualization) using R

  - Principles of clean and efficient programming using R

  - Generating publication quality graphics in R

  - Developing reproducible data analysis “work flows” as to run and re-run your analyses
    graphics outputs and all, in R

  - Making R simulations more efficient using vectorization

  - Finding and fixing errors in R code using debugging

  - Making data wrangling and analyses more efficient and convenient using custom tools such
    as tidyr

  - Using additional tools and topics in R eg. accessing databases, building your own packages
  
<br/>

**Author: &nbsp; Ben Nouhan, &nbsp; bjn20@ic.ac.uk**
<br/><br/>


<br/><br/><br/>

# File List
<br/>

## **week3/code/**
<br/>

DataWrang.R &emsp;-&emsp; A script to illustrate data-wrangling, especially wide-long conversion

DataWrangTidy.R &emsp;-&emsp; A script to illustrate data-wrangling as in DataWrang.r but with tidyverse

GPDD_Data.R &emsp;-&emsp; Creates world map and superimposes locations held in data frame

Girko.R &emsp;-&emsp; Script to produce ggplot of a simulation of Girko's Law

MyBars.R &emsp;-&emsp; Script to demonstrate ggplot annotation and formatting

PP_Dists.R &emsp;-&emsp; Script to produce plots of predator and prey mass and size ratio

PP_Regress.R &emsp;-&emsp; Visualises linear regression of predator mass vs prey mass by lifestage

R_conditionals.R &emsp;-&emsp; A simple script to illustrate writing functions with conditionals

Ricker.R &emsp;-&emsp; Runs a simulation of the Ricker model, and returns a vector of length generations

SQLinR.R &emsp;-&emsp; Demonstration of SQL in R

TAutoCorr.R &emsp;-&emsp; Determines if the annual mean temperatures in a given location one year

TAutoCorr.pdf &emsp;-&emsp; Output of TAutoCorr.tex

TAutoCorr.tex &emsp;-&emsp; Results section based off of work done in TAutoCorr.R

TreeHeight.R &emsp;-&emsp; Imports data frame, adds 4th column, uses colmumn 2 & 3 to calc 4th column

Vectorize1.R &emsp;-&emsp; Creates matrix, sums all elements using "for" and using vectorised function, compares time taken

Vectorize2.R &emsp;-&emsp; Runs the stochastic Ricker equation with gaussian fluctuations

YearTempCorr.R &emsp;-&emsp; Determines if year and annual mean temperature in a given location are significantly correlated over a given period (Just done for fun)

apply1.R &emsp;-&emsp; Demonstration of R's built-in vectorised functions

apply2.R &emsp;-&emsp; Demonstration of apply function to vectorised a user-made function

basic_io.R &emsp;-&emsp; A simple script to illustrate R input-output.

boilerplate.R &emsp;-&emsp; A simple script to illustrate writing functions

break.R &emsp;-&emsp; A simple script to illustrate break statements

browse.R &emsp;-&emsp; Demonstration of R's browser() function, for inserting breakpoints

control_flow.R &emsp;-&emsp; A simple script to illustrate if, while and for statements

get_TreeHeight.R &emsp;-&emsp; Reads argued .csv file(s) for data frame, adds blank 4th column, uses columns 2 & 3 to calculate tree heights to populate 4th column, then writes new dataframe into a new .csv file

next.R &emsp;-&emsp; A simple script to illustrate next statements

plotLin.R &emsp;-&emsp; Script to demonstrate ggthemes, ggplot annotation and linear regression

preallocate.R &emsp;-&emsp; Comparison in speed between a basic and pre-allocated memory function

run_get_TreeHeight.sh &emsp;-&emsp; Not complete, will run get_TreeHeight.R from bash terminal

sample.R &emsp;-&emsp; Demonstration of vectorization involving lapply and sapply

try.R &emsp;-&emsp; Demonstration of R's try keyword, to catcn an error but continue the script


                  
<br/><br/>

## **week3/data/** 

<br/>

ACC_Data.pdf &emsp;-&emsp; Plot used to create TAutoCorr.pdf

ACC_Hist.pdf &emsp;-&emsp; Histogram used to create TAutoCorr.pdf

EcolArchives-E089-51-D1.csv &emsp;-&emsp; Dataset for plotLin and PP_x R scripts

GPDDFiltered.RData &emsp;-&emsp; Dataset for GPDD_Data.R

KeyWestAnnualMeanTemperature.RData &emsp;-&emsp; Dataset for TAutoCorr.R and YearTempCorr.R; temperatures measured at Key West, Florida

PoundHillData.csv &emsp;-&emsp; Dataset for DataWrang R scripts demonstrating data-wrangling

PoundHillMetaData.csv &emsp;-&emsp; Meta data for PoundHillData.csv

Results.txt &emsp;-&emsp; Dataset for MyBars.R

trees.csv &emsp;-&emsp; Tree dataset for basic_io.R, TreeHeight.R and get_TreeHeight.R

 
<br/>


<br/><br/><br/>

# Requirements
<br/>

## **Languages:**
<br/>

[![](https://img.shields.io/badge/R-4.0.3-green)](https://cran.r-project.org/) &emsp;
![](https://img.shields.io/badge/Bash-5.0-red) &emsp;

<br/>

## **Libraries:**
<br/>



#### R

[![](https://img.shields.io/badge/minpack.lm-1.2_1-green)](https://cran.r-project.org/web/packages/minpack.lm/index.html) &emsp;
[![](https://img.shields.io/badge/lme4-1.1_25-blue)](https://cran.r-project.org/web/packages/lme4/index.html) &emsp;
[![](https://img.shields.io/badge/reshape2-1.4.4-brown)](https://cran.r-project.org/web/packages/reshape2/index.html) &emsp;
[![](https://img.shields.io/badge/toOrdinal-1.1_0.0-purple)](https://cran.r-project.org/web/packages/toOrdinal/vignettes/toOrdinal.html) &emsp;
[![](https://img.shields.io/badge/tidyverse-1.3.0-orange)](https://cran.r-project.org/web/packages/tidyverse/index.html) &emsp;
[![](https://img.shields.io/badge/maps-3.3.0-teal)](https://cran.r-project.org/web/packages/maps/index.html) &emsp;
[![](https://img.shields.io/badge/sqldf-0.4_11-yellow)](https://cran.r-project.org/web/packages/sqldf/index.html) &emsp;


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