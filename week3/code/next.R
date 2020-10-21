
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: next.R
#
# Desc: A simple script to illustrate next statements
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020


for (i in 1:10) {
  if ((i %% 2) == 0) # check if the number is odd
    next # pass to next iteration of loop 
  print(i)
}