///////////////////////////////////////////////////////////////////////////////
// ./src/debug/seven_segment_driver.v : 
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
`timescale 1ns / 1ps

module seven_segment_driver(
    input  wire clk,
    input  wire [11:0] value,
    output reg  [7:0] segments,
    output reg  [2:0] segment_enable
    );
    
reg [39:0] counter;
reg [2:0] next_enable;
reg [3:0] to_decode;
    
always @(posedge clk) begin

//                         Top:RT:RB:Bot:LT:LB:mid:DP
   case (to_decode)
     4'b0000: segments <= 8'b00000011; // 0
     4'b0001: segments <= 8'b10011111; // 1
     4'b0010: segments <= 8'b00100101; // 2 
     4'b0011: segments <= 8'b00001101; // 3  
     4'b0100: segments <= 8'b10011001; // 4
     4'b0101: segments <= 8'b01001001; // 5
     4'b0110: segments <= 8'b01000001; // 6
     4'b0111: segments <= 8'b00011111; // 7 
     4'b1000: segments <= 8'b00000001; // 8
     4'b1001: segments <= 8'b00001001; // 9
     4'b1010: segments <= 8'b00010001; // A
     4'b1011: segments <= 8'b11000001; // B
     4'b1100: segments <= 8'b01100011; // C 
     4'b1101: segments <= 8'b10000101; // D
     4'b1110: segments <= 8'b01100001; // E
     default: segments <= 8'b01110001; // F
   endcase;
    
   segment_enable <= next_enable;

   case (counter[19:18]) 
     2'b00:   begin 
                next_enable <= 3'b110;
                to_decode   <= value[3:0];
              end

     2'b01:   begin
                next_enable <= 3'b101;
                to_decode   <= value[7:4];
              end

     2'b10:   begin
                next_enable <= 3'b011;
                to_decode   <= value[11:8];
              end

     default: begin 
                next_enable <= 3'b111;
                to_decode   <= 4'b0000;
              end
   endcase;          

   counter  <= counter + 1;
end

endmodule
