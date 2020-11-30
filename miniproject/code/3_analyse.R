# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: 3_analyse.R
#
# Date: 12 Nov 2020
#
# Arguments: 
# 
# Output: 
#
# Desc: Compares the models from 2_fit_models.R, performs further analyses

rm(list = ls())
library(tidyverse)
library(minpack.lm)
library(parallel)


get_score <- function(row, col, NLM=FALSE){
    ### Assigns column range, sets score to 0
    if  (NLM == FALSE) {  cols <- 10:17  } else {  cols <- 14:17  }
    score <- 0
    ### Calculates weighted score based off proximity of each model's BIC to the best BIC of each experiment
    if (good_fits[row, col] < min(good_fits[row, cols]) + 2) {       score <- 5
      return(5)
  } else if (good_fits[row, col] < min(good_fits[row, cols]) + 6) {  score <- 3
      return(3)
  } else if (good_fits[row, col] < min(good_fits[row, cols]) + 10) { score <- 1}
    return(score)
}

get_total <- function(row, col, NLM=FALSE){
    ### Assigns column range, sets total to 0
    if  (NLM == FALSE) {  cols <- 10:17  } else {  cols <- 14:17  }
    total <- 0
    ### Calculates total difference between the BIC score and each less good BIC score of the same experiment
    for (i in cols){
      if (good_fits[row,col] < good_fits[row,i]){
        total <- total + abs(good_fits[row, col] - good_fits[row, i]) } }
    return(total)
}


### Loads dict, changes NA to 0, and splits into dfs of good fits and bad fits
dict <- read.csv('../data/ID_dictionary_expanded.csv')
dict[is.na(dict)] <- 0
bad_fits <- dict[0,]; good_fits <- dict[0,]
for (row in 1:nrow(dict)){
    if (max(dict[row,6:9]) < 0.7) {
           bad_fits  <- rbind(bad_fits,  dict[row,]) 
  } else { good_fits <- rbind(good_fits, dict[row,]) }
}

### Creates dataframe to enter statistics into
statistics <- as.data.frame(matrix(0, ncol = 12, nrow = 8))
colnames(statistics) <- c("Mean.R^2", "Median.R^2", "Mean.BIC", "Median.BIC", "Win.Count", "Score", "Total", "Win.Count.NLM", "Score.NLM", "Total.NLM", "Tally.All", "Tally.NLM")
rownames(statistics) <- c(paste("Model.", 1:8, sep=""))

for (col in 10:17) {
  ### Sets all metrics to 0
  winCount<-0;  winCountNLM<-0;  score<-0;  scoreNLM<-0;  total<-0;  totalNLM<-0
  ### Counts wins, gets score and gets total compared to all 7 other models
  for (row in 1:nrow(good_fits)){
      if (good_fits[row,col] < min(good_fits[row,10:17])+2){
          winCount <- winCount +1 }
      score <- score + get_score(row, col)
      total <- total + get_total(row, col)
      ### As above, but only for NLMs and other NLMs
      if (between(col, 14, 17) == TRUE){
          if (good_fits[row,col] < min(good_fits[row,14:17])+2){
              winCountNLM <- winCountNLM +1 }
          scoreNLM <- scoreNLM + get_score(row, col, NLM=TRUE)
          totalNLM <- totalNLM + get_total(row, col, NLM=TRUE) } }
  ### Calculates R^2 and BIC averages (R^2 basically irrelevevent but why not)
  statistics[col-9, 1] <- mean(  good_fits[,col-8])
  statistics[col-9, 2] <- median(good_fits[,col-8])
  statistics[col-9, 3] <- mean(  good_fits[,col])
  statistics[col-9, 4] <- median(good_fits[,col])
  ### Inputs the calculated BIC comparison measures
  statistics[col-9, 5] <- winCount;    statistics[col-9, 8] <- winCountNLM
  statistics[col-9, 6] <- score;       statistics[col-9, 9] <- scoreNLM
  statistics[col-9, 7] <- total;       statistics[col-9,10] <- totalNLM
}

### Tallies which model had the higest or joint highest in each metric
for (row in 1:8){
  tally <- 0; tallyNLM <- 0
  for (col in c(1,2,5:10)){
    if (statistics[row,col] == max(statistics[,col])){ tally <- tally + 1 } }
  for (col in 3:4){
    if (statistics[row,col] == min(statistics[,col])){ tally <- tally + 1 } }
  ### As above, but only for NLMs and other NLMs
  if (between(row, 5, 8) == TRUE) {
    for (col in c(1,2,5:10)){
      if (statistics[row,col] == max(statistics[5:8,col])){
        tallyNLM <- tallyNLM + 1 } }
    for (col in 3:4){
      if (statistics[row,col] == min(statistics[5:8,col])){
        tallyNLM <- tallyNLM + 1 } } }
  ### Inputs to data frame
  statistics[row, 11] <- tally
  statistics[row, 12] <- tallyNLM
}

