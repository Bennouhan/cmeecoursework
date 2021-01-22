#!/bin/bash
#
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: run_MiniProject.sh
#
# Date: 12 Nov 2020
#
# Arguments: plot - this or any other argument will result in plotting of 2317 fits by Rscript 2_fit_models.R; forgoing an argument will skip this, saving 50-150 seconds depending on your computer's processing power.
# 
# Desc: Runs Miniproject workflow: data prep, modelling, analysis, plotting & compilation. All initial fits are also plotted if switched on with any argument.

PYTHONHASHSEED=0 python3 1_prep_data.py
# hash so IDs are named the same in all runs, facilitating future reference

Rscript 2_fit_models.R $1
# $1 is a switch to make script plot too; to turn on, run run_MiniProject.sh with an argument

Rscript 3_analyse_fits.R 

Rscript 4_plot_figures.R 

bash 5_compile_report.sh 5_report.tex > /dev/null
# "> /dev/null" nulls expected output, allows errors to come through

echo "Report finished compiling; please see README.md for further details, or Ben_Nouhan_Report.pdf for the full writeup."