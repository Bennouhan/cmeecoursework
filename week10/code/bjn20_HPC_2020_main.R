# CMEE 2020 HPC excercises R code main proforma
# you don't HAVE to use this but it will be very helpful.  If you opt to write everything yourself from scratch please ensure you use EXACTLY the same function and parameter names and beware that you may loose marks if it doesn't work properly because of not using the proforma.

name <- "Ben Nouhan"
preferred_name <- "Ben"
email <- "bjn20@ic.ac.uk"
username <- "bjn20"

# please remember *not* to clear the workspace here, or anywhere in this file. If you do, it'll wipe out your username information that you entered just above, and when you use this file as a 'toolbox' as intended it'll also wipe away everything you're doing outside of the toolbox.  For example, it would wipe away any automarking code that may be running and that would be annoying!

# Question 1
species_richness <- function(community){
### Measures species richness of a community; returns number of unique objects present in an input vector
#
# Arguments:
#   community - vector of +ve integers; collection of individuals in the community, each object is an integer giving the species of the individual in that position
#
# Returns:   integer 1 to Inf; the count of species types present in community
########
  
  ### Removes duplicates from vector; counts objects in vector
  return(length(unique(community)))
}




# Question 2
init_community_max <- function(size){
### Generates initial state for a simulation community, with max possible number of species of the community based on its size
#
# Arguments:
#   size - integer 1 to Inf; number of individuals in a community
#
# Returns:   vector of +ve integers; sequence of 1 to community size increasing by 1 each time
#
########

  ### Generates sequence of integers from 1 to input integer, by 1
  return(1:size)
}




# Question 3
init_community_min <- function(size){
### Generates initial state for a simulation community, with min possible number of species of the community based on its size
#
# Arguments:
#   size - integer 1 to Inf; number of individuals in a community
#
# Returns:   vector of integers; repeated sequence of 1s, length equal to that of community size
#
########

  ### Generates sequence of 1s equal in length to value of input integer
  return(rep(1, size))
}





# Question 4
choose_two <- function(max_value){
### Generates vector of 2 objects from a sequence of integers, randomly sampled without replacement
#
# Arguments:
#   max_value - integer 1 to Inf; maximum value present in a numeric vector
#
# Returns:   vector of integers; two randomly sampled (without replacement) integers from sequence of 1 to max_value
#
########

  ### Takes 2 random samples without replacement (replacement default = FALSE) from 1:max_value
  return(sample(max_value, 2))
}





# Question 5
neutral_step <- function(community){
### Performs a single step of a simple neutral model simulation on a community vector (no speciation)
#
# Arguments:
#   community - vector of +ve integers; collection of individuals in the community, each object is an integer giving the species of the individual in that position
#
# Returns:   vector of +ve integers; alterered version of community, whereby one object has been replaced by one of the others
#
########

  ### Randomly choose index of 2 individuals of community
  pair <- choose_two(length(community))

  ### Replace first with value of second within community
  community[pair[1]] <- community[pair[2]]
  return(community)
}





# Question 6
neutral_generation <- function(community){
### Simulates a generation's worth of neutral steps, first calculating how many steps must occur in a generation (no speciation)
#
# Arguments:
#   community - vector of +ve integers; collection of individuals in the community, each object is an integer giving the species of the individual in that position
#
# Returns:   vector of +ve integers; alterered version of community, whereby num_steps changes have been made by calling neutral_step
#
########

  ### Finds number of neutral steps needed for generation
  num_steps <- length(community)/2
  # if number of individuals is odd, randomly sample from n/2 rounded up (ceiling) or down (floor)
  num_steps <- ifelse(num_steps %% 1 == .5, sample(c(ceiling, floor), 1)[[1]](num_steps), num_steps)

  ### Loop repeating neutral step "num_steps" times
  for (step in 1:num_steps) {
    community <- neutral_step(community) }
  
  return(community)
}



# Question 7
neutral_time_series <- function(community,duration)  {
### Simulates generations of the community based on neutral theory, and finds the species richness of each generation (no speciation)
#
# Arguments:
#   community - vector of +ve integers; collection of individuals in the community, each object is an integer giving the species of the individual in that position
#   duration  - +ve integer; number of generations the simulation is to be run for
#
# Returns:   vector of +ve integers; time series of species richness at each stage, from gen(0) to gen(duration); length is duration+1
#
########
  
  ### Finds starting species richness, creates vector
  rich_vect <- species_richness(community)

  ### Simulates next generation "duration" times, adding species richness of each generation to above vector
  for (gen in 1:duration){
    community <- neutral_generation(community)
    rich_vect <- c(rich_vect, species_richness(community)) }

  return(rich_vect)
}





# Question 8
question_8 <- function() {
### Plots a time-series graph of species richness over 200 generations simulated with the neutral theory model, starting with a community of 100 individuals all of different species (no speciation)
#
# Arguments: -
#
# Returns:  character string; statement answering "What state will the system always converge to if you wait long enough, and why?"
#
########

  ### Clear all graphics
  graphics.off()

  ### Generate the data
  generations_vect <- 0:200
  species_richness_vect <- neutral_time_series(1:100, 200)

  ### Plots species_richness_vect against generations_vect
  plot(generations_vect, species_richness_vect,
      # labels axes and graph as a whole
      xlab="Generations Elapsed", ylab="Species Richness",
      main="Species Richness of a Community \nover 200 Generations",
      # adds line, removes datapoints, sets its colour and width
      col="mediumblue", type="l", lwd=3,
      # disable numerical axes labels, sets edge of axes to origin
      xaxt="n", yaxt="n", xaxs="i", yaxs="i", ylim=c(0, 100), xlim=c(-.5, 200))
      # adds custom numerical axes labels, and minor axis ticks
  axis(1, seq(0, 200, by=20), las=1,        labels=TRUE)
  axis(2, seq(0, 100, by=10), las=2,        labels=TRUE)
  axis(1, seq(0, 200, by=4),  lwd.ticks=.3, labels=FALSE)
  axis(2, seq(0, 20,  by=2),  lwd.ticks=.3, labels=FALSE)

  ### Statement
  return("The system will always converge on a state of monodominance. Since no speciation can occur in this model, each step can only reduce or maintain species richness, hence species richness will decrease over time until it reaches the mininmum of 1.")
}




