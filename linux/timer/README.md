This folder contains the device driver for the timer component

## Instructions
Make sure you have setup the correct device tree before following these directions. check linux/dts/README.md
### To Run:
1. Move the timer.ko file to your nfs servers /home/soc
2. Use sudo insmod timer.ko to insert
3. From there you should be able to use sysfs to controll the timer start and read the clock cycles or use the custom c program in /sw/timer/


## Device tree node

Use the following device tree node:
```devicetree
timer: timmer@ff201000 {
    compatible = "adsd,timer";
    reg = <0xff201000 8>;
};
```


## Register map

Starting at memory address 0xff201000

| Offset | Name         | R/W | Purpose                     |
|--------|--------------|-----|---------------------------- |
| 0x0    | Start        | R/W | Amount Binary adder adds by |
| 0x4    | Timer        | R   | Reactin time in clock cycles|