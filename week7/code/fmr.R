# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: fmr.R
#
# Desc: Plots log(field metabolic rate) against log(body mass) for the Nagy et al 1999 dataset
#
# Arguments:
# -
#
# Output:
# fmr_plot.pdf - PDF file of final plot
#
# Date: 10 Nov 2020

### Read CSV
cat("Reading CSV\n")
nagy <- read.csv('../../week7/data/NagyEtAl1999.csv', stringsAsFactors = FALSE)

### Creates plot and saves as PDF
cat("Creating graph\n")
pdf('../../week7/results/fmr_plot.pdf', 11, 8.5)
col <- c(Aves='purple3', Mammalia='red3', Reptilia='green3')
plot(log10(nagy$M.g), log10(nagy$FMR.kJ.day.1), pch=19, col=col[nagy$Class], 
     xlab=~log[10](M), ylab=~log[10](FMR))
for(class in unique(nagy$Class)){
    model <- lm(log10(FMR.kJ.day.1) ~ log10(M.g), data=nagy[nagy$Class==class,])
    abline(model, col=col[class])
}
dev.off()

cat("Finished in R!\n")