# Question 9
neutral_step_speciation <- function(community,speciation_rate)  {
### Performs a single step of a simple neutral model simulation on a community vector, with speciation as a possibility
#
# Arguments:
#   community       - vector of +ve integers; collection of individuals in the community, each object is an integer giving the species of the individual in that position
#   speciation_rate - numeric 0 to 1; parameter to set rate at which speciation occurs when an object is replaced
#
# Returns:   vector of +ve integers; alterered version of community, whereby one object has been replaced by one of the others, or a new number
#
########

  ### Randomly choose index of 2 individuals of community
  pair <- choose_two(length(community))

  ### Applies a probability of "speciation_rate" that the replacement number is changed to a new number (ie speciation occurs)
  if (runif(1) < speciation_rate){ pair[[2]] <- max(community)+1 #quicker to argue preallocated runif dist?#this number may have existed; doesnt matter for species richness but may for other stuff; ideally use count
 }else{                            pair[[2]] <- community[pair[2]] } 

  ### Replace first with value of second within community
  community[pair[1]] <- pair[2]
  
  return(community)
}


# Question 10
neutral_generation_speciation <- function(community,speciation_rate)  {
### Simulates a generation's worth of neutral steps, first calculating how many steps must occur in a generation, with speciation as a possibility
#
# Arguments:
#   community       - vector of +ve integers; collection of individuals in the community, each object is an integer giving the species of the individual in that position
#   speciation_rate - numeric 0 to 1; parameter to set rate at which speciation occurs when an object is replaced
#
# Returns:   vector of +ve integers; alterered version of community, whereby num_steps changes have been made by calling neutral_step_speciation
#
########

  ### Finds number of neutral steps needed for generation
  num_steps <- length(community)/2
  # if number of individuals is odd, randomly sample from n/2 rounded up (ceiling) or down (floor)
  num_steps <- ifelse(num_steps %% 1 == .5, sample(c(ceiling, floor), 1)[[1]](num_steps), num_steps)

  ### Loop repeating neutral step (with speciation) "num_steps" times
  for (step in 1:num_steps) {
    community <- neutral_step_speciation(community,speciation_rate) }
  
  return(community)
}





# Question 11
neutral_time_series_speciation <- function(community,speciation_rate,duration) {
### Simulates generations of the community based on neutral theory, and finds the species richness of each generation, with speciation as a possibility
#
# Arguments:
#   community       - vector of +ve integers; collection of individuals in the community, each object is an integer giving the species of the individual in that position
#   speciation_rate - numeric 0 to 1; parameter to set rate at which speciation occurs when an object is replaced
#   duration        - +ve integer; number of generations the simulation is to be run for
#
# Returns:   vector of +ve integers; time series of species richness at each stage, from gen(0) to gen(duration); length is duration+1
#
########
  
  ### Finds starting species richness, creates vector
  rich_vect <- species_richness(community)

  ### Simulates next generation "duration" times, adding species richness of each generation to above vector
  for (gen in 1:duration){
    community <- neutral_generation_speciation(community,speciation_rate)
    rich_vect <- c(rich_vect, species_richness(community)) }

  return(rich_vect)
}





# Question 12
question_12 <- function()  {
### Plots a time-series graph of species richness over 200 generations simulated with the neutral theory model, starting with a community of 100 individuals all of different species (blue) and all the same species (red), with speciation as a possibility
#
# Arguments: -
#
# Returns:  character string; statement explaining the effect intitial conditions had, and answering "Why does the neutral model give these particular results?"
#
########

  ### Clear all graphics
  graphics.off()

  ### Generate the data; one richness vector with each max and min richness
  generations_vect <- 0:200
  max_species_richness <- neutral_time_series_speciation(1:100,      0.1, 200)
  min_species_richness <- neutral_time_series_speciation(rep(1,100), 0.1, 200)

  ### Plots max_species_richness against generations_vect
  plot(generations_vect, max_species_richness,
      # labels axes and graph as a whole
      xlab="Generations Elapsed", ylab="Species Richness",
      main="Species Richness of Maximally and Minimally Diverse Communities \n with a Speciation Rate of 0.1 over 200 Generations",
      # adds line, removes datapoints, sets its colour and width
      col="mediumblue", type="l", lwd=3,
      # disable numerical axes labels, sets edge of axes to origin
      xaxt="n", yaxt="n", xaxs="i", yaxs="i", ylim=c(0, 100), xlim=c(-.5, 200))
      # plots min_species_richness against generations_vect, formats line
  lines(generations_vect, min_species_richness, col="maroon", lwd=3)
      # adds legend for the lines in topright corner 
  legend("topright", col=c("mediumblue","maroon"), lwd=3, cex=0.8, 
         legend=c("Maximum Initial Richness","Minimum Initial Richness"))
      # adds custom numerical axes labels, and minor axis ticks
  axis(1, seq(0, 200, by=20), las=1,          labels=TRUE)
  axis(2, seq(0, 100, by=10), las=2,          labels=TRUE)
  axis(1, seq(0, 200, by=4),  lwd.ticks=.3,   labels=FALSE)
  axis(2, seq(0, 100, by=2),  lwd.ticks=.3,   labels=FALSE)

  ### Statement
  return("Speciation introduces a force to increase species richness, where before there was only a force to decrease it. The community of maximum species richness has nowhere to go but a species richness decrease, and vice versa. They will hence meet in the middle, where these two forces reach an equilibrium. With such a small sample, random variation introduces significant fluctuations even at equilibrium, but as population size and generation number increase, these lines will converge.")
}


