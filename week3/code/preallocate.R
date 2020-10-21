
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: preallocate.R
#
# Desc: Comparison in speed between a basic and pre-allocated memory function
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020

NoPreallocFun <- function(x){
    a <- vector() # empty vector
    for (i in 1:x) {
        a <- c(a, i)
        print(a)
        print(object.size(a))
    }
}

print(system.time(NoPreallocFun(1000)))



PreallocFun <- function(x){
    a <- rep(NA, x) # pre-allocated vector
    for (i in 1:x) {
        a[i] <- i
        print(a)
        print(object.size(a))
    }
}

print(system.time(PreallocFun(1000)))

#didn't actually seem to make a difference but go with it