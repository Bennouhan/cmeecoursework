#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: tabtocsv.sh
# Desc: Sub tabs with commas; Saves output into a .csv file
# Arguments: 1 -> tab delimited file
# Date: 12 Oct 2020

### request one argument from user if no. of arguments entered =/= 1
if [ $# -ne 1 ]; then
#if no. arguments =/= 1
  echo "Please enter one argument; a tab-delimited file"
  exit
elif ! [ -s $1 ] || ! [ -f $1 ]; then
#if file does not have content or does not exist
  echo "File is empty or does not exist, please enter a tab-delimited file"
  exit
fi

### inform user if argument is not a tab-delimited file
num_tab=$(cat $1 | grep -oP "\t" | wc -l)
#set variable for number of tabs in file           #ignore#  num_ext=$(basename $1 | grep -o "\." | wc -l) (set variable for number of periods in filename) ###
if [ $num_tab -lt 1 ]; then
# if number of tabs < 1
  echo "Please enter a tab-delimited file"
  exit
fi

### checks if what will be the resulting file already exists, asks to overwrite
Base=`echo "$1" | cut -d'.' -f1`
#removes extension; returns full name if no "."
if [ -f "$Base.csv" ]; then
#checks for presence of file which would be overwritten
  echo "File already exists, are you sure you wish to overwrite?"
  read -r -p "Are you sure? [y/N] " response
  if ! [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  #if response is anything but y, Y, yes (etc), abort
    then
      echo "Operation aborted. Please try again with a new file name"
      exit
  fi
fi

### gets file content; swaps tabs for commas; saves as new file, replacing any extension with .csv
echo "Creating a comma delimited version of $1 ..."
cat $1 | tr -s "\t" "," > "${1%.*}.csv"
#identifies basename, saves with new extension.     #ignore#  using this is alternative: cut -f 1 -d "."
echo "Done!"
exit