# Question 13
species_abundance <- function(community)  {
### Converts input vector into vector of species frequencies in descending order 
#
# Arguments:
#   community - vector of +ve integers; collection of individuals in the community, each object is an integer giving the species of the individual in that position
#
# Returns:  vector of +ve integers; vector of species frequencies in descending order
#
########

  ### Makes frequency table of vector, sorts in descending order, converts to vector
  return(as.vector(sort(table(community), decreasing=TRUE)))
}



# Question 14
octaves <- function(abundance_vector) {
### Bins the argued species abundancies into octave classes
#
# Arguments:
#   abundance_vector - vector of +ve integers; vector of species frequencies of a community in descending order
#
# Returns:  vector of integers 0 to Inf; vector of octave class frequencies in ascending order of class size
#
########
  
  ### log2()+1 transforms data, rounds each down, finds frequencies of result
  return(tabulate(floor(log2(abundance_vector)+1)))
}


# Question 15
sum_vect <- function(x, y) {
### Sums two vectors, after adding tailing zeros to the shorter vector in vectorised manner if there is one
#
# Arguments:
#   x, y - vectors of integers 0 to Inf; vectors to be summed 
#
# Returns:  vector of integers 0 to Inf; sum of vectors x and y
#
########

  ### Makes list of the vectors; finds length of longest one
  vector_ls  <- list(x,y)
  max_length <- max(sapply(vector_ls, length))
 
  ### Adds zeros to shorter vector in list, making them same length
  vector_ls <- lapply(vector_ls, function(x) c(x, rep(0, max_length-length(x))))

  return(vector_ls[[1]] + vector_ls[[2]])
}


# Question 16 
question_16 <- function()  {
### Plots a bargraph of mean octave class frquencies, representning mean species abundance distribution, from 100 evenly-spaced samples of 2000 post-burn-off period generations of neutral model simulations for a community of 100 individuals. 
#
# Arguments: -
#
# Returns:  character string; statement answering "Does the initial condition of the system matter, and why/why not?"
#
########

  ### Clear all graphics
  graphics.off()

  ### Generate the community of 100 individuals with maximum species richness
  community_max <- init_community_max(100)

  ### Attain state of community after 200-gen burn-in period, and the octave
  for (gen in 1:200){
    community_max <- neutral_generation_speciation(community_max, 0.1)}
  oct_total <- octaves(species_abundance(community_max)); oct_count <- 1

  ### Run rimulation 2000 more times, take a sample every 20 generations, add to total, and ultimately didvide by number of octaves total for the mean
  for (gen in 1:2000){
    community_max <- neutral_generation_speciation(community_max, 0.1)
    if (gen %% 20 == 0){ 
      oct_total <- sum_vect(oct_total,octaves(species_abundance(community_max)))
      oct_count <- oct_count + 1 }}
  mean_oct <- oct_total/oct_count

  ### Creates barplot of the mean species abundance distriubtion, as octaves, for the equilibrium period
  barplot(mean_oct, names.arg=1:length(mean_oct),
      # labels axes and graph as a whole
      xlab="Octave Class", ylab="Mean Octave Class Frequency",
      main="Estimated Mean Species Abundance Distribution as Octaves \n over 2000 Generations",
      # disable numerical axes labels, sets edge of axes to origin, sets limit
      yaxt ="n", yaxs="i", ylim=c(0, 12))
      # adds custom numerical x axis labels and minor ticks
      axis(2, seq(0, 12,  by=1),   las=1,        labels=TRUE)
      axis(2, seq(0, 12,  by=0.2), lwd.ticks=.3, labels=FALSE)

  return("The initial condition of the system does not matter using these parameters; as explained in question 12, 200 generations (the burn-off period used here) is more than enough time for equilibrium to be reached from the two extremes of species richness. Hence, at the start of the subsequent 2000 generation simulation, the expected start-point regardless of initial conditions is expected to be the same, differing only due to random fluctuations owing to the small sample size.")
}



# Question 17
cluster_run <- function(speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, output_file_name)  {
### runs the neutral_generation_speciation function repeatedly, periodically analysing the results, all in accordance with the parameters, saving all results to an argued rda file
#
# Arguments:
#   speciation_rate     - numeric 0-1; determines frequency of speciation
#   size                - +ve integer; determines population size of communies
#   wall_time           - +ve integer; determines how long each simulation runs, in minutes
#   interval_rich       - +ve integer; determines the generation interval at which species richness is taken during burn-in period
#   interval_oct        - +ve integer; determines the geberation interval at which octaves of species abundance are taken throughout simulations 
#   burn_in_generations - +ve integer; number of generations before community expected to be comfortably in equilibrium
#   output_file_name    - char string; name of output rda file
#
# Returns:  -
#
########
    
  ### Generates community of specified size and of minimum diversity 
  community <- init_community_min(size)
 
  ### Starts clock; creates generation count, and empty data structures to fill
  ptm <- proc.time(); nGens <- 1; richness_vect <- NULL; oct_vect <- list()

  ### Simulates generatrions until 60*wall_time seconds have elapsed
  while(proc.time()[3] - ptm[3] < 60*wall_time){
    community <- neutral_generation_speciation(community, speciation_rate)
    # saves species richness at given interval during given burn in period
    if (nGens %% interval_rich == 0 & nGens <= burn_in_generations){
      richness_vect <- c(richness_vect, species_richness(community)) }
    # saves octaves of species_abundance of community at given interval
    if (nGens %% interval_oct == 0){
      oct_vect <- c(oct_vect, list(octaves(species_abundance(community)))) }
    # adds to generation count
    nGens <- nGens + 1 }
  # saves finishing time for input to rda file
  elapsed_time <- proc.time()[3] - ptm[3] 

  ### Saves final versions of objects created in script, and time elapsed,
  save(richness_vect, oct_vect, community, elapsed_time,
  # alongside all original parameters, as a file as named in initial argument
  speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, file=output_file_name)
}



