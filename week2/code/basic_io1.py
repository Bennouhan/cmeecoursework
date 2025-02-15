
"""Opens a file for subsequent reading"""


f = open('../data/test.txt', 'r')
# use "implicit" for loop:
# if the object is a file, python will cycle over lines
for line in f:
    print(line)

# close the file
f.close()

# Same example, skip blank lines
f = open('../data/test.txt', 'r')
for line in f:
    if len(line.strip()) > 0:
        print(line)

f.close()
