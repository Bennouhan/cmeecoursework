#!/bin/bash
#
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: 5_compile_report.sh
#
# Date: 12 Nov 2020
#
# Arguments: $1 = 5_report.tex ;  Final draft written in LaTeX
#
# Output: Ben_Nouhan_Report.pdf ;  Final draft of report in PDF format
#
# Desc: Compiles 5_report.tex into Ben_Nouhan_Report.pdf, the project's formal form of presentation


### Removes any previous version of compiled report
if [[ -f ../results/Ben_Nouhan_Report.pdf ]]
 then rm ../results/Ben_Nouhan_Report.pdf; fi


### Removes any previous version of texcount file before recreating it
if [[ -f ${1%.tex}.sum ]]
 then rm ${1%.tex}.sum; fi
texcount -1 $1 | cut -f 1 -d "+" > ${1%.tex}.sum


### Conversion to pdf, renames and moves as appropriate
pdflatex $1
biber ${1%.tex}
pdflatex $1
pdflatex $1
mv ${1%.tex}.pdf ../results/Ben_Nouhan_Report.pdf


### Project Cleanup
declare -a ext_ls=("*.dvi" "*.log" "*.nav" "*.out" "*.snm" "*.toc" "*.bcf" "*.blg" "*.bbl" "*.fls" "*.gz" "*.fdb_latexmk" "*.pdf" "*.run.xml")
# if files with these extensions are present, delete them
for ext in ${ext_ls[@]}; do
    if [[ -f $ext ]]; then rm $ext; fi
done