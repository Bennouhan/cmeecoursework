
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: try.R
#
# Desc: Demonstration of R's try keyword, to catcn an error but continue the script
#
# Arguments:
# -
#
# Output:
# -
#
# Date: 22 Oct 2020

doit <- function(x){
    temp_x <- sample(x, replace = TRUE)
    if(length(unique(temp_x)) > 30) {#only take mean if sample was sufficient
         print(paste("Mean of this sample was:", as.character(mean(temp_x))))
        } 
    else {
        stop("Couldn't calculate mean: too few unique values!")
        }
    }

popn <- rnorm(50)

hist(popn)

#lapply(1:15, function(i) doit(popn)) #running usinglapply, repeating sampling 15 times

result <- lapply(1:15, function(i) try(doit(popn), FALSE)) #same but using try
#The FALSE modifier for the try command suppresses any error messages, but result will still contain them so that you can inspect them later

class(result) #The errors are stored in the object result, a list that stores result of each run

# #alternative; similar to above, but more compact output (yet more code); hash one of them
# result <- vector("list", 15) #Preallocate/Initialize
# for(i in 1:15) {
#     result[[i]] <- try(doit(popn), FALSE)
#     }
