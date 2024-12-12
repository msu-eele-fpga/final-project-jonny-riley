This folder contains the device driver for the pwm component

## Instructions
Make sure you have setup the correct device tree before following these directions. check linux/dts/README.md

### To Run:
1. Move the pwm.ko file to your nfs servers /home/soc
2. Use ```sudo insmod pwm.ko``` to insert
3. From there you should be able to use sysfs to controll the pwm amount or use the custom c program in /sw/pwm/

## Device tree node

Use the following device tree node:
```devicetree
pwm: pwm@ff200000 {
    compatible = "adsd,pwm";
    reg = <0xff200000 16>;
};
```

## Register map

Starting at memory address 0xff202000

| Offset | Name            | R/W | Purpose                    |
|--------|-----------------|-----|----------------------------|
| 0x0    | Period          | R/W | PWM Period                 |
| 0x4    | Blue Duty cycle | R/W | Blue Duty cycle            |
| 0x8    | Red Duty cycle  | R/W | Red Duty cycle             |
| 0xc    | Green Duty cycle| R/W | Green Duty cycle           |