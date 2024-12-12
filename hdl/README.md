# Folder contains hdl files
Below will be a list of the different hdl subfolders and thier purposes.

## addr (Binary Adder)
Adder is one of the custom harware components we made for the final project. It will incement a binary value on the DE10 nanos LED array. The component is tied to the push button 1 on the FPGA. The adder can be controlled in software to increase the amount the adder counts by. adder by default will count by 1 but can be changed to any 8 bit unsiged number.

## timer (Reaction Timer)
timer is the other custom component we created for the final project. timer takes an inpus signal `start` and when `start` goes high LED 7 of the LED array will turn on. It will stay high for an amount of time. When the light turns off the user must push the button and the amount of clock cycles the users reacion took will be sent to the sysfs registers. From sysfs we can ccontroll this component using a custom c script to trigger and handle the start condition easily for us.

## pwm
pwm is the component responsible for handling the output to the RGB led. This creates the period and duty cycle needed for the LED and this will be instatiated three times to account for each pin on the RGB LED.

## LED_patterns
This directory includes the led_patterns component we used in labs. It honestly does not need to be in here but i think it got copied for example purposes.

## async_conditioner
This component is used to handle the push button imputs from the DE10 nanos on board buttons. This component can take in any unsyncrozied button input and syncronize it to the clock, change the output to a one pulse and debouce it. To accomplish all of these tasks the component uses the three components in /one_pulse /debouncer and /syncronizer.

## one_pulse
This is support for async_conditioner. This component transforms our messy button push into a single clock pusle.

## debouncer
This is support for async_conditioner. This component debounces the input file to ensure there is only one button push every 100 ms or so.

## syncronizer
This is support for async_conditioner. This syncronizes an unsyncrous input to align with the FPGAs clock.
