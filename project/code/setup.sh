### Need to get HGDP_1000g_3pop.tar.gz from lab dir
# contains each chromosome and sample map (I think)

### Need to get genetic map from https://github.com/odelaneau/shapeit4/blob/master/maps/genetic_maps.b38.tar.gz

### Need to install all programs found in utilites script
# do manually for shapeit4: https://odelaneau.github.io/shapeit4/#installation
#(needs higher g++ than 4)

# THIS SCRIPT WILL COVER HOW TO GET AND PREP THE DATA, THEN THE HPC RUNS THAT HAVE TO BE DONE. THE PROJECT RUN SCRIPT WILL THEN DO ALL THE ANALYSIS IN ONE GO. 

# Just include in readme maybe? doesnt really need to be a script if I'm not running anything from it
n <- 30
sal <- 28500
pot <- 0
while (n > 0){
    pot <- pot + sal*0.0232
    pot <- pot*1.01
    sal <- sal*1.035
    n <- n-1
}
print(sal)
print(pot)