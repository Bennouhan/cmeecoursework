
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: R_conditionals.R
#
# Desc: A simple script to illustrate writing functions with conditionals
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020

# Checks if an integer is even
is.even <- function(n = 2){
  if (n %% 2 == 0)
  {
    return(paste(n,'is even!'))
  } 
  return(paste(n,'is odd!'))
}

print(is.even(6))



# Checks if a number is a power of 2
is.power2 <- function(n = 2){
  if (log2(n) %% 1==0)
  {
    return(paste(n, 'is a power of 2!'))
  } 
  return(paste(n,'is not a power of 2!'))
}

print(is.power2(4))



# Checks if a number is a power of 2
is.power2 <- function(n = 2){
  if (log2(n) %% 1==0)
  {
    return(paste(n, 'is a power of 2!'))
  } 
  return(paste(n,'is not a power of 2!'))
}

print(is.power2(4))