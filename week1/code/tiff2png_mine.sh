#!/bin/bash

for $f;  #doesnt differentiate between different file types - at some point work out how to be selevtive of .tif files
    do  
        echo "Converting $f"; 
        convert "$f"  "$(basename "$f" .tif).jpg"; 
    done
#This assumes you have done apt install imagemagick (remember sudo!)
#f means file, $f is pleaceholder for the file being acted upon.
