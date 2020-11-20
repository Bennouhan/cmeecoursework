
---
---
<br/>

# **CMEE Miniproject: Modelling Bacterial Population Growth** 



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


This is the full Mini-Project of the CMEE course at Silwood Campus, Imperial College London. <br/><br/>

All work was done through VSCode on a system running Ubuntu 20.04, and is explained in further detail in The Multilingual Quantitative Biologist book (link below). <br/><br/>

The project comprises a workflow which extracts bacterial growth data from the .csv file in the data directory, prepares it for analysis, uses it to fit various models (both linear and non-linear), then plots and further analyses those models. It then compiles the written report into a pdf file Ben_Nouhan_Report.pdf - please read this for further understanding of the background behind this project.
  
<br/>

**Author: &nbsp; Ben Nouhan, &nbsp; bjn20@ic.ac.uk**
<br/><br/>


<br/><br/><br/>

# File List
<br/>

## **miniproject/code/**
<br/>

run_MiniProject.sh &emsp;-&emsp; shell script to execute entire project workflow

1_prep_data.py &emsp;-&emsp; imports data frame from LogisticGrowthData.csv, cleans it up, adds unique experiment ID to each experiment, outputs to preped_data.csv

2_fit_models.R &emsp;-&emsp; imports preped_data.csv as data frame, fits the data from each experiment to various models

3_plot+analyse.R &emsp;-&emsp; plots and compares the models from fit_models.R, performs further analysis

4_compile_report.sh &emsp;-&emsp; Compiles report.tex into Ben_Nouhan_Report.pdf, the project's main form of presentation

4_library.bib &emsp;-&emsp; collection of referenfces for report bibliography

4_report.tex &emsp;-&emsp; raw LaTeX form of the report

Ben_Nouhan_Report.pdf &emsp;-&emsp; formal presentation of the report in PDF format


                  
<br/><br/>

## **miniproject/data/** 

<br/>

LogisticGrowthData.csv &emsp;-&emsp; logistic growth data from over 200 experiments from various studies; basis for the project

preped_data.csv &emsp;-&emsp; tidied version of LogisticGrowthData.csv, output from 1_prep_data.py

 
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
[![](https://img.shields.io/badge/scipy-1.5.4-blue)](https://pypi.org/project/scipy/) &emsp;
[![](https://img.shields.io/badge/urllib3-1.26.2-yellow)](https://pypi.org/project/urllib3/) &emsp;



#### R

[![](https://img.shields.io/badge/minpack.lm-1.2_1-green)](https://cran.r-project.org/web/packages/minpack.lm/index.html) &emsp;
[![](https://img.shields.io/badge/lme4-1.1_25-blue)](https://cran.r-project.org/web/packages/lme4/index.html) &emsp;
[![](https://img.shields.io/badge/reshape2-1.4.4-brown)](https://cran.r-project.org/web/packages/reshape2/index.html) &emsp;
[![](https://img.shields.io/badge/toOrdinal-1.1_0.0-purple)](https://cran.r-project.org/web/packages/toOrdinal/vignettes/toOrdinal.html) &emsp;
[![](https://img.shields.io/badge/tidyverse-1.3.0-orange)](https://cran.r-project.org/web/packages/tidyverse/index.html) &emsp;
[![](https://img.shields.io/badge/maps-3.3.0-teal)](https://cran.r-project.org/web/packages/maps/index.html) &emsp;
[![](https://img.shields.io/badge/sqldf-0.4_11-yellow)](https://cran.r-project.org/web/packages/sqldf/index.html) &emsp;

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