#!/bin/bash
#don't include .tex!!! just write basename

### request one argument from user if no. of arguments entered =/= 1
if [ $# -ne 1 ]; then
#if no. arguments =/= 1
  echo "Please enter one argument; a .tex file to be converted to pdf"
  exit
elif ! [ -s $1 ] || ! [ -f $1 ]; then
#if file does not have content or does not exist
  echo "File is empty or does not exist, please enter a .tex file to be converted to pdf"
  exit
fi

### conversion to pdf
Base=$(echo -e $(basename $1) | cut -d'.' -f1)
#allows argument to be latex file ending .tex or no/different extension
pdflatex $(dirname $1)/$Base.tex
pdflatex $(dirname $1)/$Base.tex
bibtex $(dirname $1)/$Base
pdflatex $(dirname $1)/$Base.tex
pdflatex $(dirname $1)/$Base.tex
evince $Base.pdf &

## Cleanup
rm *~
rm *.aux
rm *.dvi
rm *.log
rm *.nav
rm *.out
rm *.snm
rm *.toc
