#!/bin/bash
# Author: Ben Nouhan, bjn20@ucl.ac.uk
# Desc: Script that is run to solve the zero issue with tensorflow

for a in /sys/bus/pci/devices/*; do echo 0 | sudo tee -a $a/numa_node; done

#link to line of code: https://stackoverflow.com/questions/44232898/memoryerror-in-tensorflow-and-successful-numa-node-read-from-sysfs-had-negativ
#link to explanation of how to run automatically at startup: https://askubuntu.com/questions/814/how-to-run-scripts-on-start-up
#    (answer by ceejayoz. used nano.)
#    crontab -e
#    then @reboot bash [absolute path to sh script you want to run at reboot, /home/bennouhan/and so on]

###NOTE will give a failed to allocate from device: CUDA_ERROR_OUT_OF_MEMORY: out of memory error if this is malfunctioning; and this fix can malfunctioon
#  EG if file path to this file is changed
#  