# Question 20 
process_cluster_results <- function(iter_num, popsizes)  {
### Analyses rda files generated from run_cluster.sh, finding the mean octave of species abundancies for each size of community and saving them to a new rda file
#
# Arguments:
#   iter_num - +ve integer; determines number of rda files to be analysed, same as number of iterations run in run_cluster.sh
#   popsizes - vector or integers; gives the popsizes to do this analysis on, assuming each have the same number of iterations
#
# Returns:  list of vectors; one vector of average species abundancy octave classes of all simulations of the same population size for each population size
#
########

  ### Creates empty list and populates it with lists of rda files' objects
  combined_results <- list()
  for (i in 1:iter_num){
    # loads each data file based on iter number
    fname <- paste0("../results/output_files/output_file_", i, ".rda")
    load(file=fname)
    # creates list of objects from data file, adds to list of lists
    obj_list <- list(richness_vect, oct_vect, community, elapsed_time, speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations)
    combined_results[[length(combined_results)+1]] <- obj_list }

  ### Finds number of simulations per size, and creates blank list for ouput
  sims_per_size <- iter_num / length(popsizes)
  mean_oct_ls <- list()
  
  ### Finds information for each set of popsizes
  for (popsize in 0:(length(popsizes)-1)) {
    # corresponding first (by index) simulation for that popsize
    size_start <- popsize * sims_per_size
    # finds burn-in period, oct interval, & hence number of octaves to remove
    burn_in <- combined_results[[size_start + 1]][[10]]
    oct_int <- combined_results[[size_start + 1]][[9]]
    burn_in_octs <- burn_in/oct_int

    ### Creates list for all post-burn in octaves for all simulations of a given population size, and populates it
    multisim_oct_vect <- list()
    for (sim in 1:sims_per_size) {
      # for each simulation...
      iter <- size_start + sim
      # extracts oct_vect and removes octaves taken during burn-in
      oct_vect <- combined_results[[iter]][[2]]
      postBI_oct_vect <- oct_vect[(burn_in_octs+1):length(oct_vect)]
      # appends those left to the master list
      multisim_oct_vect <- c(multisim_oct_vect, postBI_oct_vect) }

    ### Makes all octaves in each master list the same length with 0s
    max_length <- max(sapply(multisim_oct_vect, length))
    multisim_oct_vect <- lapply(multisim_oct_vect, function(x) c(x, rep(0, max_length - length(x))))

    ### Converts list of vectors to dataframe, calculates mean of each column
    oct_df <- as.data.frame(do.call(rbind, multisim_oct_vect))
    mean_oct <- sapply(1:max_length, function(x) mean(oct_df[, x]))

    ### Appends vecotor of means of each popsize to list of all of them
    mean_oct_ls[[length(mean_oct_ls) + 1]] <- mean_oct }

  ### Saves (as .rda) and returns list of lists
  save(mean_oct_ls, file = "mean_oct_ls.rda")
  return(mean_oct_ls)
}




plot_cluster_results <- function()  {
### Plots mean octave classes for each popsize as barcharts, from the results of cluster_run, and saves the underlying data to a new rda file
#
# Arguments: -
#
# Returns:  list of vectors; one vector of average species abundancy octave classes of all simulations of the same population size for each population size
#
########

  ### Clear all graphics; sets num of iterations and popsizes to plot & analyse
  graphics.off()
  iter_num <- 100
  popsizes <- c(500, 1000, 2500, 5000)
  
  ### Extracts mean octraves per population size from results of rda files
  mean_oct_ls <- process_cluster_results(iter_num, popsizes)

  ### Sets structure of multiplot, populates it one barplot at a time (tollerates any number of iters and popsizes)
  par(mfcol = c(ceiling(length(popsizes)/2), 2))
  for (i in 1:length(popsizes)){
    # gets corresponding vector and popsize, builds palette and plot's y axis limit and interval based off of it
    mean_oct <- mean_oct_ls[[i]]
    ymax <- ceiling(max(mean_oct))
    yint <- ceiling(ymax/5)/2
    palette <- rainbow(length(mean_oct))
    nPop <- popsizes[i]
    # calculates and inputs the row and col number for the plot in in multiplot 
    row <- ceiling(i/2); col <- ifelse(i%%2!=0, 1, 2)
    par(mfg = c(row, col))

    ### Plots barplot of means of octave class values
    barplot(mean_oct, names.arg = 1:length(mean_oct),
    # labels axes and graph as a whole
      xlab = "Octave Class", ylab = "Mean Octave Class Frequency",
      main = paste("Mean Species Abundance Distribution as Octaves \n for Communities of", nPop, "individuals"),
    # disable numerical axes labels, sets edge of axes to origin, sets limit
      yaxt = "n", yaxs = "i", ylim = c(0, ymax), col = palette)
    # adds custom numerical x axis labels and minor ticks
    axis(2, seq(0, ymax, by=yint), las = 1,        labels = TRUE)
    axis(2, seq(0, ymax, by=yint/5), lwd.ticks = .3, labels = FALSE) }
  
  ### Returns the data plotted within the function
  return(mean_oct_ls)
}


