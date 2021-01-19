# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: 4_plot_figures.R
#
# Date: 29 Nov 2020
#
# Arguments: -
# 
# Output: multiplots.pdf, covariables.pdf, 8plots.pdf, growth.pdf 
#
# Desc: Plots formal figures as PDFs for use in 5_report.tex

### Clear workspace, clear figures, load packages
rm(list = ls())
unlink("../results/figures/*")

library(minpack.lm)
library(parallel)
library(grid)
suppressPackageStartupMessages(library(tidyverse))


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

get_barplot <- function(var.col){
    ### Sets pallette, gets list of categories and their frequencies from dict
    pal = c("red", "yellow", "green", "blue", "purple", "cyan", "orange", "pink", "black")
    cats <- sort(unique(dict[,var.col]))
    table      <- table(dict[,var.col])
    q <- labs(title="Unit of Pop. Size", y=NULL, x=NULL); d <- 0; v <- 1

    ### If Temp variable, changes color pallette to ramp between blue and red
    if (var.col == 19) {
      pal <- colorRampPalette(c("blue", "red"))(length(table))
      q <- labs(title="Temperature (°C)", y =NULL, x=NULL)}

    ### If Medium variable, removes media with n<11, shortens cat names for plot
    if (var.col == 20) {
      table10plus <- table[table>10]; keep <- vector()
      for (obj in 1:length(table)){
        if (is.na(match(table[obj], table10plus))==FALSE) {keep <- c(keep,obj)}}
      cats <- cats[keep]; table <- table10plus
      cats <- as.factor(c("CO2 Beef", "Cooked Chicken", "ESAW", "MRS Broth", "Raw Chicken", "Salted Chicken", "TGE Agar", "TSB", "Vacuum Beef"))
      q <- labs(title="Growth Medium", y =NULL, x=NULL); d <- 90; v <- 0.5 }

    ### Creates and returns the box plot
    p <- ggplot(data=NULL, aes(x=as.factor(cats), y=as.vector(table))) +    
         geom_bar(stat="identity", fill=pal[1:length(cats)]) +
         theme(axis.text.x=element_text(angle=d, hjust=0.5, vjust=v, size=6)) +
         theme(plot.title = element_text(size=16, hjust=0.5, face="bold")) + q 
    ### Wraps long Medium names
    if (var.col == 20){
    p <- p+aes(stringr::str_wrap(cats, 10)) + xlab(NULL) + ylab(NULL)}
    return(p)
}

set_variable <- function(var.col, i, df) { #p not needed?
    ### Sets pallette, gets list of categories and their frequencies from dict
    pal <- c("red", "yellow", "green", "blue", "purple", "cyan", "orange", "pink", "black")
    cats <- sort(unique(dict[,var.col]))
    table      <- table(dict[,var.col])

    ### If Medium variable, removes media with n<=10 ...
    if (var.col == 20) {
    table10plus <- table[table>10]; keep <- vector(); count <- 0
    for (obj in 1:length(table)){
      if (is.na(match(table[obj], table10plus))==FALSE) {keep <- c(keep,obj)}}
    cats <- cats[keep]; table <- table10plus
    ### ... then plots regression line by colour depending on medium type 
    p <- geom_blank(); match <- 0 # for dropped categories still in dict
    for (cat in 1:length(cats)){
      if (dict[i,20] == cats[cat]){ 
        p <- geom_line(data=df, aes(x=ts,y=Ns), colour=pal[cat], size=.25)}}

    ### If Pop Unit variable, plots regression line by colour depending on unit
    } else { for (cat in 1:length(cats)) {
    if (var.col == 18 ){
      if (dict[i,18] == cats[cat]) {
        p <- geom_line(data=df, aes(x=ts,y=Ns), colour=pal[cat], size=.25)}

    ### If Temp variable, plots regression lines coloured from blue-red=low-high
    } else if (var.col == 19){
      if (dict[i,19] == cats[cat]) {
        pal <- colorRampPalette(c("blue", "red"))(length(table))
        p <- geom_line(data=df, aes(x=ts,y=Ns), colour=pal[cat], size=.25)}}}}
    return(p)
}

