#!/bin/bash
#
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: run_MiniProject.sh
#
# Date: 12 Nov 2020
#
# Desc: Runs Miniproject workflow: data prep, modelling, plotting & compilation


python3 1_prep_data.py 

Rscript 2_fit_models.R 

Rscript 3_plot+analyse.R 

bash 4_compile_report.sh 4_report.tex > /dev/null #prevents expected output
#remove this but: the "&" in "&>"above prevents unexpected errors;
#rest prevents all the expected latex output; temp remove as needed
# could remove & and any rm *.exts that know we don't need by end


#add and delete to/from README.md requirements as necessary