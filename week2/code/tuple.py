
"""Script to print objects within a tuple of tuples, in two ways"""



birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2) )

# Birds is a tuple of tuples of length three: latin name, common name, mass.
# write a script to print these on a separate line or output block by species 
# Hints: use the "print" command! You can use list comprehensions!

for i in birds:
    print(i)

print("") # or (Not sue which was asked for)

for t in birds:
    for i in t:
        print(i)


#not sure which it asked for
