# DisplayPort_Verilog

A open source Verilog implementation of DisplayPort protocol for
FPGAs, released under the MIT License.

DisplayPort is quite a complex protocol. This is a minimal Verilog
implementation in the Verilog language. Hopefully this will inspire
others to improve on this.

This has now been tested using one or two lanes, and 800x600, 720p, 
1080p and 2160p resolutions, but should work with four lanes too.
YCC and 442 video are supported.

Status
======
Note that this is still very alpha. It works for me on my hardware,
but I don't expect it will work for you with a bit of effort. 

Contributions
=============
Please feel free to send pull requests, and please make sure you add
your name to the file headers. Also feel free to remove my headers 
for any new files you may add to the project - you deserve the 
credit not me!

Please make sure that where possible all files include the MIT 
License information. 

My Test setup
=============
My own test board is a Digilent Inc Nexys Video, using an Xilinx
Artix 7 FPGA. However the most of the hardware specific parts are
limited to the transcievers which can be replaced to support 
FPGAs from other vendors.

For a test display I have been using a ViewSonic VX2880ML, which 
is an older 4k monitor.

I will endevor to test with a few more monitors.

Tested resolutions
==================

    Resolution | Lanes | Colour Mode | Effective Pixel clock rate
    -----------+-------+-------------+--------------
    800x600    |   1   | RGB 444     |  40.00 MHz
    800x600    |   2   | RGB 444     |  40.00 MHz
    800x600    |   3   | RGB 444     |  40.00 MHz
    1280x720   |   1   | RGB 444     |  74.25 MHz
    1920x1080  |   2   | RGB 444     | 148.50 MHz
    3240x2160  |   2   | YCC 422     | 165.00 MHz

There are in the src/test_streams directory. To change patterns, edit
src/test_stream.v, switch the module name, and rebuild the file

These test streams are very crude, and could be greatly improved on.

The M/N problem
===============
DisplayPort have M and N values embedded in the data stream, which 
represent the ratio of the pixel clock to the lane symbol rate. For
example 148.5MHz 1080p has a ratio of 11 to 20 of the 270MHz link
speed. It also should embed the lowest 8 bits of the 'M counter' in
the stream, to allow the sink to regenerate the pixel clock.

However 11:20 (or 22:40, or 2200:4000 or any other exact ratio) does
not work but 0x4688:0x8000 (18,056:32768) does. I do not understand
this. If somebody could explain this to me so I can document this I 
would be most greatful.

I suspect is has something to do with the ability for the source to 
down-spread the link speed, and the sink must be able to correct for 
this.
