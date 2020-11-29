# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: 2_fit_models.R
#
# Date: 12 Nov 2020
#
# Arguments: 
# 
# Output: 
#
# Desc: Imports preped_data.csv as data frame, fits the data from each experiment to various models, plots them and adds them to a dataframe for subsequent analysis

### Clear workspace, clear results folder and dict, disable warns, load packages
rm(list = ls())
unlink("../results/*"); unlink("../data/ID_dictionary_expand.csv")
options(warn=-1)

library(tidyverse)
library(minpack.lm)
library(parallel)

### Finds start values for non-linear models, aproximations based off maths
find_startVals <- function(df) { 
    N0S <- min(df$logN);  NmaxS <- max(df$logN)
    r_maxS <- 0; for (dp in 2:length(df$t)) {
                   RoC <- (df[dp, 3] - df[dp-1, 3]) / (df[dp, 4] - df[dp-1, 4]) 
                   if (RoC > r_maxS & RoC != "NaN") { r_maxS <- RoC; DP <- dp }}
    t_lagS <- df[DP, 4] - (df[DP, 3] - N0S) / r_maxS
    return(as.numeric(c(N0S, NmaxS, r_maxS, t_lagS, DP)))
}

### Functions representing the formulae of the 4 non-linear models
logistic <- function(t, N0, Nmax, r_max) {
    return( N0 * Nmax * exp(r_max * t) / (Nmax + N0 * (exp(r_max * t) - 1)))
}
gompertz <- function(t, N0, Nmax, r_max, t_lag) {
    return(N0 + (Nmax - N0) * exp(-exp(r_max * exp(1) * (t_lag - t) / ((Nmax - N0) * log(10)) + 1)))
}
baranyi <- function(t, N0, Nmax, r_max, t_lag) {
    return(Nmax + log10((-1 + exp(r_max * t_lag) + exp(r_max * t)) / (exp(r_max * t) - 1 + exp(r_max * t_lag) * 10 ^ (Nmax - N0))))
}
buchanan <- function(t, N0, Nmax, r_max, t_lag) {
    return(N0 + (t >= t_lag) * (t <= (t_lag + (Nmax - N0) * log(10) / r_max)) * r_max * (t - t_lag) / log(10) +
    (t >= t_lag) * (t > (t_lag + (Nmax - N0) * log(10) / r_max)) * (Nmax - N0))
}

### fits nlls models; if fit is poor or fails, repeats many times from rnorm
nlls_multifit <- function(df, SV, mod_num, count) {
    ### Creates normal distribution around each SV; n values, SD of SV*x
    set.seed(count); n <- 20; x <- 4
    rSV <- cbind( rnorm(n,SV[[1]],SV[[1]]*x), rnorm(n,SV[[2]],SV[[2]]*x),
                  rnorm(n,SV[[3]],SV[[3]]*x), rnorm(n,SV[[4]],SV[[4]]*x))

    ### Uses start values to recreate bounds, rather than pass to each analysis
    dp <- as.integer(SV[5]); Nmax <- SV[2]
    lower <- c(0,       Nmax/1.05,    (Nmax/max(df$t)),      0          )
    upper <- c(Nmax,    Nmax*1.05,     Nmax,                 df$t[dp+1] ) #nmax +/- 5%

    ### Lists the nlm functions, applies appropriate one
    funs <- list(logistic, gompertz, baranyi, buchanan)
    if (mod_num == 5){
    fits <- lapply(1:n, function(x) try(nlsLM(logN ~ funs[[mod_num-4]](
              t=t, N0, Nmax, r_max), df, lower=lower[1:3], upper=upper[1:3], 
              list(N0=rSV[x,1], Nmax=rSV[x,2], r_max=rSV[x,3])), silent=T))
    } else {
    fits <- lapply(1:n, function(x) try(nlsLM(logN ~ funs[[mod_num-4]](
              t=t, N0, Nmax, r_max, t_lag), df, lower=lower, upper=upper,
              list(N0=rSV[x,1], Nmax=rSV[x,2], r_max=rSV[x,3], t_lag=rSV[x,4])),
              silent=T))}

    ### Finds model with highest BIC value and returns it
    bics <- lapply(1:n, function(x) try(BIC(fits[[x]]), silent=T))
    if (length(which.min(bics)) > 0){ 
    return(fits[[which.min(bics)]]) } else { 
    return(fits[[1]]) }  # Or returns random failed model if none successful
}

