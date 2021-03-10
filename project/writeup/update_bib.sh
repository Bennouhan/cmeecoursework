#!/bin/bash
#
# Author: Ben Nouhan, bjn20@ucl.ac.uk
#
# Script: 5_compile_report.sh
#
# Date: 12 Nov 2020
#
# Arguments: 
#
# Output: 
#
# Desc: Updates .bib file to newest version, in case it has been edited via mendeley


### Removes any previous version of compiled report
if [[ -f ../../../bibtex/imperial-Project.bib ]]
 then cp ../../../bibtex/imperial-Project.bib .; fi
