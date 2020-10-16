#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: csvtospace.sh
# Desc: Substitutes commas with spaces; Saves output into a .ssv file in results/
# Arguments: 1 -> csv file (but really any text file with >= 1 commas)
# Date: 14 Oct 2020

### request one argument from user if no. of arguments entered =/= 1
if [ $# -ne 1 ]; then
#if no. arguments =/= 1
  echo "Please enter one argument; a comma-separated values file"
  exit
elif ! [ -s $1 ] || ! [ -f $1 ]; then
#if file does not have content or does not exist
  echo "File is empty or does not exist, please enter a comma-separated values file"
  exit
fi

### inform user if argument is definitely not a csv file
num_tab=$(cat $1 | grep -o "," | wc -l)
#set variable for number of commas in file          
if [ $num_tab -lt 1 ]; then
# if number of commas < 1
  echo "Please enter a comma-separated values file"
  exit
fi

### checks if what will be the resulting file already exists, asks to overwrite
Base=$(echo -e $(basename $1) | cut -d'.' -f1)
#removes extension; returns full name if no "."
#$(basename $1) used, else any dots in path eg ".." in "../dir" will be cut instead
if [ -f ../results/$Base.ssv ]; then
#checks for presence of file which would be overwritten. path added back, after removed for cutting
  echo "File already exists, are you sure you wish to overwrite?"
  read -r -p "Are you sure? [y/N] " response
  if ! [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  #if response is anything but y, Y, yes (etc), abort
    then
      echo "Operation aborted. Please try again with a new file name"
      exit
  fi
fi

### gets file content; swaps 1=< adjacent commas for a space; saves as new file, replacing any extension with .ssv
echo "Creating a space-delimited version of $1 in results/ ..."
cat $1 | tr -s "," " " > "../results/$Base.ssv"
#identifies basename, saves with new extension. Different methos than above, useful to know. 
echo "Done!"
exit