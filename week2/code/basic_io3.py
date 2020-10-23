
"""Pickle dumps an object for later use"""


my_dictionary = {"a key": 10, "another key": 11}

import pickle

f = open('../results/testp.p','wb') ## note the b: accept binary files
pickle.dump(my_dictionary, f)
f.close()

## Load the data again
f = open('../results/testp.p','rb')
another_dictionary = pickle.load(f)
f.close()

print(another_dictionary)
