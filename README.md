# DisplayPort_Verilog

A open Verilog implementation of DisplayPort protocol for FPGAs

DisplayPort is quite a complex protocol. This is a minimal Verilog
implementation in the Verilog Language Hopefully this will inspire
others to improve on this.

This early version support a single lane (2.7Gb/s) and displays a
white 800x600 screen, can scale to support four lanes and 4k 
resolutions.

My own test board is a Digilent Inc Nexys Video, using an Xilinx
Artix 7 FPGA. However the most of the hardware specific parts are
limited to the transcievers which can be replaced to support 
FPGAs from other vendors.
