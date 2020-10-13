#!/bin/bash

# Shows the use of variables
MyVar='some string'
echo 'the current value of the variable is:' $MyVar
echo 'Please enter a new string'
while true; do
    read MyVar
    # request input from user if blank
    if [ -z "$MyVar" ]; then
        echo "No string entered. Please enter a new string"
    else
        break
    fi
done
echo 'the current value of the variable is:' $MyVar

## Reading multiple values
echo 'Enter two numbers separated by space(s)'
while true; do
    num='^[0-9]+$'
    read a b
    #
    if [ $a -ne $num ] || [ $b -ne $num ]; then
        echo "Error: please enter two numbers separated by space(s)"#test with no or wrong no entries
    else
        break
    fi
done
echo 'you entered' $a 'and' $b '. Their sum is:'
mysum=`expr $a + $b`
echo $mysum
exit