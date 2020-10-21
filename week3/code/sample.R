
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: sample.R
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

######### Functions ##########

## A function to take a sample of size n from a population "popn" and return its mean
myexperiment <- function(popn,n){
    pop_sample <- sample(popn, n, replace = FALSE)
    return(mean(pop_sample))
}

## Calculate means using a for loop without preallocation:
loopy_sample1 <- function(popn, n, num){
    result1 <- vector() #Initialize empty vector of size 1 
    for(i in 1:num){
        result1 <- c(result1, myexperiment(popn, n))
    }
    return(result1)
}

## To run "num" iterations of the experiment using a for loop on a vector with preallocation:
loopy_sample2 <- function(popn, n, num){
    result2 <- vector(,num) #Preallocate expected size
    for(i in 1:num){
        result2[i] <- myexperiment(popn, n)
    }
    return(result2)
}

## To run "num" iterations of the experiment using a for loop on a list with preallocation:
loopy_sample3 <- function(popn, n, num){
    result3 <- vector("list", num) #Preallocate expected size
    for(i in 1:num){
        result3[[i]] <- myexperiment(popn, n)
    }
    return(result3)
}


## To run "num" iterations of the experiment using vectorization with lapply:
lapply_sample <- function(popn, n, num){
    result4 <- lapply(1:num, function(i) myexperiment(popn, n))
    return(result4)
}

## To run "num" iterations of the experiment using vectorization with lapply:
sapply_sample <- function(popn, n, num){
    result5 <- sapply(1:num, function(i) myexperiment(popn, n))
    return(result5)
}