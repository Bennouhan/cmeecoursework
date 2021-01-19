# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: 3_analyse.R
#
# Date: 12 Nov 2020
#
# Arguments: -
# 
# Output: goodfits.csv, statistics.csv
#
# Desc: Compares the models from 2_fit_models.R, performs further analyses

### Clear workspace, clear previous outputs, load package
rm(list = ls())
unlink("../results/statistics.csv"); unlink("../data/goodfits.csv")

suppressPackageStartupMessages(library(tidyverse))


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
print("Done! Now analysing modelling results...")
statistics <- as.data.frame(matrix(0, ncol = 12, nrow = 8))
colnames(statistics) <- c("Mean R^2", "Median R^2", "Mean BIC", "Median BIC", "Win Count", "Score", "Total", "Tally /7", "NLM Win Count", "NLM Score", "NLM Total", "NLM Tally /10")
rownames(statistics) <- c("Linear", "Quadratic", "Cubic", "Quartic", "Logistic", "Gompertz", "Baranyi", "Buchanan")

### Adds blank rows to good_fits for score entries
columnsToAdd <- c(paste0("Model", 5:8, "score"), paste0("Model", 5:8, "total"))
good_fits[, columnsToAdd] = 0

### Calculates counts, scores and totals; inputs NLM ones into good_fits
for (col in 10:17) {
  ### Sets all metrics to 0
  winCount<-0;  winCountNLM<-0;  score<-0;  scoreNLM<-0;  total<-0;  totalNLM<-0
  ### Counts wins, gets score and gets total compared to all 7 other models
  for (row in 1:nrow(good_fits)){
      if (good_fits[row,col] < min(good_fits[row,10:17])+2){
          winCount <- winCount +1 }
      score <- score + get_score(row, col)
      total <- total + get_total(row, col)
      ### As above, but only for NLMs and other NLMs; also adds row scores and totals to apropriate columns (36+)
      if (between(col, 14, 17) == TRUE){
          if (good_fits[row,col] < min(good_fits[row,14:17])+2){
              winCountNLM <- winCountNLM +1 }
          row_score <- get_score(row, col, NLM=TRUE)
          good_fits[row, col+26] <- row_score
          scoreNLM <- scoreNLM + row_score
          row_total <- get_total(row, col, NLM=TRUE)
          good_fits[row, col+30] <- row_total
          totalNLM <- totalNLM + row_total } }

  ### Calculates R^2 and BIC averages (R^2 basically irrelevevent but why not)
  statistics[col-9, 1] <- mean(  good_fits[,col-8])
  statistics[col-9, 2] <- median(good_fits[,col-8])
  statistics[col-9, 3] <- mean(  good_fits[,col])
  statistics[col-9, 4] <- median(good_fits[,col])
  ### Inputs the calculated BIC comparison measures
  statistics[col-9, 5] <- winCount;    statistics[col-9, 9] <- winCountNLM
  statistics[col-9, 6] <- score;       statistics[col-9,10] <- scoreNLM
  statistics[col-9, 7] <- total;       statistics[col-9,11] <- totalNLM
}

### Tallies which model had the higest or joint highest in each metric
for (row in 1:8){
  tally <- 0; tallyNLM <- 0
  for (col in c(1:2,5:7)){
    if (statistics[row,col] == max(statistics[,col])){ tally <- tally + 1 } }
  for (col in 3:4){
    if (statistics[row,col] == min(statistics[,col])){ tally <- tally + 1 } }
  ### As above, but only for NLMs and other NLMs
  if (between(row, 5, 8) == TRUE) {
    for (col in c(1,2,5:7,9:11)){
      if (statistics[row,col] == max(statistics[5:8,col])){
        tallyNLM <- tallyNLM + 1 } }
    for (col in 3:4){
      if (statistics[row,col] == min(statistics[5:8,col])){
        tallyNLM <- tallyNLM + 1 } } }
  ### Inputs to data frame
  statistics[row, 8] <- tally
  statistics[row,12] <- tallyNLM
}
### Rounds table to 4 sigfig, writes to csv in /results
for (col in 1:ncol(statistics)) {statistics[,col] <- signif(statistics[,col],4)}
statistics[1:4,9:12] <- "-"
write.csv(statistics, '../results/statistics.csv')
write.csv(good_fits, '../data/goodfits.csv')