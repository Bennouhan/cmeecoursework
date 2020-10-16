#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: Countlines.sh
# Desc: Returns the number of lines of a file
# Arguments: 1 -> text file
# Date: 13 Oct 2020

### request one argument from user if no. of arguments entered =/= 1
if [ $# -ne 1 ]; then
#if no. arguments =/= 1
  echo "Please enter one file name as an argument for its lines to be counted"
  exit
elif ! [ -s $1 ] || ! [ -f $1 ]; then
#if file does not have content or does not exist
  echo "File is empty or does not exist, please try again"
  exit
fi

NumLines=`wc -l < $1`
echo "The file $1 has $NumLines lines"
echo
#The < redirects the contents of the file to the stdin (standard input) of the command wc -l. It is needed here because without it, you would not be able to catch just the numerical output (number of lines). To see this, try deleting < from the script and see what the output looks like (it will also print the script name, which you do not want).