for (col in 1:ncol(statistics)) {statistics[,col] <- signif(statistics[,col],4)}

#fix(statistics)
### Could do a weighted analysis rather than simply summing which model won what, but not really necessary: assuming polynomials aren't appropriate for this (only for local approximations), gompertz camy first in all except median BIC which was very close. That said, bar did well do, and logistic was trash.

#  -Less than 2, it is not worth more than a bare mention.
#  -Between 2 and 6, the evidence against the candidate model is positive
#  -Between 6 and 10, the evidence against the candidate model is strong
#  -Greater than 10, the evidence is very strong

#### NEXT UP: COOL COLOURED FIGURE THING FOR TEMP, POP UNIT AND MEDIUM!

# going forward with gompertz only; marginally better than baranyi, far better than others


gompertz <- function(t, N0, Nmax, r_max, t_lag) {
    return(N0 + (Nmax - N0) * exp(-exp(r_max * exp(1) * (t_lag - t) / ((Nmax - N0) * log(10)) + 1)))
}


### Loads data frame of start values for each dataset's earlier gompertz fit
SVs <- read_csv('../data/ID_dictionary_expanded.csv', col_types = cols()) %>% 
select(ID, N0=gomN0, Nmax=gomNmax, r_max=gomRmax, t_lag=gomTlag)

### Loads, groups and splits the prepared dataset into vector of groups
data <- read_csv('../data/preped_data.csv', col_types = cols()) %>%
# Reduce and rename dataset, group by Experiment_ID
select(ID, N=Pop_Size, logN=log2.Pop_Size, t=Time_hrs) %>% group_by(ID) %>%
# Filter-out small datasets; set size exclusion parameter (#num parameters + 2)
filter(n() >= 6) %>% group_split()

bad_gom_fits <- numeric()
for (row in 1:nrow(dict)) {
  if (max(dict[row,7]) < 0.8 ){#| max(dict[row,6:9]) < 0.7) {
    bad_gom_fits <- c(bad_gom_fits, row) }}
bad_gom_fits

# ### Removes bad fits from both datasets
# SVs <- SVs[-as.numeric(rownames(bad_fits)),]
# data <- data[-as.numeric(rownames(bad_fits))]

### Removes bad fits from both datasets
SVs <- SVs[-bad_gom_fits,]
data <- data[-bad_gom_fits]


### Fits each group to each model and analyses them in vectorised fashion
#NNNBBB:::: group by
#fit_list <- mclapply(1:n, function(x) vect_fits(data[[x]], SVs), mc.cores=6)#NB: will use cores available on your computer up to this number
fits <- mclapply(1:length(data), function(x) try(nlsLM(logN ~ gompertz(t=t, N0, 
                Nmax, r_max, t_lag), data[[x]], list(N0=SVs[x,2], Nmax=SVs[x,3],
                r_max=SVs[x,4], t_lag=SVs[x,5]) ), silent=T), mc.cores=6)


### Creates plot of all fits' regression lines, coloured by variable
count <- 0
p <- ggplot()
p <- p + theme(aspect.ratio = 1) + labs(x = "Time", y = "log(Population)")
#p  #add legend detail here, also add number of curves for each plot, n=...
for (i in 1:length(data)){#length(data)){
  ### Creates regression points for each fit
  Reg_ts <- seq(0, max(data[[i]]$t), length.out = 100)
  Reg_Ns <- predict(fits[[i]], data.frame(t = Reg_ts))
  Reg_df <- data.frame(Reg_ts, Reg_Ns)
  
  ### Transforms to standardise start time to t_lag, then to 0
  Reg_df$Reg_ts <- Reg_df$Reg_ts - rep(as.numeric(SVs[i,5]),100)
  Reg_df <- Reg_df[Reg_df$Reg_ts >= 0,]
  Reg_df$Reg_ts <- Reg_df$Reg_ts - min(Reg_df$Reg_ts)
  ### Transforms to standardise start pop to 0
  Reg_df$Reg_Ns <- Reg_df$Reg_Ns - min(Reg_df$Reg_Ns)
  ### Transforms to end at start of plateau
  Reg_df <- Reg_df[Reg_df$Reg_Ns < max(Reg_df$Reg_Ns)*0.95,]
  ### Transforms to standardise all time and pop values to 1
  Reg_df$Reg_ts <- Reg_df$Reg_ts / max(Reg_df$Reg_ts)
  Reg_df$Reg_Ns <- Reg_df$Reg_Ns / max(Reg_df$Reg_Ns)
  ### Removes outliers
  if (median(Reg_df$Reg_Ns) < 0.1 | median(Reg_df$Reg_Ns) > 0.9 |
      median(Reg_df$Reg_ts) < 0.1 | median(Reg_df$Reg_ts) > 0.9 )  { next; }
  ### Plots regression line
  p <- p + geom_line(data=Reg_df, aes(x=Reg_ts, y=Reg_Ns), colour="red")
  count <- count + 1
#print(Reg_df)
}
print(p)

