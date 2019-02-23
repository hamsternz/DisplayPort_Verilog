///////////////////////////////////////////////////////////////////////////////
// ./test_benches/tb_scrambler_all_channels.v : 
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
module tb_scrambler_all_channels;

    reg clk = 1'b0;

    reg         bypass0;
    reg         bypass1;
    reg  [71:0] in_data;
    wire [71:0] out_data;
    wire [8:0]  data0;
    wire [8:0]  data1;

    localparam [8:0] scrambler_reset = 9'b100011100;
 
    assign data0 = out_data[8:0];
    assign data1 = out_data[17:9];

    //--------------------------------------------------------------------------------
    // Should be verified against the table in Appendix C of the "PCI Express Base 
    // Specification 2.1" which uses the same polynomial.
    //
    // Here are the first 32 output words when data values of "00" are scrambled: 
    //
    // If the Scramble reset code is in the first word:
    //
    // cycle | 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    // ------+------------------------------------------------
    // data0 |[SR]17 14 E7 82 6E A6 6D 8D 40 E6 D3 B2 02 2A 34 E0
    // data1 | FF C0 B2 02 72 28 BE BF BE A7 2C E2 07 77 CD BE ...
    //
    // If the Scramble reset code is in the second word:
    //
    // cycle | 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    // ------+------------------------------------------------
    // data0 | xx FF C0 B2 02 72 28 BE BF BE A7 2C E2 07 77 CD BE ...
    // data1 |[SR]17 14 E7 82 6E A6 6D 8D 40 E6 D3 B2 02 2A 34 E0
    //
    //--------------------------------------------------------------------------------
          
initial begin
    bypass0 = 0;
    bypass1 = 0;
    
    in_data      = 72'b0;
    #4
    clk = ~clk;
    #4
    clk = ~clk;
    #4
    clk = ~clk;
    #4
    clk = ~clk;

    in_data[8:0] = scrambler_reset;
    #4
    clk = ~clk;
    #4
    clk = ~clk;

    in_data      = 72'b0;
    #4
    clk = ~clk;
    #4
    clk = ~clk;
    
        
    forever #4 clk = ~clk; // generate a clock
end

scrambler_all_channels  i_scrambler_all_channels(
    .clk      (clk),
    .bypass0  (bypass0),
    .bypass1  (bypass1),
    .in_data  (in_data),
    .out_data (out_data)
);

endmodule