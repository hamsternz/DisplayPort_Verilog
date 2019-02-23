///////////////////////////////////////////////////////////////////////////////
// ./test_benches/tb_insert_training_pattern.v : 
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
module tb_insert_training_pattern;

    reg         clk         = 1'b1;
    reg         clock_train = 1'b0;
    reg         align_train = 1'b0;
    reg  [71:0] in_data;
    wire [79:0] out_data;
    reg  [11:0] count;

initial begin
    count       = 12'b0;
    clock_train = 1'b1;  
    align_train = 1'b0;  
    in_data = 72'hFFFFFFFFFFFFFFFFFF;
    #4
    clk = ~clk;
    #4
    clk = ~clk;
    #4
    clk = ~clk;
    #4
    clk = ~clk;
   
    forever begin
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        #1
        if(count == 100) begin clock_train = 1'b0; align_train = 1'b1; end
        if(count == 200) begin clock_train = 1'b0; align_train = 1'b0; end
        #3
        clk = ~clk;
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        #4
        clk = ~clk;
        count = count + 1;
    end
end

insert_training_pattern i_insert_training_pattern(
    .clk         (clk),
    .clock_train (clock_train),
    .align_train (align_train),
    .in_data     (in_data),
    .out_data    (out_data)
);

endmodule
