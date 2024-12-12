# 467-final-project

## Project Overview
This project involved creating a system that can change the color of an RGB LED by turning poten-
tiometers associated with each RGB color as illustrated in the system diagram below. We also each came up with our
own new costom component that is a unique hardware piece and software piece, which interact with each other. More info about the custom
components can be found below.

![System Overview](/docs/assets/pwm_system_overview.png)

## File Structure
There are 6 important directorys to note in the repository:
- `/docs`     -This dir contains all the picture assets and documentation for this project.

- `/hdl`      -This dir contains all the vhdl scripts for all of our FPGA components. (All simulations will be saved in /sim)

- `/linux`    -This dir contains the device drivers for our components. These drivers allow us to control the devices using sysfs on our VMs.

- `/quartus`  -This dir contains the quartus project we used to assemble and compiled all of the components and IP cores for the project. 

- `/sim`      -This dir contains all of the simulation files that we used to test our components in modelsim/questa before we implamented them in quartus or the fpga.

- `/sw`       -This dir contains the custom software we wrote to controll the FPGA through memory mapped registers. This is what we used to demo our final project because it is a ssimple way to run the project in the end.

## Custom Components
Riley has created a reaction timer that test the speed of a users reaction. 
The component can be found under `/hdl/timer`. Other resources to support the development
of timer can also be found in this repo usually labeled timer.

Jonny has created a binary adder that outputs a binary addtion onto 7 leds on the De10 Nano. 
The component can be found under `/hdl/adder`. Other resources to support the development
of adder can also be found in this repo usually labeled timer.

The given organization of the final project repository is a suggestion.  You are free to change it to meet your needs.  However, you will need to update this readme with a discription of how your final project is organized, what the folders contain, and where your source code is located.
