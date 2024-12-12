This folder contains the device driver for the timer component

## Instructions
Make sure you have setup the correct device tree before following these directions. check linux/dts/README.md
### To Run:
1. Move the timer.ko file to your nfs servers /home/soc
2. Use sudo insmod timer.ko to insert
3. From there you should be able to use sysfs to controll the timer start and read the clock cycles or use the custom c program in /sw/timer/