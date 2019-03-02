# DisplayPort_Verilog

A open source Verilog implementation of DisplayPort protocol for FPGAs

DisplayPort is quite a complex protocol. This is a minimal Verilog
implementation in the Verilog language. Hopefully this will inspire
others to improve on this.

This has now been tested using one or two lanes, and 800x600 and
720p resolutions. 1080p should be implemented soon.

My own test board is a Digilent Inc Nexys Video, using an Xilinx
Artix 7 FPGA. However the most of the hardware specific parts are
limited to the transcievers which can be replaced to support 
FPGAs from other vendors.
