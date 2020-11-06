
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: plotLin.R
#
# Desc: Script to demonstrate ggthemes, ggplot annotation and linear regression
#
# Arguments:
# -
#
# Output:
# MyLinReg.pdf - ggthemes, ggplot annotation and formatting example plots
#
# Date: 5 Nov 2020

library(ggplot2)
library(ggthemes)


#linear regression and annotation example

x <- seq(0, 100, by = 0.1)
y <- -4. + 0.25 * x +
  rnorm(length(x), mean = 0., sd = 2.5)

# and put them in a dataframe
my_data <- data.frame(x = x, y = y)

# perform a linear regression
my_lm <- summary(lm(y ~ x, data = my_data))

# plot the data
p <-  ggplot(my_data, aes(x = x, y = y,
                          colour = abs(my_lm$residual))
             ) +
  geom_point() +
  scale_colour_gradient(low = "black", high = "red") +
  theme(legend.position = "none") +
  scale_x_continuous(
    expression(alpha^2 * pi / beta * sqrt(Theta)))

# add the regression line
p <- p + geom_abline(
  intercept = my_lm$coefficients[1][1],
  slope = my_lm$coefficients[2][1],
  colour = "red")
# throw some math on the plot
p <- p + geom_text(aes(x = 60, y = 0,
                       label = "sqrt(alpha) * 2* pi"), 
                       parse = TRUE, size = 6, 
                       colour = "blue")



# ggthemes and annotation example


MyDF <- read.csv("../data/EcolArchives-E089-51-D1.csv")
q <- ggplot(MyDF, aes(x = log(Predator.mass), y = log(Prey.mass),
                colour = Type.of.feeding.interaction )) +
                geom_point(size=I(2), shape=I(10)) + theme_bw()

q <- q + geom_rangeframe() + # now fine tune the geom to Tufte's range frame
      theme_tufte() # and theme to Tufte's minimal ink theme    

### Wasn't 100% which was the desired plot, better safe than sorry
pdf("../results/MyLinReg.pdf", 11.7, 8.3)
par(mfcol=c(2,1))
par(mfg = c(1,1))
print(p)
par(mfg = c(2,1))
print(q)
dev.off();