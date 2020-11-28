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

### Clear workspace, clear results folder, load packages
rm(list = ls())
unlink("../results/*"); unlink("../data/ID_dictionary_expand.csv")

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
    return(c(N0S, NmaxS, r_maxS, t_lagS))
}

### Functions representing the formulae of the 4 non-linear models
logistic <- function(t, N0, Nmax, r_max) {
    return(N0 * Nmax * exp(r_max * t) / (Nmax + N0 * (exp(r_max * t) - 1)))
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
### Analyses model and inputs results in dict; plots if switched on in terminal
analyseMod <- function(fit, df, mod_num, row_num) { 
    # Blank dataframe entries if fitting failed
    if (class(fit) == "try-error"){
      dict[row_num, 1 + mod_num] <- NA
      dict[row_num, 9 + mod_num] <- NA
      dict[row_num,] <<- dict[row_num,]
    } else {
    # Find AIC, BIC and adjusted R^2 for the fit
    RSS <- sum(residuals(fit)^2)
    TSS <- sum((df$logN - mean(df$logN))^2)
    R2 <- 1 - (RSS/TSS) #not good for NLLS, only using for model verification
    BIC <- BIC(fit) #just using BIC; more weight on no. paramaters
    if (is.na(R2)) { BIC <- NA }
    # Writes them into dict dataframe
    dict[row_num, 1+mod_num] <- signif(R2, 3)
    dict[row_num, 9+mod_num] <- signif(BIC, 4)
    dict[row_num,] <<- dict[row_num,]

    ### Plots the model; switched on only if extra argument provided in terminal
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
vect_fitting <- function(dataset, dict, group) {
    # Fit data to linear models of input orders, and returns list of lm fits
    lms <- lapply(1:4, function(x) lm(logN ~ poly(t, x), data = dataset))

    # Finds adequate start values for nlm parameters, formats them for nlsLM()
    SV <- find_startVals(dataset)
    SV <- list(N0=SV[1], Nmax=SV[2], r_max=SV[3], t_lag=SV[4])
    # Lists the nlm functions, applies each to dataset, adds to list of fits
    funs <- list(gompertz, baranyi, buchanan) #don't forget logistic!!!!
    models <- c(lms, lapply(funs, function(x) try(nlsLM(logN ~ x(t=t, N0, Nmax, r_max, t_lag), dataset, SV), silent = T)))

    # Find number of corresponding row in dictionary
    IDrow <- which(grepl(dataset$ID[1], dict$ID))
    # Analyse each of the 8 models in the fit list, and plot them if switched on
    dict <- try(lapply(1:7, function(x) analyseMod(models[[x]], dataset, x, IDrow)), silent = F)
    return(dict[[7]][IDrow,])
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
  # Filter small datasets; set size exclusion parameter
  filter(n() > 4) %>% #num parameters plus 1
  group_split() #splits by group into array

### Fits each group to each model and analyses them in vectorised fashion
dict_array <- mclapply(1:length(data), function(x) vect_fitting(data[[x]], dict), mc.cores = 6)  #NB: will use cores available on your computer up to this number

### Converts array output of mclapply into dataframe, writes it into CSV
dict=NULL; for (i in 1:length(data)){ dict <- bind_rows(dict, dict_array[[i]]) }
write_csv(dict, '../data/ID_dictionary_expand.csv')