# Question 21
question_21 <- function()  {
  answer <- list(log(8)/log(3),  "8 units of the constiuent, smaller object are needed to increase the width & height of the larger by 3 times: hence, where the number of dimensions is given by x,  3^x = 8, and  x = log(8)/log(3)")
  return(answer)
}





# Question 22
question_22 <- function()  {
  answer <- list(log(20)/log(3),  "20 units of the constiuent, smaller object are needed to increase the width, height and depth of the larger by 3 times: hence, where the number of dimensions is given by x,  3^x = 20, and  x = log(20)/log(3)")
  return(answer)
}





# Question 23
chaos_game <- function(A=c(0,0), B=c(3,4), C=c(4,1), X=c(0,0), points=NULL, dist=.5, reps=100000, plot=TRUE){
### Generates coordinates to plot a fractal, trianglular shape (or other shapes with non-default arguments), and either plots the shape and returns an explanatory statement (default), or only returns the coords matrix used to plot the shape, depending on "plot" argument
#
# Arguments: 
#   A, B, C  - coordinates vectors; coordinates for the shape to form between
#   X        - coordinates vector; start point for the shape
#   points   - matrix of coordinate vectors; replaces the matrix otherwise made from A, B and C, allowing more than 3 points; coordinates muct be concatenated by row, where ncol(points)==2 and nrow(points)==[number of coordinates sets]
#   dist - +ve numeric; fraction of the distance moved by point in coords to randomly sampled point
#   reps     - +ve integer; number of times the last coordinate in the coords matrix will move halfway towards a randomly chosen point from A, B and C; increases resolution
#   plot     - logical; if TRUE (default), character string is returned and generated shape is plotted; else, coords matrix is returned
#
# Returns:
#   plot=TRUE  - character string; statement describing and explaining the generated shape
#   plot=FALSE - matrix of coordinate vectors; coords matrix generated by the function, length==reps, contains all coordinates needed to plot the shape
#
########

  ### Clear all graphics; sets num of iterations and popsizes to plot & analyse
  graphics.off(); set.seed(2)

  ### Creates matrix of provided points if a suitable matrix isn't provided, & preallocates one to be populated w/ coordinates constituting the shape
  if(is.null(points)){ points <- matrix(c(A, B, C), byrow=TRUE, ncol=2) }
  coords <- matrix(rep(X, reps), byrow=TRUE, ncol=2)

  ### Creates a vector of sampled numbers 1-3, uses it to generate a matrix of randomly chosen coordinates from "points"
  rnums <- sample(nrow(points), reps, replace=TRUE)
  rpoints <- points[rnums,]

  ### Populates coords with coordinates half way between previous coordinates and the corresponding randomly sampled point from "rpoints"
  for (rep in 2:reps){
    coords[rep,] <- (coords[rep-1,] + rpoints[rep-1,])*dist }

  ### If plot is FALSE (TRUE by default), not plot, returns coords matrix
  if (plot == FALSE){ return(coords) 

  ### Else plots the shape generated without axes, returns explanatory statement
 }else{ plot(coords, cex=.001, pch=20, axes=FALSE, ann=FALSE)
  return("This code generates a fractal shape with dimension of log(3)/log(2), equivalent to the shape in Q21 but with triangles rather than squares. The plane it's on appears not to be flat on the screen because the points are not equally spaced. In fact, a 2D equalateral triangle with integer coordinates cannot exist.") }
}


# Question 24
turtle <- function(start_position, direction, length)  {
    
  return() # you should return your endpoint here.
}





# Question 25
elbow <- function(start_position, direction, length)  {
  
}





# Question 26
spiral <- function(start_position, direction, length)  {
  
  return("type your written answer here")
}





# Question 27
draw_spiral <- function()  {
  # clear any existing graphs and plot your graph within the R window
  
}





# Question 28
tree <- function(start_position, direction, length)  {
  
}





draw_tree <- function()  {
  # clear any existing graphs and plot your graph within the R window

}





# Question 29
fern <- function(start_position, direction, length)  {
  
}





draw_fern <- function()  {
  # clear any existing graphs and plot your graph within the R window

}





# Question 30
fern2 <- function(start_position, direction, length)  {
  
}

draw_fern2 <- function()  {
  # clear any existing graphs and plot your graph within the R window

}





# Challenge questions - these are optional, substantially harder, and a maximum of 16% is available for doing them.  


