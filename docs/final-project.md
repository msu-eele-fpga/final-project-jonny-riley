# Final Project Documentation

## Project Overview
This project involved creating a system capable of changing the color of an RGB LED using potentiometers to adjust each RGB channel. Additionally, each group member implemented a custom hardware and software component, ensuring interaction between the two. This project was implemented on the DE10-Nano FPGA board.

![System Overview](/docs/assets/pwm_system_overview.png)

---

## System Architecture

### Component Descriptions
1. **ADC Controller**: Reads voltage from potentiometers and converts it to digital values.
2. **PWM Controller**: Generates appropriate duty cycles to control LED intensity for R, G, and B channels.
3. **Custom Components**:
   - **Binary Adder** : Displays the binary countput of an up counter that increments on a button press.
   - **Reaction Timer** : Times a users reaction speed to an LED turning off by timing a button push.

---

## Custom Components

### Binary Adder
**Description**: Implements a binary addition operation displayed on the LED array of the DE10-Nano. The adder increment can be configured via software.
- **Hardware File**: `/hdl/adder/adder.vhd`
- **Hardware File**: `/hdl/adder/adder_avalon.vhd`
- **Software File**: `/sw/adder_control.c`

### Reaction Timer
**Description**: Tests user reaction speed by timing button presses in response to LED signals. Outputs results via sysfs.
- **Hardware File**: `/hdl/timer/timer.vhd`
- **Hardware File**: `/hdl/timer/timer_avalon.vhd`
- **Software File**: `/sw/timer_control.c`

---

## Hardware Description
- **Memory Map**:
  - PWM Registers: `period` : 0xff328c50 `blue_duty_cycle` : 0xff328c54 `red_duty_cycle` : 0xff328c58 `green_duty_cycle` : 0xff328c5c  

- Custom Component Registers:
  - Binary Adder:  `amount` : 0xff202000 
  - Reaction Timer: `start` : 0xff202000 `time` : 0xff202004 

---

## Software Description
- **Device Drivers**:
  - PWM Driver: Controls duty cycles via sysfs.
  - Custom Drivers: Binary adder and reaction timer drivers integrate with sysfs for user-space interaction.

- **User Programs**:
  - `pwm_adc_miscdev_test.c`    : Reads potentiometer values and adjusts LED colors.
  - `adder_miscdev.c`           : Configures the binary adder amount to add by.
  - `timer_miscdev_test.c`      : Manages reaction timer to trigger the start condition.
