///////////////////////////////////////////////////////////////////////////////
// ./test_benches/tb_transceiver.v : 
//
// Author: Mike Field <hamster@snap.net.nz>
//
// Part of the DisplayPort_Verlog project - an open implementation of the 
// DisplayPort protocol for FPGA boards. 
//
// See https://github.com/hamsternz/DisplayPort_Verilog for latest versions.
//
///////////////////////////////////////////////////////////////////////////////
// Version |  Notes
// ----------------------------------------------------------------------------
//   1.0   | Initial Release
//
///////////////////////////////////////////////////////////////////////////////
//
// MIT License
// 
// Copyright (c) 2019 Mike Field
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////
//
// Want to say thanks?
//
// This design has taken many hours - 3 months of work for the initial VHDL
// design, and another month or so to convert it to Verilog for this release.
//
// I'm more than happy to share it if you can make use of it. It is released
// under the MIT license, so you are not under any onus to say thanks, but....
//
// If you what to say thanks for this design either drop me an email, or how about
// trying PayPal to my email (hamster@snap.net.nz)?
//
//  Educational use - Enough for a beer
//  Hobbyist use    - Enough for a pizza
//  Research use    - Enough to take the family out to dinner
//  Commercial use  - A weeks pay for an engineer (I wish!)
//
///////////////////////////////////////////////////////////////////////////////
module tb_transceiver;

    reg clk = 1'b0;


    reg        mgmt_clk;
    reg [1:0]  powerup_channel;

    reg        preemp_0p0;
    reg        preemp_3p5;
    reg        preemp_6p0;
           
    reg        swing_0p4;
    reg        swing_0p6;
    reg        swing_0p8;

    wire [1:0] tx_running;

    reg        refclk0;
    reg        refclk1;

    wire       tx_symbol_clk;
    reg [79:0] tx_symbols;

    wire [7:0]  debug;
           
    wire [1:0] gtptx_p;
    wire [1:0] gtptx_n;

   reg  [15:0] count;
initial begin
    mgmt_clk        = 1'b0;
    powerup_channel = 2'b11;
    preemp_0p0      = 1'b1;
    preemp_3p5      = 1'b0;
    preemp_6p0      = 1'b0;
           
    swing_0p4       = 1'b1;
    swing_0p6       = 1'b0;
    swing_0p8       = 1'b0;

    refclk0         = 1'b0;
    refclk1         = 1'b0;

    tx_symbols = 80'h0000000000000003FCFF;

    count = 16'b0;
       
    forever begin 
        #2
        refclk0  = ~refclk0;
        #2
        refclk0  = ~refclk0;
        mgmt_clk = ~mgmt_clk; // generate a clock
        if(count == 100) begin
            powerup_channel = 2'b00;
        end
        count = count + 1;
    end
end     

transceiver i_transceiver(
    .mgmt_clk        (mgmt_clk),
    .powerup_channel (powerup_channel),

    .preemp_0p0      (preemp_0p0),
    .preemp_3p5      (preemp_3p5),
    .preemp_6p0      (preemp_6p0),
           
    .swing_0p4       (swing_0p4),
    .swing_0p6       (swing_0p6),
    .swing_0p8       (swing_0p8),

    .tx_running      (tx_running),

    .refclk0         (refclk0),
    .refclk1         (refclk1),

    .tx_symbol_clk   (tx_symbol_clk),
    .tx_symbols      (tx_symbols),

    .debug           (debug),
           
    .gtptx_p         (gtptx_p),
    .gtptx_n         (gtptx_n)
);

endmodule
