
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: Vectorize1.R
#
# Desc: Creates matrix, sums all elements using "for" and using vectorised function, compares time taken
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020


M <- matrix(runif(1000000),1000,1000)

SumAllElements <- function(M){
  Dimensions <- dim(M)
  Tot <- 0
  for (i in 1:Dimensions[1]){
    for (j in 1:Dimensions[2]){
      Tot <- Tot + M[i,j]
    }
  }
  return (Tot)
}
 
print("Using loops, the time taken is:")
print(system.time(SumAllElements(M)))

print("Using the in-built vectorized function, the time taken is:")
print(system.time(sum(M)))