#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Script: variables.sh
# Desc: Repeats a user-input string; returns the sum of two user-input numbers
# Arguments: -
# Date: 12 Oct 2020

### Shows the use of variables
MyVar='some string'
echo 'the current value of the variable is:' $MyVar
echo 'Please enter a new string'
while true; do
    read MyVar
    # request input from user if blank
    if [ -z "$MyVar" ]; then
    #checks for blank input
        echo "No string entered. Please enter a new string"
    else
        break
    fi
done
echo 'the current value of the variable is:' $MyVar

### Reading multiple values, handling errors
echo 'Enter two itegers separated by space(s)'
while true; do
    #numb='^[0-9]+$'
    read a b c
    #user inputs variables; including c absorbs any extra inputs without error
    if [[ $((a)) != $a ]] || [[ $((b)) != $b ]]; then
    #checks that both a and b equal themselves arithmetically - ie they're both numbers
        echo "Error: please enter two integers separated by space(s)"
        exit
    else;
        break
    fi
done

mysum=$(echo -e  $a + $b | bc -l)
#adds a and b, even if decimals (decimals will compute but with an error)
echo -e 'You entered' $a 'and' $b ' \nTheir sum is' $mysum
exit