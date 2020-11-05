# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: Ricker.R 
#
# Desc: Runs a simulation of the Ricker model, and returns a vector of length generations
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020

Ricker <- function(N0=1, r=1, K=10, generations=50)
{#is a function, where these are the inputs(like python) but the numbers are the default value if not given)
  
  N <- rep(NA, generations)    # creates vector "N", pre-allocates "generation" (50 by default) number of cells
  
  N[1] <- N0
  for (t in 2:generations)    #assigns first cell in N as N0 (ie first generation that was input)
  {                           #for cell from 2 to "generation" (50...)
    N[t] <- N[t-1] * exp(r*(1.0-(N[t-1]/K))) # we know n0 so work back from there, and repeat for every gen
  }
  return (N) #returns the vector with all cells (ie sizes of generations) filled in
}

plot(Ricker(generations=10), type="l")

# The Ricker model is a classic discrete population model which was introduced in
# 1954 by Ricker to model recruitment of stock in fisheries. It gives the expected
# number (or density) 𝑁𝑡+1 of individuals in generation 𝑡+1 as a function of the
# number of individuals in the previous generation 𝑡:

#so number in the next generation based on previous (t)

# 𝑁𝑡+1=𝑁𝑡𝑒^𝑟(1 − 𝑁𝑡/𝑘)

# Here 𝑟 is intrinsic growth rate and 𝑘 as the carrying capacity of the environment.