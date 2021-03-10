#!/bin/bash
#
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: run_Project.sh
#
# Date: 12 Nov 2020
#
# Arguments: plot - this or any other argument will result in plotting of 2317 fits by Rscript 2_fit_models.R; forgoing an argument will skip this, saving 50-150 seconds depending on your computer's processing power.
# 
# Desc: Runs Miniproject workflow: data prep, modelling, analysis, plotting & compilation. All initial fits are also plotted if switched on with any argument.

# May want to include bash update_bib.sh here

bash compile_report.sh report.tex > /dev/null
# "> /dev/null" nulls expected output, allows errors to come through

echo "Report finished compiling; please see README.md for further details, or Ben_Nouhan_Report.pdf for the full writeup."