### Analyses model and inputs results in dict; plots if switched on in terminal
analyseMod <- function(fit, df, SV, mod_num, row_num) {
    ### Calculates R2 and BIC, uses them to decide which models to multifit
    count <- 0 ###########CHANGE COUNT BACK TO 10 v ######
    while (count < 25){  #change if need be, & you may need to loosen bounds
        RSS <- try(sum(residuals(fit) ^ 2), silent = T)
        TSS <- try(sum((df$logN - mean(df$logN)) ^ 2), silent = T)
        R2 <- try(1 - (RSS / TSS), silent = T) #for model verification only!
        if (is.na(R2)) { BIC <- NA } else {BIC <- try(BIC(fit), silent = T) }
        
        ### Breaks while loop if linear model or a well-fitted non-linear model
        if (class(fit) == "lm") { break;}
        else if (class(R2) != "numeric" | R2 < 0.2) {
            count <- count + 1 
            if (count > 2 & mod_num == 5){break;} #gompertz fit easily but have poor R values
            fit <- nlls_multifit(df, SV, mod_num, count)    #funs[mod_num-4]
       }else{ break;}
    }
    ### Enters values into dict for CSV writing
    # Blank dataframe entries if fitting failed
    if (class(fit) == "try-error" | class(R2) != "numeric"){
        dict[row_num, 1 + mod_num] <- NA
        dict[row_num, 9 + mod_num] <- NA
        dict[row_num,] <<- dict[row_num,]
    } else {
    # Otherwsie writes BIC and R2 into dict dataframe
        dict[row_num, 1+mod_num] <- signif(R2, 3)
        dict[row_num, 9+mod_num] <- signif(BIC, 4)
        dict[row_num,] <<- dict[row_num,]

    ### Plots the model; switched on only if extra argument provided in terminal
    ################################ SWITCH ####################################
    if (length(commandArgs(trailingOnly = T)) > 0){
    # Creates df of timepoints and predicted N values for regression line
    Reg_ts <- seq(0, max(df$t), length.out = 100) 
    Reg_Ns <- predict(fit, data.frame(t=Reg_ts))
    Reg_df <- data.frame(Reg_ts, Reg_Ns)
    # Plots dataset with regression line, R2, BIC and model number, saves as PDF
    p <- ggplot(df, aes(x = t, y = logN)) + geom_point(size=2)
    p <- p + geom_line(data = Reg_df, aes(x = Reg_ts, y = Reg_Ns), colour="red")
    p <- p + theme(aspect.ratio=1) + labs(x="Time (Hrs)", y="log(Population)")
    p <- p + geom_text(aes(x = max(Reg_ts)/9, y = max(Reg_Ns)/1.2,
             label = paste("ID",ID[1], "\nMODEL ",mod_num, ":\n\n",
             "R2: ",R2, "\nBIC: ",BIC)), size = 7, colour = "Darkblue")
    pdf(paste("../results/",df$ID[1],"mod",mod_num,".pdf")); print(p); graphics.off() } }
    return(dict)
}

### Performs fitting and analysis of all 8 models for the given dataset
vect_fits <- function(df, dict, group) {
  # Fit data to linear models of input orders, and returns list of lm fits
  mods <- lapply(1:4, function(x) lm(logN ~ poly(t, x), data = df))
  # Finds adequate start values for nlm parameters, formats them for nlsLM()
  SV <- find_startVals(df); dp <- as.integer(SV[5]); Nmax <- SV[2]
  SV_list <- list(N0=SV[1], Nmax=SV[2], r_max=SV[3],         t_lag=SV[4])
  lower <-      c(0,        Nmax/1.05,  (Nmax/max(df$t)),      0          ) 
  upper <-      c(Nmax,     Nmax*1.05,   Nmax,                 df$t[dp+1] )

  # Lists the nlm functions, applies each to dataset, adds to list of fits
  funs <- list(logistic, gompertz, baranyi, buchanan)
  mods <- c(mods, lapply(funs[1], function(x) try(nlsLM(logN ~ x(t=t, N0, Nmax, r_max), df, SV_list[1:3], lower=lower[1:3], upper=upper[1:3]), silent=T))) 
  # If non-linear function other than logistic, uses full lists with t_lag
  mods <- c(mods, lapply(funs[2:4], function(x) try(nlsLM(logN ~ x(t=t, N0, Nmax, r_max, t_lag), df, SV_list, lower=lower, upper=upper), silent=T))) 
  
  # Find number of corresponding row in dictionary
  IDrow <- which(grepl(df$ID[1], dict$ID))
  # Analyse each of the 8 models in the fit list, and plot them if switched on
  dict <- try(lapply(1:8, function(x) analyseMod(mods[[x]], df, SV, x, IDrow)), silent = F)
  return(dict[[8]][IDrow,])
}


### Load ID dictionary, initialise extra rows for later input
dict <- read_csv('../data/ID_dictionary.csv', col_types = cols())
columnsToAdd <- c(paste("Model", 1:8, "R^2"), paste("Model", 1:8, "BIC"))
dict[, columnsToAdd] = 0
dict <- dict[, colnames(dict)[c(1,7:22,2:6)]] #rearrange

### Load, group and split the prepared dataset into vector of groups
data <- read_csv('../data/preped_data.csv', col_types = cols()) %>%
# Reduce and rename dataset, group by Experiment_ID
select(ID, N=Pop_Size, logN=log2.Pop_Size, t=Time_hrs) %>% group_by(ID) %>%
# Filter-out small datasets; set size exclusion parameter (#num parameters + 2)
filter(n() >= 6) %>% group_split(); n <- length(data)#splits by group into array

### Fits each group to each model and analyses them in vectorised fashion
dict_array <- mclapply(1:n, function(x) vect_fits(data[[x]], dict), mc.cores=6)#NB: will use cores available on your computer up to this number

### Converts array output of mclapply into dataframe, writes it into CSV
dict=NULL; for (i in 1:n) { dict <- bind_rows(dict, dict_array[[i]]) }
write_csv(dict, '../data/ID_dictionary_expand.csv')

print(map(dict, ~ sum(is.na(.)))[c(6:9)]) #6:9,14:17 with logistic