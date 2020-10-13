#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: tabtocsv.sh
# Desc: Sub tabs with commas; Saves output into a .csv file
# Arguments: 1 -> tab delimited file
# Date: 12 Oct 2019

# request argument from user if no. of arguments entered =/= 1
if [ $# -ne 1 ]     # if no. arguments =/= 1
  then
    echo "Please enter one argument"
    exit
fi

# inform user if argument is not a tab-delimited file
num_tab=$(cat $1 | grep -oP "\t" | wc -l)   #set variable for number of tabs in file
num_ext=$(basename $1 | grep -o "\." | wc -l)    #set variable for number of periods in filename
if [ $num_tab -lt 1 ] || [ $num_ext -lt 1 ]    # number of tabs < 1 OR file has no extension (ie periods in filename)
  then
    echo "Please enter a tab-delimited file with an extension"
    exit
fi

#gets file content; swaps tabs for commas; saves as new file, replacing any extension with .csv
echo "Creating a comma delimited version of $1 ..."
cat $1 | tr -s "\t" "," > "${1%.*}.csv"     #identifies basename, saves with new extension
echo "Done!"
exit