# tomorrow: add legend and colours, do for all 3 variables, do for bar and buc
# end up with 1 figure pdf, 3 cell grid
## should be easy to make function for different model functions (gom, bar, buc)
## may be harder for variables and colours; input just row to function somehow?
# maybe 4 cell grid, also showing barplots of different variable frequencies in same colour as legend?

# dict[,18] = unit, dict[,19] = temp.c, dict[,20] = medium
#barplot(unlist(as.vector(dict[,18])))
table(dict[,18]) # these are fine as is
table(dict[,19]) # these should be sorted into ranges, or a gradient from blue to red if possible? could be very cool. if so can be incraments of 5 or 10 in barchart; if not, should be somewhat uniform, maybe 0-10, 10-20, 20-40
length(as.numeric(dict[,19])==2)
hist( dict[,19])
table(dict[,20]) # this is a mes. should probs remove all with n < 10, and maybe randomly reduce the bigger ones (TGE and TSB) to stop dominating?




#   # Plots dataset with regression line, R2, BIC and model number, saves as PDF
#   p <- ggplot(df, aes(x = t, y = logN)) + geom_point(size = 2)
#   p <- p + geom_line(data = Reg_df, aes(x = Reg_ts, y = Reg_Ns), colour = "red")
#   p <- p + theme(aspect.ratio = 1) + labs(x = "Time (Hrs)", y = "log(Population)")
#   p <- p + geom_text(aes(x = max(Reg_ts) / 9, y = max(Reg_Ns) / 1.2,
#              label = paste("ID", ID[1], "\nMODEL ", mod_num, ":\n\n",
#              "R2: ", R2, "\nBIC: ", BIC)), size = 7, colour = "Darkblue")
#   pdf(paste("../results/", df$ID[1], "mod", mod_num, ".pdf"));
#   print(p);
#   graphics.off()

























# ######### SPLINE THING ######
# ### Load, group and split the prepared dataset into vector of groups
# data <- read_csv('../data/preped_data.csv', col_types = cols()) %>%
# # Reduce and rename dataset, group by Experiment_ID
# select(ID, N=Pop_Size, logN=log2.Pop_Size, t=Time_hrs) %>% group_by(ID) %>%
# # Filter-out small datasets; set size exclusion parameter (#num parameters + 2)
# filter(n() >= 6) %>% group_split(); n <- length(data)#splits by group into array
# df <- data[[64]]
# Reg_ts <- seq(0, max(df$t), length.out = 100)
# fit <- smooth.spline(df$t, df$logN, df=4, nknots = 10) #4 = cubic; 2=linear
# Reg_df <- stats:::predict.smooth.spline(fit, Reg_ts)
# plot(Reg_df)

# # Reg_ts <- seq(0, max(df$t), length.out = 100) #alternative, overfits
# # Reg_df <- spline(df$t, df$logN) #4 = cubic; 2=linear

# # Plots dataset with regression line, R2, BIC and model number, saves as PDF
# p <- ggplot(df, aes(x = t, y = logN)) + geom_point(size = 2)
# p <- p + geom_line(data = data.frame(Reg_df), aes(x = x, y = y), colour = "red")
# p <- p + theme(aspect.ratio = 1) + labs(x = "Time (Hrs)", y = "log(Population)")
# # p <- p + geom_text(aes(x = max(Reg_ts) / 9, y = max(Reg_Ns) / 1.2,
# #              label = paste("ID", ID[1], "\nMODEL ", mod_num, ":\n\n",
# #              "R2: ", R2, "\nBIC: ", BIC)), size = 7, colour = "Darkblue")
# p



# Final plotting and analysis script ¶

# Next, write a script that imports the results from the previous step and plots
#   every curve with the two(or more) models(or none, if nothing converges) overlaid.

# Doing this will help you identify poor fits visually and help you decide whether
#  the model fitting(e.g., using NLLS) can be further optimized.

# All plots should be saved in a single separate sub - directory.

# This script will also perform any analyses of the results of the Model fitting, for
#  example to summarize which model(s) fit(s) best, and address any biological
#  questions involving co - variates.
