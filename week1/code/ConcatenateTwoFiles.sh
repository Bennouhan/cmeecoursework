#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: ConcatenateTwoFiles.sh
# Desc: Creates new file, with the content of second file appended to content of first
# Arguments: 1 -> text file, 2 -> text file, 3 -> new text file
# Date: 12 Oct 2020

### request one argument from user if no. of arguments entered =/= 1
if [ $# -ne 3 ]; then
#if no. arguments =/= 3
    echo "Please enter three arguments: two text files to concatenate, then one new destination file"
    exit
elif ! [ -s $1 ] || ! [ -f $1 ] || ! [ -s $2 ] || ! [ -f $2 ]; then
#if files 1 or 2 do not have content or does not exist
    echo "File 1 &/or 2 are empty or do not exist, please try again"
    exit
elif [ -f $3 ]; then
#if file 3 already exists, ask before overwriting
    echo "File already exists, are you sure you wish to overwrite?"
    read -r -p "Are you sure? [y/N] " response
    if ! [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    #if response is anything but y, Y, yes (etc), abort
    then
        echo "Operation aborted. Please try again with a new file name"
        exit
    fi
fi

### concatenates the files
cat $1 > $3
#creates new file, 3, with same content as 1
cat $2 >> $3
#appends content of 2
echo -e "Merged File is:\n\n\n"
cat $3
#returns content of new file
