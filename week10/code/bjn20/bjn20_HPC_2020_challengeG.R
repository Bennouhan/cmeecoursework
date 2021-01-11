# CMEE 2020 HPC excercises R code challenge G proforma

rm(list=ls()) # nothing written elsewhere should be needed to make this work

# please edit these data to show your information.
name <- "Ben Nouhan"
preferred_name <- "Ben"
email <- "bjn20@ic.ac.uk"
username <- "bjn20"

#nb, swap c(.5,0) for .2 for a centered but 5 chars longer version
f=function(s,θ,l,d){e=s+l*sin(c(r-θ,θ));lines(rbind(s,e));if(l>1e-3){f(e,θ+d,l*.38,d);f(e,θ,l*.87,-d)}};r=pi/2;frame();f(.2,r,.1,r/2)