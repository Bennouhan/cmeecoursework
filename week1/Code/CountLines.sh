#!/bin/bash

NumLines=`wc -l < $1`
echo "The file $1 has $NumLines lines"
echo
#The < redirects the contents of the file to the stdin (standard input) of the command wc -l. It is needed here because without it, you would not be able to catch just the numerical output (number of lines). To see this, try deleting < from the script and see what the output looks like (it will also print the script name, which you do not want).