# Challenge question A
Challenge_A <- function() {
### Plots a time-series graph of mean species richness over 'nGens' generations simulated 'nSims' times with the neutral theory model, starting with a community of 'nPop' individuals all of different species (blue) and all the same species (red) and an estimate of generation at which equilibrium is reached
#
# Arguments: -
#
# Returns: - 
#
########

  ### Clear all graphics
  graphics.off()

  ### Set parameters: number of simulations, generations & individuals, and confidence interval to be used in plotting
  nSims <- 500; nGens <- 80; nPop <- 100; CI <- 97.2

  ### Creates matrix of 100 starting populations of each max and min richness
  sims <- matrix(c( rep(1:nPop, nSims), rep(rep(1,nPop), nSims)), nrow=nPop)

  ### Creates vectors of means and SDs of species richness for both communities, and populates them by running each simulation 'nGen' times
  mean_SRs_max <- nPop; sd_SRs_max <- sd(1:nPop)
  mean_SRs_min <- 1;    sd_SRs_min <- 0.1 #should be 0 but avoids warning)
  for (gen in 1:nGens){
    # runs neutral_generation_speciation on each column, replace=TRUE
    sims <- apply(sims, 2, neutral_generation_speciation, speciation_rate=.1)
    # make vector of species richness of each column
    SRs_vect <- sapply(1:ncol(sims), function(x) species_richness(sims[, x]))
    # finds the means and SDs of species richness for the two communities
    mean_SRs_max <- c(mean_SRs_max, mean(SRs_vect[1:nSims]))
    mean_SRs_min <- c(mean_SRs_min, mean(SRs_vect[(nSims+1):(nSims*2)]))
      sd_SRs_max <- c(sd_SRs_max,     sd(SRs_vect[1:nSims]))
      sd_SRs_min <- c(sd_SRs_min,     sd(SRs_vect[(nSims + 1):(nSims * 2)])) }
  
  ### Uses input confidence interval and calculated SDs to find margins of error
  alpha <- 1-CI/100
  marg_err_max <- abs(qnorm(alpha/2)*(sd_SRs_max/sqrt(nPop)))
  marg_err_min <- abs(qnorm(alpha/2)*(sd_SRs_min/sqrt(nPop)))

  ### Finds first generation where margins of error between the two communities overlap; estimate for equilibrium being reached, used by abline in plot
  for (gen in 1:nGens){
    if((mean_SRs_max[gen] - marg_err_max[gen]) - 
       (mean_SRs_min[gen] + marg_err_min[gen]) < 0){ equil_gen <- gen; break; }}
  
  ### Plots those vectors populated against the generations they were taken from
  plot(0:nGens, mean_SRs_max,
      # labels axes and graph as a whole
      xlab="Generations Elapsed", ylab="Mean Species Richness",
      main=paste("Mean Species Richness of",nSims,"Simulations of \n Maximally and Minimally Diverse Communities with a \n Speciation Rate of 0.1 over",nGens,"Generations"),
      # adds line, removes datapoints, sets its colour and width
      col="mediumblue", type="l", lwd=3,
      # disable numerical axes labels, sets edge of axes to origin
      xaxt="n", yaxt="n", xaxs="i", yaxs="i", ylim=c(0,nPop), xlim=c(-.5,nGens))
      # plots min_species_richness against generations_vect, formats line
  lines(0:nGens, mean_SRs_min, col="maroon", lwd=3)
      # adds error bars for each line based on pre-calculated margins of error at the (seemingly arbitrary) 0.028 (or 1-CI/100) significance level
  arrows(0:nGens, mean_SRs_max + marg_err_max,
         0:nGens, mean_SRs_max - marg_err_max, angle=90, code=3, length=0.02)
  arrows(0:nGens, mean_SRs_min + marg_err_min,
         0:nGens, mean_SRs_min - marg_err_min, angle=90, code=3, length=0.02)
      # adds line and explanatory text at estimated point of equilibrium
  abline(v=equil_gen, lwd=2, col="darkgreen", lty="dashed")
  text(equil_gen, nPop/1.3, "Point of Equilibrium", pos=2, offset=0.5, srt=90)
      # adds legend for the lines in topright corner 
  legend("topright", col=c("mediumblue","maroon"), lwd=3, cex=0.8, 
         legend=c("Maximum Initial Richness","Minimum Initial Richness"))
      # adds custom numerical axes labels, and minor axis ticks
  axis(1, seq(0, nGens, by=10), las=1,          labels=TRUE)
  axis(2, seq(0, nPop,  by=10), las=2,          labels=TRUE)
  axis(1, seq(0, nGens, by=2),  lwd.ticks=.3,   labels=FALSE)
  axis(2, seq(0, nPop,  by=2),  lwd.ticks=.3,   labels=FALSE)
}







# Challenge question B
Challenge_B <- function() {
### Plots a time-series graph of mean species richness over 'nGens' generations simulated 'nSims' times with the neutral theory model, starting with 'nSCs' communities of 'nPop' individuals with varying degrees of initial species richness
#
# Arguments: -
#
# Returns: - 
#
########

  ### Clear all graphics
  graphics.off()

  ### Set parameters: number of simulations, generations, starting conditions and individuals/community
  nSims <- 150; nGens <- 50; nSCs <- 11; nPop <- 100 #must be multiple of nSCs-1
  # Calculates species richness gap between starting conditions (except first)
  SR_interval <- nPop/(nSCs-1)

  ### Preallocates matricies to use for simulations, and to store means
  sims <- matrix(0, nrow=nPop, ncol=nSCs*nSims)
  means <- matrix(0, nrow=nGens+1, ncol=nSCs)
  means[1,] <- c(1, seq(SR_interval, nPop, length=nSCs-1))

  ### Populates 1st & last nSims rows w/ communities of min&max species richness
  sims[,c(1:nSims)] <- rep(rep(1, nPop), nSims)
  sims[,((nSCs-1)*nSims+1):(nSCs*nSims)] <- rep(1:nPop, nSims)

  ### Populates middle rows with communities of intermediate species richness
  for (SC in 1:(nSCs-2)){
    for (col in 1:nSims){
      # multiple rounds of non-replacement sampling, until length(indivs)>= nSim
      indivs <- NULL; while (length(indivs) < nPop){
        indivs <- c(indivs, sample(1:(SC * SR_interval), SC * SR_interval)) }
      # input into apropriate column
      sims[,(SC * nSims + col)] <- indivs[1:nPop] } }

  ### Creates dataframe of means of species richness for all communities, and populates them by running each simulation 'nGen' times
  for (gen in 1:nGens){
    # runs neutral_generation_speciation on each column, replace=TRUE
    sims <- apply(sims, 2, neutral_generation_speciation, speciation_rate=.1)
    # make vector of species richness of each column
    SRs_vect <- sapply(1:ncol(sims), function(x) species_richness(sims[, x]))
    # finds the means and SDs of species richness for the two communities
    for (SC in 1:nSCs){
      means[(1+gen), SC] <- mean(SRs_vect[(1+nSims*(SC-1)):(nSims*SC)]) } }


  ### Plots those vectors populated against the generations they were taken from
  # creates palette of colours for the different lines
  palette <- rainbow(nSCs)
  # plots the first line
  plot(0:nGens, means[,1],
      # labels axes and graph as a whole
      xlab="Generations Elapsed", ylab="Mean Species Richness",
      main=paste("Mean Species Richness of",nSims,"Simulations of \n Varyingly Diverse Communities with a \n Speciation Rate of 0.1 over",nGens,"Generations"),
      # adds line, removes datapoints, sets its colour and width
      col=palette[1], type="l", lwd=2,
      # disable numerical axes labels, sets edge of axes to origin
      xaxt="n", yaxt="n", xaxs="i", yaxs="i", ylim=c(0,nPop), xlim=c(-.5,nGens))
      # plots other means columns against generation number, formats line
  for (SC in 2:nSCs){
    lines(0:nGens, means[,SC], col=palette[SC], lwd=2) }
      # adds legend for the lines in topright corner 
  legend("topright", col=palette[1:nSCs], lwd=3, cex=0.8, legend=paste(
         "Starting Richness of", c(1, seq(SR_interval, nPop, length=nSCs-1))))
      # adds custom numerical axes labels, and minor axis ticks
  axis(1, seq(0, nGens, by=5),  las=1,          labels=TRUE)
  axis(2, seq(0, nPop,  by=10), las=2,          labels=TRUE)
  axis(1, seq(0, nGens, by=1),  lwd.ticks=.3,   labels=FALSE)
  axis(2, seq(0, nPop,  by=2),  lwd.ticks=.3,   labels=FALSE)
}





