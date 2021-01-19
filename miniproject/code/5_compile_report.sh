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
# Desc: Compiles 5_report.tex into Ben_Nouhan_Report.pdf, the project's formal
#       form of presentation

### Removes any previous version of compiled report
if [[ -f $../results/Ben_Nouhan_Report.pdf ]]
 then rm $../results/Ben_Nouhan_Report.pdf; fi

### Compiles as PDF, renames as appropriate
pdflatex $1
pdflatex $1
bibtex $1 # will need to get $base; may also need biber not bibtex, see proposal
pdflatex $1
pdflatex $1
mv ${1%.tex}.pdf ../results/Ben_Nouhan_Report.pdf

### Project Cleanup
declare -a ext_ls=("*.aux" "*.dvi" "*.log" "*.nav" "*.out" "*.snm" "*.toc"
                   "*.blg" "*.bbl" "*.fls" "*.fdb_latexmk" "*.gz"
                   "../data/*.png" "../data/*.pdf" "../code/*.pdf")

for ext in ${ext_ls[@]}; do
    if [[ -f $ext ]]; then rm $ext; fi
done