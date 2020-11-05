
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: apply2.R
#
# Desc: Demonstration of apply function to vectorised a user-made function
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020

SomeOperation <- function(v){ #if sum of all cells in v > 0, multiplies it by 100, else nothing, and returns v
  if (sum(v) > 0){ #note that sum(v) is a single (scalar) value
    return (v * 100)
  }
  return (v)
}

M <- matrix(rnorm(100), 10, 10)
print (apply(M, 1, SomeOperation)) #so here I've made a function to apply, rather than eg "mean"
#note: as shown in sample.R, you can include the apply within the function, or apply like this