# Challenge question C
Challenge_C <- function() {
### Analyses rda files generated from run_cluster.sh, finding the generation at which equilibrium was reached for each size of community
#
# Arguments: -
#  
# Returns: character string; explanatory statement
#
########

  ### Clear all graphics; sets num of iterations and popsizes to plot & analyse
  graphics.off()
  iter_num <- 100
  popsizes <- c(500, 1000, 2500, 5000)

  ### Creates empty list and populates it with lists of rda files' objects
  combined_results <- list()
  for (i in 1:iter_num){
    # loads each data file based on iter number
    fname <- paste0("../results/output_files/output_file_", i, ".rda")
    load(file=fname)
    # creates list of objects from data file, adds to list of lists
    obj_list <- list(richness_vect, interval_rich, burn_in_generations)
    combined_results[[length(combined_results)+1]] <- obj_list }

  ### Finds number of simulations per size, and creates blank list for ouput
  sims_per_size <- iter_num / length(popsizes)
  mean_SR_ls <- list()
  
  ### Finds information for each set of popsizes
  for (popsize in 0:(length(popsizes)-1)) {
    # corresponding first and last (by index) simulations for that popsize
    start <- sims_per_size *  popsize + 1
    end   <- sims_per_size * (popsize + 1)
    # finds burn-in period and richness interval
    burn_in <- combined_results[[start + 1]][[3]]
    richness_int <- combined_results[[start + 1]][[2]]
    # hence generates the vector of corresponding generation numbers
    gen_vect <- seq(richness_int, burn_in, by=richness_int)
    # creates dataframe of each size's richness_vect, and finds mean of each col
    popsize_SRs <- lapply(combined_results[start:end], `[[`, 1)
    SR_df <- as.data.frame(do.call(rbind, popsize_SRs))
    mean_SR <- sapply(1:ncol(SR_df), function(x) mean(SR_df[, x]))

    ### Appends vectors of species richness means and generations of each popsize to list of all of them for plotting
    mean_SR_ls[[length(mean_SR_ls) + 1]] <- list(log(mean_SR), log(gen_vect+1))}

  ### Plots mean vectors against generation vectors of each popsize
  # creates palette of colours for the different lines
  palette <- rainbow(length(popsizes))
  # finds upper limit of largest popsize's data - will have highest of each
  round_to <- signif(popsizes[length(popsizes)]/100, 1)
  ymax <- ceiling(max(mean_SR_ls[[length(popsizes)]][[1]]))
  xmax <- ceiling(max(mean_SR_ls[[length(popsizes)]][[2]]))
  # finds lower limit of smallest popsize's data - will have lowest of each
  ymin <- floor(min(mean_SR_ls[[1]][[1]]))
  xmin <- ceiling(min(mean_SR_ls[[1]][[2]]))
  # plots the first line
  plot(mean_SR_ls[[1]][[2]], mean_SR_ls[[1]][[1]],
      # labels axes and graph as a whole
      xlab="Log of Generations Elapsed", ylab="Log of Mean Species Richness",
      main=paste("Mean Species Richness of",sims_per_size,"Simulations of \n Varyingly-Sized Communities"),
      # adds line, removes datapoints, sets its colour and width
      col=palette[1], type="l", lwd=2,
      # disable numerical axes labels, sets edge of axes to origin, & sets upper limits assuming the largest popsize has the largest values
      yaxs="i", xaxs="i", ylim=c(ymin,ymax), xlim=c(xmin,xmax), yaxt="n", xaxt="n")
      # plots other means columns against generation number, formats line
  for (i in 2:length(popsizes)) {
    lines(mean_SR_ls[[i]][[2]], mean_SR_ls[[i]][[1]], col=palette[i], lwd=2) }
      # adds legend for the lines in topright corner 
  legend("bottomright", col=palette[1:length(popsizes)], lwd=3, cex=0.8,
         legend=paste("Population Size of", popsizes))
      # adds custom numerical axes labels, and minor axis ticks
  axis(1, seq(xmin, xmax,  by=1),   las=1,        labels=TRUE)
  axis(2, seq(ymin, ymax,  by=1),   las=2,        labels=TRUE)
  axis(1, seq(xmin, xmax,  by=0.2), lwd.ticks=.3, labels=FALSE)
  axis(2, seq(ymin, ymax,  by=0.1), lwd.ticks=.3, labels=FALSE)

  ### Estimates pont at which equilibrium has been reached for each popsize
  for (pop in 1:length(popsizes)){
    for (SR in 101:length(mean_SR_ls[[pop]][[1]])){
      if (mean_SR_ls[[pop]][[1]][SR] < min(mean_SR_ls[[pop]][[1]][(SR-100):(SR-1)])){
        print(paste("estimated generation of equilibrium for community of size", popsizes[pop], "is",  (SR-50)*richness_int))
        break;} } }

  ### Return an explanatory statement
  return(paste("From the curves we can see all communities have equilibrated by aproximately e^7.25, or", signif(exp(7.25), 3), "generations from the start. We can estimate more precisely for each community by finding where the data levels out, eg finding the first datapoint lower than a trailing average of the 50 previous datapoints as above. Hence, 2*popsize is a sufficient burn-in period here; 8*popsize is unnecessarily large, albeit not a big issue."))
}


 

