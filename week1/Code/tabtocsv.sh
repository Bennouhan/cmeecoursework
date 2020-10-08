#!/bin/bash
# Author: bjn20@ic.ac.uk
# Script: tabtocsv.sh
# Description: substitute the tabs in the files with commas
#
# Saves the output into a .csv file
# Arguments: 1 -> tab delimited file
# Date: 8 Oct 2019

echo "Creating a comma delimited version of $1 ..."
cat $1 | tr -s "\t" "," >> $1.csv #$1 will allow it to act on the file named after - bash tabtocsv.sh test.txt
echo "Done!" #will translate all tabs, \ts, to 1 comma
exit #will save as a .txt.csv - will fix later on
