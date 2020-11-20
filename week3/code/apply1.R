# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: apply1.R
#
# Desc: Demonstration of R's built-in vectorised functions
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020

## Build a random matrix
M <- matrix(rnorm(100), 10, 10)

## Take the mean of each row
RowMeans <- apply(M, 1, mean) #matrix applied to, each row, mean
print (RowMeans)

## Now the variance
RowVars <- apply(M, 1, var)
print (RowVars)

## By column
ColMeans <- apply(M, 2, mean)
print (ColMeans)

### uses inbuilt vectorised functions. see apply2.R for making your own