# Challenge question D
Challenge_D <- function() {
  # clear any existing graphs and plot your graph within the R window
  
  return("type your written answer here")
}





# Challenge question E
Challenge_E <- function(){
### Generates and plots a series of fractal shapes based off different parameters of the chaos_game function, and returns an explanatory statement.
#
# Arguments: -
#
# Returns:  character string; statement describing and explaining the generated shapes
#
########

  #not to self!!!!!!!!! add 3 plots at start showing what different startpoints do using colours
  
  graphics.off()

  ### Create and manipulate vectors of coordinates for use
  equi_pts <- c(c(0,0), c(10,0), c(5,5*sqrt(3))) #equilateral triangle
  mid_pt <- c(5, 5 / 3 * sqrt(3)) #equilateral triangle center
  half_mid_pts <- (equi_pts+mid_pt)/2 #halfway between verticies and midpoint
  mid_equi_pts <- (equi_pts+c(equi_pts[5:6], equi_pts[1:4]))/2 #halfway points between verticies

  ### Creates list of vectors using chaos_game() function, for later plotting
  matricies <- list(
    ### Sierpinski Gasket - dist 1/2 only as explained in text
    chaos_game(points=equil, dist=1/2, plot=F),

    ### Like Sierpinski Gasket, but with points half way between each pair of verticies; identical but only when on 1/3 rather than 1/2
    chaos_game(points=matrix(c(mid_equi_pts, equi_pts), byrow=TRUE, ncol=2),
               dist=1/3, plot=F),
    #   As above but with distance of 3/7
    chaos_game(points=matrix(c(mid_equi_pts, equi_pts), byrow=TRUE, ncol=2),
               dist=3/7, plot=F),

    ### Like Sierpinski Gasket but with extra point at center of triangle
    chaos_game(points=matrix(c(equi_pts, mid_pt), byrow=TRUE, ncol=2),
               dist=1/2, plot=F),
    #   As above but with distance of 3/7
    chaos_game(points=matrix(c(equi_pts, mid_pt), byrow=TRUE, ncol=2),
               dist=3/7, plot=F),

    ### Equilateral with points halfway between midpoint and each vertex
    chaos_game(points=matrix(c(half_mid_pts, equi_pts), byrow=TRUE, ncol=2),
               dist=4/11, plot=F),

    ### No equilateral triangle points; only points halfway between midpoint and each vertex AND points half way between each pair of verticies
    chaos_game(points=matrix(c(half_mid_pts, mid_equi_pts), byrow=TRUE, ncol=2),
      X=mid_pt,dist=1/3, plot=F),
    #   As above but with extra point at center
    chaos_game(points=matrix(c(half_mid_pts, mid_equi_pts, mid_pt), byrow=TRUE, ncol=2), X=mid_pt, dist=1/3, plot=F),
    #   As above but with distance of 4/11
    chaos_game(points=matrix(c(half_mid_pts, mid_equi_pts, mid_pt), byrow=TRUE, ncol=2), X=mid_pt, dist=4/11, plot=F))

  ### Sets structure of multiplot, populates it one plot at a time (tollerates any number of plots)
  par(mfcol = c(ceiling(length(matricies) / 3), 3))
  for (i in 1:length(matricies)) {
    # calculates and inputs the row and col number for the plot in in multiplot 
    row <- ceiling(i / 3)
    if(i %% 3 == 0){ col <- 3
   }else{            col <- i %% 3 }
    par(mfg = c(row, col))
    ### Plots matrix, with small black dots and no axes or labels
    plot(matricies[[i]], cex=.001, pch=20, axes=FALSE, ann=FALSE) }

  return("changing X seems to make no difference; leads to a few points outside the sape but they quickly find their way to it.

  Decreasing from 0.5, triangular fractals' small constituent units shrink and move towards the closest vertex; increasing, they start to overlap and converge on eachother.
  ")
}

Challenge_E() #### see note in function



# Challenge question F
Challenge_F <- function() {
  # clear any existing graphs and plot your graph within the R window
  
  return("type your written answer here")
}





# Challenge question G should be written in a separate file that has no dependencies on any functions here.


