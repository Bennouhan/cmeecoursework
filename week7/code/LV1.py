#!/usr/bin/env python3

""" Script to integrate resource and consumer data using a Lotka-Volterra model, and plot the result

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import sys
import scipy as sc
from scipy.integrate import odeint as integrate #not imported by scipy for some reason
import matplotlib.pylab as p


def dCR_dt(pops, t=0):
    """
    Works in conjuction with scipy.integrate to integrate the below formula using every timestep of t and each additional value of R and C to find the growth rate of consumer and resource population at any given time step.

    Parameters:

    pops - a scipy array with R0 and C0 values in a row
    t - a sequence of timesteps, specified in the main function

    Returns:

    sc.array([dRdt, dCdt] - a scipy array with calculated dRdt & dCdt values in a row, all of which for all values of t are later compiled into "pops" by scipy.integrate

    """
    
    ### Set parameters here
    r, a, z, e = 1., 0.1, 1.5, 0.75
    R = pops[0]
    C = pops[1]
    
    ### Calculations; couldn't find way to to preallocate
    dRdt = r * R - a * R * C 
    dCdt = -z * C + e * a * R * C
    return sc.array([dRdt, dCdt])

def main(argv):
    """
    Generates random data using specified parameters, integrates and saves plots as PDFs
    """
    ### Integration
    t = sc.linspace(0, 15, 1000) #from 0 to 15 (units not relevent in this eg), 1000 subdivisions
    R0 = 10
    C0 = 5
    RC0 = sc.array([R0, C0]) #pops input
    pops, infodict = integrate(dCR_dt, RC0, t, full_output=True)

    ### Plotting pop density over time
    f1 = p.figure() #open empty fihure object
    p.plot(t, pops[:,0], 'g-', label='Resource density') # Plot
    p.plot(t, pops[:,1]  , 'b-', label='Consumer density')
    p.grid()
    p.legend(loc='best')
    p.xlabel('Time')
    p.ylabel('Population density')
    p.title('Consumer-Resource population dynamics')
    f1.savefig('../results/LV_model1.pdf')
    
    ### Plotting Comsumer density by resource density
    f2 = p.figure()  # open empty fihure object
    p.plot(pops[:, 0], pops[:, 1], 'r-', label='Resource density')  # Plot
    p.grid()
    p.xlabel('Resource density')
    p.ylabel('Consumer density')
    p.title('Consumer-Resource population dynamics')
    #p.show()# To display the figures
    f2.savefig('../results/LV_model1-1.pdf')
    p.close('all')
    # Save and clear figure - prevents accumalation

    
    
    return None
        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