multiplot <- function(mod.num, fun, var.col) {
    
    ### Loads data frame of start values for each dataset's earlier gompertz fit
    SVs <- dict  %>% select(
        ID,N0=paste0("N0",mod.num),      Nmax=paste0("Nmax",mod.num),
        r_max=paste0("Rmax",mod.num),   t_lag=paste0("Tlag",mod.num))

    ### Fits each group to model in vectorised fashion
    fits <- mclapply(1:length(data), function(x) try(nlsLM(logN ~ fun(t=t, N0, Nmax, r_max, t_lag), data[[x]], list(N0 = SVs[x, 2], Nmax = SVs[x, 3], r_max = SVs[x, 4], t_lag = SVs[x, 5])), silent = T), mc.cores = 6)

    ### Lists bad fits, filter point set at R < 0.7 or failed fitting
    bad_fits <- numeric()
    for (i in 1:length(fits)){
      if (class(fits[[i]]) != "nls" | dict[i, mod.num+1] < 0.7){
        bad_fits <- c(bad_fits, i) } }

    ### Removes bad fits from all datasets
    SVs <- SVs[-bad_fits,]; data <- data[-bad_fits]; fits <- fits[-bad_fits]

    ### Creates plot of all fits' regression lines, coloured by variable
    count <- 0
    p <- ggplot()
    p <- p + theme(aspect.ratio = 1) + labs(x="Time (hrs)", y="log(Population)")
    for (i in 1:length(data)) {
      ## Creates regression points for each fit
      ts <- seq(0, max(data[[i]]$t), length.out = 100) #replace all ts with ts!!!!!!! when you know it works and can check
      Ns <- predict(fits[[i]], data.frame(t = ts))
      df <- data.frame(ts, Ns)

      ### Transforms to standardise start time to t_lag, then to 0
      df$ts <- df$ts - rep(as.numeric(SVs[i, 5]), 100)
      df <- df[df$ts >= 0,]
      df$ts <- df$ts - min(df$ts)
      ### Transforms to standardise start pop to 0
      df$Ns <- df$Ns - min(df$Ns)
      ### Transforms to end at start of plateau, estimated at 95% of highest pop
      df <- df[df$Ns < max(df$Ns) * 0.95,]
      ### Transforms to standardise all time and pop values to 1
      df$ts <- df$ts / max(df$ts)
      df$Ns <- df$Ns / max(df$Ns)
      ### Removes outliers
      if (median(df$Ns) < 0.1 | median(df$Ns) > 0.9 | 
          median(df$ts) < 0.1 | median(df$ts) > 0.9) { next; }
      ### Plots regression line
      p <- p + set_variable(var.col, i, df)}
    return(p)
}

plot_8mods <- function(ID, gom.only=FALSE, labs=FALSE){
    ### Finds row ID belongs to, fits linear models
    IDrow <- which(grepl(ID, dict$ID)); df <- data[[IDrow]]
    mods <- lapply(1:4, function(x) lm(logN ~ poly(t, x), data = df))

    ### Lists the nlm functions, applies each to dataset, adds to list of fits
    funs <- list(logistic, gompertz, baranyi, buchanan)
    mods <- c(mods, lapply(1,   function(x) nlsLM(logN ~ funs[[x]](t=t, N0,
              Nmax, r_max), df, list( N0 = dict[[IDrow, 20+4*x]],  Nmax = dict[[IDrow, 21+4*x]],    r_max = dict[[IDrow, 22+4*x]]))))
    #   If non-linear function other than logistic, uses t_lag also
    mods <- c(mods, lapply(2:4, function(x) nlsLM(logN ~ funs[[x]](t=t, N0, 
              Nmax, r_max, t_lag), df, list(
       N0 = dict[[IDrow, 20+4*x]],  Nmax = dict[[IDrow, 21+4*x]],
    r_max = dict[[IDrow, 22+4*x]], t_lag = dict[[IDrow, 23+4*x]]))))

    ### Removes other models for the growth diagram figure; alters lineweight
                                          size <- 0.5
    if (gom.only==TRUE){ mods <- mods[6]; size <- 1 }

    ### Creates background for figures, formatss lines
    pal <- c("grey20","yellow","green","red","purple","cyan","orange","pink")
    p <- ggplot(df, aes(x=t, y=logN)) + geom_point(size=3.5*size, colour="black")
    p <- p + theme(aspect.ratio = 1)
    #p <- p +theme(axis.text.x=element_text(size=8))
    if (labs==FALSE){ p <- p + labs(x=NULL, y=NULL) }
    linetype <- "dashed"
    for (i in 1:length(mods)){
      if (i > 4 | length(mods) == 1) { linetype <- "solid" }

      ### Creates dataframe of values for each regression line & plots them
      mod <- mods[[i]]
      ts <- seq(0, max(df$t), length.out = 100)
      Ns <- predict(mod, data.frame(t = ts))
      if (gom.only==TRUE){ # Extends regression line w/ fictional death phase
        ts <- c(ts, seq(max(ts),  1.33 * max(ts), length.out = 25))
        Ns <- c(Ns, seq(max(Ns), 6 / 7 * max(Ns), length.out = 25)) }
      Reg_df <- data.frame(ts, Ns) # Adds regression line
      p <- p + geom_line(data=Reg_df, aes(x=ts, y=Ns), colour=pal[i], size=size, linetype = linetype) }
    return(p)
}

