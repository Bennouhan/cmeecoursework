#!/bin/bash
#
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: run_MiniProject.sh
#
# Date: 12 Nov 2020
#
# Desc: Runs Miniproject workflow: data prep, modelling, plotting & compilation

PYTHONHASHSEED=0 python3 1_prep_data.py

Rscript 2_fit_models.R $1 #switch to make script plot too

Rscript 3_analyse.R 

Rscript 4_plot_figures.R 

bash 5_compile_report.sh 5_report.tex > /dev/null #prevents expected output
#remove this but: the "&" in "&>"above prevents unexpected errors;
#rest prevents all the expected latex output; temp remove as needed
# could remove & and any rm *.exts that know we don't need by end

echo "Report finished compiling; please see README.md for further details, or Ben_Nouhan_Report.pdf for the full writeup."


#add and delete to/from README.md requirements as necessary