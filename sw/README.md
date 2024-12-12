# Software source code

## pwm_adc_miscdev_test

- This software will continously read from ADC registers into software
and convert this values to PMW duty cycles. The result output can be used to controll
an RGB LED. The FPGAs GPIO pins 35, 33, and 31 will be hooked up to the output pwm signals 
which should run to the LED and the potentiometers that controll the PWM signal are wired to the DE10 nanos on board ADC (Channels 0, 1, and 2).


## devmem

- This software can be used to read and write to specific memory addresses in the FPGA Memory. 
This allows us to analyze the ADC and PWM duty cycle registers from the putty terminal.
devmem allows us to quickly test the functionallity of a new platform designer device.


## timer_miscdev_test in sw/timer

This miscdev file runs the reaction timer component. To do so, make sure the device is programed. Make sure to have compiled and loaded the .ko file found in the linux directory. Then compile the timer_miscdev_test.c file and run it on the fpga.

The miscdev file writes a 0x01 the the start register to tell the program to start. Then it writes a 0x0 to the start register to turn it off so it doesnt continuesly loop. This happens when the delay is going(when the light is on). As soon as the light turns off, press the button as soon as possible. Once the button is pressed, the program will print out the reaction time in clock cycles.

## adder_miscdev in sw/adder

This miscdev file runs the binary adder component. To do so, make sure the device is programed. Make sure to have compiled and loaded the .ko file found in the linux directory. Then compile the adder_miscdev.c file and run it on the fpga.

By default the adder component will be set to 1, and the add by amount is also set to 1. When we load this script the add by amount chages every 3 seconds. When the amount changes we can see a difference in behavior on the binary counter indicating the scrippt is working. Every time the button is pressed the add by amount will be added to the LEDs and when it gets over 8 bits the counter rolls over.