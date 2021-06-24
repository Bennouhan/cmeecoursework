run taino_ppx_xxp.py; change subpop sirectory on lines 57-58.

see usage instructions, lines 68-74.

e.g. to run without bootstrap, use below command (must be python 2!!!)
cd ~/cmeecoursework/project/code/tracts_py2/
# python2 taino_ppx_xxp.py [subpop] 1
#so...
cd ~/cmeecoursework/project/code/tracts_py2


python2 taino_ppx_xxp.py ACB 1
python2 taino_ppx_xxp.py ASW 1
python2 taino_ppx_xxp.py CLM 1
python2 taino_ppx_xxp.py MXL 1
python2 taino_ppx_xxp.py PEL 1
python2 taino_ppx_xxp.py PEL_sub_99 1
python2 taino_ppx_xxp.py PUR 1


### Run plotting: see usage, fancyplotting.py lines 41-79
# can add colours, see usage, try for same as in R but with matplotlib

python2 fancyplotting.py --input-dir ../../data/analysis/bed_files/PUR/output --output-dir ../../results/tracts --name boot0_-552.09 --plot-format png --overwrite --population-tags European,Native,African --colors blue,green,red 

# plotting on 100 bootstrap 
python2 taino_ppx_xxp.py PUR

python2 fancyplotting.py --input-dir ../../data/analysis/bed_files/PUR/output --output-dir ../../results/tracts --name boot99_-740.92 --plot-format png --overwrite --population-tags European,Native,African --colors blue,green,red 



# cols we want: #377EB8,#4DAF4A,#E41A1C #test cols: dodgerblue,green,red
# format was FMT but didnt work, placeholder? trying with png, FMT gave error: Format 'fmt' is not supported (supported formats: eps, pdf, pgf, png, ps, raw, rgba, svg, svgz)
# was also throwing error path not defined; changed all path.[function] to os.path.[function], seems to work

# 3 pulse test (NB - only 2 pops, then 1, then 1; cant start w/ 3)

cd ~/cmeecoursework/project/code/tracts_py2

python2 taino_ppxx_xxpp.py ACB 1 #start with 1 for test

python2 fancyplotting.py --input-dir ../../data/analysis/bed_files/ACB/output --output-dir ../../results/tracts --name boot0_-1204.92 --plot-format png --overwrite --population-tags European,Native,African,European --colors blue,green,red,blue



# Running .m script, after saving .nb file as .m
math -script fancyplotting.m #throws lisence expiry error?
wolframscript -file fancyplotting.m #alternative, dosnt throw error?
wolfram -script fancyplotting.m #throws lisence expiry error?

wolfram
math -script fancyplotting.m
WolframScript -script fancyplotting.m
wolframscript -f fancyplotting.m