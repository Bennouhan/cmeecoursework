
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: control_flow.R
#
# Desc: A simple script to illustrate if, while and for statements
#
# Arguments:
# -
#
# Output:
# 
#
# Date: 21 Oct 2020

a <- TRUE
if (a == TRUE){
    print ("a is TRUE")
    } else {
    print ("a is FALSE")
}






for (i in 1:10){
    j <- i * i
    print(paste(i, " squared is", j ))
}


for(species in c('Heliodoxa rubinoides', 
                 'Boissonneaua jardini', 
                 'Sula nebouxii')){
  print(paste('The species is', species))
}


v1 <- c("a","bc","def")
for (i in v1){
    print(i)
}




i <- 0
while (i < 10){
    i <- i+1
    print(i^2)
}

