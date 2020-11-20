# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: 3_plot+analyse.R
#
# Date: 12 Nov 2020
#
# Arguments: 
# 
# Output: 
#
# Desc: Plots and compares the models from 2_fit_models.R, performs further
#       analyses


library(plyr)


### Whatever first thing is













# Final plotting and analysis script ¶

# Next, write a script that imports the results from the previous step and plots
#   every curve with the two(or more) models(or none, if nothing converges) overlaid.

# Doing this will help you identify poor fits visually and help you decide whether
#  the model fitting(e.g., using NLLS) can be further optimized.

# All plots should be saved in a single separate sub - directory.

# This script will also perform any analyses of the results of the Model fitting, for
#  example to summarize which model(s) fit(s) best, and address any biological
#  questions involving co - variates.
