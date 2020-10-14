#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: tiff2png.sh
# Desc: Converts a .tif file to a .png
# Dependencies: imagemagick
# Arguments: none, converts .tif file in same directory
# Date: 13 Oct 2020

### converts .tif to .jpg
if [ -f *.tif ]; then
#checks for .tif files in directory
    for f in *.tif
    do  
        echo "Converting $f" 
        convert "$f"  "$(basename "$f" .tif).jpg" 
    done
else
    echo "There is no .tif file in this directory"
    exit
fi
exit
