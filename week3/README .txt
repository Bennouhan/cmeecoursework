____________________________________________________

----------------------------------------------------


CMEE COURSEWORK WEEK 3

Author: Ben Nouhan


----------------------------------------------------
____________________________________________________





 * Description

 * Files list
  
 * Requirements
 
 * Contributions
 
 * Credits



----------------------
----------------------
DESCRIPTION
----------------------


This is all the assessed coursework from Week 3 (19th Oct - 25th Oct 2020) of the CMEE course at Silwood Campus, Imperial College London. 

All work was done through VSCode on a system running Ubuntu 20.04, and is explained in further details in The Multilingual Quantitative Biologist book (link below).

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




----------------------
----------------------
FILES LIST
----------------------


//////////
      CODE
//////////


DataWrang.R - A script to illustrate data-wrangling, especially wide-long conversion

DataWrangTidy.R - A script to illustrate data-wrangling as in DataWrang.r but with tidyverse

GPDD_Data.R - Creates world map and superimposes locations held in data frame

Girko.R - Script to produce ggplot of a simulation of Girko's Law

MyBars.R - Script to demonstrate ggplot annotation and formatting

PP_Dists.R - Script to produce plots of predator and prey mass and size ratio

PP_Regress.R - Visualises linear regression of predator mass vs prey mass by lifestage

R_conditionals.R - A simple script to illustrate writing functions with conditionals

Ricker.R - Runs a simulation of the Ricker model, and returns a vector of length generations

SQLinR.R - Demonstration of SQL in R

TAutoCorr.R - Determines if the annual mean temperatures in a given location one year

TAutoCorr.pdf - Output of TAutoCorr.tex

TAutoCorr.tex - Results section based off of work done in TAutoCorr.R

TreeHeight.R - Imports data frame, adds 4th column, uses colmumn 2 & 3 to calc 4th column

Vectorize1.R - Creates matrix, sums all elements using "for" and using vectorised function, compares time taken

Vectorize2.R - Runs the stochastic Ricker equation with gaussian fluctuations

YearTempCorr.R - Determines if year and annual mean temperature in a given location are significantly correlated over a given period (Just done for fun)

apply1.R - Demonstration of R's built-in vectorised functions

apply2.R - Demonstration of apply function to vectorised a user-made function

basic_io.R - A simple script to illustrate R input-output.

boilerplate.R - A simple script to illustrate writing functions

break.R - A simple script to illustrate break statements

browse.R - Demonstration of R's browser() function, for inserting breakpoints

control_flow.R - A simple script to illustrate if, while and for statements

get_TreeHeight.R - Reads argued .csv file(s) for data frame, adds blank 4th column, uses columns 2 & 3 to calculate tree heights to populate 4th column, then writes new dataframe into a new .csv file

next.R - A simple script to illustrate next statements

plotLin.R - Script to demonstrate ggthemes, ggplot annotation and linear regression

preallocate.R - Comparison in speed between a basic and pre-allocated memory function

run_get_TreeHeight.sh - Not complete, will run get_TreeHeight.R from bash terminal

sample.R - Demonstration of vectorization involving lapply and sapply

try.R - Demonstration of R's try keyword, to catcn an error but continue the script





----------------------
----------------------
REQUIREMENTS
----------------------


List of all modules etc required to run every script in this project:


R and all dependencies

The following R modules: 'maps', 'sqldf', 'tidyverse', 'dplyr', 'broom', 'reshape2', 'ggthemes', 'ggplot2'



----------------------
----------------------
CONTRIBUTIONS
----------------------


I am not currently looking for contributions, but feel free to send me any suggestions related to the project at b.nouhan.20@imperial.ac.uk



----------------------
----------------------
CREDITS
----------------------


This project was (almost exclusively) inspired by The Multilingual Quantitative Biologist book (https://mhasoba.github.io/TheMulQuaBio/intro.html). Special thanks to Dr Samraat Pawar, Pok Ho and Francis Windram for their help.



----------------------------------------------------
____________________________________________________

