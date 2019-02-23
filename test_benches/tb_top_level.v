///////////////////////////////////////////////////////////////////////////////
// ./test_benches/tb_top_level.v : 
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
module tb_top_level;

    reg        clk100;
    wire [7:0] debug;
    wire [1:0] dp_tx_lane_p;
    wire [1:0] dp_tx_lane_n;
    wire [7:0] LED;
    //////////////////////////////////////////
    reg        dp_refclk_p;
    reg        dp_refclk_n;
    reg        mgtrefclk1_p;
    reg        mgtrefclk1_n;
    //////////////////////////////////////////
    wire       dp_tx_hp_detect;
    wire       dp_tx_auxch_tx_p;
    wire       dp_tx_auxch_tx_n;
    wire       dp_tx_auxch_rx_p;
    wire       dp_tx_auxch_rx_n;
    ///////////////////////////////////////////
    reg  [3:0] sw;
    wire       auxch_data;

    reg  [31:0] i, j, k;


    
initial begin
    clk100               = 1'b0;

    dp_refclk_p = 1'b1;
    dp_refclk_n = 1'b0;

    mgtrefclk1_p         = 1'b0;
    mgtrefclk1_n         = 1'b1;

    sw                   = 3'b001;

    i                    = 31'b0;
    j                    = 31'b0;
    k                    = 31'b0;

end

   
always begin
        #5  clk100 = ~clk100; // generate a clock
end 

always begin
        #4  dp_refclk_p = ~dp_refclk_p; dp_refclk_n = ~dp_refclk_n;// generate a clock
end 

assign dp_tx_auxch_rx_p = auxch_data;
assign dp_tx_auxch_rx_n = ~auxch_data;

tb_dummy_sink i_tb_dummy_sink(
    .clk100           (clk100),
    .auxch_data       (auxch_data),
    .hotplug_detect   (dp_tx_hp_detect)
);

top_level_nexys_video i_top_level_nexys_video(
    .clk100           (clk100),
    //////////////////////////////////////////
    .dp_tx_lane_p     (dp_tx_lane_p),
    .dp_tx_lane_n     (dp_tx_lane_n),
    //////////////////////////////////////////
    .dp_refclk_p      (dp_refclk_p),
    .dp_refclk_n      (dp_refclk_n),
    .mgtrefclk1_p     (mgtrefclk1_p),
    .mgtrefclk1_n     (mgtrefclk1_n),
    //////////////////////////////////////////
    .dp_tx_hp_detect  (dp_tx_hp_detect),
    .dp_tx_auxch_tx_p (dp_tx_auxch_tx_p),
    .dp_tx_auxch_tx_n (dp_tx_auxch_tx_n),
    .dp_tx_auxch_rx_p (dp_tx_auxch_rx_p),
    .dp_tx_auxch_rx_n (dp_tx_auxch_rx_n),
    ///////////////////////////////////////////
    .debug            (debug),
    .sw               (sw),
    .LED              (LED)
);

endmodule
