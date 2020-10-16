#!/usr/bin/env python3
# Filename: using_name.py

"""Script to demonstrate python programmes being used as such, or as a module"""


if __name__ == '__main__':
    print('This program is being run by itself')
else:
    print('I am being imported from another module')

print("This module's name is: " + __name__)