### Loads data frames of BIC and start values for later reference
dict      <- read.csv('../data/ID_dictionary_expanded.csv')
good_fits <- read.csv('../data/goodfits.csv')
### Loads, groups and splits the prepared dataset into vector of groups
data <- read_csv('../data/preped_data.csv', col_types = cols()) %>%
  # Reduce and rename dataset, group by Experiment_ID
select(ID, N=Pop_Size, logN=log2.Pop_Size, t=Time_hrs) %>% group_by(ID) %>%
  # Filter-out small datasets; size exclusion parameter is num parameters + 2
filter(n() >= 6) %>% group_split()


### Plots the big multiplot figure as a 4x3 grid
print("Done! Now plotting multiplots.pdf; this should take 20-40s seconds...")
pdf("../results/figures/multiplots.pdf")
grid.newpage()
pushViewport(viewport(layout = grid.layout(4,3, heights=rep(.1,12))))
print(get_barplot(18),          vp=viewport(layout.pos.row=1, layout.pos.col=1))
print(get_barplot(19),          vp=viewport(layout.pos.row=1, layout.pos.col=2))
print(get_barplot(20),          vp=viewport(layout.pos.row=1, layout.pos.col=3))
print(multiplot(6,gompertz,18), vp=viewport(layout.pos.row=2, layout.pos.col=1))
print(multiplot(6,gompertz,19), vp=viewport(layout.pos.row=2, layout.pos.col=2))
print(multiplot(6,gompertz,20), vp=viewport(layout.pos.row=2, layout.pos.col=3))
print(multiplot(7,baranyi,18),  vp=viewport(layout.pos.row=3, layout.pos.col=1))
print(multiplot(7,baranyi,19),  vp=viewport(layout.pos.row=3, layout.pos.col=2))
print(multiplot(7,baranyi,20),  vp=viewport(layout.pos.row=3, layout.pos.col=3))
print(multiplot(8,buchanan,18), vp=viewport(layout.pos.row=4, layout.pos.col=1))
print(multiplot(8,buchanan,19), vp=viewport(layout.pos.row=4, layout.pos.col=2))
print(multiplot(8,buchanan,20), vp=viewport(layout.pos.row=4, layout.pos.col=3))
graphics.off()


