# Software source code

## pwm_adc_miscdev_test

- This software will continously read from ADC registers into software
and convert this values to PMW duty cycles. The result can be used to controll
an RGB Led


## devmem

- This software can be used to read and write to specific memory addresses in the FPGA Memory. 
This allows us to analyze the ADC and PWM duty cycle registers from the putty terminal.
devmem allows us to quickly test the functionallity of a new platform designer device.


## timer_miscdev_test in sw/timer

This miscdev file runs the reaction timer component. To do so, make sure the device is programed. Make sure to have compiled and loaded the .ko file found in the linux directory. Then compile the timer_miscdev_test.c file and run it on the fpga.

The miscdev file writes a 0x01 the the start register to tell the program to start. Then it writes a 0x0 to the start register to turn it off so it doesnt continuesly loop. This happens when the delay is going(when the light is on). As soon as the light turns off, press the button as soon as possible. Once the button is pressed, the program will print out the reaction time in clock cycles.
