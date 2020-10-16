
"""Collection of scripts demonstrating variable scope"""


print("\n\n" + "_a_global can be overwritten in a function, but is not changed in the workspace:\n")

_a_global = 10  # a global variable

if _a_global >= 5:
    _b_global = _a_global + 5  # also a global variable


def a_function():
    """Sets global and a local variables, uses a conditional to alter their value, prtints out their current values"""
    _a_global = 5  # a local variable

    if _a_global >= 5:
        _b_global = _a_global + 5  # also a local variable

    _a_local = 4

    print("Inside the function, the value of _a_global is ", _a_global)
    print("Inside the function, the value of _b_global is ", _b_global)
    print("Inside the function, the value of _a_local is ", _a_local)

    return None


a_function()

print("Outside the function, the value of _a_global is ", _a_global)
print("Outside the function, the value of _b_global is ", _b_global)

##########################################################

print("\n\n" + "But global variables, if set prior, are available in subsequent functions:\n")

_a_global = 10

def a_function():
    """Sets local variable, prtints out local and inherited global values"""
    _a_local = 4

    print("Inside the function, the value _a_local is ", _a_local)
    print("Inside the function, the value of _a_global is ", _a_global)

    return None

a_function()

print("Outside the function, the value of _a_global is", _a_global)

############################################################

print("\n\n" + "The global keyword, ie 'global _a_global', allows the global variable to be reassigned within a function:\n")

_a_global = 10

print("Outside the function, the value of _a_global is", _a_global)


def a_function():
    """Sets global and a local variables within, in a way that changes the global (but not local) variable in the workspace too, prtints out their current values"""
    global _a_global
    _a_global = 5
    _a_local = 4

    print("Inside the function, the value of _a_global is ", _a_global)
    print("Inside the function, the value _a_local is ", _a_local)

    return None


a_function()

print("Outside the function, the value of _a_global now is", _a_global)

##############################################################

print("\n\n" + "If used within nested functions, where the variable was initially set within the outer function, global reassigns the variable in workspace, but not the outer function or therefore the nested function:\n")

def a_function():
    """Sets global variable within, defines a nested function (which reassigns global variable in the workspace but not the function), prints global variable, calls the nested function, and prints the value again"""
    _a_global = 10

    def _a_function2():
        """reassigns global variable in the workspace but not the function"""
        global _a_global
        _a_global = 20

    print("Before calling a_function, value of _a_global is ", _a_global)

    _a_function2()

    print("After calling _a_function2, value of _a_global is ", _a_global)

    return None


a_function()

print("The value of a_global in main workspace / namespace is ", _a_global)

##############################################################

print("\n\n" + "Whereas if set prior, the outer function has the same variable value as the workspace, hence both are changed if global is used in the nested function:\n")

_a_global = 10


def a_function():
    """Inherits global variable value, defines a nested function (which reassigns global variable in the workspace), prints global variable, calls the nested function, and prints the value again"""
    def _a_function2():
        """reassigns global variable in the workspace and the function, since the function inherits the value from the workspace"""
        global _a_global
        _a_global = 20

    print("Before calling a_function, value of _a_global is ", _a_global)

    _a_function2()

    print("After calling _a_function2, value of _a_global is ", _a_global)


a_function()

print("The value of a_global in main workspace / namespace is ", _a_global)