### Plots covariates with average BIC score for each group, by model
print("Done! Now plotting the rest...")
pdf("../results/figures/covariables.pdf")
grid.newpage()
pushViewport(viewport(layout = grid.layout(2, 8, heights=rep(.4, 3))))
# Barchart for Pop Size Units
print(good_fits %>%
    select(Pop_Size_units, Logistic = Model5total, Gompertz = Model6total, Baranyi = Model7total, Buchanan = Model8total) %>%
    group_by(Pop_Size_units) %>%
    filter(n() > 10) %>%
    summarise_at(vars(Logistic, Gompertz, Baranyi, Buchanan), mean) %>%
    pivot_longer(!Pop_Size_units, names_to = "Model") %>%
    ggplot(aes(fill = Model, y = value, x = Pop_Size_units)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(y = "Mean Relative BIC Score", x = "Unit of Population Size") +
    theme(legend.position = "none"),
    vp = viewport(layout.pos.row = 1, layout.pos.col = 1:3))
# Scatterplot for Temperature
print(good_fits %>%
    select(Temp_C, Logistic = Model5total, Gompertz = Model6total, Baranyi = Model7total, Buchanan = Model8total) %>%
    group_by(Temp_C) %>%
    summarise_at(vars(Logistic, Gompertz, Baranyi, Buchanan), mean) %>%
    pivot_longer(!Temp_C, names_to = "Model") %>%
    ggplot(aes(Temp_C, value, shape = Model, colour = Model, fill = Model)) +
    geom_smooth(method = "lm", size = 0.5, se = T, formula = 'y ~ x') + 
    geom_point(size = 1.5) +
    theme_bw() +
    labs(y = "Mean Relative BIC Score", x = "Culturing Temperature (°C)") +
    expand_limits(y = 0),
    vp = viewport(layout.pos.row = 1, layout.pos.col = 4:8))
# Barchart for Media
print(good_fits %>%
    select(Medium, Logistic = Model5total, Gompertz = Model6total, Baranyi = Model7total, Buchanan = Model8total) %>%
    group_by(Medium) %>%
    filter(n() > 10) %>%
    summarise_at(vars(Logistic, Gompertz, Baranyi, Buchanan), mean) %>%
    pivot_longer(!Medium, names_to = "Model") %>%
    ggplot(aes(fill = Model, y = value, x = Medium)) +
    geom_bar(stat = "identity", position = "dodge") +
    aes(stringr::str_wrap(Medium, 10)) + theme(legend.position = "none") +
    labs(y = "Mean Relative BIC Score", x = "Growth Medium"),
    vp = viewport(layout.pos.row = 2, layout.pos.col = 1:8))
graphics.off()


### Plots regression line of all 8 models on 5 example experiments' data
pdf("../results/figures/8plots.pdf")
grid.newpage()
pushViewport(viewport(layout = grid.layout(3,1, heights=c(.1,.1,.108))))
print(plot_8mods(83031), vp=viewport(layout.pos.row=1, layout.pos.col=1)) # 83031 - eg of poly4 being silly
print(plot_8mods(10739), vp=viewport(layout.pos.row=2, layout.pos.col=1)) #this OR one above for death phase (only poly 3 and 4 follow)
print(plot_8mods(01078, labs=TRUE) + labs(x="Time (hrs)", y=NULL)
, vp=viewport(layout.pos.row=3, layout.pos.col=1))# buchanan fails to capture curve shape; & bar to lesser extent, AND log doesnt curve at bottom
# in figure text, mention popN, and give colours of lines
graphics.off()


### Plots a figure demonstrating bacterial growth phases on an exemplary dataset
pdf("../results/figures/growth.pdf")
p <- plot_8mods(65313, gom.only=TRUE, labs=TRUE)
t_lag <- as.numeric(dict[which(grepl(65313, dict$ID)), 35])
tmax  <-  max(     data[[which(grepl(65313, dict$ID))]]$t)
p <- p + annotate("rect", xmin=-Inf,  xmax=t_lag, ymin=-Inf, ymax=Inf,
                          alpha=0.2,  fill="turquoise") +
         annotate("rect", xmin=t_lag, xmax=370,   ymin=-Inf, ymax=Inf,
                          alpha=0.2,  fill="green") +
         annotate("rect", xmin=370,   xmax=tmax,  ymin=-Inf, ymax=Inf,
                          alpha=0.2,  fill="yellow") +
         annotate("rect", xmin=tmax,  xmax=Inf,   ymin=-Inf, ymax=Inf,
                          alpha=0.2,  fill="red") +
         annotate("text", x=c(35,250,500,760),    y=9.7, cex=6, fontface=2,
                  label=c("Lag\nPhase","Exponential\nPhase","Stationary\nPhase","Death\nPhase")) +
         labs(x = "Time (hrs)", y = "log(Population)") +
         theme(axis.title = element_text(size = 15))
print(p)
graphics.off()
print("Done! Now compiling report...")