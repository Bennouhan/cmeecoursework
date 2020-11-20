# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: 2_fit_models.R
#
# Date: 12 Nov 2020
#
# Arguments: 
# 
# Output: 
#
# Desc: Imports preped_data.csv as data frame, fits the data from each
#       experiment to various models


library(plyr)


### Whatever first thing is


#'..data/preped_data.csv'





# Model fitting script ¶

# A separate script that does the Model fitting. For example, it may have the 
#   following features:

#    -Opens the(new, modified) dataset from previous step.

#    -Does model fitting. Ultimately you need to fit at least one mechanistic or
#       nonlinear model along with one or more linear models, but for building
#       your workflow, just go ahead an fit a couple of different linear models
#       (e.g., linear regression bvs quadratic and / or cubic polynomial) .

#    -Calculates AIC, BIC, R2, and other statistical measures of model fit
#       (you decide what you want to include; isn't R2 no good here?

#    -Exports the results to a csv that the final plotting script can read.



# Note:

# Some data series(e.g., a single growth rate or functional response curve) may
#   have insufficient data points for fitting a particular model.

# That is, the number of unique x - axis values is ≤𝑘, where 𝑘 is the number of
#   parameters in the model(e.g., a regression line has two parameters). 

# Your model fitting will fail on such datasets, but you can deal with those
#   failures later (e.g., by using the try keyword that you have learned in
#   both Python and R chapters).
  
# In particular, the model fitting(or estimation of goodness of fit statistics)
#   will fail for datasets with small sample sizes, and you can then filter
#   these datasets after the Model fitting script has finished running and you
#   are in the Analysis phase.



# data_subset = data[data['ID'] ==
#                    'Chryseobacterium.balustinum_5_TSB_Bae, Y.M., Zheng, L., Hyun, J.E., Jung, K.S., Heu, S. and Lee, S.Y., 2014. Growth characteristics and biofilm formation of various spoilage bacteria isolated from fresh produce. Journal of food science, 79(10), pp.M2072-M2080.']
# data_subset.head()

#sigmoidal, as with previous example in practical in sandbox

#https: // mhasoba.github.io/TheMulQuaBio/notebooks/Appendix-MiniProj.html

#alt models:
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC184525/
#also: Linear
#      Quadratic
#      Cubic
#      one with like 6 just for the lols?


#package? #http://www.simecol.de/modecol/

#look at past students! and current, all on github
# eg https://github.com/Bennouhan/Coursework/tree/master/Miniproject/Code
#   run_Miniproject.sh shows order of scripts - try do an extra model at least
