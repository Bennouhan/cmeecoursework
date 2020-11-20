""" Uses single regex pattern to extract labelled data from .txt file

"""

import re
import pandas as pd

### Import text
with open('../data/blackbirds.txt', 'r') as f:
    text = f.read()

### Replace \t's and \n's with spaces
text = text.replace('\t',' '); text = text.replace('\n',' ')

### Encode and decode to remove non-ascii chars
text = text.encode('ascii', 'ignore').decode('ascii', 'ignore') # Now decode 

### Create list of Kingdom, Phylum and Species tuples for each species
taxa = re.findall(r"Kingdom\s(\w+).+?(?=Phyl)Phylum\s+(\w+).+?(?=Spec)Species\s+\w+\s+(\w+)", text) 
#for each occurence of Kingdom: extract following word; find next occurence of Phylum, extract following word; find next occurrence of Species, extract 2nd following word (1st is genus); create tuple of the 3 words

### Print list of tuples as dataframe with labelled columns
print(pd.DataFrame(taxa, columns=['Kingdom', 'Phylum', 'Species']))