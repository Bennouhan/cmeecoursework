
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: break.R
#
# Desc: A simple script to illustrate break statements
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020


i <- 0 #Initialize i
    while(i < Inf) {
        if (i == 10) {
            break 
             } # Break out of the while loop! 
        else { 
            cat("i equals " , i , " \n")
            i <- i + 1 # Update i
    }
}
