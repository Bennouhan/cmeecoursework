birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2) )

#(1) Write three separate list comprehensions that create three different
# lists containing the latin names, common names and mean body masses for
# each species in birds, respectively. 

latinname_ls = [i[0] for i in birds]
print(latinname_ls)

commonname_ls = [i[1] for i in birds]
print(commonname_ls)

bodymass_ls = [i[2] for i in birds]
print(bodymass_ls)

# (2) Now do the same using conventional loops (you can choose to do this 
# before 1 !). 

latinname_ls2 = []
for i in birds:
    latinname_ls2.append(i[0])

print(latinname_ls2)

commonname_ls2 = []
for i in birds:
    commonname_ls2.append(i[1])

print(commonname_ls2)

bodymass_ls2 = []
for i in birds:
    bodymass_ls2.append(i[2])

print(bodymass_ls2)
