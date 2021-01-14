#!/usr/bin/env python3

""" Script to integrate resource and consumer data using a prey density dependent Lotka-Volterra model, and plot the result

"""

__author__ = 'Ben Nouhan'
__version__ = '0.0.1'

import sys
import scipy as sc
from scipy.integrate import odeint as integrate
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
    R = pops[0]
    C = pops[1]
    K = 80  # about double highest R value
    if len(sys.argv) == 5:
        r, a = float(sys.argv[1]), float(sys.argv[2])
        z, e = float(sys.argv[3]), float(sys.argv[4])
    else:
        r, a, z, e = 1., 0.1, 1.5, 0.75  
    
    ### Caclulate dx/dt
    dRdt = r * R * (1 - R/K) - a * R * C
    dCdt = -z * C + e * a * R * C
    return sc.array([dRdt, dCdt])

def main(argv):
    """
    Generates random data using specified parameters, integrates and saves plots as PDFs
    """
    
    
    ### Integration
    t = sc.linspace(0, 50, 1000)
    R0 = 10
    C0 = 5
    RC0 = sc.array([R0, C0]) #pops input
    pops, infodict = integrate(dCR_dt, RC0, t, full_output=True)
    
    ### Plotting pop density over time
    f1 = p.figure()
    p.plot(t, pops[:,0], 'g-', label='Resource density')
    p.plot(t, pops[:,1]  , 'b-', label='Consumer density')
    p.grid()
    p.legend(loc='best')
    p.xlabel('Time')
    p.ylabel('Population density')
    p.title('Consumer-Resource population dynamics')
    if len(sys.argv) == 5:
        p.text(5/9*max(t), 6/7*max(pops[:,0:1]), "r="+sys.argv[1]+", a="+sys.argv[2]+", z="+sys.argv[3]+", e="+sys.argv[4])
    else:
        p.text(5/9*max(t), 6/7*max(pops[:,0:1]), "r=1.0, a=0.1, z=1.5, e=0.75")
    f1.savefig('../results/LV_model2.pdf')
    print("Final predator and prey populations are", round(pops[len(t)-1,1],2), "and", round(pops[len(t)-1,0],2), "respectively.")
    
    ### plotting Comsumer density by resource density
    f2 = p.figure()
    p.plot(pops[:, 0], pops[:, 1], 'r-', label='Resource density')  # Plot
    p.grid()
    p.xlabel('Resource density')
    p.ylabel('Consumer density')
    p.title('Consumer-Resource population dynamics')
    #p.show()# To display the figure
    f2.savefig('../results/LV_model2-1.pdf')
    p.close('all')
    
    return None
        
if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
