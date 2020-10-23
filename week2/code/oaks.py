
"""Scripts to extract and manipulate data from a list of tree taxa"""


## Finds just those taxa that are oak trees from a list of species

taxa = ['Quercus robur','Fraxinus excelsior','Pinus sylvestris',\
'Quercus cerris','Quercus petraea']

def is_an_oak(name):
    """Determines whether an object, made lower-case, begins with 'quercus '
    
    Parameters:
    
    name - genus and species of tree species
    
    
    Returns:
    
    True OR False - depending on whether name starts with 'quercus '
    
    """
    return name.lower().startswith('quercus ')
    
#if when made lowercase it starts with 'quercus ', return True, else False

##Using for loops
oaks_loops = set()
for species in taxa:
    if is_an_oak(species):
        oaks_loops.add(species)
print(oaks_loops)

##Using list comprehensions   
oaks_lc = set([species for species in taxa if is_an_oak(species)])
print(oaks_lc)

##Get names in UPPER CASE using for loops
oaks_loops = set()
for species in taxa:
    if is_an_oak(species):
        oaks_loops.add(species.upper())
print(oaks_loops)

##Get names in UPPER CASE using list comprehensions
oaks_lc = set([species.upper() for species in taxa if is_an_oak(species)])
print(oaks_lc)
