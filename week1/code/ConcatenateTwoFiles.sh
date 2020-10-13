#!/bin/bash

cat $1 > $3
cat $2 >> $3
echo "Merged File is"
cat $3 #copes 1 into a new file, 3, then appends 2 onto 3. pretty cool
