#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: tiff2png.sh
# Desc: Converts all .tif files in working dir, or a dir specified by argument, to a .png in same dir
# Dependencies: imagemagick
# Arguments: 1 -> directory containing .tif file(s), or none (working directory is default)
# Date: 13 Oct 2020

### rejects more than 1 argument
if [ $# -gt 1 ]; then
#if no. arguments =/= 1
  echo "Please enter one argument; a directory containing .tif file(s)"
  exit
fi

### if no argument, sets working directory as argument
if [ $# -eq 0 ]; then
    set -- $1 $PWD/
fi

### searches argued directory for .tif, converts them all
if [ -f $1/*.tif ]; then
#checks for .tif files in directory
    #could make a .png subdirectory here if you wanted to
    for f in $1/*.tif
    do  
        echo "Converting $f" 
        convert "$f"  "$1/$(basename "$f" .tif).jpg"
        #and move these to subdirectory here. may be excessice though
    done
else
    echo "There is no .tif file in this directory"
    #states if no .tif present in argued (or working) directory
    exit
fi
exit