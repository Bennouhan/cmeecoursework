# CMEE 2020 HPC excercises R code main proforma
# you don't HAVE to use this but it will be very helpful.  If you opt to write everything yourself from scratch please ensure you use EXACTLY the same function and parameter names and beware that you may loose marks if it doesn't work properly because of not using the proforma.

name <- "Ben Nouhan"
preferred_name <- "Ben"
email <- "bjn20@ic.ac.uk"
username <- "bennouhan"

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
### Plots a time-series graph of species richness over 100 generations simulated with the neutral theory model, starting with a community of 200 individuals all of different species (no speciation)
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
  if (runif(1) < speciation_rate){ pair[[2]] <- max(community)+1 #quicker to argue preallocated runif dist?#this number may have existed; doesnt matter for species richness but may for other stuff
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
### Plots a time-series graph of species richness over 100 generations simulated with the neutral theory model, starting with a community of 200 individuals all of different species (blue) and all the same species (red), with speciation as a possibility
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
  max_species_richness <- neutral_time_series_speciation(1:100, 0.1, 200)
  min_species_richness <- neutral_time_series_speciation(rep(1,100), 0.1, 200)

  ### Plots max_species_richness against generations_vect
  plot(generations_vect, max_species_richness,
      # labels axes and graph as a whole
      xlab="Generations Elapsed", ylab="Species Richness",
      main="Species Richness of maximally and minimally diverse communities \n with a speciation rate of 0.1 over 200 Generations",
      # adds line, removes datapoints, sets its colour and width
      col="mediumblue", type="l", lwd=3,
      # disable numerical axes labels, sets edge of axes to origin
      xaxt="n", yaxt="n", xaxs="i", yaxs="i", ylim=c(0, 100), xlim=c(-.5, 200))
      # plots min_species_richness against generations_vect, formats line
  lines(generations_vect, min_species_richness, col="maroon", lwd=3)
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
  #table(factor(floor(log2(y)), levels=0:max(floor(log2(y)))))long but no transf
  ### log2()+1 transforms data, rounds each down, finds frequencies of result
  return(tabulate(floor(log2(y)+1)))
}
################# ask about above


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
 
  ### Adds zeros to shorter vector, making them same length
  vector_ls <- lapply(vector_ls, function(x) c(x, rep(0, max_length-length(x))))

  return(vector_ls[[1]] + vector_ls[[2]])
}
#################### said use if statement, ok if not?

# Question 16 
question_16 <- function()  {
### 
#
# Arguments: -
#
# Returns:  character string; statement answering "Does the initial condition of the system matter, and why/why not?"
#
########

  ### Clear all graphics
  graphics.off()

  ### Generate the data; one richness vector with each max and min richness
  generations_vect <- 0:200
  max_species_richness <- neutral_time_series_speciation(1:100, 0.1, 200)
  min_species_richness <- neutral_time_series_speciation(rep(1,100), 0.1, 200)

  
  ### Statement
  return(" ")
}





# Question 17
cluster_run <- function(speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, output_file_name)  {
    
}





# Questions 18 and 19 involve writing code elsewhere to run your simulations on the cluster

# Question 20 
process_cluster_results <- function()  {
  combined_results <- list() #create your list output here to return
  # save results to an .rda file
  
}





plot_cluster_results <- function()  {
    # clear any existing graphs and plot your graph within the R window
    # load combined_results from your rda file
    # plot the graphs
    
    return(combined_results)
}





# Question 21
question_21 <- function()  {
    
  return("type your written answer here")
}





# Question 22
question_22 <- function()  {
    
  return("type your written answer here")
}





# Question 23
chaos_game <- function()  {
  # clear any existing graphs and plot your graph within the R window
  
  return("type your written answer here")
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
  # clear any existing graphs and plot your graph within the R window

}





# Challenge question B
Challenge_B <- function() {
  # clear any existing graphs and plot your graph within the R window

}





# Challenge question C
Challenge_C <- function() {
  # clear any existing graphs and plot your graph within the R window

}





# Challenge question D
Challenge_D <- function() {
  # clear any existing graphs and plot your graph within the R window
  
  return("type your written answer here")
}





# Challenge question E
Challenge_E <- function() {
  # clear any existing graphs and plot your graph within the R window
  
  return("type your written answer here")
}





# Challenge question F
Challenge_F <- function() {
  # clear any existing graphs and plot your graph within the R window
  
  return("type your written answer here")
}





# Challenge question G should be written in a separate file that has no dependencies on any functions here.


