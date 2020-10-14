# What does each of foo_x do? 
def foo_1(x):
    return x ** 0.5
#squareroot of input
def foo_2(x, y):
    if x > y:
        return x
    return y
#returns biggest input
def foo_3(x, y, z):
    if x > y:
        tmp = y
        y = x
        x = tmp
    if y > z:
        tmp = z
        z = y
        y = tmp
    return [x, y, z]
#orders input by size
def foo_4(x):
    result = 1
    for i in range(1, x + 1):
        result = result * i
    return result
#x!
def foo_5(x): # a recursive function that calculates the factorial of x
    if x == 1:
        return 1
    return x * foo_5(x - 1)
#basically works up from one, multiplying each time, but in reverse - trippy
 
def foo_6(x): # Calculate the factorial of x in a different way
    facto = 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return facto
#a third x! - easier to get my head around through