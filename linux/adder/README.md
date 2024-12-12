This folder contains the device driver for the adder component

## Instructions
Make sure you have setup the correct device tree before following these directions. check linux/dts/README.md
### To Run:
1. Move the adder.ko file to your nfs servers /home/soc
2. Use sudo insmod adder.ko to insert
3. From there you should be able to use sysfs to controll the adder amount or use the custom c program in /sw/adder/

## Device tree node

Use the following device tree node:
```devicetree
adder: adder@ff202000 {
    compatible = "adsd,adder";
    reg = <0xff202000 4>;
};
```


## Register map

Starting at memory address 0xff202000

| Offset | Name         | R/W | Purpose                    |
|--------|--------------|-----|----------------------------|
| 0x0    | Amount       | R/W | Amount Binary adder adds by|
