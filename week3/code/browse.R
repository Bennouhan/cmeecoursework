
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: browse.R
#
# Desc: Demonstration of R's browser() function, for inserting breakpoints
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 22 Oct 2020

Exponential <- function(N0 = 1, r = 1, generations = 10){
  # Runs a simulation of exponential growth
  # Returns a vector of length generations
  
  N <- rep(NA, generations)    # Creates a vector of NA
  
  N[1] <- N0
  for (t in 2:generations){
    N[t] <- N[t-1] * exp(r)
    #browser() #unhash to use
  }
  return (N)
}

plot(Exponential(), type="l", main="Exponential growth")