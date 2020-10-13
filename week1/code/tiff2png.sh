#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: tiff2png.sh
# Desc: Converts a .tif file to a .png
# Dependencies: imagemagick
# Arguments: 1 -> directory containing .tif files to be converted
# Date: 13 Oct 2020

for f in *.tif
do  
    echo "Converting $f" 
    convert "$f"  "$(basename "$f" .tif).jpg" 
done
