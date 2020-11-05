# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: sample.R
#
# Desc: Runs the stochastic Ricker equation with gaussian fluctuations
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020

rm(list=ls())
                    #not random error - just introducing random variation in startpoints for the simulations
stochrick<-function(p0=runif(1000,.5,1.5),r=1.2,K=1,sigma=0.2,numyears=100) #rather than N0=1 for all, p0 is random generated versions between 0.5 and 1.5....?
{#p0 is vector of 1000 random numbers from 0.5 to 1.5    #sigma is standard deviation
  #initialize
  N<-matrix(NA,numyears,length(p0))   #matrix of NAs, other 2 are the no. rows and columns, so 100 and 1000 by default
  N[1,]<-p0
  
  #want to get rid of at least one of these loops, replaced by vesctorising the function
  for (pop in 1:length(p0)){ #for cell in column 1 to 1000:

    for (yr in 2:numyears){ #for cell in each column after the 1st:

      N[yr,pop] <- N[yr-1,pop] * exp(r * (1 - N[yr - 1,pop] / K) + rnorm(1,0,sigma))    #stochasicity? rnorm(10, m=0, sd=1) Draw 10 normal random numbers with mean=0 and standard deviation = 1. so sigma is the SD
    #                                                               #epsilon - adding random error each time
    } #is it doing 1000 simulations? why do we expect 1 year per gen?
  
  }
 return(N)
}

### This function uses a stochastic version of the Ricker model to estimate the
# population of a fishery in a given year based off of the population of the 
# previous year and other parameters given below, running many simulations with
# varying starting populations. 
#
# 𝑁(t+1)=𝑁(t)e^r(1 − 𝑁(t)/𝑘)
#
#
# ARGUMENTS
#
# p0:       Vector of initial populations; one simulation per value.
#           Default = runif(1000,.5,1.5)
# r:        Intrinsic population growth rate. Default = 1.2
# k:        Carrying capacity of the environment. Default = 1
# sigma:    Standard deviation, used for adding stochastic error. Default = 0.2
# numyears: Number of years/generations population estimated for. Default = 100
#
#
# RETURN
#
# N:        A matrix with "length(p0)" columns denotating simulations and
#           "numyears" rows denoting the number of generations estimated per
#           starting p0
#
stochrickvect<-function(p0=runif(1000,.5,1.5),r=1.2,K=1,sigma=0.2,numyears=100)
{
  N<-matrix(NA,numyears,length(p0))
  N[1,]<-p0 
  for (yr in 2:numyears){ #for each pop, loop through the years
    N[yr,] <- N[yr-1,] * exp(r * (1 - N[yr-1,] / K) + rnorm(1,0,sigma))
  }
 return(N)
} 
#removed the first loop and replaced all mentions of pop with just ","
#R automatically applies it to all columns in the matrix

print("Stochastic Ricker takes:")
print(system.time(res1<-stochrick()))

print("Vectorized Stochastic Ricker takes:")
print(system.time(res2<-stochrickvect()))