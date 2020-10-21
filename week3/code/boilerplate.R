
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: boilerplate.R
#
# Desc: A simple script to illustrate writing functions
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 21 Oct 2020


MyFunction <- function(Arg1, Arg2){
  
  # Statements involving Arg1, Arg2:
  print(paste("Argument", as.character(Arg1), "is a", class(Arg1))) # print Arg1's type
  print(paste("Argument", as.character(Arg2), "is a", class(Arg2))) # print Arg2's type
    
  return (c(Arg1, Arg2)) #this is optional, but very useful
}

MyFunction(1,2) #test the function
MyFunction("Riki","Tiki") #A different test